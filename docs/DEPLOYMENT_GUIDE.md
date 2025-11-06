# Deployment Guide

This guide walks through configuring the local environment, provisioning infrastructure for N8N and
LangFlow, and validating deployments on Google Cloud.

## Prerequisites

1. **Google Cloud Project** with billing enabled and the following APIs activated:
   - Cloud Run Admin API (`run.googleapis.com`)
   - Cloud Functions API (`cloudfunctions.googleapis.com`)
   - Cloud Build API (`cloudbuild.googleapis.com`)
   - Secret Manager API (`secretmanager.googleapis.com`)
   - Artifact Registry API (`artifactregistry.googleapis.com`)

2. **Service Account** with permissions to manage Cloud Run, Cloud Functions, Cloud Build, IAM, and
   Secret Manager resources.

3. **Tooling Installed**
   - Terraform `>= 1.6`
   - Google Cloud SDK (`gcloud` CLI)
   - Python `>= 3.10`
   - UV for Python dependency management
   - Ruff (installed via `uv sync`)

4. **Authentication**
   - Run `gcloud auth application-default login` to generate Application Default Credentials used by
     Terraform and Python automation.

## Repository Structure Overview

```
terraform/
├── n8n/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── langflow/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

scripts/
└── deploy.py
```

Each Terraform package can be deployed independently to manage its workload resources. Use
Terraform workspaces or duplicate directories for staging/production environments as needed.

## Setting Up the Python Environment

```bash
uv sync  # install runtime and dev dependencies defined in pyproject.toml
uv run python scripts/deploy.py --help
```

The sample script uses the Google Cloud SDK libraries to illustrate where automation tasks such as
triggering builds or verifying service status can be implemented.

## Terraform Deployment Workflow

1. **Initialize**

   ```bash
   cd terraform/n8n
   terraform init
   ```

2. **Plan**

   ```bash
   terraform plan \
     -var="project_id=YOUR_GCP_PROJECT" \
     -var="region=YOUR_GCP_REGION" \
     -var="run_image=REGISTRY_PATH_TO_N8N_IMAGE"
   ```

3. **Apply**

   ```bash
   terraform apply
   ```

   Repeat the same process inside `terraform/langflow` with image and configuration values tailored
   to LangFlow.

4. **Post-Deployment Checks**
   - Use `gcloud run services describe SERVICE_NAME --region=REGION` to confirm the Cloud Run
     service status.
   - Invoke the created Cloud Function using
     `gcloud functions call FUNCTION_NAME --region=REGION --data '{}'`.

## Testing Methodology

1. **Infrastructure Validation**
   - Run `terraform fmt -check` and `terraform validate` within each project directory.
   - Leverage `terraform plan` in CI to detect configuration drift before merging changes.

2. **Python Quality Gates**
   - Execute `uv run ruff check .` to enforce style and catch common Python issues.
   - Extend with unit tests (e.g., `pytest`) as automation scripts evolve.

3. **Deployment Smoke Tests**
   - Call the Cloud Run service URLs and Cloud Function HTTP endpoints to ensure they return
     expected responses (HTTP `200` or project-specific payloads).
   - Monitor Cloud Logging for runtime errors immediately after deployment.

4. **Rollbacks**
   - Maintain versioned container images for each workload.
   - Use `terraform apply` with prior configuration or `gcloud run services update` to pin a
     previous revision when necessary.

## Cleanup

To remove provisioned resources, run `terraform destroy` in each project directory. Confirm the
command before applying to avoid deleting shared infrastructure.

