variable "project_id" {
  description = "GCP project identifier"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "langflow-app"
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "service_account_email" {
  description = "Optional workload service account"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables passed to the container"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels applied to the service"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations applied to the service"
  type        = map(string)
  default     = {}
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU request"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory request"
  type        = string
  default     = "1Gi"
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

variable "invoker_members" {
  description = "Principals allowed to invoke"
  type        = set(string)
  default     = ["allUsers"]
}
