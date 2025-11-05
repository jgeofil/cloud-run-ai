# Deployment Guide

This guide walks through provisioning infrastructure for the N8N and LangFlow projects on Google Cloud Platform using Terraform, configuring Python tooling with uv, and validating deployments.

## Prerequisites

1. **Google Cloud access**
   - Active GCP project with billing enabled.
   - IAM permissions to manage Cloud Run, Cloud Functions, Artifact Registry, and IAM.
2. **Local tooling**
   - [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.
   - [uv](https://github.com/astral-sh/uv#installation) for Python package management.
   - [gcloud CLI](https://cloud.google.com/sdk/docs/install) authenticated against the target project.
   - Docker (optional) for building container images locally.

## Repository bootstrap

```bash
# Install Python dependencies (project-wide)
uv sync

# Run Ruff linting
uv run ruff check .
```

Terraform provider and module files live under `infra/`, while per-project infrastructure lives in `projects/<name>/terraform/`.

## Shared configuration

1. Copy `infra/envs/shared/terraform.tfvars.example` to `terraform.tfvars` and fill in project-specific values.
2. Initialize Terraform:

   ```bash
   cd infra/envs/shared
   terraform init
   ```

3. Apply shared resources as required (e.g., common service accounts, Artifact Registry repositories):

   ```bash
   terraform apply
   ```

## Project deployments

Each project folder provides separate Terraform configurations and application code scaffolding.

### N8N

1. Navigate to the Terraform directory:

   ```bash
   cd projects/n8n/terraform
   terraform init
   terraform plan -var-file="terraform.tfvars"
   ```

2. Update the container image URI, Cloud Run concurrency, and environment variables in `cloud_run.tf` as needed.
3. Deploy the associated Cloud Function (if required) by updating the artifact bucket and entry point in `cloud_functions.tf`.
4. Apply the Terraform plan once satisfied:

   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

5. Build and push the N8N container image using Cloud Build or Docker prior to applying infrastructure.

### LangFlow

Follow the same process as N8N, adjusting Terraform variables for LangFlow-specific configuration.

### Python application code

Each project includes a `app/cloud_function/main.py` stub to extend with request handling logic. Manage dependencies with uv by editing `pyproject.toml` and adding any project-specific optional dependency groups under `[project.optional-dependencies]`.

Install dependencies within the repo root so they are available to both projects:

```bash
uv add fastapi  # example dependency
```

## Testing methodology

1. **Static analysis**
   - Run Ruff across the repository: `uv run ruff check .`
2. **Terraform validation**
   - `terraform fmt` to ensure consistent formatting.
   - `terraform validate` in each Terraform directory.
   - `terraform plan` using environment-specific `tfvars` files.
3. **Smoke tests**
   - After applying, hit the Cloud Run service URL with `curl` or Postman to confirm application responsiveness.
   - Trigger the Cloud Function via the HTTPS endpoint and review Cloud Logging for execution traces.
4. **Monitoring**
   - Verify service health metrics in Cloud Monitoring dashboards.

## Cleanup

To remove resources, run `terraform destroy` in the corresponding directories. Ensure that container images and other artifacts in Artifact Registry are cleaned up separately.
