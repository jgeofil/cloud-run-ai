resource "google_storage_bucket" "langflow_data" {
  name                        = "${var.project_id}-langflow-data"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
