variable "project_id" {
  description = "GCP project identifier"
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run service"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name for the Cloud Run service"
  type        = string
  default     = "n8n-automation"
}

variable "image" {
  description = "Container image to deploy"
  type        = string
}

variable "service_account_email" {
  description = "Optional service account email"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Map of environment variables passed to the container"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels applied to the Cloud Run service"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations applied to the Cloud Run service"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 5678
}

variable "cpu_limit" {
  description = "Requested CPU"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Requested memory"
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "invoker_members" {
  description = "Principals allowed to invoke the service"
  type        = set(string)
  default     = ["allUsers"]
}
