output "n8n_url" {
  description = "The URL of the n8n service"
  value       = google_cloud_run_v2_service.n8n_run.uri
}

output "storage_bucket" {
  description = "The name of the storage bucket"
  value       = google_storage_bucket.n8n_storage.name
}

output "service_account_email" {
  description = "The email of the n8n service account"
  value       = google_service_account.n8n_run_sa.email
}
