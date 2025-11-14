terraform {
  required_version = ">= 1.0"

  # This module uses only built-in functions and local values
  # No external providers required
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
