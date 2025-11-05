# Deployment Guide

This guide outlines the steps required to provision the infrastructure for N8N and LangFlow on Google Cloud using Terraform, configure the Python tooling, and validate the resulting deployments.

## 1. Plan the deployment

1. Identify the Google Cloud project that will host the workloads.
2. Create a dedicated Artifact Registry repository for container images (`gcloud artifacts repositories create`).
3. Decide on networking requirements (VPC connectors, ingress restrictions, secrets) for each service.
4. Gather environment variables and secrets required by N8N and LangFlow.

Document these decisions inside your team runbook or in a `terraform.tfvars` file before applying the infrastructure.

## 2. Configure authentication

```bash
# Authenticate the gcloud CLI and application default credentials
gcloud auth login
gcloud auth application-default login

# Set the target project and region
gcloud config set project <PROJECT_ID>
gcloud config set run/region <REGION>
```

If you are using a CI/CD system, configure a dedicated service account with the following roles:

- `roles/run.admin`
- `roles/cloudfunctions.admin`
- `roles/iam.serviceAccountUser`
- `roles/secretmanager.admin`
- `roles/storage.admin`

## 3. Manage Python dependencies with uv

```bash
uv sync --dev
```

The `--dev` flag installs Ruff alongside runtime dependencies so you can lint the repository locally. To inspect the generated Python configuration for a workload, use the CLI helper:

```bash
uv run python scripts/deploy.py show-config langflow --target=cloud-run \
  --project-id=<PROJECT_ID> --region=<REGION> \
  --image=<REGION>-docker.pkg.dev/<PROJECT_ID>/langflow/langflow:latest \
  --service-account=langflow@<PROJECT_ID>.iam.gserviceaccount.com
```

## 4. Prepare Terraform variables

Each Terraform directory expects a `terraform.tfvars` file. Example values for N8N Cloud Run:

```hcl
project_id             = "my-project"
region                 = "us-central1"
image                  = "us-docker.pkg.dev/my-project/applications/n8n:latest"
service_name           = "n8n-automation"
service_account_email  = "n8n@my-project.iam.gserviceaccount.com"
min_instances          = 1
max_instances          = 3
environment_variables = {
  N8N_BASIC_AUTH_USER = "admin"
  N8N_BASIC_AUTH_PASSWORD = "changeme"
}
labels = {
  environment = "dev"
  workload    = "n8n"
}
annotations = {
  "run.googleapis.com/client-name" = "terraform"
}
```

For Cloud Functions, specify `source_bucket_name` and `source_archive_object` that contain your zipped function code, along with the `event_trigger` object describing Pub/Sub topics or other events.

## 5. Apply Terraform

```bash
cd infrastructure/n8n/cloud_run
terraform init
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

Repeat the process for `langflow/cloud_run`, `n8n/cloud_functions`, and `langflow/cloud_functions` as required. Consider configuring backend state storage (for example, a Google Cloud Storage bucket) before collaboration.

## 6. Post-deployment validation

1. Visit the Cloud Run URL output by Terraform to confirm the application loads.
2. For Cloud Functions, trigger the Pub/Sub topic or HTTP invocation depending on the event trigger.
3. Verify logs using:

   ```bash
  gcloud run services logs read <SERVICE_NAME> --region <REGION>
  gcloud functions logs read <FUNCTION_NAME> --gen2
   ```

4. Ensure the service accounts have the correct permissions and secrets are accessible.

## 7. Automated testing strategy

- **Infrastructure validation**: run `terraform plan` in CI on every pull request and fail the build when changes introduce drift.
- **Policy enforcement**: integrate tools like `terraform fmt` and `terraform validate` to catch syntax errors early.
- **Runtime smoke tests**: implement HTTP or Pub/Sub based checks that run after deployment to confirm the services respond with 200 OK and return expected payloads.
- **Python linting**: execute `uv run ruff check` as part of the CI pipeline to guarantee code quality across helper scripts.

Following these steps ensures repeatable, auditable deployments for both N8N and LangFlow across Cloud Run and Cloud Functions.
