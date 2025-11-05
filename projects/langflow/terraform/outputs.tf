output "cloud_run_url" {
  description = "Deployed Cloud Run service URL for LangFlow."
  value       = google_cloud_run_v2_service.langflow.uri
}

output "function_uri" {
  description = "HTTPS trigger URL for the LangFlow Cloud Function."
  value       = google_cloudfunctions2_function.langflow.service_config[0].uri
}
