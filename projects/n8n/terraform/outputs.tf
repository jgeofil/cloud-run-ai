output "cloud_run_service_url" {
  description = "Public URL for the N8N Cloud Run service."
  value       = google_cloud_run_v2_service.n8n.uri
}

output "cloud_function_uri" {
  description = "URI endpoint for invoking the N8N Cloud Function."
  value       = google_cloudfunctions2_function.n8n.service_config[0].uri
}

output "service_account_email" {
  description = "Service account email used by the Cloud Run service."
  value       = google_service_account.n8n.email
}
