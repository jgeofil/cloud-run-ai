resource "google_storage_bucket" "function" {
  name          = var.function_bucket
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true
  labels                      = local.labels
}

data "archive_file" "function" {
  type        = "zip"
  output_path = "${path.module}/.terraform/tmp/n8n-function.zip"
  source_dir  = "../app/cloud_function"
}

resource "google_storage_bucket_object" "archive" {
  name   = "${var.environment}-n8n-function.zip"
  bucket = google_storage_bucket.function.name
  source = data.archive_file.function.output_path
}

resource "google_cloudfunctions2_function" "n8n" {
  name        = "${var.environment}-n8n-hook"
  location    = var.region
  description = "N8N auxiliary Cloud Function"

  build_config {
    runtime     = "python311"
    entry_point = var.function_entry_point

    source {
      storage_source {
        bucket = google_storage_bucket_object.archive.bucket
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      ENVIRONMENT = var.environment
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = var.pubsub_topic
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}
