# Video 7 — Governance with Reusable Workflows

**Persona:** Sandra, platform / security leadership. Accountable for what ships
across every team. Cannot personally review every repository.
**Workflows:**
[`.github/workflows/demo-7-golden-path.yml`](../../.github/workflows/demo-7-golden-path.yml)
(the reusable one) and
[`.github/workflows/demo-7-governance.yml`](../../.github/workflows/demo-7-governance.yml)
(the caller)
**Target runtime:** 5 minutes

**Goal:** the phrase to land is *impossible to quietly bypass*. Not "documented."
Not "recommended." Structurally impossible, with evidence produced automatically.

> This is the last video in the library, so close the arc: video 1 was one
> workflow in one repo, this is the same idea applied to an organisation.

---

## [SCREEN] Repo list with several repositories visible

Sandra's problem is not one pipeline. It is a hundred of them, owned by teams she
does not manage, and a requirement that every one of them scans for
vulnerabilities before it ships.

## [SCREEN] Stay on the repo list

The usual approach is a wiki page and good intentions. That is not a control. It
is a hope, and it fails silently — you find out at audit.

## [SCREEN] Open `demo-7-golden-path.yml`

So instead, you write the pipeline once.

## [SCREEN] Highlight `on: workflow_call`

`workflow_call`. That makes this workflow callable by other workflows, in other
repositories.

## [SCREEN] Highlight the `inputs` block

It takes inputs — language, runner, working directory. The things that legitimately
differ between teams.

## [SCREEN] Scroll through the three jobs

And inside it, three jobs. Security scan. Build. Compliance.

## [SCREEN] Highlight the `security` job, then `needs:` on `build`

Note the order. Build *needs* security. Not by convention — by dependency. If the
scan does not pass, the build does not start.

## [SCREEN] Open `demo-7-governance.yml`, the caller

Now here is a team using it.

## [SCREEN] Highlight the `uses:` line

That is their entire CI file. One `uses:`, pointing at the golden path, plus their
inputs.

## [SCREEN] Point at the inputs in the caller

And this is the important detail. They can choose their language. They can choose
their runner. What they cannot do is choose whether the security job runs. It is
not exposed as an input, so there is no way to express "skip it."

## [SCREEN] Stay on the caller file

If you want to make it stricter still, you can require this workflow through
rulesets at the organisation level, so a repository cannot merge without it. Then
the golden path is not just the easy option, it is the only one.

## [SCREEN] Actions tab → the completed caller run → the job graph

Here it is running. The caller's job, and inside it the three jobs from the
reusable workflow.

## [SCREEN] Expand the compliance job's summary

And this is what Sandra actually needed.

## [SCREEN] Point at the attestation output and the control table

An attestation: what was scanned, what was built, which commit, which controls
were enforced. Produced by the pipeline, not by a person filling in a
spreadsheet the week before the audit.

## [SCREEN] Show the attestation being consumed by the caller's `report` job

And it is an output, so the calling workflow can use it — publish it, ship it to a
compliance system, gate a release on it.

## [SCREEN] Back to the golden-path workflow

The shape of this is worth naming, because it is the whole argument.

Sandra writes one workflow. Teams get to move fast, because adopting it is a
single line and they still control the parts that are legitimately theirs. Sandra
gets a guarantee, because the parts that are hers are not negotiable in the
caller. And the evidence generates itself.

That is the difference between a policy and a control. And it is a reason a
platform team ends up preferring this over the pipeline sprawl they had before —
which is usually the conversation that actually closes.
