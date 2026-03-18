resource "google_storage_bucket" "n8n_storage" {
  name          = "n8n-storage-${var.project_id}"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true
}
