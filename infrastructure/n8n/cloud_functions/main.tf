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
  function_name = var.function_name
}

resource "google_project_service" "apis" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "pubsub.googleapis.com"
  ])

  service = each.key
}

resource "google_service_account" "function" {
  account_id   = replace(var.function_name, "-", "")
  display_name = "${var.function_name} cloud function"
}

resource "google_storage_bucket" "source" {
  name                        = var.source_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  labels                      = var.labels
}

resource "google_cloudfunctions2_function" "function" {
  name        = local.function_name
  location    = var.region
  description = var.description

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.source.name
        object = var.source_archive_object
      }
    }
    environment_variables = var.environment_variables
  }

  service_config {
    max_instance_count = var.max_instances
    min_instance_count = var.min_instances
    available_memory   = var.memory_limit
    available_cpu      = var.cpu_limit
    service_account_email = var.service_account_email != "" ? var.service_account_email : google_service_account.function.email
    ingress_settings = var.ingress_settings
    vpc_connector    = var.vpc_connector
    labels           = var.labels
  }

  event_trigger {
    event_type   = var.event_trigger.event_type
    trigger_region = var.region
    pubsub_topic = var.event_trigger.pubsub_topic
    retry_policy = var.event_trigger.retry_policy
  }
}
