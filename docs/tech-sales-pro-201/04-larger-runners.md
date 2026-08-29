# Video 4 — Larger Runners for Faster Builds

**Persona:** Jordan, engineering manager. Does not care about YAML. Cares that
the team is waiting.
**Workflow:** [`.github/workflows/demo-4-larger-runners.yml`](../../.github/workflows/demo-4-larger-runners.yml)
**Target runtime:** 3–4 minutes

> **Film this one in `octodemo/actions-playground`.** Larger runners require an
> organization plan. On a personal account those labels queue forever — the
> workflow has a guard that skips the job outside `octodemo` so it fails fast
> instead of hanging.

> **Verify the per-minute rates before recording.** They are baked into the
> workflow's matrix and they change. Check the published
> [rate card](https://docs.github.com/billing/managing-billing-for-your-products/managing-billing-for-github-actions/about-billing-for-github-actions)
> and update the `per_min` values if they have moved. This is an external
> audience; a stale price is the one thing they will remember.

**Goal:** land the counter-intuitive point — a bigger, more expensive machine is
often *the same price per run* and always cheaper in engineering time.

---

## [SCREEN] Open `demo-4-larger-runners.yml`

The default GitHub-hosted runner is a two-core machine. It is fine for most
things, and it is not fine for a large build.

## [SCREEN] Highlight the matrix `include` block

You can ask for a bigger one. Four cores, eight, sixteen, thirty-two, sixty-four.
Same workflow, different label.

## [SCREEN] Highlight `runs-on: ${{ matrix.runner }}`

This workflow runs the identical job across all of them so we can compare.

## [SCREEN] Highlight the workload steps

The work is a fixed, parallelisable compression job — same input every time, and
it can actually use the cores it is given. That last part matters more than it
sounds. The first version of this demo capped itself at eight threads by accident,
and the thirty-two core runner came out no faster than the eight. A job that
cannot parallelise will not get faster on a bigger machine, and you should say so
before someone tries it and is disappointed.

## [SCREEN] Actions tab → the completed run → the job list with durations

Here is the result.

## [SCREEN] Walk down the durations

Eighty-five seconds on two cores. Nineteen on eight. Five on thirty-two.

## [SCREEN] Open the job summary with the time-and-cost table

Now the money. The rate card is sub-linear — a thirty-two core runner is sixteen
times the machine but not sixteen times the price — and the faster machines run
for fewer minutes, so the two effects push against each other.

## [SCREEN] Point at the cost column

A cent and a bit, two cents, eight cents. Seventeen times faster for about seven
cents more per run.

## [SCREEN] Stay on the table, point at the 32-core row

But look closely at that last row, because this is the part worth teaching. The
job took five seconds. It billed a full minute. GitHub rounds every job up to the
whole minute, so past a certain point you stop buying speed and start buying
rounding.

## [SCREEN] Point back at the 8-core row

Eight cores is the sweet spot here. Four and a half times faster for less than
double the cost. Thirty-two gets you fourteen more seconds and triples the bill.

So the honest recommendation is not "buy the biggest one." It is "measure, then
pick." The demo you just watched is the measurement, and it is one line of YAML
to run it against your own build.

## [SCREEN] Stay on the table

And when you do that comparison, the invoice is not the interesting number
anyway. Jordan's team is.

If a build goes from twenty minutes to six, every engineer waiting on it gets
fourteen minutes back, every time. Multiply by the number of pull requests per
day and the number of engineers. That number dwarfs the difference in the compute
line, and it is the number Jordan is actually managing.

## [SCREEN] Settings → Actions → Runners → New GitHub-hosted runner

Setting one up is this. Pick a size, pick an image, give it a label.

## [SCREEN] Show the runner creation form briefly

You can attach it to specific repositories, and you can put it behind a static IP
range if your network team needs that.

## [SCREEN] Back to the workflow file, `runs-on:` highlighted

Then in the workflow, it is one line.

No procurement, no capacity planning, no machine sitting idle overnight. You are
renting exactly the minutes you use.

---

## Recording notes

- **Film this in `octodemo/actions-playground`.** Larger runner labels require
  an organization on Team or above; on a personal account the jobs queue
  forever and never start.
- **Re-check the per-minute rates before recording.** They are hardcoded in the
  workflow matrix and they move. Source:
  [Actions runner pricing](https://docs.github.com/en/enterprise-cloud@latest/billing/reference/actions-runner-pricing).
