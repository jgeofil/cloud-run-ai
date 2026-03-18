resource "google_cloud_run_v2_service" "n8n_run" {
  name     = "n8n-run"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.n8n_run_sa.email

    containers {
      image   = "n8nio/n8n:latest"
      command = ["/bin/sh"]
      args    = ["-c", "sleep 5; n8n start"]

      ports {
        container_port = 5678
      }

      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }
      env {
        name  = "DB_POSTGRESDB_HOST"
        value = "/cloudsql/${var.project_id}:${var.region}:${google_sql_database_instance.n8n_db_instance.name}"
      }
      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_POSTGRESDB_DATABASE"
        value = google_sql_database.n8n_db.name
      }
      env {
        name  = "DB_POSTGRESDB_USER"
        value = google_sql_user.n8n_user.name
      }
      env {
        name  = "DB_POSTGRESDB_SCHEMA"
        value = "public"
      }
      env {
        name  = "GENERIC_TIMEZONE"
        value = "UTC"
      }
      env {
        name  = "N8N_ENDPOINT_HEALTH"
        value = "health"
      }
      env {
        name  = "N8N_HEALTHCHECK_ENABLED"
        value = "true"
      }
      env {
        name  = "N8N_TEMPLATES_ENABLED"
        value = "true"
      }
      env {
        name  = "N8N_BASIC_AUTH_USER"
        value = var.n8n_basic_auth_user
      }
      env {
        name  = "N8N_EXTERNAL_STORAGE_MODE"
        value = "s3"
      }
      env {
        name  = "N8N_EXTERNAL_STORAGE_S3_BUCKET_NAME"
        value = google_storage_bucket.n8n_storage.name
      }
      env {
        name  = "N8N_EXTERNAL_STORAGE_S3_REGION"
        value = var.region
      }
      env {
        name  = "N8N_EXTERNAL_STORAGE_S3_ENDPOINT"
        value = "https://storage.googleapis.com"
      }
      env {
        name  = "N8N_EXTERNAL_STORAGE_S3_FORCE_PATH_STYLE"
        value = "true"
      }

      # Secrets
      env {
        name = "DB_POSTGRESDB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = "N8N_DB_PASSWORD"
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_ENCRYPTION_KEY"
        value_source {
          secret_key_ref {
            secret  = "N8N_ENCRYPTION_KEY"
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_BASIC_AUTH_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = "N8N_BASIC_AUTH_PASSWORD"
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_EXTERNAL_STORAGE_S3_ACCESS_KEY_ID"
        value_source {
          secret_key_ref {
            secret  = "N8N_S3_ACCESS_KEY"
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_EXTERNAL_STORAGE_S3_SECRET_ACCESS_KEY"
        value_source {
          secret_key_ref {
            secret  = "N8N_S3_SECRET_KEY"
            version = "latest"
          }
        }
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Allow public access to Cloud Run service
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.n8n_run.location
  name     = google_cloud_run_v2_service.n8n_run.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
