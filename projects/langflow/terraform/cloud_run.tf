resource "google_cloud_run_v2_service" "langflow" {
  name     = "${var.environment}-langflow"
  location = var.region
  labels   = local.labels

  template {
    service_account = var.cloud_run_service_account

    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      image = var.cloud_run_image

      ports {
        container_port = 7860
      }

      resources {
        limits = {
          cpu    = var.cloud_run_cpu
          memory = var.cloud_run_memory
        }
      }

      dynamic "env" {
        for_each = var.cloud_run_env
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
}

data "google_iam_policy" "invoker" {
  binding {
    role    = "roles/run.invoker"
    members = var.invoker_members
  }
}

resource "google_cloud_run_service_iam_policy" "langflow" {
  location = google_cloud_run_v2_service.langflow.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.langflow.name

  policy_data = data.google_iam_policy.invoker.policy_data
}
