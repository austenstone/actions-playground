#!/bin/bash
# Quick deployment script for Bicep

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying Azure API Management Gateway for GitHub Actions${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Logging in...${NC}"
    az login
fi

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-apim-actions-gateway-dev}"
LOCATION="${LOCATION:-eastus}"
DEPLOYMENT_NAME="apim-gateway-$(date +%Y%m%d-%H%M%S)"

echo ""
echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  Deployment Name: $DEPLOYMENT_NAME"
echo ""

# Create resource group if it doesn't exist
echo -e "${GREEN}📦 Creating resource group...${NC}"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table

echo ""
echo -e "${GREEN}🏗️  Deploying API Management...${NC}"
echo -e "${YELLOW}⏰ This will take 30-45 minutes for a new APIM instance...${NC}"

# Deploy using bicep
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --output table

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"

# Get outputs
echo ""
echo -e "${GREEN}📊 Getting deployment outputs...${NC}"
GATEWAY_URL=$(az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --query properties.outputs.apimGatewayUrl.value \
  --output tsv)

MANAGEMENT_URL=$(az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$DEPLOYMENT_NAME" \
  --query properties.outputs.apimManagementUrl.value \
  --output tsv)

echo ""
echo -e "${GREEN}🎉 Success! Your API Gateway is ready:${NC}"
echo ""
echo -e "  Gateway URL: ${YELLOW}$GATEWAY_URL${NC}"
echo -e "  Management Portal: ${YELLOW}$MANAGEMENT_URL${NC}"
echo ""
echo -e "${GREEN}📝 Next steps:${NC}"
echo "  1. Set APIM_GATEWAY_URL as a repository variable in GitHub"
echo "  2. Update the backend service URL in the parameters"
echo "  3. Run the api-gateway-example workflow"
echo ""
