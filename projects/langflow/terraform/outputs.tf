output "cloud_run_service_url" {
  description = "Public URL for the Lang Flow Cloud Run service."
  value       = google_cloud_run_v2_service.langflow.uri
}

output "cloud_function_uri" {
  description = "URI endpoint for invoking the Lang Flow Cloud Function."
  value       = google_cloudfunctions2_function.langflow.service_config[0].uri
}

output "service_account_email" {
  description = "Service account email used by the Lang Flow Cloud Run service."
  value       = google_service_account.langflow.email
}
