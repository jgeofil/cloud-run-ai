output "run_service_name" {
  description = "Name of the LangFlow Cloud Run service"
  value       = google_cloud_run_v2_service.langflow.name
}

output "run_service_uri" {
  description = "Deployed LangFlow Cloud Run service URI"
  value       = google_cloud_run_v2_service.langflow.uri
}

output "function_name" {
  description = "Name of the LangFlow Cloud Function"
  value       = google_cloudfunctions2_function.langflow_worker.name
}

output "function_uri" {
  description = "URI of the LangFlow Cloud Function"
  value       = google_cloudfunctions2_function.langflow_worker.service_config[0].uri
}

output "service_account_email" {
  description = "Service account used by LangFlow runtime components"
  value       = google_service_account.langflow.email
}

