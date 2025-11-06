output "run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.n8n.name
}

output "run_service_uri" {
  description = "Deployed Cloud Run service URI"
  value       = google_cloud_run_v2_service.n8n.uri
}

output "function_name" {
  description = "Name of the Cloud Function"
  value       = google_cloudfunctions2_function.n8n_webhook.name
}

output "function_uri" {
  description = "URI of the Cloud Function"
  value       = google_cloudfunctions2_function.n8n_webhook.service_config[0].uri
}

output "service_account_email" {
  description = "Service account used by runtime components"
  value       = google_service_account.n8n.email
}

