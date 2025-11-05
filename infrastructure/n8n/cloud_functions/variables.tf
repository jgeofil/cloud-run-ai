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
  description = "Name of the Cloud Function"
  type        = string
  default     = "n8n-trigger"
}

variable "runtime" {
  description = "Runtime for the Cloud Function"
  type        = string
  default     = "python311"
}

variable "entry_point" {
  description = "Entry point function"
  type        = string
  default     = "main"
}

variable "description" {
  description = "Description for the function"
  type        = string
  default     = "Automation trigger for N8N"
}

variable "source_bucket_name" {
  description = "Bucket for storing source archives"
  type        = string
}

variable "source_archive_object" {
  description = "Archive object containing the function source"
  type        = string
}

variable "service_account_email" {
  description = "Optional service account email"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Map of environment variables"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels attached to resources"
  type        = map(string)
  default     = {}
}

variable "memory_limit" {
  description = "Memory allocation"
  type        = string
  default     = "512Mi"
}

variable "cpu_limit" {
  description = "CPU allocation"
  type        = string
  default     = "1"
}

variable "min_instances" {
  description = "Minimum instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum instances"
  type        = number
  default     = 5
}

variable "ingress_settings" {
  description = "Ingress control"
  type        = string
  default     = "ALLOW_ALL"
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
