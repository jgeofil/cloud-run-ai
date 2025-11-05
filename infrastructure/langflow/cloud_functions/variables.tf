variable "project_id" {
  description = "GCP project identifier"
  type        = string
}

variable "region" {
  description = "Deployment region"
  type        = string
  default     = "us-central1"
}

variable "function_name" {
  description = "Cloud Function name"
  type        = string
  default     = "langflow-batch"
}

variable "runtime" {
  description = "Function runtime"
  type        = string
  default     = "python311"
}

variable "entry_point" {
  description = "Entry point"
  type        = string
  default     = "main"
}

variable "description" {
  description = "Description of the function"
  type        = string
  default     = "LangFlow batch task handler"
}

variable "source_bucket_name" {
  description = "Source archive bucket"
  type        = string
}

variable "source_archive_object" {
  description = "Source archive object"
  type        = string
}

variable "service_account_email" {
  description = "Optional service account"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  default     = {}
}

variable "memory_limit" {
  description = "Memory allocation"
  type        = string
  default     = "1Gi"
}

variable "cpu_limit" {
  description = "CPU allocation"
  type        = string
  default     = "2"
}

variable "timeout_seconds" {
  description = "Execution timeout"
  type        = number
  default     = 540
}

variable "min_instances" {
  description = "Minimum instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum instances"
  type        = number
  default     = 10
}

variable "ingress_settings" {
  description = "Ingress configuration"
  type        = string
  default     = "ALLOW_INTERNAL_AND_GCLB"
}

variable "vpc_connector" {
  description = "Optional VPC connector"
  type        = string
  default     = ""
}

variable "event_trigger" {
  description = "Event trigger configuration"
  type = object({
    event_type   = string
    pubsub_topic = string
    retry_policy = string
  })
}
