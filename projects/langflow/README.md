# Lang Flow Infrastructure

Terraform configuration for deploying the Lang Flow application to Google Cloud Run with an accompanying Cloud Function for orchestrating asynchronous tasks.

## Infrastructure Components

- Google Cloud Run v2 service running the Lang Flow container image.
- Dedicated service account associated with the Cloud Run revision.
- Optional public invoker binding for external access.
- Cloud Storage bucket dedicated to function source archives.
- 2nd generation Cloud Function for orchestrating webhook or batch processing tasks with access to the Cloud Run URL.
- API enablement for Cloud Run, Cloud Functions, Cloud Build, Artifact Registry, and Secret Manager.

## Required Variables

| Variable | Description |
| --- | --- |
| `project_id` | Target Google Cloud project ID. |
| `region` | Deployment region (defaults to `us-central1`). |
| `langflow_container_image` | Fully qualified container image for Lang Flow. |
| `langflow_function_bucket_name` | Cloud Storage bucket hosting the function artifact. |
| `langflow_function_source_object` | Object name for the uploaded Cloud Function source archive. |

## Usage

```bash
terraform init
terraform apply -var="project_id=YOUR_PROJECT" \
  -var="langflow_container_image=REGION-docker.pkg.dev/YOUR_PROJECT/langflow/langflow:latest" \
  -var="langflow_function_bucket_name=YOUR_BUCKET" \
  -var="langflow_function_source_object=langflow-function.zip"
```

Refer to [`../../docs/deployment-guide.md`](../../docs/deployment-guide.md) for a full walkthrough.
