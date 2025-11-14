variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "publisher_email" {
  description = "The email address of the owner of the service"
  type        = string
  
  validation {
    condition     = length(var.publisher_email) > 0
    error_message = "The publisher_email must contain at least one character."
  }
}

variable "publisher_name" {
  description = "The name of the owner of the service"
  type        = string
  
  validation {
    condition     = length(var.publisher_name) > 0
    error_message = "The publisher_name must contain at least one character."
  }
}

variable "resource_group_name" {
  description = "Optional: Name of the resource group (if empty, auto-generated)"
  type        = string
  default     = ""
}

variable "sku" {
  description = "The pricing tier of this API Management service"
  type        = string
  default     = "Developer"
  
  validation {
    condition     = contains(["Consumption", "Developer", "Basic", "BasicV2", "Standard", "StandardV2", "Premium", "PremiumV2"], var.sku)
    error_message = "SKU must be one of: Consumption, Developer, Basic, BasicV2, Standard, StandardV2, Premium, PremiumV2"
  }
}

variable "sku_count" {
  description = "The instance size of this API Management service"
  type        = number
  default     = 1
  
  validation {
    condition     = contains([1, 2], var.sku_count)
    error_message = "The sku_count must be one of the following: 1, 2."
  }
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "octodemo"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "actions-playground"
}

variable "backend_service_url" {
  description = "Backend service URL (your private service)"
  type        = string
  sensitive   = true
}

variable "vnet_name" {
  description = "Virtual Network Name (if using VNet integration)"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Subnet Name for APIM (if using VNet integration)"
  type        = string
  default     = ""
}

variable "vnet_resource_group_name" {
  description = "Resource group name where the VNet is located"
  type        = string
  default     = ""
}
