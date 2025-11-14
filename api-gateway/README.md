# API Gateway for GitHub Actions OIDC

This directory contains Infrastructure as Code (IaC) for deploying an Azure API Management gateway that enables GitHub Actions workflows to securely access private network resources using OIDC authentication.

## 🎯 What Does This Do?

Instead of using self-hosted runners or storing long-lived credentials, this solution allows GitHub-hosted runners to authenticate to your private services using short-lived OIDC tokens.

```
GitHub Actions Runner (public)
    ↓ OIDC Token
Azure API Management (validates token, checks claims)
    ↓
Your Private Services (databases, internal APIs, etc.)
```

## 🏗️ Architecture

- **Azure API Management** - Validates GitHub OIDC tokens and routes requests
- **VNet Integration** (optional) - Connect APIM to your private network
- **No Code Gateway** - Uses native APIM policies for JWT validation

## 📦 What's Included

### Bicep Deployment
- `main.bicep` - Main infrastructure template
- `main.bicepparam` - Parameters file
- `deploy-bicep.sh` - Quick deployment script

### Terraform Deployment
- `terraform/main.tf` - Main infrastructure
- `terraform/variables.tf` - Variable definitions
- `terraform/outputs.tf` - Output values
- `terraform/terraform.tfvars.example` - Example configuration
- `deploy-terraform.sh` - Quick deployment script

### GitHub Actions
- `.github/workflows/api-gateway-example.yml` - Example workflow

## 🚀 Quick Start

### Prerequisites

- Azure CLI installed and logged in
- Either Bicep or Terraform installed
- GitHub repository with Actions enabled
- Azure subscription with permissions to create resources

### Option 1: Deploy with Bicep

1. **Update parameters:**
   ```bash
   cd api-gateway
   # Edit main.bicepparam with your values
   ```

2. **Deploy:**
   ```bash
   chmod +x deploy-bicep.sh
   ./deploy-bicep.sh
   ```

3. **⏰ Wait 30-45 minutes** for APIM to be provisioned

### Option 2: Deploy with Terraform

1. **Configure variables:**
   ```bash
   cd api-gateway/terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy:**
   ```bash
   cd ..
   chmod +x deploy-terraform.sh
   ./deploy-terraform.sh
   ```

3. **⏰ Wait 30-45 minutes** for APIM to be provisioned

## ⚙️ Configuration

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `publisherEmail` | Admin email for APIM | `admin@example.com` |
| `publisherName` | Organization name | `Your Company` |
| `githubOrg` | GitHub organization | `octodemo` |
| `githubRepo` | GitHub repository | `actions-playground` |
| `backendServiceUrl` | Your private service URL | `https://api.internal.com` |

### Optional Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `environment` | Environment name | `dev` |
| `location` | Azure region | `eastus` |
| `sku` | APIM pricing tier | `Developer` |
| `vnetName` | VNet name for integration | `""` (disabled) |
| `subnetName` | Subnet for APIM | `""` |

### SKU Options

- **Consumption** - Serverless, pay-per-call (~$0.035/10K calls)
- **Developer** - Dev/test only, $50/month, no SLA
- **Basic** - Production, $150/month, 99.95% SLA
- **Standard** - Production, $750/month, 99.95% SLA
- **Premium** - Enterprise, $2,700/month, 99.99% SLA, multi-region

💡 **Recommendation**: Start with **Developer** for testing, move to **Basic** for production.

## 🔐 Security Features

### OIDC Token Validation

The gateway validates:
- ✅ Token is from GitHub Actions
- ✅ Token has correct audience (`api://ActionsOIDCGateway`)
- ✅ Request comes from allowed repository
- ✅ Token signature is valid
- ✅ Token hasn't expired

### Claim Checking

Default policy only allows requests from your specified `org/repo`. The token includes claims like:

- `repository` - Full repo name (org/repo)
- `workflow` - Workflow name
- `ref` - Branch/tag reference
- `actor` - User who triggered the workflow
- `job_workflow_ref` - Reusable workflow reference

### Customizing Authorization

Edit the APIM policy to add more granular checks:

```xml
<required-claims>
  <!-- Only allow from specific repo -->
  <claim name="repository" match="all">
    <value>octodemo/actions-playground</value>
  </claim>
  
  <!-- Only allow from main branch -->
  <claim name="ref" match="all">
    <value>refs/heads/main</value>
  </claim>
  
  <!-- Only allow specific workflow -->
  <claim name="workflow" match="all">
    <value>Production Deploy</value>
  </claim>
</required-claims>
```

## 📝 Using in GitHub Actions

### 1. Set Repository Variable

After deployment, set the `APIM_GATEWAY_URL` variable:

```bash
gh variable set APIM_GATEWAY_URL --body "https://apim-xxx.azure-api.net/private"
```

Or in GitHub UI: **Settings → Secrets and variables → Actions → Variables**

### 2. Use in Workflow

```yaml
name: Access Private Service

on: [workflow_dispatch]

permissions:
  id-token: write  # Required!

jobs:
  call-api:
    runs-on: ubuntu-latest
    steps:
      - name: Get OIDC Token
        id: token
        run: |
          OIDC_TOKEN=$(curl -sS -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
            -H "Accept: application/json; api-version=2.0" \
            "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=api://ActionsOIDCGateway" | jq -r '.value')
          echo "::add-mask::$OIDC_TOKEN"
          echo "token=$OIDC_TOKEN" >> $GITHUB_OUTPUT

      - name: Call Private Service
        run: |
          curl -H "Authorization: Bearer ${{ steps.token.outputs.token }}" \
            ${{ vars.APIM_GATEWAY_URL }}/your-endpoint
```

### 3. Test It

Run the example workflow:
```bash
gh workflow run api-gateway-example.yml
```

## 🔍 Troubleshooting

### 401 Unauthorized

**Cause**: Token validation failed

**Check**:
1. `id-token: write` permission is set
2. Token audience matches (`api://ActionsOIDCGateway`)
3. Repository name in policy matches your repo
4. Token hasn't expired (10 minutes)

**Debug**:
```bash
# Decode token to see claims
echo "$OIDC_TOKEN" | cut -d'.' -f2 | base64 -d | jq '.'
```

### 404 Not Found

**Cause**: Wrong URL or path

**Check**:
1. Gateway URL includes `/private` path
2. API operation matches your request method (GET/POST)
3. APIM is fully provisioned

### 502 Bad Gateway

**Cause**: Backend service unreachable

**Check**:
1. Backend service URL is correct
2. APIM can reach the backend (VNet routing, firewall rules)
3. Backend service is running

### APIM Diagnostics

View logs in Azure Portal:
1. Navigate to your APIM instance
2. **APIs → Your API → Settings → Enable diagnostics**
3. View **Application Insights** for detailed logs

## 🌐 VNet Integration

To connect APIM to your private network:

### 1. Create a Subnet

Your VNet needs a dedicated subnet for APIM (minimum /27):

```bash
az network vnet subnet create \
  --resource-group your-rg \
  --vnet-name your-vnet \
  --name apim-subnet \
  --address-prefixes 10.0.2.0/27
```

### 2. Update Parameters

**Bicep** (`main.bicepparam`):
```bicep
param vnetName = 'your-vnet-name'
param subnetName = 'apim-subnet'
```

**Terraform** (`terraform.tfvars`):
```hcl
vnet_name                = "your-vnet-name"
subnet_name              = "apim-subnet"
vnet_resource_group_name = "your-vnet-rg"
```

### 3. Redeploy

```bash
./deploy-bicep.sh
# or
./deploy-terraform.sh
```

## 💰 Cost Estimation

**Monthly costs** (approximate):

| SKU | Price | Best For |
|-----|-------|----------|
| Consumption | ~$3.50 per million calls | Infrequent use |
| Developer | $50 | Testing (no SLA) |
| Basic | $150 | Small production workloads |
| Standard | $750 | Standard production |
| Premium | $2,700+ | Enterprise, multi-region |

**Plus**:
- VNet integration: No extra cost
- Bandwidth: ~$0.05/GB outbound
- Application Insights: ~$2.30/GB

💡 **Pro tip**: Use Developer tier for testing, then upgrade to Basic/Standard for production.

## 🎓 Learn More

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [GitHub OIDC Gateway Example](https://github.com/github/actions-oidc-gateway-example)
- [Azure API Management Documentation](https://docs.microsoft.com/azure/api-management/)
- [APIM JWT Validation Policy](https://docs.microsoft.com/azure/api-management/api-management-access-restriction-policies#ValidateJWT)

## 🆘 Support

- **Issues**: Open an issue in this repository
- **Questions**: Check existing issues or ask in Discussions
- **Azure Support**: Contact Azure support for APIM-specific issues

## 📜 License

This project is licensed under the MIT License.

---

**Built with ❤️ for secure GitHub Actions workflows**
