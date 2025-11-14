locals {
  # GitHub Configuration
  github_org  = "octodemo"
  github_repo = "actions-playground"
  
  # Standardized naming conventions
  name_prefix = "${var.service_name}-${var.environment}"
  
  # Common tags that all resources should have
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = var.purpose
      Project     = var.project_name
    }
  )
  
  # GitHub OIDC configuration
  github_oidc_issuer = "https://token.actions.githubusercontent.com"
  github_jwks_url    = "${local.github_oidc_issuer}/.well-known/jwks"
  github_openid_config = "${local.github_oidc_issuer}/.well-known/openid-configuration"
  
  # Repository identifier
  repository_full_name = "${local.github_org}/${local.github_repo}"
  
  # API path standardization
  normalized_api_path = trimsuffix(trimprefix(var.api_path, "/"), "/")
}

# Random string for unique naming across all cloud providers
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  numeric = true
  special = false
  upper   = false
}
