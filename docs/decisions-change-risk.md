# OpenAI Decisions change-risk experiment

This experiment uses OpenAI's public-beta [Decisions API](https://developers.openai.com/api/docs/guides/decisions) as a fast pull request change-risk classifier. It is deliberately **shadow mode**: the [workflow](../.github/workflows/decisions-change-risk.yml) always runs baseline validation, then Decisions can add demo validation or review jobs. A negative model decision never skips a required check.

## Architecture

1. `pull_request` or manual dispatch starts the workflow with read-only repository and pull request permissions.
2. The workflow checks out only [the external router script](../.github/scripts/decisions-change-risk/decisions_change_risk.py) from the pull request's base commit. It never checks out or executes code from the pull request head.
3. The router reads changed-file metadata and patches through GitHub's pull request files API.
4. It sends a bounded text input to `POST https://api.openai.com/v1/decisions` with model `gpt-6-luna`.
5. Four predicate probabilities are compared with explicit thresholds and exposed as step and job outputs.
6. Conditional, side-effect-free jobs demonstrate lightweight, full-test, security-review, and deploy-review routes.

Fork pull requests skip classification before fetching the diff because Actions secrets are unavailable. A missing API key, refusal, HTTP failure, malformed response, or absent predicate produces an explicit non-success classifier status and neutral routing outputs. Those conditions do not masquerade as a successful low-risk classification.

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

## Setup and data handling

Create an Actions repository secret named `OPENAI_API_KEY` containing an OpenAI API key authorized for the public Decisions API. No secret is currently configured, so live classification will report `skipped_missing_api_key` until this is done.

The request transmits bounded pull request filenames and patch content to OpenAI. Treat that as an external data transfer and confirm the repository's privacy, retention, residency, and regulatory requirements before enabling the workflow. OpenAI documents Zero Data Retention, HIPAA, and regional processing support for eligible customers, but eligibility and contractual requirements still apply.

The Decisions API is public beta. OpenAI describes it as roughly 10x faster than the Responses API, but availability, schemas, latency, and calibration may change before general availability.

## Cost

`gpt-6-luna` Decisions pricing is input-only at $0.10 per 1 million tokens. A 60,000-character cap is roughly 15,000 tokens for typical source text, or about $0.0015 at the cap, plus the small question prompt. Actual tokenization varies. The job summary reports API latency, input tokens, and an estimated per-request cost from the response usage.

## Run it

Automatic runs occur for pull requests when they are opened, synchronized, or reopened. To test a specific pull request manually:

1. Open **Actions** and select **OpenAI Decisions change-risk experiment**.
2. Choose **Run workflow**.
3. Enter the pull request number and run it from a branch containing the workflow.
4. Inspect the classifier job summary and the conditional demo jobs.

For deterministic local validation without an API key:

```bash
python3 -m unittest discover -s .github/scripts/decisions-change-risk -p 'test_*.py'
actionlint .github/workflows/decisions-change-risk.yml
zizmor .github/workflows/decisions-change-risk.yml
```
