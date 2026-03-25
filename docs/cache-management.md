# GitHub Actions Cache Management

GitHub Actions caches, artifacts, and GitHub Packages share a **pooled storage allowance** per organization. When you exceed it, older caches are evicted, builds get slower, and you may see unexpected storage charges.

The GitHub UI shows basic billing info but **doesn't provide a per-repo or per-workflow cache breakdown**. You need the API or CLI.

## Quick Start: See Your Cache Usage

### Organization Level

```bash
# Total cache usage across the org
gh api /orgs/{org}/actions/cache/usage
```

```json
{
  "total_active_caches_size_in_bytes": 10737418240,
  "total_active_caches_count": 1523
}
```

### Per-Repository Breakdown

```bash
# Which repos are consuming the most cache?
gh api --paginate /orgs/{org}/actions/cache/usage-by-repository \
  --jq '.repository_cache_usages | sort_by(.active_caches_size_in_bytes) | reverse | .[:10] | .[] | "\(.full_name)\t\(.active_caches_count) caches\t\(.active_caches_size_in_bytes) bytes"'
```

### Individual Caches in a Repo

```bash
# List all caches, sorted by size
gh cache list -R owner/repo --sort size_in_bytes --order desc

# JSON output for scripting
gh cache list -R owner/repo --json key,ref,sizeInBytes,lastAccessedAt,createdAt
```

## Automated Audit Workflow

The [cache-audit.yml](../.github/workflows/cache-audit.yml) workflow scans every repo in your org and produces a report showing:

- **Total org cache size and count**
- **Top repos ranked by cache size or count**
- **Per-repo breakdown by branch and cache key prefix**
- **Top 10 largest individual caches per repo**
- **Actionable recommendations**

Run it manually from the Actions tab:

```
Actions → Cache Audit → Run workflow → Enter org name → Go
```

The report is written to the Job Summary and uploaded as an artifact.

## Cache Cleanup Strategies

### 1. Auto-cleanup on PR close

Add this to any repo to automatically delete caches when a PR is merged or closed:

```yaml
on:
  pull_request:
    types: [closed]

permissions:
  actions: write

jobs:
  cleanup:
    runs-on: ubuntu-latest
    steps:
      - name: Delete PR branch caches
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh cache list --ref refs/pull/${{ github.event.pull_request.number }}/merge \
            --json key -q '.[].key' | \
            xargs -I {} gh cache delete {}
```

### 2. Delete caches from deleted branches

```bash
# Get all cache refs, cross-reference with active branches
gh api --paginate /repos/owner/repo/actions/caches \
  --jq '.actions_caches[].ref' | sort -u

# Delete caches for a specific branch
gh cache list --ref refs/heads/feature-branch --json key -q '.[].key' | \
  xargs -I {} gh cache delete {}
```

### 3. Delete caches older than N days

```bash
# Find caches not accessed in 14 days
cutoff=$(date -u -v-14d '+%Y-%m-%dT%H:%M:%SZ')  # macOS
# cutoff=$(date -u -d '14 days ago' '+%Y-%m-%dT%H:%M:%SZ')  # Linux

gh api --paginate /repos/owner/repo/actions/caches \
  --jq ".actions_caches[] | select(.last_accessed_at < \"$cutoff\") | .key" | \
  xargs -I {} gh cache delete {} -R owner/repo
```

### 4. Nuclear option: delete all caches

```bash
gh cache list -R owner/repo --json key -q '.[].key' | \
  xargs -I {} gh cache delete {} -R owner/repo
```

## Understanding the Storage Bill

GitHub Actions storage billing can be confusing. Here's the breakdown:

| Storage Type | What It Is | Shared Allowance? |
|---|---|---|
| **Actions Caches** | Dependency caches (`actions/cache`) | ✅ Yes |
| **Actions Artifacts** | Uploaded build outputs (`actions/upload-artifact`) | ✅ Yes |
| **GitHub Packages** | Container images, npm packages, etc. | ✅ Yes |
| **Git LFS** | Large file storage | ❌ Separate |

All three pooled types share the same monthly allowance. When people say "storage spiked," it could be any of the three. Check each:

```bash
# Cache usage
gh api /orgs/{org}/actions/cache/usage

# Artifact and log storage (per-repo)
gh api /repos/owner/repo/actions/artifacts --jq '[.artifacts[].size_in_bytes] | add'

# Packages storage (org level)
gh api /orgs/{org}/settings/billing/packages
```

## Common Causes of Cache Growth

| Pattern | Why It Happens | Fix |
|---|---|---|
| **High CI failure rates** | Failed builds write caches but don't produce useful output. A 50% failure rate means half your cache writes are waste. | Fix flaky tests first. Cache storage follows. |
| **Matrix fan-outs** | A matrix of 20 jobs × 10 branches = 200 cache entries | Use more specific cache keys, share caches across matrix jobs |
| **Stale PR branches** | Caches scoped to `refs/pull/N/merge` persist after the PR closes | Add the PR close cleanup workflow above |
| **Overly broad restore keys** | `restore-keys: Linux-` restores stale caches, which then get re-saved as new entries | Use precise keys: `Linux-node-18-${{ hashFiles('**/package-lock.json') }}` |
| **Default retention too long** | Caches live 7 days by default without access, but the max retention can be 90 days | Lower org-level `ACTIONS_CACHE_MAX_RETENTION_DAYS` |

## API Reference

| Endpoint | Description |
|---|---|
| [`GET /orgs/{org}/actions/cache/usage`](https://docs.github.com/en/rest/actions/cache#get-github-actions-cache-usage-for-an-organization) | Total org cache usage |
| [`GET /orgs/{org}/actions/cache/usage-by-repository`](https://docs.github.com/en/rest/actions/cache#list-repositories-with-github-actions-cache-usage-for-an-organization) | Per-repo breakdown |
| [`GET /repos/{owner}/{repo}/actions/caches`](https://docs.github.com/en/rest/actions/cache#list-github-actions-caches-for-a-repository) | List individual caches |
| [`DELETE /repos/{owner}/{repo}/actions/caches/{cache_id}`](https://docs.github.com/en/rest/actions/cache#delete-a-github-actions-cache-for-a-repository-using-a-cache-id) | Delete by ID |
| [`DELETE /repos/{owner}/{repo}/actions/caches?key={key}`](https://docs.github.com/en/rest/actions/cache#delete-github-actions-caches-for-a-repository-using-a-cache-key) | Delete by key |

### CLI Reference

```bash
gh cache list      # List caches (supports --ref, --sort, --json)
gh cache delete    # Delete a cache by key or ID
```

See [gh cache docs](https://cli.github.com/manual/gh_cache) for full options.

## Tools

| Tool | Description |
|---|---|
| [gh-actions-cache](https://github.com/actions/gh-actions-cache) | Official GitHub CLI extension for cache management |
| [gh-artifact-purge](https://github.com/andyfeller/gh-artifact-purge) | CLI extension to list/delete artifacts based on retention policy |
| [cache-audit.yml](../.github/workflows/cache-audit.yml) | Workflow to audit cache usage across an org (this repo) |
| [cache-cleanup.yml](../.github/workflows/cache-cleanup.yml) | Workflow to clean up stale caches (this repo) |
