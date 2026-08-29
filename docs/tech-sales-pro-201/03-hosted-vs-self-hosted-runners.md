# Video 3 — Hosted vs. Self-Hosted Runners

**Personas:** Sandra (platform lead, owns the build infrastructure) and Blake
(DevOps, currently maintains it)
**Workflow:** [`.github/workflows/demo-3-hosted-runners.yml`](../../.github/workflows/demo-3-hosted-runners.yml)
**Target runtime:** 5–6 minutes

**This is the commercial centerpiece of the module.** Everything else teaches
Actions. This one explains what GitHub is actually selling, and where the money
goes. If you only have time to make one video excellent, make it this one.

**Goal:** the viewer leaves able to explain *who is responsible for what* under
each model, and able to name the specific costs a customer is already paying for
self-hosted without seeing them on an invoice.

> Tone: not a hard sell. Self-hosted is a legitimate choice with real reasons.
> The credibility comes from saying so, and then being precise about the trade.

---

## [SCREEN] Open `demo-3-hosted-runners.yml`

Every job in Actions runs on a runner. There are two kinds, and the choice
between them is one of the bigger decisions a platform team makes.

## [SCREEN] Highlight `runs-on: ubuntu-latest`

GitHub-hosted: GitHub owns the machine. You write a label, you get a VM.

## [SCREEN] Highlight the commented-out `runs-on: self-hosted` line

Self-hosted: you own the machine. You install the runner agent on your
infrastructure, it registers with GitHub, and jobs get sent to it.

Same YAML, same workflow syntax. The only thing that changes is who is holding
the machine.

## [SCREEN] Highlight the two `identity` jobs

Let's start with the property people underestimate. These two jobs are identical.
Both print the machine ID of the host they are running on.

## [SCREEN] Actions tab → run the workflow → open both identity jobs side by side

Different machines. Every job got a clean VM, and both of those VMs are gone now.

That is *ephemeral*, and it is a security property, not a convenience one. Nothing
leaks between jobs. A compromised build cannot poison the next one. There is no
long-lived box accumulating state, credentials, and other teams' artifacts.

> Pause here. This is the point self-hosted shops feel most, and rarely have an
> answer for.

## [SCREEN] Open the `preinstalled` job's log

The second thing you are buying is the image.

## [SCREEN] Scroll the toolchain versions

Node, Python, Java, Go, Docker, the AWS and Azure CLIs, GitHub CLI. Already there.
Nobody installed them, nobody keeps them current, and nobody gets paged when the
image drifts. GitHub maintains that image, publicly, and updates it continuously.

The equivalent on self-hosted is somebody's Packer template. That template is a
product now, and it has an owner, and it has a backlog.

## [SCREEN] Scroll to the responsibility matrix in the job summary

So here is the honest comparison.

## [SCREEN] Walk the matrix rows

Provisioning, patching, scaling, image maintenance, security isolation, capacity
planning. Under GitHub-hosted, that column is GitHub. Under self-hosted, that
column is Blake.

## [SCREEN] Stay on the matrix

None of those line items appear on a bill, which is exactly why self-hosted looks
cheap. The compute is cheap. The *ownership* is the cost, and it lands on the
platform team's roadmap as work that does not ship anything the business asked
for.

## [SCREEN] Settings → Actions → Runners

This is where you manage it. Runner groups, so you control which repositories can
target which machines.

## [SCREEN] Show the runner groups / hosted runners view

And you can mix. This is not all-or-nothing. Most large customers run
GitHub-hosted for the overwhelming majority of jobs, and keep self-hosted for the
narrow set that genuinely needs it.

## [SCREEN] Back to the workflow file

Which brings up the honest part: when *is* self-hosted right?

When the job needs something inside your network that cannot be reached from
outside. When you have hardware GitHub does not offer — GPUs, specific silicon,
a mainframe. When a regulator requires the compute to sit somewhere specific.

Those are real. They are also narrower than most estates assume. Teams often
discover that eighty or ninety percent of their jobs have no such requirement,
and are self-hosted for a reason nobody remembers.

## [SCREEN] Highlight `runs-on:` one more time

And when you do move them, the change is this line.

That is the whole migration for a job that had no special requirement. Which is
why this conversation is usually worth having.

---

## Recording notes

- Have **Settings → Actions → Runners** open in a second tab. Cutting to it
  right after the "who maintains this?" beat is what makes the point land.
