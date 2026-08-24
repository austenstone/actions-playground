# Video 2 — CI on a Pull Request

**Persona:** Dara, developer. Wants fast feedback and no surprises at merge time.
**Workflow:** [`.github/workflows/demo-2-pr-ci.yml`](../../.github/workflows/demo-2-pr-ci.yml)
**Prop:** an open pull request in this repo — [#100](https://github.com/austenstone/actions-playground/pull/100) works, or open a fresh one
**Target runtime:** 4–5 minutes

**Goal:** show that CI is not a separate system you visit. It is part of the pull
request. The emotional beat is *confidence at merge time*.

> Have the PR open in a tab **before** you hit record, with checks already run
> once so the history is green. Then push a small commit on camera to trigger a
> live run.

---

## [SCREEN] The pull request, Conversation tab, checks section visible

This is a pull request. Someone changed some code and wants it merged. And down
here, without anyone asking for it, the repository has already gone and checked
the work.

## [SCREEN] Point at the check names

Lint, test, build. Nobody clicked anything. The pull request itself was the
trigger.

## [SCREEN] Open `demo-2-pr-ci.yml` in a second tab

Here is why.

## [SCREEN] Highlight `on: pull_request:` and the `paths` filter

The trigger is `pull_request`. Every time this PR gets a new commit, this runs
again.

## [SCREEN] Highlight the `concurrency` block

And this bit is quietly important. If Dara pushes three commits in a row, the
first two runs get cancelled. You get feedback on the code that actually matters
— the latest — and you are not paying for two builds of code nobody will merge.

## [SCREEN] Highlight the `lint` job

The first job is lint. Fast, cheap, runs on its own.

## [SCREEN] Highlight the `test` job and its `strategy.matrix`

The second is test — and look at this. One job definition, three versions of
Node. That is a matrix. Actions expands it into three parallel jobs, on three
separate machines, at the same time. If you support multiple runtimes or multiple
operating systems, you do not write the job three times.

## [SCREEN] Highlight the coverage step

It also collects coverage, and posts it into the summary.

## [SCREEN] Highlight the `build` job and its `needs:`

And the third job is build, which says `needs: [lint, test]`. It will not start
until both pass. That is your dependency graph — declared, not scripted.

## [SCREEN] Back to the PR. Make a trivial commit (edit the README in the web UI, commit to the branch)

Let's see it happen live. I'll change one line.

> Commit. Return to the PR.

## [SCREEN] The checks section, now showing a run in progress

There it goes. Yellow, immediately.

## [SCREEN] Click "Details" on the test check → the matrix jobs in the sidebar

And there is the matrix — three Node versions, running side by side. Serially
this would be three times as long.

## [SCREEN] Wait for green, return to the Conversation tab

Green. Dara did not leave the pull request, did not open a second tool, and did
not ask anyone to run anything.

## [SCREEN] Point at the merge button

Now the part that makes this real. In Settings, you make these checks **required**.

## [SCREEN] Settings → Rules → Rulesets (or Branches → protection rule), show required status checks

Once a check is required, the merge button is disabled until it passes. Not a
convention, not a code review comment — the platform will not let the change in.

## [SCREEN] Back to the PR

That is CI on a pull request. The feedback is on the change, while the author is
still looking at it, and the rule is enforced by the same system that stores the
code.
