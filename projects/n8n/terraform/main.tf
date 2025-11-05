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
    application = "n8n",
    managed_by  = "terraform",
  }, var.labels)

  service_account_email = "${var.n8n_service_account_name}@${var.project_id}.iam.gserviceaccount.com"
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

resource "google_service_account" "n8n" {
  account_id   = var.n8n_service_account_name
  display_name = "N8N Cloud Run"
  project      = var.project_id
}

resource "google_service_account_iam_member" "n8n_invoker" {
  service_account_id = google_service_account.n8n.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${local.service_account_email}"
}

resource "google_cloud_run_v2_service" "n8n" {
  name     = "n8n-service"
  project  = var.project_id
  location = var.region

  template {
    service_account = google_service_account.n8n.email
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = var.n8n_min_instances
      max_instance_count = var.n8n_max_instances
    }

    containers {
      image = var.n8n_container_image

      dynamic "env" {
        for_each = var.n8n_env_vars
        iterator = env_var
        content {
          name  = env_var.key
          value = env_var.value
        }
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].labels]
  }

  labels = local.labels

  depends_on = [
    google_project_service.required,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  location = google_cloud_run_v2_service.n8n.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.n8n.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_storage_bucket" "functions" {
  name                        = var.n8n_function_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = false

  labels = local.labels
}

resource "google_cloudfunctions2_function" "n8n" {
  name        = var.n8n_function_name
  location    = var.region
  project     = var.project_id
  description = "Helper background tasks for N8N"

  build_config {
    runtime     = var.n8n_function_runtime
    entry_point = var.n8n_function_entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.functions.name
        object = var.n8n_function_source_object
      }
    }
  }

  service_config {
    max_instance_count = 3
    available_memory   = "512M"
    timeout_seconds    = 540
    ingress_settings   = "ALLOW_INTERNAL_AND_GCLB"
    environment_variables = {
      CLOUD_RUN_SERVICE_URL = google_cloud_run_v2_service.n8n.uri
    }
  }

  depends_on = [
    google_project_service.required,
  ]
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = var.project_id
  location       = google_cloudfunctions2_function.n8n.location
  cloud_function = google_cloudfunctions2_function.n8n.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
