variable "project_id" {
  description = "The GCP project ID where the service account will be created."
  type        = string
}

variable "account_id" {
  description = "The service account ID (without domain)."
  type        = string
}

variable "display_name" {
  description = "Display name for the service account."
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the service account."
  type        = string
  default     = null
}

variable "project_roles" {
  description = "List of IAM roles to attach to the service account."
  type        = list(string)
  default     = []
}
