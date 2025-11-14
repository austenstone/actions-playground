output "github_org" {
  description = "GitHub organization name"
  value       = local.github_org
}

output "github_repo" {
  description = "GitHub repository name"
  value       = local.github_repo
}

output "name_prefix" {
  description = "Standardized name prefix for resources"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags to apply to all resources"
  value       = local.common_tags
}

output "github_oidc_issuer" {
  description = "GitHub OIDC issuer URL"
  value       = local.github_oidc_issuer
}

output "github_jwks_url" {
  description = "GitHub JWKS URL for token validation"
  value       = local.github_jwks_url
}

output "github_openid_config" {
  description = "GitHub OpenID configuration URL"
  value       = local.github_openid_config
}

output "repository_full_name" {
  description = "Full repository name (org/repo)"
  value       = local.repository_full_name
}

output "normalized_api_path" {
  description = "Normalized API path without leading/trailing slashes"
  value       = local.normalized_api_path
}

output "region" {
  description = "Cloud region for resources"
  value       = var.region
}

output "backend_service_url" {
  description = "Backend service URL"
  value       = var.backend_service_url
  sensitive   = true
}

output "oidc_audience" {
  description = "OIDC token audience"
  value       = var.oidc_audience
}

output "random_suffix" {
  description = "Random suffix for unique resource naming"
  value       = random_string.suffix.result
}
