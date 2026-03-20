output "langflow_url" {
  description = "The URL of the Langflow service"
  value       = google_cloud_run_v2_service.langflow_run.uri
}

output "langflow_admin_password" {
  description = "The admin password for Langflow"
  value       = random_password.langflow_admin_password.result
  sensitive   = true
}

output "langflow_admin_username" {
  description = "The admin username for Langflow"
  value       = "admin"
}
