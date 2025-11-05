terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.20.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.20.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.credentials_file == null ? null : file(var.credentials_file)
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = var.credentials_file == null ? null : file(var.credentials_file)
}

locals {
  labels = merge(
    {
      application = "langflow"
      environment = var.environment
      managed_by  = "terraform"
    },
    var.additional_labels
  )
}
