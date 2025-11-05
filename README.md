# Cloud Run AI Deployment Scaffold

This repository provides Terraform infrastructure-as-code, Python deployment helpers, and tooling configuration for deploying **N8N** and **LangFlow** workloads to **Google Cloud Run** and **Google Cloud Functions**. The scaffold standardises provider configuration, package management with [uv](https://docs.astral.sh/uv/), linting with [Ruff](https://docs.astral.sh/ruff/), and automation scripts for future CI/CD pipelines.

## Repository layout

```
.
├── infrastructure/
│   ├── n8n/
│   │   ├── cloud_run/
│   │   └── cloud_functions/
│   └── langflow/
│       ├── cloud_run/
│       └── cloud_functions/
├── src/cloud_run_ai/
│   ├── common/
│   ├── langflow/
│   └── n8n/
├── scripts/
└── docs/
```

- `infrastructure/` – Terraform configurations for each workload and target platform.
- `src/cloud_run_ai/` – Python helpers for generating deployment manifests and orchestrating workflows.
- `scripts/` – Command line entry points, including `deploy.py`.
- `docs/` – Detailed documentation covering setup, testing, and deployment guidance.

## Getting started

### Prerequisites

- Terraform ≥ 1.6
- Python ≥ 3.11
- [uv](https://docs.astral.sh/uv/) for dependency management
- Google Cloud CLI with application default credentials

### Bootstrap the Python environment

```bash
uv sync
uv run scripts/deploy.py --help
```

`uv sync` reads `pyproject.toml` and installs both runtime and development dependencies (including Ruff when the `--dev` flag is used).

### Run linting

```bash
uv run ruff check src scripts
```

### Terraform workflows

Each workload has an independent Cloud Run and Cloud Functions stack. Navigate to the relevant directory, copy `terraform.tfvars.example`, customise values, and apply:

```bash
cd infrastructure/n8n/cloud_run
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

See [`docs/deployment-guide.md`](docs/deployment-guide.md) for a complete walkthrough, including environment variable recommendations and testing guidance.

## Automation helpers

The `scripts/deploy.py` CLI exposes a `show-config` command that surfaces the resolved Python configuration objects for each project. This can be integrated into CI jobs or used locally to validate configuration prior to applying Terraform.

```bash
uv run python scripts/deploy.py show-config n8n --project-id=my-project --region=us-central1 \
  --image=us-docker.pkg.dev/my-project/applications/n8n:latest --service-account=n8n@my-project.iam.gserviceaccount.com
```

## Next steps

1. Configure remote Terraform state (for example, using Google Cloud Storage).
2. Integrate the CLI and Terraform modules into your CI/CD pipeline.
3. Extend the Python helpers with API calls to trigger Cloud Build or Cloud Deploy once images are updated.
