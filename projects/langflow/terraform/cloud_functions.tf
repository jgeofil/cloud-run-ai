resource "google_storage_bucket" "function" {
  name          = var.function_bucket
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true
  labels                      = local.labels
}

data "archive_file" "function" {
  type        = "zip"
  output_path = "${path.module}/.terraform/tmp/langflow-function.zip"
  source_dir  = "../app/cloud_function"
}

resource "google_storage_bucket_object" "archive" {
  name   = "${var.environment}-langflow-function.zip"
  bucket = google_storage_bucket.function.name
  source = data.archive_file.function.output_path
}

resource "google_cloudfunctions2_function" "langflow" {
  name        = "${var.environment}-langflow-proxy"
  location    = var.region
  description = "LangFlow HTTP proxy function"

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
    available_memory      = "512M"
    timeout_seconds       = 120
    ingress_settings      = "ALLOW_ALL"
    environment_variables = var.function_environment
  }
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.langflow.project
  location       = google_cloudfunctions2_function.langflow.location
  cloud_function = google_cloudfunctions2_function.langflow.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
