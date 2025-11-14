using './main.bicep'

// Required parameters
param publisherEmail = 'your-email@example.com'
param publisherName = 'Your Organization'
param githubOrg = 'octodemo'
param githubRepo = 'actions-playground'
param backendServiceUrl = 'https://your-private-service.internal'

// Optional parameters
param environment = 'dev'
param location = 'eastus'
param sku = 'Developer'
param skuCount = 1

// VNet integration (optional) - uncomment and configure if needed
// param vnetName = 'your-vnet-name'
// param subnetName = 'apim-subnet'
// param vnetResourceGroupName = 'your-vnet-rg'  // Optional, defaults to current RG
