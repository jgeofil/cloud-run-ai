# Cloud Run AI Deployment Scaffold

This repository provides a Terraform- and Python-based scaffold for deploying two independent
workloads—**N8N** and **LangFlow**—to Google Cloud Run and Google Cloud Functions. The project is
opinionated around:

- Infrastructure-as-code definitions managed with Terraform.
- Python automation tooling using [UV](https://github.com/astral-sh/uv) for dependency management.
- Google Cloud Python SDKs for scripting around deployment workflows.
- Linting and formatting enforced through [Ruff](https://docs.astral.sh/ruff/).

## Contents

- `docs/PROJECT_PLAN.md`: High-level roadmap and checklist for implementing the scaffold.
- `docs/DEPLOYMENT_GUIDE.md`: Step-by-step instructions for provisioning resources and running
  validation checks.
- `terraform/`: Terraform configurations for each workload.
- `scripts/`: Python helper utilities that will evolve into automation entrypoints.

## Getting Started

1. Install the required tooling:
   - [Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
   - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
   - [UV](https://github.com/astral-sh/uv#installation)
   - Python 3.10 or newer

2. Install Python dependencies using UV:

   ```bash
   uv sync
   ```

3. Run Ruff to ensure code quality:

   ```bash
   uv run ruff check .
   ```

4. Follow the deployment guide in `docs/DEPLOYMENT_GUIDE.md` to provision infrastructure.

## Repository Status

The repository currently contains placeholder Terraform modules and Python scripts to illustrate the
structure. Extend the definitions with environment-specific variables, secrets management, and
CI/CD workflows as needed for production usage.

