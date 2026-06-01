#!/usr/bin/env bash
# Emit actions/cache telemetry to Datadog. Runs as the post-cache step.
# Failures are non-fatal: telemetry must never break a build.
set -uo pipefail

DURATION_MS=$(( $(date +%s%3N) - START_TS ))
HIT=$([[ "${CACHE_HIT:-}" == "true" ]] && echo 1 || echo 0)
KEY_PREFIX=$(echo "${CACHE_KEY}" | cut -d- -f1-3)
SITE="${DD_SITE:-datadoghq.com}"

TAGS=(
  "repo:${GITHUB_REPOSITORY}"
  "workflow:${GITHUB_WORKFLOW}"
  "job:${GITHUB_JOB}"
  "runner_os:${RUNNER_OS}"
  "cache_key_prefix:${KEY_PREFIX}"
  "hit:$([[ $HIT == 1 ]] && echo true || echo false)"
)

{
  echo "### 📊 Cache telemetry"
  echo "| Hit | Key prefix | Duration |"
  echo "|---|---|---|"
  echo "| \`${CACHE_HIT:-false}\` | \`${KEY_PREFIX}\` | ${DURATION_MS} ms |"
} >> "${GITHUB_STEP_SUMMARY}"

if [[ -z "${DD_API_KEY:-}" ]]; then
  echo "::notice::DD_API_KEY unset — telemetry skipped (summary only)"
  exit 0
fi

TS=$(date +%s)
TAGS_JSON=$(printf '%s\n' "${TAGS[@]}" | jq -R . | jq -cs .)

PAYLOAD=$(jq -cn \
  --argjson ts "$TS" --argjson hit "$HIT" --argjson ms "$DURATION_MS" --argjson tags "$TAGS_JSON" '
  { series: [
    { metric: "actions.cache.hit",                  type: 1, points: [{ timestamp: $ts, value: $hit }], tags: $tags },
    { metric: "actions.cache.lookup",               type: 1, points: [{ timestamp: $ts, value: 1 }],    tags: $tags },
    { metric: "actions.cache.restore_duration_ms",  type: 3, points: [{ timestamp: $ts, value: $ms }],  tags: $tags }
  ] }')

CODE=$(curl -sS -o /tmp/dd.json -w "%{http_code}" \
  -X POST "https://api.${SITE}/api/v2/series" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  --data-binary "$PAYLOAD")

if [[ "$CODE" == "202" ]]; then
  echo "::notice::cache telemetry → datadog (hit=${CACHE_HIT:-false}, ${DURATION_MS}ms)"
else
  echo "::warning::datadog submit failed: HTTP ${CODE}"
  cat /tmp/dd.json 2>/dev/null || true
fi
exit 0
