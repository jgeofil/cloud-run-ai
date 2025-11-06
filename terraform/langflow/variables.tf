variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Primary region for Cloud Run and Cloud Functions"
  type        = string
}

variable "service_account_id" {
  description = "Identifier for the LangFlow runtime service account"
  type        = string
  default     = "langflow-runtime"
}

variable "service_account_roles" {
  description = "Set of IAM roles to bind to the LangFlow runtime service account"
  type        = set(string)
  default = [
    "roles/run.invoker",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
  ]
}

variable "run_service_name" {
  description = "Name of the LangFlow Cloud Run service"
  type        = string
  default     = "langflow-service"
}

variable "run_image" {
  description = "Container image for the LangFlow Cloud Run service"
  type        = string
}

variable "run_cpu" {
  description = "CPU allocation for the Cloud Run service"
  type        = string
  default     = "2"
}

variable "run_memory" {
  description = "Memory allocation for the Cloud Run service"
  type        = string
  default     = "1Gi"
}

variable "run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 5
}

variable "run_ingress" {
  description = "Ingress settings for the Cloud Run service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "run_invoker_member" {
  description = "IAM member allowed to invoke the Cloud Run service"
  type        = string
  default     = "allUsers"
}

variable "run_env_vars" {
  description = "Environment variables for the Cloud Run container"
  type        = map(string)
  default     = {}
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
  default     = "langflow-worker"
}

variable "function_runtime" {
  description = "Runtime for the Cloud Function"
  type        = string
  default     = "python311"
}

variable "function_entry_point" {
  description = "Entry point for the Cloud Function handler"
  type        = string
  default     = "main"
}

variable "function_source_bucket" {
  description = "GCS bucket containing the function source archive"
  type        = string
}

variable "function_source_object" {
  description = "GCS object path for the function source archive"
  type        = string
}

variable "function_memory" {
  description = "Memory allocation for the Cloud Function"
  type        = string
  default     = "1Gi"
}

variable "function_timeout" {
  description = "Timeout for the Cloud Function in seconds"
  type        = number
  default     = 120
}

variable "function_max_instances" {
  description = "Maximum number of Cloud Function instances"
  type        = number
  default     = 10
}

variable "function_ingress" {
  description = "Ingress settings for the Cloud Function"
  type        = string
  default     = "ALLOW_INTERNAL_ONLY"
}

variable "function_env_vars" {
  description = "Environment variables for the Cloud Function"
  type        = map(string)
  default     = {}
}

variable "function_invoker_member" {
  description = "IAM member allowed to invoke the Cloud Function"
  type        = string
  default     = "allUsers"
}

