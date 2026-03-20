resource "google_service_account" "langflow_sa" {
  account_id   = "langflow-run-sacc"
  display_name = "Langflow Service Account"
}

# Allow Langflow to read/write to its GCS data bucket (for SQLite persistence)
resource "google_storage_bucket_iam_member" "langflow_gcs_admin" {
  bucket = google_storage_bucket.langflow_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.langflow_sa.email}"
}

# Secret Access for admin password
resource "google_secret_manager_secret_iam_member" "admin_secret_accessor" {
  secret_id = google_secret_manager_secret.langflow_admin_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.langflow_sa.email}"
}
