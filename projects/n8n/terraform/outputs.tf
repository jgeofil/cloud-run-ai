output "cloud_run_url" {
  description = "Deployed Cloud Run service URL."
  value       = google_cloud_run_v2_service.n8n.uri
}

output "function_uri" {
  description = "HTTPS trigger URL for the Cloud Function."
  value       = google_cloudfunctions2_function.n8n.service_config[0].uri
}
