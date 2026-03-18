resource "google_service_account" "n8n_run_sa" {
  account_id   = "n8n-run-sacc"
  display_name = "n8n Service Account"
}

# IAM bindings for Cloud SQL and Storage
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.n8n_run_sa.email}"
}

resource "google_storage_bucket_iam_member" "storage_admin" {
  bucket = google_storage_bucket.n8n_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.n8n_run_sa.email}"
}

# Secret Access for all required n8n secrets
locals {
  n8n_secrets = [
    "N8N_DB_PASSWORD",
    "N8N_ENCRYPTION_KEY",
    "N8N_BASIC_AUTH_PASSWORD",
    "N8N_S3_ACCESS_KEY",
    "N8N_S3_SECRET_KEY"
  ]
}

resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each  = toset(local.n8n_secrets)
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.n8n_run_sa.email}"
}
