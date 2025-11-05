# N8N Deployment

This directory defines the Terraform configuration and application code scaffold for deploying [N8N](https://n8n.io/) to Google Cloud Run with an auxiliary Cloud Function to process asynchronous hooks.

## Structure

- `terraform/` — Infrastructure-as-code for Cloud Run, Cloud Functions, storage buckets, and IAM bindings.
- `app/cloud_function/` — Python entry point scaffold for the optional Cloud Function trigger.

## Usage

1. Copy `terraform/terraform.tfvars.example` to `terraform.tfvars` and customize for your environment.
2. Initialize Terraform:

   ```bash
   cd terraform
   terraform init
   ```

3. Format and validate the configuration:

   ```bash
   terraform fmt
   terraform validate
   terraform plan -var-file="terraform.tfvars"
   ```

4. Apply once satisfied with the plan output:

   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

Update `app/cloud_function/main.py` with project-specific logic and ensure dependencies are listed in `pyproject.toml` under the `n8n` optional dependency group.
