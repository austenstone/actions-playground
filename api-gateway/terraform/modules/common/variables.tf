variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "region" {
  description = "Cloud region for all resources"
  type        = string
}

variable "service_name" {
  description = "Service name for resource naming"
  type        = string
  default     = "github-actions-gateway"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "GitHub Actions OIDC Gateway"
}

variable "purpose" {
  description = "Purpose of the resources"
  type        = string
  default     = "GitHub Actions OIDC Gateway"
}

variable "cloud_provider" {
  description = "Cloud provider (azure, aws, gcp)"
  type        = string
  
  validation {
    condition     = contains(["azure", "aws", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be one of: azure, aws, gcp"
  }
}

variable "api_path" {
  description = "API path prefix"
  type        = string
  default     = "private"
}

variable "backend_service_url" {
  description = "Backend service URL (your private service)"
  type        = string
  sensitive   = true
}

variable "oidc_audience" {
  description = "OIDC token audience"
  type        = string
  default     = "api://ActionsOIDCGateway"
}

variable "tags" {
  description = "Additional tags to merge with common tags"
  type        = map(string)
  default     = {}
}
