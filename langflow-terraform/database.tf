# Langflow uses an embedded SQLite database stored on a GCS-backed volume.
# No external Cloud SQL instance is required.

# Admin passwordLangflow database URL secret
resource "google_secret_manager_secret" "langflow_admin_password" {
  secret_id = "LANGFLOW_ADMIN_PASSWORD"
  replication {
    auto {}
  }
}

resource "random_password" "langflow_admin_password" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret_version" "langflow_admin_password_version" {
  secret      = google_secret_manager_secret.langflow_admin_password.id
  secret_data = random_password.langflow_admin_password.result
}
