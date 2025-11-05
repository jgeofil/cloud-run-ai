# LangFlow Deployment

This directory contains Terraform configuration and application scaffolding for running [LangFlow](https://github.com/logspace-ai/langflow) on Google Cloud Run with a companion Cloud Function for lightweight HTTP proxying or automation tasks.

## Structure

- `terraform/` — Infrastructure definitions for Cloud Run, Cloud Functions, buckets, and IAM.
- `app/cloud_function/` — Python entry point scaffold for the HTTP Cloud Function.

## Usage

1. Copy `terraform/terraform.tfvars.example` to `terraform.tfvars` and adjust values for your project.
2. Initialize Terraform in the directory:

   ```bash
   cd terraform
   terraform init
   ```

3. Review the plan before applying:

   ```bash
   terraform fmt
   terraform validate
   terraform plan -var-file="terraform.tfvars"
   ```

4. Apply once the plan meets expectations:

   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

Customize `app/cloud_function/main.py` to integrate with LangFlow APIs or automation requirements. Manage dependencies using the `langflow` optional dependency group defined in the repository `pyproject.toml`.
