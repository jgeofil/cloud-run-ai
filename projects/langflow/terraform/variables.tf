variable "project_id" {
  description = "Target GCP project ID."
  type        = string
}

variable "region" {
  description = "Deployment region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Short environment name (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "credentials_file" {
  description = "Optional path to a service account JSON key file."
  type        = string
  default     = null
}

variable "cloud_run_image" {
  description = "Container image for the LangFlow Cloud Run service."
  type        = string
}

variable "cloud_run_service_account" {
  description = "Service account email for the Cloud Run execution environment."
  type        = string
}

variable "cloud_run_env" {
  description = "Map of environment variables to inject into the Cloud Run service."
  type        = map(string)
  default     = {}
}

variable "cloud_run_cpu" {
  description = "vCPU allocation for the container."
  type        = string
  default     = "2"
}

variable "cloud_run_memory" {
  description = "Memory allocation for the container."
  type        = string
  default     = "2Gi"
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances to keep warm."
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances."
  type        = number
  default     = 10
}

variable "invoker_members" {
  description = "IAM members granted Cloud Run invocation permissions."
  type        = list(string)
  default     = ["allUsers"]
}

variable "function_bucket" {
  description = "GCS bucket used to store Cloud Function source archives."
  type        = string
}

variable "function_entry_point" {
  description = "Entry point function name for the Cloud Function."
  type        = string
  default     = "handle"
}

variable "function_environment" {
  description = "Environment variables for the Cloud Function."
  type        = map(string)
  default     = {}
}

variable "additional_labels" {
  description = "Additional labels to attach to resources."
  type        = map(string)
  default     = {}
}
