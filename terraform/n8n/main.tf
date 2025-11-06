terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.28.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.28.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Enable core services that support Cloud Run and Cloud Functions deployments.
resource "google_project_service" "required" {
  for_each = toset([
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
  ])

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
}

resource "google_service_account" "n8n" {
  account_id   = var.service_account_id
  display_name = "${var.service_account_id} (N8N Runtime)"
}

resource "google_project_iam_member" "n8n_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.n8n.email}"
}

resource "google_cloud_run_v2_service" "n8n" {
  name     = var.run_service_name
  location = var.region

  template {
    service_account = google_service_account.n8n.email

    scaling {
      min_instance_count = var.run_min_instances
      max_instance_count = var.run_max_instances
    }

    containers {
      image = var.run_image

      resources {
        cpu_idle = true
        limits = {
          cpu    = var.run_cpu
          memory = var.run_memory
        }
      }

      env = [for k, v in var.run_env_vars : {
        name  = k
        value = v
      }]
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress     = var.run_ingress
  launch_stage = "GA"

  depends_on = [
    google_project_service.required,
    google_service_account.n8n,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  name     = google_cloud_run_v2_service.n8n.name
  location = google_cloud_run_v2_service.n8n.location
  role     = "roles/run.invoker"
  member   = var.run_invoker_member
}

resource "google_cloudfunctions2_function" "n8n_webhook" {
  provider = google-beta

  name        = var.function_name
  location    = var.region
  description = "N8N webhook handler"

  build_config {
    runtime     = var.function_runtime
    entry_point = var.function_entry_point

    source {
      storage_source {
        bucket = var.function_source_bucket
        object = var.function_source_object
      }
    }
  }

  service_config {
    max_instance_count = var.function_max_instances
    available_memory   = var.function_memory
    timeout_seconds    = var.function_timeout
    environment_variables = merge(
      {
        "TARGET_RUN_SERVICE" = google_cloud_run_v2_service.n8n.name
      },
      var.function_env_vars,
    )
    ingress_settings = var.function_ingress
    service_account_email = google_service_account.n8n.email
  }

  depends_on = [
    google_project_service.required,
    google_service_account.n8n,
  ]
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  provider = google-beta

  name     = google_cloudfunctions2_function.n8n_webhook.name
  location = google_cloudfunctions2_function.n8n_webhook.location
  role     = "roles/cloudfunctions.invoker"
  member   = var.function_invoker_member
}

