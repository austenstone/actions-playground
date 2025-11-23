# SDLC Demo Workflow - Setup Instructions

This workflow demonstrates secure integration testing practices using GitHub Secrets for database credentials.

## Required GitHub Secrets

Before running this workflow, you need to create the following repository secrets:

### Secret Configuration

| Secret Name | Value | Description |
|------------|-------|-------------|
| `TEST_DB_USER` | `testuser` | PostgreSQL database username for integration tests |
| `TEST_DB_PASSWORD` | `testpass` | PostgreSQL database password for integration tests |
| `TEST_DB_NAME` | `testdb` | PostgreSQL database name for integration tests |

## How to Create Secrets

### Via GitHub Web UI

1. Navigate to your repository on GitHub
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the name and value from the table above
5. Click **Add secret**

### Via GitHub CLI

```bash
# Install GitHub CLI if not already installed
# https://cli.github.com/

# Authenticate
gh auth login

# Create the secrets
gh secret set TEST_DB_USER --body "testuser"
gh secret set TEST_DB_PASSWORD --body "testpass"
gh secret set TEST_DB_NAME --body "testdb"
```

### Via GitHub API

```bash
# Replace OWNER and REPO with your repository details
# Replace YOUR_TOKEN with a personal access token with repo scope

OWNER="austenstone"
REPO="actions-playground"
TOKEN="YOUR_TOKEN"

# Or using the same --body flag format for consistency
# Using GitHub API requires encrypting values with the repository's public key
# See: https://docs.github.com/en/rest/actions/secrets#create-or-update-a-repository-secret
# We recommend using GitHub CLI (gh) instead for easier secret management
```

## Security Benefits

This workflow demonstrates several security best practices:

1. **No Hardcoded Credentials**: Database credentials are not stored in the workflow file
2. **Secret Masking**: GitHub automatically masks secret values in workflow logs (displayed as ***)
3. **Minimal Permissions**: The workflow uses `permissions: contents: read` by default
4. **Secure Environment Variables**: Secrets are only exposed as environment variables in specific steps
5. **Production Ready**: This pattern is suitable for production workflows

## Workflow Structure

The workflow includes the following jobs:

- **build**: Builds the application and creates artifacts
- **test-unit**: Runs unit tests
- **test-integration**: Runs integration tests with PostgreSQL and Redis (uses secrets)
- **test-e2e**: Runs end-to-end tests
- **security-scan**: Performs security audits
- **deploy**: Deploys to staging (only on main branch)
- **summary**: Provides a summary of all test results

## Testing the Workflow

After creating the secrets:

1. Push changes to trigger the workflow
2. Navigate to **Actions** tab in your repository
3. Click on the running workflow
4. Verify that:
   - Secrets are masked in logs (shown as ***)
   - PostgreSQL connection is successful
   - Integration tests pass
   - No credential information is exposed

## For Demo Purposes

**Note**: For a demo repository like this one, hardcoded credentials in workflow files are acceptable. However, this workflow demonstrates the proper security practices that should be followed in production environments.

The values used (`testuser`, `testpass`, `testdb`) are:
- Only used for ephemeral test containers
- Never used for production databases
- Automatically destroyed after each workflow run
- Suitable for local development and CI/CD testing

## Troubleshooting

### Secrets Not Found Error

If you see an error like "Error: Process completed with exit code 1" related to database connection:

1. Verify all three secrets are created in repository settings
2. Check that secret names match exactly (case-sensitive)
3. Ensure the workflow has permission to access secrets
4. Check workflow logs for specific error messages (credentials will be masked)

### Database Connection Failed

If PostgreSQL connection fails:

1. Health checks ensure the database is ready before tests run
2. The workflow includes a "Wait for services" step
3. Check that the postgres image is accessible
4. Verify network connectivity in the runner

## References

- [GitHub Actions: Using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [GitHub Actions: Service containers](https://docs.github.com/en/actions/using-containerized-services)
- [GitHub Actions: Security hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
