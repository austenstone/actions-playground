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
5. Create an artifact
   1. Use [actions/upload-artifact](https://github.com/marketplace/actions/upload-a-build-artifact) to save build output.
6. Use parallel jobs to speed up your workflow.
   1. Now that the build is output as an artifact, you can quickly download it in another job.
   2. Use `needs:` to control the execution order.
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

## Architecture
1. `pull_request` should trigger PR tests
2. `push` should trigger deployments

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
```
ok go ahead and test it
```
3. Create workflow
```
Help me create the github actions workflow now
```
4. Debug the workflow file
```
awe no it failed
https://github.com/octodemo/actions-playground/actions/runs/19458124105/job/55675963464
Please fix.
```
5. Test functionality by opening an issue and having it labeled. Ask copilot for a test issue.

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
4. Demonstrate how to create and use custom base images in self-hosted runners

# Actions Networking

1. Azure VNet injection
2. API Gateway 

# Actions Performance (cache, parallelisation, right-sizing machines)

# Actions Security Story (SLSA lvl3 via artifact attestation)

# Creating best practices and golden paths for setting up design patterns specifically at large scale

