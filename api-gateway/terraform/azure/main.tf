# Common module for shared values
module "common" {
  source = "../modules/common"
  
  environment         = var.environment
  region              = var.region
  cloud_provider      = "azure"
  backend_service_url = var.backend_service_url
  oidc_audience       = var.oidc_audience
}

# Resource Group
resource "azurerm_resource_group" "apim" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "rg-apim-${var.environment}-${module.common.random_suffix}"
  location = module.common.region
  
  tags = module.common.common_tags
}

# API Management Service
resource "azurerm_api_management" "gateway" {
  name                = "apim-${module.common.random_suffix}"
  location            = azurerm_resource_group.apim.location
  resource_group_name = azurerm_resource_group.apim.name
  publisher_name      = "GitHub Actions"
  publisher_email     = "noreply@github.com"

  sku_name = "${var.sku}_${var.sku_count}"

  virtual_network_type = var.vnet_name != "" ? "Internal" : "None"

  dynamic "virtual_network_configuration" {
    for_each = var.vnet_name != "" ? [1] : []
    content {
      subnet_id = data.azurerm_subnet.apim[0].id
    }
  }

  identity {
    type = "SystemAssigned"
  }
  
  tags = module.common.common_tags
}

# Data source for existing VNet (if using VNet integration)
data "azurerm_subnet" "apim" {
  count                = var.vnet_name != "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name != "" ? var.vnet_resource_group_name : azurerm_resource_group.apim.name
}

# API for GitHub Actions
resource "azurerm_api_management_api" "github_actions" {
  name                = "github-actions-api"
  resource_group_name = azurerm_resource_group.apim.name
  api_management_name = azurerm_api_management.gateway.name
  revision            = "1"
  display_name        = "GitHub Actions Private Access API"
  description         = "API Gateway for GitHub Actions to access private resources using OIDC authentication"
  path                = module.common.normalized_api_path
  protocols           = ["https"]
  subscription_required = false
}

# Backend for private service
resource "azurerm_api_management_backend" "private_service" {
  name                = "private-service-backend"
  resource_group_name = azurerm_resource_group.apim.name
  api_management_name = azurerm_api_management.gateway.name
  protocol            = "http"
  url                 = module.common.backend_service_url
  description         = "Private service backend"

  tls {
    validate_certificate_chain = true
    validate_certificate_name  = true
  }
}

# API Policy with OIDC validation
resource "azurerm_api_management_api_policy" "github_oidc" {
  api_name            = azurerm_api_management_api.github_actions.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.apim.name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <!-- Validate GitHub OIDC JWT Token -->
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Invalid or missing GitHub OIDC token.">
      <openid-config url="https://token.actions.githubusercontent.com/.well-known/openid-configuration" />
      <audiences>
        <audience>${module.common.oidc_audience}</audience>
      </audiences>
      <required-claims>
        <claim name="repository" match="all">
          <value>${module.common.repository_full_name}</value>
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
XML
}

# API Operation: GET
resource "azurerm_api_management_api_operation" "get_resource" {
  operation_id        = "get-resource"
  api_name            = azurerm_api_management_api.github_actions.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.apim.name
  display_name        = "Get Private Resource"
  method              = "GET"
  url_template        = "/*"
  description         = "Proxy GET requests to private service"
}

# API Operation: POST
resource "azurerm_api_management_api_operation" "post_resource" {
  operation_id        = "post-resource"
  api_name            = azurerm_api_management_api.github_actions.name
  api_management_name = azurerm_api_management.gateway.name
  resource_group_name = azurerm_resource_group.apim.name
  display_name        = "Post to Private Resource"
  method              = "POST"
  url_template        = "/*"
  description         = "Proxy POST requests to private service"
}
