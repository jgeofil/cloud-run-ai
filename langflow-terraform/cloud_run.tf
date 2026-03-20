resource "google_cloud_run_v2_service" "langflow_run" {
  name                = "langflow-run"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.langflow_sa.email
    timeout         = "300s"

    containers {
      image = "langflowai/langflow:latest"

      ports {
        container_port = 7860
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "2Gi"
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

      # Use embedded SQLite stored on the GCS-backed persistent volume
      env {
        name  = "LANGFLOW_DATABASE_URL"
        value = "sqlite:////app/data/langflow.db"
      }

      env {
        name  = "LANGFLOW_CONFIG_DIR"
        value = "/app/data"
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

      # Mount the GCS bucket at /app/data for persistent SQLite storage
      volume_mounts {
        name       = "langflow-data"
        mount_path = "/app/data"
      }
    }

    # GCS volume for persistent SQLite storage
    volumes {
      name = "langflow-data"
      gcs {
        bucket    = google_storage_bucket.langflow_data.name
        read_only = false
      }
    }

    scaling {
      # SQLite supports only one writer at a time — keep to 1 instance
      max_instance_count = 1
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
