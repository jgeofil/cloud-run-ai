# Project Plan: Cloud Run and Cloud Functions Deployment Scaffold

## Objectives
- Provide a reusable Terraform scaffold for deploying two independent workloads (N8N and LangFlow) to Google Cloud Run and Google Cloud Functions.
- Standardise Python tooling around UV for dependency management and Ruff for linting.
- Document deployment and testing procedures to accelerate future project work.

## High-Level Phases
1. **Repository Initialization**
   - Create base directory structure for Terraform configurations, Python tooling, and documentation.
   - Configure project-wide `.gitignore`, `pyproject.toml`, and linting settings.

2. **Toolchain Configuration**
   - Set up Python project metadata compatible with UV.
   - Declare Google Cloud Python SDK dependencies and developer tooling (Ruff).
   - Provide helper Python scripts for future automation hooks.

3. **Infrastructure Definition**
   - Draft Terraform provider configuration shared between projects.
   - Author Cloud Run and Cloud Functions resources for N8N.
   - Author Cloud Run and Cloud Functions resources for LangFlow.
   - Expose configurable variables (region, project ID, image names, service account bindings).

4. **Documentation & Testing Guidance**
   - Produce deployment guide describing prerequisites, Terraform workflow, and Python tooling usage.
   - Describe testing methodology covering Terraform validation, deployment smoke tests, and automated linting.

## Task Breakdown
- [x] Establish repository scaffold with directories for Terraform modules, scripts, and documentation.
- [x] Add project plan outlining deliverables and phased milestones.
- [ ] Configure shared Terraform provider settings and remote state placeholders.
- [ ] Implement N8N Terraform configuration (Cloud Run service, supporting Cloud Function, IAM bindings).
- [ ] Implement LangFlow Terraform configuration (Cloud Run service, supporting Cloud Function, IAM bindings).
- [ ] Create Python project metadata and dependency declarations for UV usage.
- [ ] Add Ruff configuration and ensure compatibility with planned codebase.
- [ ] Produce deployment documentation including setup steps, commands, and testing strategy.
- [ ] Validate Terraform files with `terraform fmt`/`terraform validate` (to be performed once Terraform CLI is available).
- [ ] Run Ruff linting against scripts to verify configuration (requires Ruff installation).

## Assumptions & Dependencies
- Google Cloud project(s) already exist and Cloud Run/Cloud Functions APIs are enabled.
- Terraform state storage (e.g., Google Cloud Storage bucket) will be configured by the operator.
- UV is available on the developer workstation or CI runner.
- Deployment images for N8N and LangFlow are stored in a container registry accessible to the Cloud Run services.

## Risks & Mitigations
- **API Enablement**: Document prerequisites for enabling required GCP services.
- **Credential Management**: Encourage use of service accounts and Secret Manager for sensitive values.
- **Drift & Environments**: Structure configuration to support per-environment workspaces, reducing configuration drift.

