variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "cloud-run-487213"
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "n8n_basic_auth_user" {
  description = "n8n basic auth username"
  type        = string
  default     = "jeremygf"
}

variable "db_tier" {
  description = "The tier for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}
