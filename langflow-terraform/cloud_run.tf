resource "google_cloud_run_v2_service" "langflow_run" {
  name                = "langflow-run"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.langflow_sa.email
    timeout         = "300s" # Increased timeout for initial database migrations

    containers {
      image   = "langflowai/langflow:latest"
      
      ports {
        container_port = 7860
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "2Gi" # Langflow requires significant RAM to start
        }
      }

      env {
        name  = "LANGFLOW_HOST"
        value = "0.0.0.0"
      }

      env {
        name  = "LANGFLOW_PORT"
        value = "7860"
      }
      
      env {
        name  = "LANGFLOW_AUTO_LOGIN"
        value = "false"
      }

      env {
        name  = "LANGFLOW_SUPERUSER"
        value = var.langflow_admin_user
      }

      # SQLAlchemy Connection String using Unix Socket for Cloud SQL Auth Proxy
      # Format: postgresql+psycopg2://user:password@/dbname?host=/cloudsql/PROJECT:REGION:INSTANCE
      env {
        name  = "LANGFLOW_DATABASE_URL"
        value = "postgresql+psycopg2://${google_sql_user.langflow_user.name}:${random_password.langflow_db_password.result}@/${google_sql_database.langflow_db.name}?host=/cloudsql/${var.project_id}:${var.region}:${data.google_sql_database_instance.n8n_db_instance.name}"
      }

      env {
        name  = "LANGFLOW_DATABASE_CONNECTION_RETRY"
        value = "true"
      }

      env {
        name = "LANGFLOW_SUPERUSER_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.langflow_admin_password.secret_id
            version = "latest"
          }
        }
      }
    }

    # Connect the Cloud SQL instance using Cloud Run's native integration
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [data.google_sql_database_instance.n8n_db_instance.connection_name]
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
  location = google_cloud_run_v2_service.langflow_run.location
  name     = google_cloud_run_v2_service.langflow_run.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
