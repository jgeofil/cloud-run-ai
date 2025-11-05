# Cloud Run & Cloud Functions Deployment Scaffold

This repository provides a scaffold for deploying two independent workloads—**N8N** and **LangFlow**—to Google Cloud Platform (GCP) using Terraform. It includes opinionated defaults for managing Python tooling with [uv](https://github.com/astral-sh/uv), linting with [Ruff](https://docs.astral.sh/ruff/), and infrastructure-as-code definitions for Cloud Run and Cloud Functions.

## Repository layout

```
.
├── docs/                     # Extended documentation and runbooks
├── infra/                    # Shared Terraform provider configuration and modules
├── projects/
│   ├── langflow/             # LangFlow-specific IaC and application code
│   └── n8n/                  # N8N-specific IaC and application code
├── pyproject.toml            # Python project definition managed by uv
├── ruff.toml                 # Ruff linting configuration
└── README.md                 # Project overview and quickstart
```

Refer to [`docs/deployment.md`](docs/deployment.md) for detailed setup, deployment, and testing instructions.
