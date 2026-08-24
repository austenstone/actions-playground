# Tech Sales Pro 201 — GitHub Actions Demo Library

Narration scripts for the seven demo videos in the Actions module of Microsoft's
Tech Sales Pro 201 partner credential course.

**Audience:** GitHub partners, Microsoft partners, and internal Microsoft teams.
Assume technical literacy, not GitHub Actions literacy.

**Format:** short, screen-driven clips. Microsoft ACE supplies intros and outros,
so start on the content and end on the content. No "hi, I'm…", no "thanks for
watching."

## The library

| # | Video | Persona | Workflow | Script |
|---|---|---|---|---|
| 1 | Anatomy of a workflow | foundation | [`demo-1-anatomy.yml`](../../.github/workflows/demo-1-anatomy.yml) | [script](01-anatomy-of-a-workflow.md) |
| 2 | CI on a pull request | Dara, developer | [`demo-2-pr-ci.yml`](../../.github/workflows/demo-2-pr-ci.yml) | [script](02-ci-on-a-pull-request.md) |
| 3 | Hosted vs. self-hosted runners | Sandra + Blake | [`demo-3-hosted-runners.yml`](../../.github/workflows/demo-3-hosted-runners.yml) | [script](03-hosted-vs-self-hosted-runners.md) |
| 4 | Larger runners for faster builds | Jordan, eng manager | [`demo-4-larger-runners.yml`](../../.github/workflows/demo-4-larger-runners.yml) | [script](04-larger-runners.md) |
| 5 | Secretless deployment with OIDC | Priya, security | [`demo-5-oidc.yml`](../../.github/workflows/demo-5-oidc.yml) | [script](05-secretless-deployment-with-oidc.md) |
| 6 | Migrating from Jenkins | Blake, DevOps | [`demo-6-jenkins-migration.yml`](../../.github/workflows/demo-6-jenkins-migration.yml) | [script](06-migrating-from-jenkins.md) |
| 7 | Governance with reusable workflows | Sandra, platform lead | [`demo-7-golden-path.yml`](../../.github/workflows/demo-7-golden-path.yml) · [`demo-7-governance.yml`](../../.github/workflows/demo-7-governance.yml) | [script](07-governance-with-reusable-workflows.md) |

Video 3 is the commercial centerpiece. If time is short, make that one great.

## Before you record

- [ ] **Film in `octodemo/actions-playground`.** Video 4 needs larger runners,
      which a personal account cannot provision. The other six work anywhere,
      but keeping one repo on screen across all seven is worth more than the
      convenience of switching.
- [ ] **Pre-run every workflow once** so the Actions tab has green history. An
      empty Actions tab reads as "nobody uses this."
- [ ] **Re-check the prices in video 4** against the public
      [per-minute rate card](https://docs.github.com/billing/managing-billing-for-your-products/managing-billing-for-github-actions/about-billing-for-github-actions).
      Rates change; this is an external audience.
- [ ] **Zoom the browser to ~150%** and set the editor font large. Most viewers
      are on a laptop, some on a phone.
- [ ] **Use light theme.** It survives compression and projector washout better.
- [ ] **Close every unrelated tab**, and check the org/repo name in the URL bar
      for anything you would not want on a partner's screen.

## How to read these scripts

- `[SCREEN]` — what the viewer sees. Not spoken.
- Plain prose — spoken word, written to be read aloud verbatim.
- `> Note` — direction to you, not content.

Written to be read cold. If a sentence feels awkward in your mouth, change it —
the intent matters more than the wording.
