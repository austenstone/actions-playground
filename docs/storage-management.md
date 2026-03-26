# GitHub Actions Storage Management

> **Docs:** [How storage billing works](https://docs.github.com/en/billing/concepts/product-billing/github-actions#how-storage-billing-works)

"We exceeded our monthly allotment for GHA storage" is one of the most common questions from customers. The confusion stems from a confusing billing model: **Actions caches, Actions artifacts, and GitHub Packages all share a single pooled storage allowance.** When a customer says "storage spiked," it could be any of the three, and the UI doesn't make it easy to figure out which.

This guide helps you find what's consuming storage, clean it up, and prevent it from growing back.

## How Actions Storage Billing Works

Three different storage types share one pool:

| Storage Type | What It Is | How It Gets There | Shared Pool? |
|---|---|---|---|
| **Actions Caches** | Dependency caches (`actions/cache`) | Automatically created during workflow runs | ✅ Yes |
| **Actions Artifacts** | Build outputs, test results, logs (`actions/upload-artifact`) | Explicitly uploaded in workflows | ✅ Yes |
| **GitHub Packages** | Container images, npm/Maven/NuGet packages | Published via workflows or CLI | ✅ Yes |
| **Git LFS** | Large file storage | Committed to repos with LFS tracking | ❌ Separate |

**Key details:**
- Each plan includes a base storage amount (e.g., GitHub Team = 2 GB, Enterprise = 50 GB)
- Overage is billed by the GB/month
- Caches auto-evict after 7 days without access (configurable up to the org max)
- Artifacts default to 90-day retention (configurable per-workflow or per-org)
- Storage is calculated as a **daily average** across the billing period

> **Pro tip:** The "Actions" tab in org billing settings shows total storage but doesn't break it down by type. You need the API or CLI for that.

## Step 1: Identify What's Using Storage

### Check all three pools

```bash
# 1. Cache usage (org total + per-repo)
gh api /orgs/{org}/actions/cache/usage
gh api --paginate /orgs/{org}/actions/cache/usage-by-repository \
  --jq '.repository_cache_usages | sort_by(.active_caches_size_in_bytes) | reverse | .[:10] | .[] |
    "\(.full_name)\t\(.active_caches_count) caches\t\(.active_caches_size_in_bytes) bytes"'

# 2. Artifact storage (per-repo, check your biggest repos)
gh api --paginate /repos/{owner}/{repo}/actions/artifacts \
  --jq '[.artifacts[] | .size_in_bytes] | add'

# 3. Packages storage (org total)
gh api /orgs/{org}/settings/billing/packages
```

### Drill into cache usage for a specific repo

```bash
# List all caches, sorted by size (biggest first)
gh cache list -R owner/repo --sort size_in_bytes --order desc

# JSON output for scripting
gh cache list -R owner/repo --json key,ref,sizeInBytes,lastAccessedAt,createdAt

# Group by branch to find stale PR caches
gh api --paginate /repos/{owner}/{repo}/actions/caches \
  --jq '.actions_caches[].ref' | sort | uniq -c | sort -rn
```

### Drill into artifact storage for a specific repo

```bash
# List artifacts with size and age
gh api --paginate /repos/{owner}/{repo}/actions/artifacts \
  --jq '.artifacts[] | "\(.name)\t\(.size_in_bytes)\t\(.created_at)\t\(.expired)"' | \
  sort -t$'\t' -k2 -rn | head -20

# Total artifact storage
gh api --paginate /repos/{owner}/{repo}/actions/artifacts \
  --jq '[.artifacts[] | select(.expired == false) | .size_in_bytes] | add'
```

## Step 2: Automated Audit

### Org-wide cache audit workflow

The [cache-audit](../.github/actions/cache-audit) composite action scans every repo in your org and produces a report:

- Total org cache size and count
- Top repos ranked by cache size or count
- Per-repo breakdown by branch and cache key prefix
- Top 10 largest individual caches per repo
- Actionable recommendations

Run it from the [Cache Audit workflow](../.github/workflows/cache-audit.yml):

```
Actions → Cache Audit → Run workflow → Enter org name → Go
```

The report is written to the Job Summary and uploaded as an artifact.

### Use it in your own workflow

```yaml
- uses: austenstone/actions-playground/.github/actions/cache-audit@main
  with:
    org: my-org
    top_n: '10'
    sort_by: size
    token: ${{ secrets.ORG_READ_TOKEN }}
```

> **Note:** The default `GITHUB_TOKEN` can only see the current repo's caches. For org-wide auditing, you need a PAT or GitHub App token with `actions:read` scope across the org.

## Step 3: Clean Up

### Caches

**Auto-cleanup on PR close** (add to any repo):

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
            --json key -q '.[].key' | xargs -I {} gh cache delete {}
```

**Delete caches from deleted branches:**

```bash
gh cache list --ref refs/heads/feature-branch --json key -q '.[].key' | \
  xargs -I {} gh cache delete {}
```

**Delete caches older than N days:**

```bash
cutoff=$(date -u -v-14d '+%Y-%m-%dT%H:%M:%SZ')  # macOS
# cutoff=$(date -u -d '14 days ago' '+%Y-%m-%dT%H:%M:%SZ')  # Linux

gh api --paginate /repos/{owner}/{repo}/actions/caches \
  --jq ".actions_caches[] | select(.last_accessed_at < \"$cutoff\") | .key" | \
  xargs -I {} gh cache delete {} -R owner/repo
```

**Delete all caches in a repo:**

```bash
gh cache list -R owner/repo --json key -q '.[].key' | \
  xargs -I {} gh cache delete {} -R owner/repo
```

The [cache-cleanup](../.github/actions/cache-cleanup) composite action wraps all of these strategies into a reusable action with dry-run support.

### Artifacts

```bash
# List expired artifacts still taking storage
gh api --paginate /repos/{owner}/{repo}/actions/artifacts \
  --jq '.artifacts[] | select(.expired == true) | .id' | \
  xargs -I {} gh api -X DELETE /repos/{owner}/{repo}/actions/artifacts/{}

# Delete artifacts older than 30 days
gh api --paginate /repos/{owner}/{repo}/actions/artifacts \
  --jq '.artifacts[] | select(.expired == false) | "\(.id)\t\(.created_at)"' | \
  while IFS=$'\t' read -r id created; do
    if [[ "$created" < "$(date -u -v-30d '+%Y-%m-%dT%H:%M:%SZ')" ]]; then
      echo "Deleting artifact $id (created $created)"
      gh api -X DELETE "/repos/{owner}/{repo}/actions/artifacts/$id"
    fi
  done
```

**Set shorter retention in your workflow:**

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: results/
    retention-days: 7  # Default is 90!
```

**Set org-wide default:** Settings → Actions → General → Artifact and log retention.

### Packages

```bash
# List package versions (e.g., container images)
gh api --paginate /orgs/{org}/packages/container/{package}/versions \
  --jq '.[] | "\(.id)\t\(.metadata.container.tags)\t\(.created_at)"'

# Delete untagged container images
gh api --paginate /orgs/{org}/packages/container/{package}/versions \
  --jq '.[] | select(.metadata.container.tags | length == 0) | .id' | \
  xargs -I {} gh api -X DELETE /orgs/{org}/packages/container/{package}/versions/{}
```

## Common Patterns That Drive Storage Growth

| Pattern | What Happens | Fix |
|---|---|---|
| **High CI failure rates** | Failed builds still write caches. A repo with 50% failure rate has half its cache writes going to waste. | Fix flaky tests. Cache savings follow automatically. |
| **Matrix fan-outs** | A 20-job matrix × 10 branches = 200 cache entries, each potentially large | Use precise cache keys, share caches across matrix legs |
| **Stale PR branches** | Caches scoped to `refs/pull/N/merge` persist after PR is merged/closed | Add the PR close cleanup trigger above |
| **Artifact hoarding** | Default 90-day retention on large build outputs, test snapshots, coverage reports | Set `retention-days: 7` (or less) for anything you don't need long-term |
| **Package image sprawl** | Every CI build pushes a new container tag, old ones never get cleaned up | Delete untagged versions, prune old tags on a schedule |
| **Overly broad restore keys** | `restore-keys: Linux-` restores stale caches that get re-saved as new entries | Use precise keys: `Linux-node-20-${{ hashFiles('**/package-lock.json') }}` |
| **Default retention too long** | Caches live 7 days without access, but org max can be set to 90 | Lower `ACTIONS_CACHE_MAX_RETENTION_DAYS` in org settings |

## Org-Level Settings to Reduce Storage

| Setting | Where | Recommendation |
|---|---|---|
| **Artifact & log retention** | Settings → Actions → General | Lower to 7-30 days unless you need longer |
| **Cache retention** | Org policy / `ACTIONS_CACHE_MAX_RETENTION_DAYS` | 7 days covers most CI needs |
| **Fork PR policies** | Settings → Actions → General | Restrict fork PR artifacts to reduce noise |
| **Package cleanup policies** | Settings → Packages | Enable automatic deletion of old versions |

## API Reference

### Cache APIs

| Endpoint | Description |
|---|---|
| [`GET /orgs/{org}/actions/cache/usage`](https://docs.github.com/en/rest/actions/cache#get-github-actions-cache-usage-for-an-organization) | Total org cache usage |
| [`GET /orgs/{org}/actions/cache/usage-by-repository`](https://docs.github.com/en/rest/actions/cache#list-repositories-with-github-actions-cache-usage-for-an-organization) | Per-repo cache breakdown |
| [`GET /repos/{owner}/{repo}/actions/caches`](https://docs.github.com/en/rest/actions/cache#list-github-actions-caches-for-a-repository) | List individual caches |
| [`DELETE /repos/{owner}/{repo}/actions/caches/{cache_id}`](https://docs.github.com/en/rest/actions/cache#delete-a-github-actions-cache-for-a-repository-using-a-cache-id) | Delete cache by ID |
| [`DELETE /repos/{owner}/{repo}/actions/caches?key={key}`](https://docs.github.com/en/rest/actions/cache#delete-github-actions-caches-for-a-repository-using-a-cache-key) | Delete cache by key |

### Artifact APIs

| Endpoint | Description |
|---|---|
| [`GET /repos/{owner}/{repo}/actions/artifacts`](https://docs.github.com/en/rest/actions/artifacts#list-artifacts-for-a-repository) | List all artifacts |
| [`DELETE /repos/{owner}/{repo}/actions/artifacts/{id}`](https://docs.github.com/en/rest/actions/artifacts#delete-an-artifact) | Delete an artifact |
| [`GET /orgs/{org}/settings/billing/actions`](https://docs.github.com/en/rest/billing/billing#get-github-actions-billing-for-an-organization) | Org Actions billing (includes storage) |

### Packages APIs

| Endpoint | Description |
|---|---|
| [`GET /orgs/{org}/packages`](https://docs.github.com/en/rest/packages/packages#list-packages-for-an-organization) | List org packages |
| [`GET /orgs/{org}/settings/billing/packages`](https://docs.github.com/en/rest/billing/billing#get-github-packages-billing-for-an-organization) | Org Packages billing |

### CLI

```bash
gh cache list      # List caches (supports --ref, --sort, --json)
gh cache delete    # Delete a cache by key or ID
```

See [`gh cache` docs](https://cli.github.com/manual/gh_cache) for full options.

## Tools

| Tool | Description |
|---|---|
| [`gh cache`](https://cli.github.com/manual/gh_cache) | Built-in CLI for cache management |
| [`gh-actions-cache`](https://github.com/actions/gh-actions-cache) | Official GitHub CLI extension with extra features |
| [`gh-artifact-purge`](https://github.com/andyfeller/gh-artifact-purge) | CLI extension to list/delete artifacts based on retention policy |
| [cache-audit action](../.github/actions/cache-audit) | Composite action to audit cache usage across an org (this repo) |
| [cache-cleanup action](../.github/actions/cache-cleanup) | Composite action to clean up stale caches with dry-run support (this repo) |

## Further Reading

- [GitHub Docs: How storage billing works](https://docs.github.com/en/billing/concepts/product-billing/github-actions#how-storage-billing-works)
- [GitHub Docs: Managing caching](https://docs.github.com/en/actions/how-tos/using-cache-dependencies-to-speed-up-workflows)
- [GitHub Docs: Remove workflow artifacts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/remove-workflow-artifacts)
- [GitHub Docs: Managing GitHub Packages billing](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-packages)
