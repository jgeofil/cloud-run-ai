output "cloud_run_service_name" {
  description = "Deployed Cloud Run service name"
  value       = google_cloud_run_v2_service.service.name
}

output "cloud_run_uri" {
  description = "Public URL for the Cloud Run service"
  value       = google_cloud_run_v2_service.service.uri
}

output "service_account_email" {
  description = "Service account used by Cloud Run"
  value       = var.service_account_email != "" ? var.service_account_email : google_service_account.workload.email
}
