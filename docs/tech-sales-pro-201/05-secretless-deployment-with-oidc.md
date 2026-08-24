# Video 5 — Secretless Deployment with OIDC

**Persona:** Priya, security. Her problem is not "can we deploy." It is "how many
long-lived cloud credentials are sitting in repositories right now, and who
rotates them."
**Workflow:** [`.github/workflows/demo-5-oidc.yml`](../../.github/workflows/demo-5-oidc.yml)
**Target runtime:** 4–5 minutes

**Goal:** the viewer understands that the credential is *gone*, not hidden. And
that the trust is bound to a specific repo, branch, and workflow — so stealing
the config gets you nothing.

> This is a Microsoft-adjacent audience. Lead with Entra ID / Azure as the
> example, and mention AWS and GCP once so it does not read as Azure-only.

---

## [SCREEN] Settings → Secrets and variables → Actions

Here is how deployment usually works. Someone generates a credential in the cloud
— a client secret, an access key — and pastes it in here.

## [SCREEN] Stay on the secrets list

It works. It is also a standing credential with a long life, stored outside the
system that issued it, valid from anywhere on the internet, and rotated only when
somebody remembers.

Priya's actual question is: how many of these exist across the estate, and what
would it take to rotate them all tomorrow.

## [SCREEN] Open `demo-5-oidc.yml`

There is a way to have none of them.

## [SCREEN] Highlight `permissions: id-token: write`

This line. It tells Actions this job is allowed to ask for an identity token.

## [SCREEN] Highlight the token request step

At runtime, the job asks GitHub's token service for a short-lived token, and
GitHub signs it. This is OpenID Connect — the same standard behind most modern
single sign-on.

## [SCREEN] Point at the decode step

We never print the token. We decode the payload and show the claims, because the
claims are the interesting part.

## [SCREEN] Actions tab → the completed run → expand the claims group

Here is what the cloud actually receives.

## [SCREEN] Walk the claims

`iss` — issued by GitHub, and the cloud can verify that signature independently.

`repository` — which repo.

`ref` — which branch.

`job_workflow_ref` — which workflow file.

`sub` — the subject, which combines those into one identity string.

## [SCREEN] Point at `exp`

And an expiry measured in minutes. By the time this video finishes, that token is
already dead.

## [SCREEN] Stay on the claims

Now the important consequence. On the cloud side, you configure trust *once*: an
Entra ID app registration with a federated credential that says "accept tokens
from GitHub where the subject is exactly this repo, this branch."

A fork produces a different `repository`. A different branch produces a different
`ref`. A different workflow produces a different `job_workflow_ref`. Any of those
and the `sub` no longer matches, and the cloud refuses.

## [SCREEN] Highlight the `deploy` job and `vars.AZURE_CLIENT_ID`

Which is why the deploy job here has no secret in it. It has a client ID and a
tenant ID — public identifiers, stored as variables, not secrets. There is
nothing here worth stealing.

## [SCREEN] Back to Settings → Secrets, showing the shorter list

So Priya's answer changes. There is no credential to rotate, no credential to
scan for, and no credential to leak — because there is no credential.

## [SCREEN] Back to the workflow file

This works the same way with AWS and with Google Cloud. Same token, same claims,
different trust configuration on the other side.

If a customer is deploying to any major cloud from Actions today with a stored
key, this is the highest-value change they can make, and it is usually an
afternoon.
