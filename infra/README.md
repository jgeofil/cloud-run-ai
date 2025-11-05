# Shared Infrastructure

Terraform configuration in this directory defines shared GCP resources such as service accounts, Artifact Registry repositories, and networking that can be reused by multiple application projects. Each environment (e.g., `shared`, `dev`, `prod`) receives its own subdirectory under `infra/envs/` with independent state files.

Modules stored under `infra/modules/` encapsulate reusable building blocks consumed by individual environments or application stacks.
