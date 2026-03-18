data "google_sql_database_instance" "n8n_db_instance" {
  name = "n8n-postgres-instance"
}

resource "google_sql_database" "langflow_db" {
  name     = "langflow"
  instance = data.google_sql_database_instance.n8n_db_instance.name
}

# Generate a random password for the Langflow database user
resource "random_password" "langflow_db_password" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "langflow_db_secret" {
  secret_id = "LANGFLOW_DB_PASSWORD"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "langflow_db_secret_version" {
  secret      = google_secret_manager_secret.langflow_db_secret.id
  secret_data = random_password.langflow_db_password.result
}

# New Secret for Admin User
resource "google_secret_manager_secret" "langflow_admin_password" {
  secret_id = "LANGFLOW_ADMIN_PASSWORD"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "langflow_admin_password_version" {
  secret      = google_secret_manager_secret.langflow_admin_password.id
  secret_data = random_password.langflow_db_password.result # Reusing for simplicity, or generate new
}

resource "google_sql_user" "langflow_user" {
  name     = "langflow"
  instance = data.google_sql_database_instance.n8n_db_instance.name
  password = random_password.langflow_db_password.result
}
