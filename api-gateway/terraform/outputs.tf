output "apim_service_name" {
  description = "The name of the API Management service"
  value       = azurerm_api_management.gateway.name
}

output "apim_gateway_url" {
  description = "The Gateway URL for API Management"
  value       = "https://${azurerm_api_management.gateway.gateway_url}/private"
}

output "apim_management_url" {
  description = "The Management URL for API Management"
  value       = "https://${azurerm_api_management.gateway.portal_url}"
}

output "apim_resource_id" {
  description = "The Resource ID of the API Management service"
  value       = azurerm_api_management.gateway.id
}

output "api_name" {
  description = "The name of the API"
  value       = azurerm_api_management_api.github_actions.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.apim.name
}
