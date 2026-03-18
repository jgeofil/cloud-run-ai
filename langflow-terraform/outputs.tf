output "langflow_url" {
  description = "The URL of the Langflow service"
  value       = google_cloud_run_v2_service.langflow_run.uri
}

output "langflow_db_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = data.google_sql_database_instance.n8n_db_instance.connection_name
}
