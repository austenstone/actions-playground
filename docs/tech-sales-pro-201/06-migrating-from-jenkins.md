# Video 6 — Migrating from Jenkins with Actions Importer

**Persona:** Blake, platform engineer. Owns the Jenkins estate. Is not
sentimental about it, but is realistic about how many pipelines there are.
**Workflow:** [`.github/workflows/demo-6-jenkins-migration.yml`](../../.github/workflows/demo-6-jenkins-migration.yml)
**Target runtime:** 4–5 minutes

**Goal:** dismantle the "we have 400 pipelines, we can never move" objection. The
answer is not heroics. It is tooling, and the tooling opens pull requests.

> Do not oversell. Actions Importer gets you most of the way, not all of the way.
> Saying so is what makes the rest of the video credible.

> **This demo runs a real Jenkins.** The workflow starts a Jenkins container,
> installs the pipeline plugins, loads our `Jenkinsfile` into it as an actual
> job, and then points the Importer at the running server. Everything on screen
> is genuine tool output. Actions Importer requires a live Jenkins instance — it
> cannot convert a `Jenkinsfile` sitting on disk — so any demo that appears to
> convert a bare file is not exercising the real tool.

---

## [SCREEN] Open the `Jenkinsfile` in the repo

Every conversation about leaving Jenkins hits the same wall. Not "is Actions
better." It is: we have hundreds of these, some written by people who left, and
nobody is going to rewrite them by hand.

## [SCREEN] Scroll the Jenkinsfile — Build, Test, Deploy

Fair. So don't.

## [SCREEN] Open `demo-6-jenkins-migration.yml`, scroll to "Stand up a real Jenkins"

Quick note on what you are about to watch. This workflow boots an actual Jenkins
server and loads that pipeline into it, because Actions Importer talks to a live
Jenkins over its API. It reads your real estate, not a file you handed it.

## [SCREEN] Highlight the `gh extension install` / `gh actions-importer update` step

The tool itself is a `gh` CLI extension. Install it, pull the image, done. Runs
on your laptop, runs in CI, runs wherever you can reach the Jenkins server.

## [SCREEN] Highlight the `audit` step

And it has three modes, which map to how a migration actually goes. The first one
is the one nobody expects to matter most.

## [SCREEN] Actions tab → the run → the job summary, "The migration report"

**Audit.** Point it at Jenkins and it inventories everything, then scores it.

## [SCREEN] Zoom the audit numbers

One pipeline here, because this is a demo. But look at the shape of the report.
It converted successfully — a hundred percent. Six build steps, all six of them
recognized. Three `sh` calls, three `echo`s, all mapped to something on the other
side.

Run that against four hundred pipelines and you get a real number: how many
convert clean, how many convert partially, how many need a person. That report is
your migration plan, and you get it on day one.

## [SCREEN] Stay on the summary

That is the part I want platform teams to hear. The audit is read-only. It does
not touch your Jenkins, it does not touch your repos, it costs you an afternoon.
And it turns "we could never move" into a spreadsheet.

## [SCREEN] Scroll to the three-mode table

**Dry run.** Take one pipeline and convert it. Nothing is written anywhere. You
just look at what comes out.

**Migrate.** Same conversion, except it opens a pull request on the target
repository.

## [SCREEN] Hold on `migrate`

That last one is the part I want to land on. The output of a migration is a pull
request.

Which means it gets reviewed. It gets commented on. Someone who knows that
pipeline looks at it and fixes the two things the tool got wrong. It goes through
exactly the process every other change goes through.

Migration stops being a project with a war room and becomes a queue of pull
requests you work through.

## [SCREEN] Expand the converted workflow in the job summary

Here is the actual conversion. Three Jenkins stages, three Actions jobs. `agent
any` became `runs-on: ubuntu-latest`. The shell steps came across as `run`.

## [SCREEN] Point at `needs: Build` and `needs: Test`

And it kept the ordering — Test waits on Build, Deploy waits on Test.

## [SCREEN] Point at the repeated `actions/checkout` in each job

Now, this is where I want to be straight with you. Look at those three checkouts.

Jenkins stages share one agent and one workspace, so the checkout happens once.
Actions jobs are separate machines, so the tool checks out in each one. That is a
faithful conversion. It is not the workflow you would have written.

## [SCREEN] Scroll to the `native` job in the workflow file

This is the destination — the same pipeline, written by a person. One job, one
checkout, three steps.

## [SCREEN] Compare on screen: converted output left, native job right

Shorter, faster, and it does the same thing.

So be honest with customers about the split. The importer takes you from four
hundred Groovy files to four hundred working workflows. A human takes the twenty
that matter from working to good. Those are very different amounts of effort, and
only one of them was ever the blocker.

## [SCREEN] Back to the summary table

Same tool covers GitLab CI, Azure DevOps, CircleCI, Bamboo, and Travis. If a
customer is on any of those, the first move is always the same: run the audit. It
is free, it is read-only, and it replaces an argument with a number.

---

## Recording notes

- The audit summary renders the Jenkins host as `http://172.17.0.1:8080` — that
  is the container talking to the Jenkins on the runner. If it draws the eye,
  say "that's our throwaway Jenkins" and move on.
- Let the "Stand up a real Jenkins" and plugin-install steps stay collapsed. They
  are plumbing, not content. Mention once that Jenkins is real, then move to the
  output.
- The full converted workflow and the audit report are both attached to the run
  as an artifact if you want them open in an editor instead of the summary.
