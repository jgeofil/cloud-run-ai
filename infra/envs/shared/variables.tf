variable "project_id" {
  description = "Target GCP project ID."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "service_accounts" {
  description = "List of service account objects to provision."
  type = list(object({
    account_id    = string
    display_name  = optional(string)
    description   = optional(string)
    project_roles = optional(list(string), [])
  }))
  default = []
}
