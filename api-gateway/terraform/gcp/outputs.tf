output "gateway_url" {
  description = "The Gateway URL for Cloud Run service"
  value       = var.use_api_gateway && length(google_api_gateway_gateway.gateway) > 0 ? google_api_gateway_gateway.gateway[0].default_hostname : "${google_cloud_run_service.gateway.status[0].url}/${module.common.normalized_api_path}"
}

output "cloud_run_url" {
  description = "The Cloud Run service URL"
  value       = google_cloud_run_service.gateway.status[0].url
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_service.gateway.name
}

output "service_account_email" {
  description = "The service account email for the gateway"
  value       = google_service_account.gateway.email
}

output "api_gateway_url" {
  description = "The API Gateway URL (if enabled)"
  value       = var.use_api_gateway && length(google_api_gateway_gateway.gateway) > 0 ? google_api_gateway_gateway.gateway[0].default_hostname : null
}
