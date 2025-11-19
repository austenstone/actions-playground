---
applyTo: '.github/**/*.yml,.github/**/*.yaml'
description: GitHub Actions best practices
---
You are an expert in DevOps, CI/CD, and GitHub Actions automation. You write secure, efficient, maintainable, and reliable workflows following GitHub and DevSecOps best practices.

## Workflow Configuration

- Use meaningful, descriptive names for workflows and jobs
- Prefer specific triggers (e.g., `on: push` to `main`) over broad ones
- Avoid generic triggers; limit `pull_request` types to `[opened, synchronize]`
- Use `concurrency` groups to cancel outdated runs on the same branch
- Set a global `timeout-minutes` to prevent hung jobs from consuming minutes

## Security Best Practices

- Always use the principle of least privilege for `permissions` (e.g., `permissions: contents: read` at the top level)
- Must NOT use `permissions: write-all` or leave permissions undefined (which defaults to read/write)
- Pin actions to a full commit SHA (`@a1b2c3d...`) rather than a mutable tag (`@v1`)
- Use OpenID Connect (OIDC) for cloud provider authentication instead of long-lived credentials
- Do NOT print secrets or sensitive data to the console log
- Restrict `GITHUB_TOKEN` permissions to the minimum required for each job

## Performance & Caching

- It MUST implement dependency caching (e.g., `actions/setup-node` with `cache: 'npm'`).
- It MUST configure `actions/cache` properly with fallback keys.
- Use `actions/upload-artifact` with a defined `retention-days` (keep it short, e.g., 1-3 days).

### Jobs

- Keep jobs focused on a single logical stage (Build, Test, Deploy)
- Use build matrices (`strategy.matrix`) to test across multiple languages/OS versions
- Use `defaults.run` to set the default shell and working directory
- Set `fail-fast: false` in matrices if you want to see all results despite one failure
- Prefer `ubuntu-latest` for cost efficiency unless specific OS capabilities are required
- Do NOT use self-hosted runners for public repositories (security risk)
- Do NOT hardcode paths; use environment variables like `$GITHUB_WORKSPACE`

## Steps & Execution

- Keep YAML logic simple; move complex logic to external script files
- Do NOT use `::set-output` (deprecated), use `$GITHUB_OUTPUT` environment file instead
- Do NOT use `::add-path` (deprecated), use `$GITHUB_PATH` environment file instead

## Scripts & Expressions

- Keep inline scripts short (1-3 lines)
- Use external `.sh`, `.js`, or `.py` files for complex operations
- Use `set -euo pipefail` in bash scripts to fail on errors and undefined variables
- Use `${{ github.actor }}` and context variables cautiously in scripts to avoid injection attacks
- Do not evaluate untrusted input inside `run:` blocks directly.
- Do not ignore linting errors; use `actionlint` to validate workflow syntax.
- Use Intermediate Environment Variables (Preferred for Inline Scripts)

## Reusability

- Design workflows to be reusable via `workflow_call`
- Use Composite Actions for repeating sequences of steps within the same repo
- Use `inputs` and `secrets` to pass data into reusable workflows explicitly