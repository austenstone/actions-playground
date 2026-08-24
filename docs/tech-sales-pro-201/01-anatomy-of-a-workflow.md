# Video 1 — Anatomy of a Workflow

**Persona:** foundation (no persona; everything else builds on this)
**Workflow:** [`.github/workflows/demo-1-anatomy.yml`](../../.github/workflows/demo-1-anatomy.yml)
**Target runtime:** 3–4 minutes

**Goal:** after this video the viewer can open any workflow file in any repo and
say what each part does. That is the whole job. Resist the urge to teach more.

---

## [SCREEN] Repo home page, Code tab

Every GitHub repository can automate itself, and the automation lives in the
repository — same branch, same pull requests, same review as the application
code.

## [SCREEN] Navigate to `.github/workflows/`, show the file list

It lives here: a folder called `.github/workflows`. Every YAML file in this
folder is a workflow. GitHub picks them up automatically. There is nothing to
install and no server to point at this repo.

> Scroll the list briefly. A repo with many workflows sells the point better
> than a repo with one.

## [SCREEN] Open `demo-1-anatomy.yml`

Let's read one. This whole file is about seventy lines, and there are only five
things in it.

## [SCREEN] Highlight the `on:` block

First, the trigger. `on` answers *when*. This one runs when someone pushes, when
a pull request opens, and on a manual button. Workflows are event-driven — you
are not scheduling a job, you are reacting to something that happened in the
repository.

## [SCREEN] Highlight `permissions:`

Second, permissions. Every run gets a token automatically, and this block decides
what that token can touch. Here it is `contents: read` — this workflow can read
the code and nothing else. Start from read-only and add what you need. This is
the single most useful habit in Actions.

## [SCREEN] Highlight the `jobs:` key and the job name

Third, jobs. A job is a unit of work. A workflow can have one or many, they run
in parallel by default, and you make them wait for each other when you need to.

## [SCREEN] Highlight `runs-on:`

Fourth, the runner. `runs-on: ubuntu-latest` means GitHub gives me a fresh
virtual machine for this job. I did not provision it, I do not patch it, and
when the job finishes it is destroyed. We spend a whole video on runners later,
because this is where a lot of the value is.

## [SCREEN] Scroll through the numbered steps

And fifth, steps. Steps run in order on that machine. A step either runs a shell
command, or it uses an action — a reusable piece of automation, shared from
another repository.

## [SCREEN] Point at the `uses:` line

That is what `uses` means. This one checks out the code. There are thousands of
these on the Marketplace, and you can write your own.

## [SCREEN] Actions tab → the workflow → Run workflow → Run

So: trigger, permissions, job, runner, steps. Let's run it.

> Click through. Do not narrate the wait — cut it.

## [SCREEN] Open the running job, expand a step's live log

You get live logs, streaming, per step. Anyone with access to the repo can watch
this, which matters more than it sounds — build output stops being something
only one team can see.

## [SCREEN] Scroll to the job summary at the bottom

And a workflow can publish a summary — a rendered report attached to the run.
This one is showing the five parts we just read.

## [SCREEN] Back to the file

That is the anatomy. Trigger, permissions, job, runner, steps. Every workflow you
see from here on is a variation of this file.
