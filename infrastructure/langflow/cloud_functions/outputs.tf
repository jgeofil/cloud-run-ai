output "function_name" {
  description = "Deployed Cloud Function name"
  value       = google_cloudfunctions2_function.function.name
}

output "function_service_account" {
  description = "Service account used by the function"
  value       = var.service_account_email != "" ? var.service_account_email : google_service_account.function.email
}
