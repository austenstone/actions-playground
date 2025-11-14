# Common module for shared values
module "common" {
  source = "../modules/common"
  
  environment         = var.environment
  region              = var.region
  cloud_provider      = "gcp"
  backend_service_url = var.backend_service_url
  oidc_audience       = var.oidc_audience
}

# Cloud Run Service for OIDC Validation Proxy
resource "google_cloud_run_service" "gateway" {
  name     = "github-actions-gateway-${var.environment}-${module.common.random_suffix}"
  location = module.common.region

  template {
    spec {
      containers {
        image = var.gateway_image
        
        env {
          name  = "GITHUB_ORG"
          value = module.common.github_org
        }
        
        env {
          name  = "GITHUB_REPO"
          value = module.common.github_repo
        }
        
        env {
          name  = "OIDC_AUDIENCE"
          value = var.oidc_audience
        }
        
        env {
          name  = "BACKEND_SERVICE_URL"
          value = var.backend_service_url
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
      
      service_account_name = google_service_account.gateway.email
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10"
        "autoscaling.knative.dev/minScale" = "1"
      }
      labels = module.common.common_tags
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    labels = module.common.common_tags
  }
}

# Service Account for Cloud Run
resource "google_service_account" "gateway" {
  account_id   = "github-gateway-${var.environment}-${module.common.random_suffix}"
  display_name = "GitHub Actions OIDC Gateway Service Account"
  description  = "Service account for GitHub Actions OIDC Gateway Cloud Run service"
}

# Allow unauthenticated access to Cloud Run (OIDC auth handled in app)
resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.gateway.name
  location = google_cloud_run_service.gateway.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# API Gateway (optional, for more advanced routing)
resource "google_api_gateway_api" "gateway" {
  count        = var.use_api_gateway ? 1 : 0
  provider     = google-beta
  api_id       = "github-actions-api-${var.environment}-${module.common.random_suffix}"
  display_name = "GitHub Actions OIDC Gateway API"
}

# API Gateway Config
resource "google_api_gateway_api_config" "gateway" {
  count        = var.use_api_gateway ? 1 : 0
  provider     = google-beta
  api          = google_api_gateway_api.gateway[0].api_id
  api_config_id = "config-${module.common.random_suffix}"
  display_name = "Gateway Config"

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = base64encode(templatefile("${path.module}/openapi.yaml", {
        cloud_run_url = google_cloud_run_service.gateway.status[0].url
        api_path      = module.common.normalized_api_path
      }))
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Gateway
resource "google_api_gateway_gateway" "gateway" {
  count        = var.use_api_gateway ? 1 : 0
  provider     = google-beta
  gateway_id   = "github-gateway-${var.environment}-${module.common.random_suffix}"
  api_config   = google_api_gateway_api_config.gateway[0].id
  region       = module.common.region
  display_name = "GitHub Actions OIDC Gateway"

  labels = module.common.common_tags
}

# Serverless VPC Connector (for private backend)
resource "google_vpc_access_connector" "connector" {
  count         = var.vpc_network != "" ? 1 : 0
  name          = "github-gateway-${var.environment}-${module.common.random_suffix}"
  region        = module.common.region
  network       = var.vpc_network
  ip_cidr_range = var.vpc_connector_cidr
  min_instances = 2
  max_instances = 3
}

# Update Cloud Run with VPC connector if specified
resource "google_cloud_run_service" "gateway_with_vpc" {
  count    = var.vpc_network != "" ? 1 : 0
  name     = google_cloud_run_service.gateway.name
  location = module.common.region

  template {
    spec {
      containers {
        image = var.gateway_image
        
        env {
          name  = "GITHUB_ORG"
          value = module.common.github_org
        }
        
        env {
          name  = "GITHUB_REPO"
          value = module.common.github_repo
        }
        
        env {
          name  = "OIDC_AUDIENCE"
          value = module.common.oidc_audience
        }
        
        env {
          name  = "BACKEND_SERVICE_URL"
          value = module.common.backend_service_url
        }
      }
      
      service_account_name = google_service_account.gateway.email
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "10"
        "autoscaling.knative.dev/minScale"      = "1"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector[0].id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_cloud_run_service.gateway]
}
