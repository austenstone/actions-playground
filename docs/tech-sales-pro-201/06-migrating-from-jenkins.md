# Video 6 — Migrating from Jenkins with Actions Importer

**Persona:** Blake, platform engineer. Owns the Jenkins estate. Is not
sentimental about it, but is realistic about how many pipelines there are.
**Workflow:** [`.github/workflows/demo-6-jenkins-migration.yml`](../../.github/workflows/demo-6-jenkins-migration.yml)
**Target runtime:** 4–5 minutes

**Goal:** dismantle the "we have 400 pipelines, we can never move" objection. The
answer is not heroics. It is tooling, and the tooling opens pull requests.

> Do not oversell. Actions Importer gets you most of the way, not all of the way.
> Saying so is what makes the rest of the video credible.

---

## [SCREEN] Open the `Jenkinsfile` in the repo

Every conversation about leaving Jenkins hits the same wall. Not "is Actions
better." It is: we have hundreds of these, some written by people who left, and
nobody is going to rewrite them by hand.

## [SCREEN] Scroll the Jenkinsfile

Fair. So don't.

## [SCREEN] Open `demo-6-jenkins-migration.yml`

GitHub ships a tool called Actions Importer. It reads your existing CI and
converts it.

## [SCREEN] Highlight the `gh extension install github/gh-actions-importer` step

It is a `gh` CLI extension. Runs locally, runs in CI, runs wherever you point it.

## [SCREEN] Highlight the `dry-run` step

And it has three modes, which map to how a migration actually goes.

## [SCREEN] Actions tab → the run → the job summary with the three-mode table

**Audit.** Point it at your Jenkins server and it inventories everything. Every
job, and a per-job score for how completely it can convert. That report is the
migration plan — you learn on day one which pipelines are trivial and which ones
need a human.

**Dry run.** Take one job and convert it. Nothing is written anywhere, you just
see the Actions workflow it would produce.

**Migrate.** Same conversion, except it opens a pull request on the target
repository.

## [SCREEN] Stay on the summary

That last one is the part I want to land on. The output of a migration is a pull
request.

Which means it gets reviewed. It gets commented on. Someone who knows that
pipeline looks at it and fixes the two things the tool got wrong. It goes through
exactly the process every other change goes through.

Migration stops being a project with a war room and becomes a queue of pull
requests you work through.

## [SCREEN] Expand the converted-workflow output in the logs

Here is a conversion. Jenkins stages become jobs. Steps become steps. `agent`
becomes `runs-on`. Credentials become secret references.

## [SCREEN] Point at anything the tool flagged or left as a comment

And where it could not convert something cleanly, it says so, in place, as a
comment. It does not guess and it does not silently drop work. You get a to-do
list attached to the file.

## [SCREEN] Scroll to the `native` job in the workflow

This is the destination — the same pipeline as a workflow somebody actually wrote
rather than converted.

## [SCREEN] Compare on screen: Jenkinsfile left, native job right

Shorter. No agent labels, no plugin versions, no groovy. The importer gets you to
something that works; a person gets you to something that reads well. Do the
first one for four hundred pipelines and the second one for the twenty that
matter.

## [SCREEN] Back to the summary table

The same tool covers GitLab CI, Azure DevOps, CircleCI, Bamboo, and Travis. If a
customer is on any of those, the first move is the audit. It is free, it is
read-only, and it turns "we could never move" into a number.
