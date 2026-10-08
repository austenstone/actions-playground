# OpenAI Decisions change-risk experiment

This experiment uses OpenAI's public-beta [Decisions API](https://developers.openai.com/api/docs/guides/decisions) as a fast pull request change-risk classifier. It is deliberately **shadow mode**: the [workflow](../.github/workflows/decisions-change-risk.yml) always runs baseline validation, then Decisions can add demo validation or review jobs. A negative model decision never skips a required check.

## Architecture

1. `pull_request` or manual dispatch starts the workflow with read-only repository and pull request permissions.
2. The workflow checks out only [the external router script](../.github/scripts/decisions-change-risk/decisions_change_risk.py) from the pull request's base commit. It never checks out or executes code from the pull request head.
3. The router reads changed-file metadata and patches through GitHub's pull request files API.
4. Pull request runs send the bounded input to public OpenAI `POST https://api.openai.com/v1/decisions` with model `gpt-6-luna`. Trusted manual runs resolve the current staff CAPI origin and use model `gpt-6-luna-decisions`.
5. Four predicate probabilities are compared with explicit thresholds and exposed as step and job outputs.
6. Conditional, side-effect-free jobs demonstrate lightweight, full-test, security-review, and deploy-review routes.

Fork pull requests skip classification before fetching the diff because Actions secrets are unavailable. A missing credential, refusal, endpoint discovery failure, HTTP failure, unexpected model, malformed response, or absent predicate produces an explicit non-success classifier status and neutral routing outputs. Those conditions do not masquerade as a successful low-risk classification.

## Predicates and thresholds

| Predicate | Threshold | Effect |
|---|---:|---|
| `security_sensitive` | 0.65 | Adds the security review demo job |
| `needs_full_test_suite` | 0.55 | Selects the full validation demo instead of the lightweight demo |
| `needs_manual_deploy_approval` | 0.60 | Adds the deploy review demo job |
| `docs_only` | 0.80 | Reported as an informational signal only |

Predicates are used instead of choices because they map directly to independent routing conditions and avoid depending on choice ordering or probability calibration during the beta. The thresholds are experiment defaults, not universal policy. Calibrate them against labeled historical pull requests and the cost of false positives and false negatives before changing any required CI behavior. In particular, do not let negative decisions suppress tests, security review, or deploy controls until the classifier has been measured on representative data.

## Diff bounds and safety

The router considers at most 100 changed files and sends at most 60,000 characters, including filenames, change metadata, and patches. It marks the input as truncated when either limit is reached. GitHub may also omit patches for binary files or truncate very large patches.

The prompt treats the diff as untrusted evidence and tells the model not to follow instructions embedded in code, comments, filenames, or prose. The workflow uses `pull_request`, never `pull_request_target`, and executes only router code from the trusted base commit. The full diff and API response are not printed to logs or the job summary.

Repository secrets are available to same-repository pull request workflows. This personal-repository experiment therefore assumes people who can push branches in the repository are trusted not to alter the workflow to expose secrets. For a broader contributor model, put the API key behind an environment with required reviewers or keep the classifier on a separately controlled workflow boundary.

## Providers and credentials

### Automatic pull request runs

Pull requests use the public OpenAI endpoint and read only `OPENAI_API_KEY`. If that secret is absent, including on forks, the classifier skips before fetching or transmitting the diff. `COPILOT_CAPI_TOKEN` is never referenced by the pull request classifier step.

### Trusted manual staff demo

Manual dispatch from the repository's default branch uses the dedicated `COPILOT_CAPI_TOKEN` secret only for GitHub's staff CAPI preview:

1. `GET https://api.github.com/copilot_internal/user` resolves `.endpoints.api`.
2. The script accepts only an HTTPS origin on `githubcopilot.com` or a subdomain.
3. It posts to `<origin>/v1/decisions` with model `gpt-6-luna-decisions`, `Copilot-Integration-Id: copilot-developer-app`, and `Editor-Version: CopilotCLI/1.0`.

The secret is scoped to the staff classifier step, which runs only for `workflow_dispatch` on the default branch. A dispatch from another ref fails before the staff step. The workflow never prints the token and does not use it to fetch pull request data.

This path is **staff/internal experimentation only**, not a public integration pattern. The dedicated secret contains a GitHub CLI authentication token because the preview currently requires Copilot staff authentication. Do not copy this pattern into production; prefer a product-supported short-lived or workload identity when one exists.

## Data handling

The request transmits bounded pull request filenames and patch content to the selected provider. Treat that as an external data transfer and confirm the repository's privacy, retention, residency, and regulatory requirements before enabling the workflow. OpenAI documents Zero Data Retention, HIPAA, and regional processing support for eligible public-API customers, but eligibility and contractual requirements still apply.

The Decisions API is public beta. OpenAI describes it as roughly 10x faster than the Responses API, but availability, schemas, latency, and calibration may change before general availability.

## Cost

Public `gpt-6-luna` Decisions pricing is input-only at $0.10 per 1 million tokens. A 60,000-character cap is roughly 15,000 tokens for typical source text, or about $0.0015 at the cap, plus the small question prompt. Actual tokenization varies. The job summary reports provider, model, API latency, input tokens, output tokens, and an estimated public-API cost. It does not estimate internal staff CAPI cost.

## Run it

Automatic public-OpenAI runs occur for pull requests when they are opened, synchronized, or reopened. To run the trusted staff CAPI demo against a specific pull request:

1. Open **Actions** and select **OpenAI Decisions change-risk experiment**.
2. Choose **Run workflow**.
3. Enter the pull request number and select the repository's default branch.
4. Inspect the classifier job summary and the conditional demo jobs.

For deterministic local validation without an API key:

```bash
python3 -m unittest discover -s .github/scripts/decisions-change-risk -p 'test_*.py'
actionlint .github/workflows/decisions-change-risk.yml
zizmor .github/workflows/decisions-change-risk.yml
```
