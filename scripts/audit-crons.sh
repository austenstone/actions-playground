#!/usr/bin/env bash
#
# audit-crons.sh — find orphaned / silently-dead scheduled GitHub Actions workflows.
#
# Why this exists:
#   A scheduled (cron) workflow runs as the user who last edited its file. When
#   that user is deprovisioned — routine in EMU after offboarding — GitHub
#   silently stops creating runs. The workflow still reports state=active, so
#   every native "disabled workflows" filter misses it. There is no built-in
#   report for this. This script reconstructs the audit from the REST API.
#
# Signal we surface per scheduled workflow:
#   - last_sched_run : created_at of the most recent event=schedule run (or NEVER)
#   - days_since     : age of that run (inf when NEVER)
#   - last_editor    : login of whoever last committed the file (the scheduling
#                      actor). Cross-reference against your suspended/removed
#                      members — a dead editor + DEAD/STALE run = orphaned cron.
#
# Flags:
#   DEAD  = no event=schedule run on record (NEVER). Conclusive for sub-~90-day
#           cadences since the runs API only retains ~90 days. A brand-new cron
#           also shows NEVER until its first fire, so weigh against repo age.
#   STALE = last schedule run older than --stale-days.
#   ok    = ran within --stale-days.
#
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
audit-crons.sh — find orphaned / silently-dead scheduled GitHub Actions workflows

Usage:
  audit-crons.sh <org>                  sweep every repo in an org
  audit-crons.sh <owner>/<repo>         audit a single repo

Options:
  --stale-days N    flag schedule runs older than N days (default 2)
  --active-days N   only repos pushed within N days (default 0 = all)
  -h, --help        show this help

Output: CSV to stdout
  repo,workflow,state,cron,last_sched_run,days_since,last_editor,flag

Requires: gh (authenticated), jq
EOF
  exit 2
}

[ $# -ge 1 ] || usage
TARGET="$1"
shift
STALE_DAYS=2
ACTIVE_DAYS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --stale-days) STALE_DAYS="$2"; shift 2 ;;
    --active-days) ACTIVE_DAYS="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
done

days_since() { # ISO8601 -> integer days; "inf" for NEVER
  local t="$1"
  [ "$t" = "NEVER" ] && { echo "inf"; return; }
  jq -rn --arg t "$t" '((now - ($t | fromdateiso8601)) / 86400) | floor'
}

list_repos() { # emit: full_name<TAB>pushed_at
  if [[ "$TARGET" == */* ]]; then
    printf '%s\t%s\n' "$TARGET" ""
  else
    gh api --paginate "/orgs/${TARGET}/repos?per_page=100&sort=pushed" \
      --jq '.[] | [.full_name, (.pushed_at // "")] | @tsv'
  fi
}

audit_repo() {
  local repo="$1"
  local id path content cron last days editor flag
  while IFS=$'\t' read -r id path; do
    [ -n "${id}" ] || continue
    content=$(gh api -H "Accept: application/vnd.github.raw" \
      "/repos/${repo}/contents/${path}" 2>/dev/null) || continue
    grep -qiE '^[[:space:]]*schedule:' <<<"${content}" || continue
    cron=$(grep -iE 'cron:' <<<"${content}" | head -1 \
      | sed -E "s/.*cron:[[:space:]]*//; s/^'([^']*)'.*/\1/; s/^\"([^\"]*)\".*/\1/; s/[[:space:]]+#.*$//; s/[[:space:]]+$//")
    last=$(gh api "/repos/${repo}/actions/workflows/${id}/runs?event=schedule&per_page=1" \
      --jq '.workflow_runs[0].created_at // "NEVER"' 2>/dev/null || echo "NEVER")
    editor=$(gh api "/repos/${repo}/commits?path=${path}&per_page=1" \
      --jq '.[0].author.login // .[0].commit.author.name // "unknown"' 2>/dev/null || echo "unknown")
    days=$(days_since "${last}")
    if [ "${days}" = "inf" ]; then
      flag="DEAD"
    elif [ "${days}" -gt "${STALE_DAYS}" ]; then
      flag="STALE"
    else
      flag="ok"
    fi
    printf '%s,%s,active,"%s",%s,%s,%s,%s\n' \
      "${repo}" "${path}" "${cron}" "${last}" "${days}" "${editor}" "${flag}"
  done < <(gh api "/repos/${repo}/actions/workflows?per_page=100" \
    --jq '.workflows[] | select(.state=="active") | [.id, .path] | @tsv' 2>/dev/null || true)
}

echo "repo,workflow,state,cron,last_sched_run,days_since,last_editor,flag"
while IFS=$'\t' read -r repo pushed; do
  [ -n "${repo}" ] || continue
  if [ "${ACTIVE_DAYS}" -gt 0 ] && [ -n "${pushed}" ]; then
    pd=$(days_since "${pushed}")
    if [ "${pd}" != "inf" ] && [ "${pd}" -gt "${ACTIVE_DAYS}" ]; then
      continue
    fi
  fi
  audit_repo "${repo}"
done < <(list_repos)
