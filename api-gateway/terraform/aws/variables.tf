variable "aws_access_key_id" {
  description = "AWS Access Key ID (optional if using default credentials)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key (optional if using default credentials)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
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

variable "vpc_id" {
  description = "VPC ID for private backend (optional)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for VPC Link (optional)"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "Security Group ID for VPC Link (optional)"
  type        = string
  default     = ""
}
