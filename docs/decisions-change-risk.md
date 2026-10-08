# Decisions PR risk router demo

This manual [GitHub Actions workflow](../.github/workflows/decisions-change-risk.yml) uses OpenAI's public-beta [Decisions API](https://developers.openai.com/api/docs/guides/decisions) to classify a pull request diff and demonstrate additive CI routing.

It is intentionally **shadow mode**. The output can suggest extra tests or reviews, but it does not deploy anything or suppress required checks.

## What it does

1. A trusted user manually enters a pull request number on the repository's default branch.
2. The workflow checks out only the [classifier script](../.github/scripts/decisions-change-risk/decisions_change_risk.py) from that trusted commit.
3. The script reads changed-file metadata and patches with the read-only `github.token`.
4. It resolves the staff Copilot API origin from `GET https://api.github.com/copilot_internal/user`.
5. It calls `<origin>/v1/decisions` with the preview model `gpt-6-luna-decisions`.
6. Short conditional steps show which additional CI paths would run.

The staff endpoint can return the canonical model name `gpt-6-luna`; the parser accepts only that name or the requested preview alias.

## Predicates and thresholds

| Predicate | Threshold | Demo route |
|---|---:|---|
| `security_sensitive` | 0.65 | Add security tooling or human review |
| `needs_full_test_suite` | 0.55 | Choose full rather than lightweight validation |
| `needs_manual_deploy_approval` | 0.60 | Add human deploy review |
| `docs_only` | 0.80 | Report an informational signal only |

Predicates keep the routing questions independent and avoid relying on choice ordering during the beta. These thresholds are experiment defaults. Teams should calibrate them on labeled historical pull requests before allowing negative decisions to suppress any work.

## Trust and data boundaries

The workflow is `workflow_dispatch` only and its single job runs only from the repository's default branch. The dedicated `COPILOT_CAPI_TOKEN` secret is scoped to the classifier step. It is never printed, used to fetch pull request data, or exposed to pull request-triggered workflows.

This staff CAPI path is **internal experimentation only**, not a public integration pattern. Prefer a product-supported short-lived or workload identity for production when one exists.

The classifier treats the diff as untrusted data, not instructions. It accepts only an HTTPS API origin on `githubcopilot.com` or a subdomain, sends at most 100 changed files and 60,000 characters, and never logs the full diff or API response. GitHub can omit patches for binary files or truncate very large patches.

The bounded filenames and patch content are transmitted to the selected Copilot API endpoint. Confirm privacy, retention, residency, and regulatory requirements before adapting this experiment to other repositories.

## Run the demo

1. Open **Actions** and select **Decisions PR risk router demo**.
2. Choose **Run workflow** on the default branch.
3. Enter a pull request number.
4. Inspect the classifier job summary for probabilities, thresholds, model, latency, and token usage.
5. Expand the short route steps to see which additive paths ran.

## Validate locally

No API credential is required for deterministic validation:

```bash
python3 -m unittest discover -s .github/scripts/decisions-change-risk -p 'test_*.py'
python3 -m py_compile \
  .github/scripts/decisions-change-risk/decisions_change_risk.py \
  .github/scripts/decisions-change-risk/test_decisions_change_risk.py
actionlint .github/workflows/decisions-change-risk.yml
zizmor .github/workflows/decisions-change-risk.yml
```
