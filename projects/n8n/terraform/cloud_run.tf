resource "google_cloud_run_v2_service" "n8n" {
  name     = "${var.environment}-n8n"
  location = var.region
  labels   = local.labels

  template {
    service_account = var.cloud_run_service_account
    max_instance_request_concurrency = 80

    scaling {
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      image = var.cloud_run_image

      ports {
        container_port = 5678
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
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

    dynamic "vpc_access" {
      for_each = var.vpc_connector == null ? [] : [var.vpc_connector]
      content {
        connector = vpc_access.value
      }
    }
  }
}

data "google_iam_policy" "invoker" {
  binding {
    role = "roles/run.invoker"

    members = var.invoker_members
  }
}

resource "google_cloud_run_service_iam_policy" "n8n" {
  location = google_cloud_run_v2_service.n8n.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.n8n.name

  policy_data = data.google_iam_policy.invoker.policy_data
}
