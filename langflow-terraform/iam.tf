resource "google_service_account" "langflow_sa" {
  account_id   = "langflow-run-sacc"
  display_name = "Langflow Service Account"
}

# IAM bindings for Cloud SQL
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.langflow_sa.email}"
}

# Secret Access for Langflow secrets
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.langflow_db_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.langflow_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "admin_secret_accessor" {
  secret_id = google_secret_manager_secret.langflow_admin_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.langflow_sa.email}"
}
