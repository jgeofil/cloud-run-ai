# Cloud Run AI Deployment Project Plan

## Objective
Establish a reusable infrastructure-as-code scaffold that provisions Google Cloud Run and Google Cloud Functions resources for two independent workloads (N8N and Lang Flow). Provide supporting Python tooling managed by [uv](https://github.com/astral-sh/uv) and quality gates powered by Ruff.

## Workstreams & Tasks

### 1. Repository Bootstrapping
- [x] Create high-level directory structure for documentation, infrastructure code, and support scripts.
- [x] Author a repository README describing the scaffold and usage expectations.
- [x] Capture this project plan to guide subsequent implementation steps.

### 2. Tooling & Python Environment
- [x] Define a `pyproject.toml` managed by uv with runtime (Python 3.11) and dependencies (`google-cloud-functions`, `google-api-python-client`, `google-cloud-run`, `python-dotenv`, etc.).
- [x] Configure Ruff linting rules via `ruff.toml` and ensure compatibility with uv tasks.
- [x] Provide helper script(s) for environment bootstrapping, e.g., authentication checks or deployment orchestrations.

### 3. Terraform Infrastructure Definition
- [x] Create shared Terraform provider configuration and re-usable locals/variables for project/region settings.
- [x] Implement N8N-specific infrastructure definition for Cloud Run and Cloud Functions.
- [x] Implement Lang Flow-specific infrastructure definition for Cloud Run and Cloud Functions.
- [x] Document required Google APIs and secret management considerations.

### 4. Documentation & Operational Guidance
- [x] Write deployment runbooks detailing prerequisites, initialization, Terraform workflows, and application deployment steps.
- [x] Outline testing & validation methodology for both Cloud Run services and Cloud Functions invocations.
- [x] Describe CI/CD integration hooks for linting (Ruff) and Terraform validation.

### 5. Quality Gates
- [x] Execute Ruff linting to verify Python code quality.
- [ ] Run Terraform `init`/`validate` (plan optional) for both projects to ensure syntactic correctness.

### 6. Future Enhancements (Backlog)
- Automate secret provisioning via Secret Manager.
- Integrate Cloud Build triggers or GitHub Actions for continuous deployment.
- Add monitoring dashboards (Cloud Monitoring) and alerting policies.

## Deliverables
- Terraform configuration files for N8N and Lang Flow projects.
- Python tooling scaffold with uv + Ruff integration.
- Documentation covering setup, deployment, and verification.
- Testing strategy for infrastructure and application validation.
