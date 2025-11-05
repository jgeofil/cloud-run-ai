terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  service_accounts = var.service_accounts
}

module "service_accounts" {
  source = "../../modules/service_account"

  for_each = { for sa in local.service_accounts : sa.account_id => sa }

  project_id    = var.project_id
  account_id    = each.value.account_id
  display_name  = lookup(each.value, "display_name", null)
  description   = lookup(each.value, "description", null)
  project_roles = lookup(each.value, "project_roles", [])
}
