terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.27.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  service_name = var.service_name
}

resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com"
  ])

  service = each.key
}

resource "google_service_account" "workload" {
  account_id   = replace(var.service_name, "-", "")
  display_name = "${var.service_name} cloud run"
}

resource "google_cloud_run_v2_service" "service" {
  name     = local.service_name
  location = var.region

  template {
    service_account = var.service_account_email != "" ? var.service_account_email : google_service_account.workload.email
    containers {
      image = var.image
      env = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]
      ports {
        name          = "http1"
        container_port = var.container_port
      }
      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
    }
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels      = var.labels
  annotations = var.annotations
}

resource "google_cloud_run_v2_service_iam_binding" "invoker" {
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  members  = var.invoker_members
}
