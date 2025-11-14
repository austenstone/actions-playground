variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-central1"
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

variable "gateway_image" {
  description = "Container image for the OIDC gateway proxy"
  type        = string
  default     = "gcr.io/cloudrun/hello" # Placeholder - need to build actual gateway image
}

variable "use_api_gateway" {
  description = "Whether to use API Gateway (vs direct Cloud Run)"
  type        = bool
  default     = false
}

variable "vpc_network" {
  description = "VPC network name for private backend (optional)"
  type        = string
  default     = ""
}

variable "vpc_connector_cidr" {
  description = "CIDR range for VPC connector (e.g., 10.8.0.0/28)"
  type        = string
  default     = "10.8.0.0/28"
}
