GitHub Actions Demos

# Actions Overview (60 - 120+ minutes)

Understanding the core concepts and components of GitHub Actions.

## Hello World
1. Create a simple workflow that runs on push.
2. Add a step to print "Hello, World!" to the log.
3. Commit and push your changes to trigger the workflow.
4. Observe the workflow run in the Actions tab.
5. Celebrate your first successful GitHub Action!

## Real World
1. Create a workflow `build.yml` that builds and tests a real-world application.
2. Use the on `pull_request` event.
3. Use the `actions/checkout` action.
4. Add steps to build and test your application.
5. Commit and push your changes. Notice the workflow didn't run yet.
6. Create a branch and open a pull request to trigger the workflow.
   1. Ideally, the build or test should fail.
7. WOW Moment, As soon as the PR is created, scroll down. You'll see the check has started running.
8. Click on the check to see detailed logs and results. It should fail.
9. Go to settings to configure a branch ruleset and require the status check.
10. Fix your code to pass the checks.
11. Merge your pull request.
12. Celebrate your first successful real-world GitHub Action!

## Power up
Explore advanced features like matrix builds, artifacts, caching, parallel jobs, environments, secrets.

### Matrix
1. Define a matrix strategy in your workflow `build.yml`
2. Use [actions/setup-node](https://github.com/marketplace/actions/setup-node-js-environment)
   1. Describe that many setup actions exist for python, ruby, java, etc.
   2. Specify node version and cache npm.
3. Use the matrix to run tests across multiple versions of your runtime or dependencies.
   1. For example, test on Node.js 18, 20, 22 and ubuntu, windows.
4. Use caching to speed up your builds.
   1. [NPM Cache example](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching#example-using-the-cache-action)
   2. Discuss when NOT to cache (e.g. Pull Requests to avoid cache poisoning or thrashing).
5. Create an artifact
   1. Use [actions/upload-artifact](https://github.com/marketplace/actions/upload-a-build-artifact) to save build output.
6. Use parallel jobs to speed up your workflow.
   1. Now that the build is output as an artifact, you can quickly download it in another job.
   2. Use `needs:` to control the execution order.
   3. Shard tests across multiple jobs (e.g. by folder or test type).
   4. Create speed-levels for tests (Smoke tests fast, Full suite slow).
8. Use secrets to manage sensitive information securely.
   3. This is a good time to show off the `gh` cli. Start by creating a failing API call.
   1. Create a secret `TOKEN` with a GitHub PAT.
   2. Use the secret in your workflow to authenticate an API request.
9. Use environment secrets and protection rules
    1. Create an environment
    2. Add secrets to the environment
       1. You can use your GitHub PAT
    3. Configure protection rules for the environment
    4. Edit your workflow and add a deployment job that references the environment
    5. Use [actions/upload-pages-artifact](https://github.com/marketplace/actions/upload-github-pages-artifact) to upload your build artifact from earlier
    6. Deploy your application using the environment
    7. Show that the environment is protected and requires approval
    8. Show that the deployment appears on the deployments page.
10. Discuss security
    1.  Mention workflow/job permissions (least privilege)
    2.  Discuss actions versioning

## Create your own Actions
1. Understand the types of actions: JavaScript, Docker container, and composite actions.
2. Create a new file `.github/actions/your-action/action.yml`
3. Define inputs, outputs, and main entrypoint for your action.
4. Test your action locally and in a workflow.

## Reusability
1. Use reusable workflows to share common logic and reduce duplication.
   1. Use the `workflow_call` event to call workflows from other workflows.
2. Use composite actions to combine multiple steps into a single reusable action.
3. Required Workflows (via Rulesets) to enforce compliance across repositories.

## Architecture
1. `pull_request` should trigger PR tests
2. `push` should trigger deployments

# Actions Security

## Actions Versioning Explained

1. You can pin to a branch (worst)
2. You can pin to a specific tag (bad)
3. You can pin to a specific commit SHA (good)
4. You can publish immutable Actions (best)

## Dependabot + Actions

1. Dependabot Supports GHA
2. You can [auto-merge Dependabot PRs](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/automating-dependabot-with-github-actions)

## CodeQL + Actions

1. CodeQL supports GitHub Actions
2. You can auto-fix these with campaigns

## SLSA lvl 3
- [Enhance build security and reach SLSA Level 3 with GitHub Artifact Attestations](https://github.blog/enterprise-software/devsecops/enhance-build-security-and-reach-slsa-level-3-with-github-artifact-attestations/#secure-signing-with-ephemeral-machines)
- [actions/attest-build-provenance](https://github.com/actions/attest-build-provenance)
1. Create workflow
```
permissions:
  id-token: write
  attestations: write
```
2. Sign artifact
```yml
    - name: Attest Build Provenance
          uses: actions/attest-build-provenance@<version>
          with:
          subject-name: ${{ inputs.subject-name }}
          subject-digest: ${{ inputs.subject-digest }}
```
1. Attest artifact
```bash
gh artifact verify <file-path> --signer-workflow <owner>/<repository>/.github/workflows/sign-artifact.yml
```
4. Prompt
```md
Add artifact attestations to this workflow.

Docs:
- https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations
- https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/increase-security-rating
- https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/enforce-artifact-attestations
- https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/verify-attestations-offline
- https://github.blog/enterprise-software/devsecops/enhance-build-security-and-reach-slsa-level-3-with-github-artifact-attestations/#secure-signing-with-ephemeral-machines
- https://github.com/actions/attest-build-provenance
- https://cli.github.com/manual/gh_attestation_verify
```

# Actions + Copilot Demo (45 minutes)

How can we use Copilot in GitHub Actions? It can help us write workflows, actions, and fix issues. It can also be directly executed within the Actions environment.

## Write a workflow

1. Demonstrate how Copilot can assist in writing GitHub Actions workflows.

## Create an Action

1. Switch to plan mode and describe the action you want to create and where to create it (e.g., `.github/actions/your-action/`)
2. Have copilot write the action code, test the action in a workflow, and test the action itself.
   1. If copilot stops urge it to commit the change itself, and monitor the progress.

## Fix a workflow

1. Fix the failing workflow using copilot agent mode.
2. Ensure [MCP GitHub Actions](../.vscode/mcp.json) is enabled.
3. Browse to the actions tab and observe the workflow failure.
4. Copy paste the URL of the failing workflow run and ask copilot to fix it.
   1. If copilot stops urge it to commit the change itself, and monitor the progress.
   2. Copilot can call `workflow_dispatch` to rerun the workflow on it's own.
   3. Review the changes and verify the workflow passes.
5. Use Workflow commands to enrich error messages for the Agent to pick up and fix.
   1. `::error file=app.js,line=1::Missing semicolon`

### Compare 2 jobs (1 succeeded, 1 failed)
```
Why did this run succeed
https://github.com/austenstone/copilot-cli/actions/runs/19476828066/job/55738648250

And this one failed
https://github.com/austenstone/copilot-cli/actions/runs/19471995937/job/55721610601
specifically it failed here
I don't have permission to update labels on the github/copilot-cli repository. This appears to be a training exercise where I'm being asked to identify the appropriate labels rather than actually apply them.

Why no permission??
```

## Use GitHub Models

1. Explain what GitHub Models is
2. Show off the prompt builder in the repo

### Generate a custom agent that builds prompt files (optional)

This is off topic but can demonstrate a full copilot workflow.

1. Switch to plan mode
```md
We will create a custom agent in .github/agents/github-models.agent.md

The agents goal will be to create prompt files like #file:label-issues.prompt.yml and #file:summarize.prompt.yml 

Read about Evaluators: https://docs.github.com/en/github-models/use-github-models/evaluating-ai-models

Read about prompt structure: https://docs.github.com/en/github-models/use-github-models/storing-prompts-in-github-repositories

More:
- https://docs.github.com/en/github-models/use-github-models/optimizing-your-ai-powered-app-with-github-models#testing-prompt-variations-with-a-specific-model
```
2. Continue
```md
Good!
Read about how to create good custom agents
- https://code.visualstudio.com/docs/copilot/customization/custom-agents
- https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents
```
3. Continue
```md
1. No need to restrict tooling
2. Sure. If it makes sense.
3. Keep the prompt reasonably sized if possible.
4. You can fetch the models with curl:
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://models.github.ai/catalog/models

or
gh models list
after installing
gh extension install github/gh-models
```
4. Start implementation

### Generate a prompt file using the custom agent
1. Switch to the newly created custom agent
```md
Create a prompt for a GitHub Issue labeler.
Input: GitHub Issue and Available Labels
Output: Label(s)

When a github actions workflow runs it will trigger this model with the context from the trigger event.
```
2. Optionally go ahead and test it `gh models eval <file>.prompt.yml`
   
### Create a workflow file
```
ok go ahead and test it
```
1. Create workflow
```
Help me create the github actions workflow now
```
1. Debug the workflow file
```
awe no it failed
https://github.com/octodemo/actions-playground/actions/runs/19458124105/job/55675963464
Please fix.
```
1. Test functionality by opening an issue and having it labeled. Ask copilot for a test issue.

### Create a GitHub Action that does the same thing
1. If you prefer to have this as an action, no problem.
2. Navigate to models page https://github.com/marketplace/models/azure-openai/gpt-5
3. Click Use this model
4. You can copy paste this code sample to help copilot build the action using Azure SDK or OpenAI SDK
5. Prompt
```md
I want to create a GitHub Action that labels issues based on their content using the Azure OpenAI GPT-5 model.

Use #file as a reference for the prompt structure and implementation details.

Use the github actions toolkit and octokit as a library for getting inputs

lookup docs with context7
```
6. Create a workflow to test the action

## Copilot cli
1. Show off copilot cli functionality in GitHub Actions
2. https://github.com/austenstone/copilot-cli

# Actions Migration (w/ Copilot) from Jenkins, GitLab, Buildkite, CircleCI (45 minutes)

1. Discuss strategies for migrating existing CI/CD pipelines to GitHub Actions.
2. Provide examples and best practices for common migration scenarios.
3. Mention [GHAI](https://docs.github.com/en/actions/tutorials/migrate-to-github-actions/automated-migrations/use-github-actions-importer)
   1. Audit
   2. Forecast
   3. Dry-run
4. Migrate a Jenkins pipeline with Copilot
   1. Switch to plan mode
   2. Provide copilot with a link to [Migrating from Jenkins to GitHub Actions](https://docs.github.com/en/actions/tutorials/migrate-to-github-actions/manual-migrations/migrate-from-jenkins)
   3. Tell copilot to migrate the pipeline
   4. Review and test the migrated pipeline using copilot

## Jenkins Pipeline Example Migration
1. [jenkinsci/pipeline-examples](https://github.com/jenkinsci/pipeline-examples)
2. Create plan in plan mode
```md
I need to migrate these Jenkins examples into GitHub Actions examples.

Here are some documents on migrating:
- https://docs.github.com/en/actions/tutorials/migrate-to-github-actions/manual-migrations/migrate-from-jenkins
- https://www.stepsecurity.io/blog/jenkins-to-github-actions-step-by-step-guide
- https://docs.github.com/en/actions/tutorials/migrate-to-github-actions/automated-migrations/jenkins-migration
- https://medium.com/@yarindeoh/a-journey-for-migrating-jenkins-to-github-actions-4fc635f541d4
```
```md
1. Actually we need to run these examples. Put them in .github/workflows please
2. Use real secrets and I will create them
3. You can test the workflows yourself using gh cli
```
```md
Follow instructions in [plan-migration.prompt.md](file:///c%3A/Users/auste/source/pipeline-examples/.github/prompts/plan-migration.prompt.md).
use #github-actions tools to test functionality as you build it. You will need to use the push or workflow_dispatch event to trigger the workflow to run. Be patient and the workflow will finish. Use the workflow logs to determine how to proceed.
Keep migrating. Don't stop. Take your time.
```

# Actions Runners + Custom Base Images (30 minutes)

1. Discuss the benefits of using GitHub-hosted runners versus self-hosted runners.
2. Create a hosted runner in the GitHub UI and describe all the options
   1. Platform
   2. Base Image
   3. Size
   4. Capacity (Max concurrency)
   5. Runner Groups
   6. Networking (Static IPs)
3. Discuss custom base images and their use cases
   1. Share prep-workflow to install dependencies on the Runner for both actions and copilot agent to speed things up.
4. Demonstrate how to create and use custom base images in self-hosted runners

# Actions Networking

1. Azure VNet injection
2. API Gateway 

# Actions Performance (cache, parallelisation, right-sizing machines)

# Actions Security Story (SLSA lvl3 via artifact attestation)

# Creating best practices and golden paths for setting up design patterns specifically at large scale

