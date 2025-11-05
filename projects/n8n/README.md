# N8N Infrastructure

Terraform configuration for deploying the N8N automation platform to Google Cloud Run with a supporting Cloud Function for background automation tasks.

## Infrastructure Components

- Google Cloud Run v2 service running the N8N container image.
- Dedicated service account with invoker permissions.
- Optional public invoker binding for HTTP access.
- Cloud Storage bucket for storing Cloud Function source archives.
- 2nd generation Cloud Function for background processing, referencing the Cloud Run URL via environment variables.
- API enablement for Cloud Run, Cloud Functions, Cloud Build, Artifact Registry, and Secret Manager.

## Required Variables

| Variable | Description |
| --- | --- |
| `project_id` | Target Google Cloud project ID. |
| `region` | Deployment region (defaults to `us-central1`). |
| `n8n_container_image` | Fully qualified container image for N8N. |
| `n8n_function_bucket_name` | Cloud Storage bucket to host function artifacts. |
| `n8n_function_source_object` | Object name of the uploaded Cloud Function source archive. |

## Usage

1. Create or choose a bucket for your function artifacts.
2. Package the Cloud Function source and upload it to the bucket.
3. Run Terraform from the `terraform/` directory:

```bash
terraform init
terraform apply -var="project_id=YOUR_PROJECT" \
  -var="n8n_container_image=REGION-docker.pkg.dev/YOUR_PROJECT/n8n/n8n:latest" \
  -var="n8n_function_bucket_name=YOUR_BUCKET" \
  -var="n8n_function_source_object=n8n-function.zip"
```

Refer to [`../../docs/deployment-guide.md`](../../docs/deployment-guide.md) for more details.
