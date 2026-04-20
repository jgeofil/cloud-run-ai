variable "project_id" {
  description = "GCP project identifier used for all Lang Flow resources."
  type        = string
}

variable "region" {
  description = "Primary region for Cloud Run and Cloud Functions."
  type        = string
  default     = "us-central1"
}

variable "langflow_container_image" {
  description = "Container image reference for the Lang Flow Cloud Run service."
  type        = string
}

variable "langflow_service_account_name" {
  description = "Service account name (without domain) for the Cloud Run service."
  type        = string
  default     = "langflow-runner"
}

variable "langflow_min_instances" {
  description = "Minimum number of Cloud Run instances to keep warm."
  type        = number
  default     = 0
}

variable "langflow_max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 5
}

variable "langflow_env_vars" {
  description = "Environment variables for the Lang Flow Cloud Run service."
  type        = map(string)
  default     = {}
}

variable "langflow_function_name" {
  description = "Name for the Lang Flow helper Cloud Function."
  type        = string
  default     = "langflow-hooks"
}

variable "langflow_function_entry_point" {
  description = "Entrypoint for the Lang Flow Cloud Function."
  type        = string
  default     = "main"
}

variable "langflow_function_runtime" {
  description = "Runtime for the Lang Flow Cloud Function."
  type        = string
  default     = "python311"
}

variable "langflow_function_bucket_name" {
  description = "GCS bucket that stores the Lang Flow function source archive."
  type        = string
}

variable "langflow_function_source_object" {
  description = "Name of the Lang Flow function source archive object."
  type        = string
}

variable "labels" {
  description = "Common labels applied to all Lang Flow resources."
  type        = map(string)
  default     = {}
}
