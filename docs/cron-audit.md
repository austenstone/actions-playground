# Orphaned Cron Audit

Working example for auditing **orphaned / silently-dead scheduled GitHub Actions workflows**.

## The problem

A scheduled (`on: schedule`) workflow runs **as the user who last edited its file**. When that user is deprovisioned — routine in EMU after offboarding — GitHub silently stops creating runs. The workflow still reports `state: active`, so every native "disabled workflows" filter misses it. There is **no built-in report** for this.

Real case: an enterprise had **132 scheduled workflows across 48 repos** that hadn't fired in up to 1.5 years, every one bound to a removed user. Nobody noticed until a downstream job went missing.

## The audit

[`audit-crons.sh`](../scripts/audit-crons.sh) reconstructs the missing report from the REST API. Per active scheduled workflow it reports:

| column | meaning |
| --- | --- |
| `cron` | the schedule expression |
| `last_sched_run` | `created_at` of the most recent `event=schedule` run, or `NEVER` |
| `days_since` | age of that run (`inf` when `NEVER`) |
| `last_editor` | login of whoever last committed the file = the scheduling actor |
| `flag` | `DEAD` (never ran), `STALE` (older than `--stale-days`), or `ok` |

**Orphaned cron = `DEAD`/`STALE` flag + a `last_editor` who is a suspended/removed member.** Cross-reference the `last_editor` column against your org's member list to confirm.

## Usage

```bash
# single repo
./scripts/audit-crons.sh austenstone/actions-playground

# whole org
./scripts/audit-crons.sh my-org

# only repos pushed in the last 90 days, flag runs older than 1 day
./scripts/audit-crons.sh my-org --active-days 90 --stale-days 1
```

Requires `gh` (authenticated) and `jq`.

## Caveats

- The runs API retains only **~90 days**, so `NEVER` is conclusive for daily/weekly crons but a brand-new cron also shows `NEVER` until its first fire — weigh against repo age.
- API-heavy. Scope big orgs with `--active-days`. Watch your rate limit (`gh api /rate_limit`).
- `last_editor` is the file's last committer, which is the scheduling actor in the common case. A history rewrite or bot commit can mask the true actor.

## The fix

Have an **active** user (ideally a service/bot account) make a trivial commit to the workflow file on the default branch. That re-binds the schedule to a live actor. Using a non-human account future-proofs it against offboarding.
