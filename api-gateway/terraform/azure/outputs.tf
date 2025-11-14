output "service_name" {
  description = "The name of the API Management service"
  value       = azurerm_api_management.gateway.name
}

output "gateway_url" {
  description = "The Gateway URL for API Management"
  value       = "https://${azurerm_api_management.gateway.gateway_url}/${module.common.normalized_api_path}"
}

output "management_url" {
  description = "The Management URL for API Management"
  value       = "https://${azurerm_api_management.gateway.portal_url}"
}

output "resource_id" {
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

output "public_ip" {
  description = "The public IP address of the API Management service"
  value       = azurerm_api_management.gateway.public_ip_addresses
}
