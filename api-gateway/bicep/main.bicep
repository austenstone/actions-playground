// Azure API Management Gateway for GitHub Actions OIDC
// This deploys an API Management instance that validates GitHub OIDC tokens
// and routes traffic to private network resources

@description('Environment name (dev, staging, prod)')
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('The name of the API Management service instance')
param apimServiceName string = 'apim-actions-gateway-${environment}-${uniqueString(resourceGroup().id)}'

@description('The pricing tier of this API Management service')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
param skuCount int = 1

@description('GitHub organization name')
param githubOrg string

@description('GitHub repository name')
param githubRepo string

@description('Virtual Network Name (if using VNet integration)')
param vnetName string = ''

@description('Subnet Name for APIM (if using VNet integration)')
param subnetName string = ''

@description('Resource group name where VNet is located (if different from current)')
param vnetResourceGroupName string = resourceGroup().name

@description('Backend service URL (your private service)')
@secure()
param backendServiceUrl string

// Reference existing subnet if VNet integration is enabled
resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = if (!empty(vnetName)) {
  scope: resourceGroup(vnetResourceGroupName)
  name: '${vnetName}/${subnetName}'
}

// API Management Service
resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apimServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    virtualNetworkType: !empty(vnetName) ? 'Internal' : 'None'
    virtualNetworkConfiguration: !empty(vnetName) ? {
      subnetResourceId: existingSubnet.id
    } : null
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// API for GitHub Actions
resource api 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'github-actions-api'
  properties: {
    displayName: 'GitHub Actions Private Access API'
    description: 'API Gateway for GitHub Actions to access private resources using OIDC authentication'
    path: 'private'
    protocols: [
      'https'
    ]
    subscriptionRequired: false
    isCurrent: true
  }
}

// Backend service pointing to your private resource
resource backend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagementService
  name: 'private-service-backend'
  properties: {
    description: 'Private service backend'
    url: backendServiceUrl
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

// Global policy with OIDC validation
resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: api
  name: 'policy'
  properties: {
    value: '''
      <policies>
        <inbound>
          <base />
          <!-- Validate GitHub OIDC JWT Token -->
          <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Invalid or missing GitHub OIDC token.">
            <openid-config url="https://token.actions.githubusercontent.com/.well-known/openid-configuration" />
            <audiences>
              <audience>api://ActionsOIDCGateway</audience>
            </audiences>
            <required-claims>
              <claim name="repository" match="all">
                <value>${githubOrg}/${githubRepo}</value>
              </claim>
            </required-claims>
          </validate-jwt>
          
          <!-- Optional: Extract and log claims for debugging -->
          <set-variable name="workflow" value="@(context.Request.Headers.GetValueOrDefault("Authorization","").Split(' ')[1].AsJwt()?.Claims.GetValueOrDefault("workflow", "unknown"))" />
          <set-variable name="ref" value="@(context.Request.Headers.GetValueOrDefault("Authorization","").Split(' ')[1].AsJwt()?.Claims.GetValueOrDefault("ref", "unknown"))" />
          
          <!-- Set backend service -->
          <set-backend-service backend-id="private-service-backend" />
        </inbound>
        <backend>
          <base />
        </backend>
        <outbound>
          <base />
        </outbound>
        <on-error>
          <base />
        </on-error>
      </policies>
    '''
  }
}

// Example operation: GET request to backend
resource apiOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: api
  name: 'get-resource'
  properties: {
    displayName: 'Get Private Resource'
    method: 'GET'
    urlTemplate: '/*'
    description: 'Proxy GET requests to private service'
  }
}

// Example operation: POST request to backend
resource apiOperationPost 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: api
  name: 'post-resource'
  properties: {
    displayName: 'Post to Private Resource'
    method: 'POST'
    urlTemplate: '/*'
    description: 'Proxy POST requests to private service'
  }
}

// Outputs
output apimServiceName string = apiManagementService.name
output apimGatewayUrl string = 'https://${apiManagementService.properties.gatewayUrl}/private'
output apimManagementUrl string = 'https://${apiManagementService.properties.portalUrl}'
output apimResourceId string = apiManagementService.id
output apiName string = api.name
