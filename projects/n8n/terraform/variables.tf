variable "project_id" {
  description = "GCP project identifier used for all resources."
  type        = string
}

variable "region" {
  description = "Primary region for Cloud Run and Cloud Functions."
  type        = string
  default     = "us-central1"
}

variable "n8n_container_image" {
  description = "Container image reference for the N8N Cloud Run service."
  type        = string
}

variable "n8n_service_account_name" {
  description = "Service account name (without domain) for the Cloud Run service."
  type        = string
  default     = "n8n-runner"
}

variable "n8n_min_instances" {
  description = "Minimum number of Cloud Run instances to keep warm."
  type        = number
  default     = 0
}

variable "n8n_max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 5
}

variable "n8n_env_vars" {
  description = "Map of environment variables to inject into the Cloud Run service."
  type        = map(string)
  default     = {}
}

variable "n8n_function_name" {
  description = "Name for the N8N helper Cloud Function (2nd gen)."
  type        = string
  default     = "n8n-background-worker"
}

variable "n8n_function_entry_point" {
  description = "Python entrypoint for the helper Cloud Function."
  type        = string
  default     = "main"
}

variable "n8n_function_runtime" {
  description = "Runtime for the helper Cloud Function."
  type        = string
  default     = "python311"
}

variable "n8n_function_bucket_name" {
  description = "GCS bucket that stores the function source archive."
  type        = string
}

variable "n8n_function_source_object" {
  description = "Name of the source archive object uploaded to the bucket."
  type        = string
}

variable "labels" {
  description = "Common labels applied to all resources."
  type        = map(string)
  default     = {}
}
