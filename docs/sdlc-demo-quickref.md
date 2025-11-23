# 🚀 SDLC Demo Workflow - Quick Reference

## Workflow Overview

**File:** `.github/workflows/sdlc-demo.yml`  
**Purpose:** Comprehensive CI/CD demonstration with security & performance best practices  
**Runtime:** ~3-4 minutes (cached), ~5-6 minutes (cold)  
**Cost:** ~$0.06-0.08 per run (private repos), FREE (public repos)

---

## Job Architecture

```
┌─────────────────────────────────────────────┐
│           BUILD (1-2 min)                   │
│  • Checkout code (shallow)                  │
│  • Setup Node.js 20 + npm cache             │
│  • npm ci (install dependencies)            │
│  • npm run build                            │
│  • Cache dist/ artifacts                    │
└─────────────────────────────────────────────┘
                    ↓
    ┌───────────────┼───────────────┬─────────┐
    ↓               ↓               ↓         ↓
┌──────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐
│ UNIT     │  │ INTEGR.  │  │  LINT   │  │SECURITY │
│ TESTS    │  │ TESTS    │  │ (ESLint)│  │ (Trivy) │
│ Matrix:  │  │ Services:│  │ 15-30s  │  │ 1-2 min │
│ Node 18  │  │ PG + Redis│  └─────────┘  └─────────┘
│ Node 20  │  │ 1-2 min  │
│ Node 22  │  └──────────┘
│ 30-45s ea│
└──────────┘
    └───────────────┬───────────────┴─────────┘
                    ↓
         ┌─────────────────────────┐
         │  RELEASE (30s)          │
         │  • Semantic versioning  │
         │  • GitHub release       │
         │  • Attach artifacts     │
         │  (main branch only)     │
         └─────────────────────────┘
```

---

## Quick Commands

### Trigger Workflow
```bash
# Manual trigger via CLI
gh workflow run sdlc-demo.yml

# With skip-release option
gh workflow run sdlc-demo.yml --field skip-release=true

# View runs
gh run list --workflow=sdlc-demo.yml

# Watch latest run
gh run watch
```

### Local Development
```bash
# Setup
cd demo-app
npm install

# Build
npm run build

# Test
npm test                  # All tests
npm run test:unit         # Unit tests only
npm run test:integration  # Integration tests

# Lint
npm run lint

# Run
npm start
```

---

## Key Features at a Glance

### 🚀 Performance Optimizations

| Feature | Benefit | Savings |
|---------|---------|---------|
| **npm caching** | Faster installs | 1-2 min per job |
| **Build artifact cache** | Skip rebuilding | ~1 min |
| **ESLint cache** | Incremental linting | 10-30s |
| **Concurrency cancellation** | Stop outdated runs | 20-30% minutes |
| **Shallow clone** | Faster checkout | 5-15s |
| **Parallel jobs** | Concurrent execution | 50% total time |

### 🛡️ Security Features

| Feature | Purpose |
|---------|---------|
| **SHA-pinned actions** | Immutable action versions |
| **Least privilege permissions** | Minimal default access |
| **Job-level permission overrides** | Granular control |
| **Trivy scanning** | Vulnerability detection |
| **SARIF upload** | Security tab integration |
| **Script injection prevention** | Safe input handling |
| **Dependabot** | Auto-update dependencies |

---

## Workflow Triggers

### Automatic
- **Push** to `main` or `develop` (full pipeline + release)
- **Pull Request** to `main` or `develop` (all checks, no release)

### Manual
- **workflow_dispatch** (Actions tab → Run workflow)

### Ignored Paths
- `docs/**` (documentation)
- `**.md` (markdown files)
- `.github/ISSUE_TEMPLATE/**` (issue templates)

---

## Environment Variables

### Workflow-Level
```yaml
NODE_VERSION: '20'         # Node.js version for builds
CACHE_VERSION: 'v1'        # Cache invalidation key
```

### Job-Specific (Integration Tests)
```yaml
DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
REDIS_URL: redis://localhost:6379
NODE_ENV: test
```

---

## Artifacts & Retention

| Artifact | Content | Retention | Purpose |
|----------|---------|-----------|---------|
| `build-dist` | Compiled code | 1 day | Downstream jobs |
| `coverage-node18` | Test coverage | 7 days | Analysis |
| `coverage-node20` | Test coverage | 7 days | Analysis |
| `coverage-node22` | Test coverage | 7 days | Analysis |
| `integration-test-results` | Test reports | 7 days | Debugging |

---

## Caching Strategy

### Cache Keys

```yaml
# npm dependencies
cache-key: npm-${{ hashFiles('**/package-lock.json') }}

# Build artifacts
cache-key: build-v1-${{ hashFiles('src/**') }}-${{ github.sha }}

# ESLint cache
cache-key: eslint-v1-${{ hashFiles('.eslintrc.json', 'src/**/*.js') }}
```

### Cache Invalidation
- Bump `CACHE_VERSION` to clear all caches
- Lock file changes automatically invalidate npm cache
- Source changes invalidate build cache

---

## Common Customizations

### Change Node.js Version
```yaml
env:
  NODE_VERSION: '22'  # Update to desired version
```

### Add Matrix Variants
```yaml
strategy:
  matrix:
    node-version: ['18.x', '20.x', '22.x', '23.x']  # Add new version
```

### Modify Timeout
```yaml
jobs:
  build:
    timeout-minutes: 15  # Increase if needed
```

### Skip Release
```yaml
# Via workflow input
skip-release: true

# Or modify condition
if: |
  github.ref == 'refs/heads/main' &&
  !contains(github.event.head_commit.message, '[skip release]')
```

---

## Troubleshooting

### Workflow not triggering?
- ✅ Check branch name matches triggers
- ✅ Verify file is committed to default branch
- ✅ Check `paths-ignore` filters

### Build failing?
- ✅ Run `npm ci` locally to reproduce
- ✅ Check Node version compatibility
- ✅ Clear cache by bumping `CACHE_VERSION`

### Tests failing?
- ✅ Ensure service containers are healthy
- ✅ Check environment variables
- ✅ Review job logs for specific errors

### Release not creating?
- ✅ Verify on `main` branch
- ✅ Check permissions: `contents: write`
- ✅ Ensure previous jobs succeeded

---

## Performance Benchmarks

### Expected Times (with cache)

| Job | Duration | Billable |
|-----|----------|----------|
| Build | 1-2 min | 1-2 min |
| Test Unit (×3) | 30-45s each | 1.5-2 min total |
| Test Integration | 1-2 min | 1-2 min |
| Lint | 15-30s | 0.5 min |
| Security | 1-2 min | 1-2 min |
| Release | 30s | 0.5 min |
| **TOTAL** | **3-4 min** | **8-10 min** |

### Without Cache (First Run)

| Job | Duration | Billable |
|-----|----------|----------|
| Build | 2-3 min | 2-3 min |
| Test Unit (×3) | 1 min each | 3 min total |
| Test Integration | 2-3 min | 2-3 min |
| Lint | 30-60s | 1 min |
| Security | 2-3 min | 2-3 min |
| Release | 30s | 0.5 min |
| **TOTAL** | **5-6 min** | **12-15 min** |

---

## Security Checklist

- [x] Actions pinned to commit SHA
- [x] Workflow-level permissions set to `contents: read`
- [x] Job-level permission overrides only where needed
- [x] Secrets passed via environment variables
- [x] Script injection prevention demonstrated
- [x] Vulnerability scanning enabled (Trivy)
- [x] SARIF results uploaded to Security tab
- [x] Dependabot configured for actions + npm

---

## Demo Talking Points

1. **Parallelization**: "5 jobs run concurrently, cutting total time by 50%"
2. **Caching**: "Second run is 60-70% faster due to caching"
3. **Matrix**: "Test 3 Node versions in parallel, not sequentially"
4. **Services**: "Real PostgreSQL + Redis, no mocking"
5. **Security**: "SHA-pinned actions prevent supply chain attacks"
6. **Permissions**: "Least privilege by default, write only when needed"
7. **Concurrency**: "Auto-cancel outdated runs, saves 20-30%"
8. **Artifacts**: "Smart retention policies reduce storage costs"

---

## Related Workflows

- `01-hello-world.yml` - Getting started
- `cache-node.yml` - Caching patterns
- `10-matrix.yml` - Matrix strategies
- `11-containers-and-services.yml` - Service containers
- `oidc-aws.yml` - Cloud authentication

---

## Learn More

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Caching Dependencies](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)

---

**Built with ❤️ for the GitHub Actions community**
