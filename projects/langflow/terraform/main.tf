terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.25.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  labels = merge({
    application = "langflow",
    managed_by  = "terraform",
  }, var.labels)

  service_account_email = "${var.langflow_service_account_name}@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_project_service" "required" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
  ])

  project = var.project_id
  service = each.key
}

resource "google_service_account" "langflow" {
  account_id   = var.langflow_service_account_name
  display_name = "Lang Flow Cloud Run"
  project      = var.project_id
}

resource "google_cloud_run_v2_service" "langflow" {
  name     = "langflow-service"
  project  = var.project_id
  location = var.region

  template {
    service_account = google_service_account.langflow.email

    scaling {
      min_instance_count = var.langflow_min_instances
      max_instance_count = var.langflow_max_instances
    }

    containers {
      image = var.langflow_container_image

      dynamic "env" {
        for_each = var.langflow_env_vars
        iterator = env_var
        content {
          name  = env_var.key
          value = env_var.value
        }
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "2Gi"
        }
      }
    }
  }

  labels = local.labels

  depends_on = [
    google_project_service.required,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  location = google_cloud_run_v2_service.langflow.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.langflow.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_storage_bucket" "functions" {
  name                        = var.langflow_function_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = false

  labels = local.labels
}

resource "google_cloudfunctions2_function" "langflow" {
  name        = var.langflow_function_name
  location    = var.region
  project     = var.project_id
  description = "Lang Flow automation hooks"

  build_config {
    runtime     = var.langflow_function_runtime
    entry_point = var.langflow_function_entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.functions.name
        object = var.langflow_function_source_object
      }
    }
  }

  service_config {
    max_instance_count = 2
    available_memory   = "512M"
    timeout_seconds    = 300
    ingress_settings   = "ALLOW_INTERNAL_AND_GCLB"
    environment_variables = {
      LANGFLOW_SERVICE_URL = google_cloud_run_v2_service.langflow.uri
    }
  }

  depends_on = [
    google_project_service.required,
  ]
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = var.project_id
  location       = google_cloudfunctions2_function.langflow.location
  cloud_function = google_cloudfunctions2_function.langflow.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
