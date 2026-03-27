# Deployment Guide

This guide walks through configuring and deploying the N8N and Lang Flow projects onto Google Cloud Run and Google Cloud Functions using Terraform.

## Prerequisites

- Google Cloud project with billing enabled.
- IAM permissions: `roles/owner` or a combination that grants access to Cloud Run, Cloud Functions, IAM, Artifact Registry, and Cloud Build.
- Installed tooling:
  - Terraform >= 1.5
  - Python 3.11+
  - [uv](https://docs.astral.sh/uv/) for Python package management
  - Google Cloud SDK (`gcloud`)

## 1. Authenticate and Configure GCP

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```

Enable required APIs (Terraform also enables them, but pre-enabling reduces first-run latency):

```bash
gcloud services enable run.googleapis.com cloudfunctions.googleapis.com \
  artifactregistry.googleapis.com cloudbuild.googleapis.com secretmanager.googleapis.com
```

## 2. Bootstrap the Python Environment

```bash
uv venv
source .venv/bin/activate
uv pip install -e .[dev]
```

Verify tooling:

```bash
uv run python -m scripts.env_check
uv run ruff check .
```

## 3. Prepare Artifact Registries and Images

1. Create an Artifact Registry repository for each workload (optional but recommended).
2. Build and push container images for N8N and Lang Flow:

```bash
gcloud builds submit --tag REGION-docker.pkg.dev/PROJECT_ID/n8n/n8n:latest path/to/n8n

gcloud builds submit --tag REGION-docker.pkg.dev/PROJECT_ID/langflow/langflow:latest path/to/langflow
```

## 4. Package Cloud Function Source

1. Author Cloud Function code (Python 3.11) for background tasks or webhooks.
2. Package the source code:

```bash
cd path/to/function
zip -r n8n-function.zip main.py requirements.txt
zip -r langflow-function.zip main.py requirements.txt
```

3. Upload the archives to dedicated Cloud Storage buckets (or allow Terraform to create them):

```bash
gsutil mb -l REGION gs://n8n-functions-<SUFFIX>/
gsutil cp n8n-function.zip gs://n8n-functions-<SUFFIX>/

gsutil mb -l REGION gs://langflow-functions-<SUFFIX>/
gsutil cp langflow-function.zip gs://langflow-functions-<SUFFIX>/
```

## 5. Deploy Infrastructure with Terraform

### N8N

```bash
cd projects/n8n/terraform
terraform init
terraform apply \ 
  -var="project_id=PROJECT_ID" \ 
  -var="n8n_container_image=REGION-docker.pkg.dev/PROJECT_ID/n8n/n8n:latest" \ 
  -var="n8n_function_bucket_name=n8n-functions-SUFFIX" \ 
  -var="n8n_function_source_object=n8n-function.zip"
```

### Lang Flow

```bash
cd projects/langflow/terraform
terraform init
terraform apply \ 
  -var="project_id=PROJECT_ID" \ 
  -var="langflow_container_image=REGION-docker.pkg.dev/PROJECT_ID/langflow/langflow:latest" \ 
  -var="langflow_function_bucket_name=langflow-functions-SUFFIX" \ 
  -var="langflow_function_source_object=langflow-function.zip"
```

## 6. Post-Deployment Validation

1. Confirm Cloud Run services are serving traffic:
   ```bash
   curl https://<n8n-service-url>
   curl https://<langflow-service-url>
   ```
2. Trigger Cloud Functions via HTTP or Pub/Sub (depending on your implementation) to ensure proper wiring.
3. Inspect Cloud Run and Cloud Functions logs via:
   ```bash
   gcloud logs read --project=PROJECT_ID --limit=50 "resource.type=cloud_run_revision"
   gcloud logs read --project=PROJECT_ID --limit=50 "resource.type=cloud_function"
   ```

## 7. Testing Methodology

- **Infrastructure Validation**: Run `terraform validate` in each project directory and optionally `terraform plan` before apply.
- **Integration Tests**: Use Cloud Run URL smoke tests and Cloud Function invocations as described above.
- **Python Tooling**: Execute `uv run ruff check .` and `uv run python -m scripts.env_check` in CI to ensure dependencies and environment remain healthy.
- **Observability**: Configure alerting on Cloud Run error rates and Cloud Function execution failures using Cloud Monitoring.

## 8. Cleanup

To remove resources when no longer needed:

```bash
terraform destroy -var="project_id=PROJECT_ID" ...
```

Repeat for both project directories.
