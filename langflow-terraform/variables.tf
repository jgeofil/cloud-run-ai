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

variable "db_tier" {
  description = "The tier for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "langflow_admin_user" {
  description = "Initial admin user for Langflow"
  type        = string
  default     = "admin"
}
