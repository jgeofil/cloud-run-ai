# Cloud Run AI Deployment Scaffold

This repository provides a Terraform-first scaffold for deploying two independent workloads—**N8N** and **Lang Flow**—onto Google Cloud Run and Google Cloud Functions. It includes Python tooling managed by [uv](https://github.com/astral-sh/uv) and linting powered by [Ruff](https://docs.astral.sh/ruff/).

## Repository Layout

```
.
├── docs/
│   ├── deployment-guide.md       # Step-by-step operational documentation
│   └── project-plan.md           # High-level plan and backlog
├── projects/
│   ├── langflow/
│   │   └── terraform/            # Terraform IaC for Lang Flow
│   └── n8n/
│       └── terraform/            # Terraform IaC for N8N
├── scripts/                      # Python helper scripts (auth checks, deploy orchestration)
├── pyproject.toml                # Python environment managed through uv
├── ruff.toml                     # Linting rules for Ruff
└── README.md
```

## Getting Started

1. Install the prerequisites:
   - Terraform >= 1.5
   - Python 3.11+
   - [uv CLI](https://docs.astral.sh/uv/getting-started/installation/)
   - Google Cloud SDK (`gcloud`)

2. Authenticate with Google Cloud:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. Create a Python virtual environment managed by uv:
   ```bash
   uv venv
   source .venv/bin/activate
   uv pip install -e .
   ```

4. Navigate to the desired project (e.g., `projects/n8n/terraform`) and follow the deployment guide in [`docs/deployment-guide.md`](docs/deployment-guide.md).

## Contributing

- Run `uv pip install -e .` to install dependencies.
- Run `uv run ruff check .` before committing.
- Execute `terraform fmt` and `terraform validate` within each project directory to verify infrastructure configurations.

## License

This project is licensed under the [MIT License](LICENSE).
