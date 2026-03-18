resource "google_sql_database_instance" "n8n_db_instance" {
  name             = "n8n-postgres-instance"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier = var.db_tier
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled = true # Public IP enabled for Auth Proxy connection
    }
  }
}

resource "google_sql_database" "n8n_db" {
  name     = "n8n-db-pg"
  instance = google_sql_database_instance.n8n_db_instance.name
}

resource "google_sql_user" "n8n_user" {
  name     = "n8n-db-pg"
  instance = google_sql_database_instance.n8n_db_instance.name
  password = data.google_secret_manager_secret_version.db_password.secret_data
}

# Fetching the password from existing secret manager
data "google_secret_manager_secret_version" "db_password" {
  secret  = "N8N_DB_PASSWORD"
  version = "latest"
}
