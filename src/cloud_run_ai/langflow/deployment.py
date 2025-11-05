"""Deployment helpers for the LangFlow application."""

from __future__ import annotations

from pathlib import Path
from typing import Mapping

from cloud_run_ai.common.config import DeploymentConfig, FunctionConfig, default_labels, merge_env


def cloud_run_config(
    project_id: str,
    region: str,
    image: str,
    service_account_email: str,
    *,
    environment: Mapping[str, str] | None = None,
) -> DeploymentConfig:
    """Produce a Cloud Run configuration tailored for LangFlow."""

    base_env = {
        "LANGFLOW_DATABASE_URL": "sqlite:///data/langflow.db",
        "LANGFLOW_PORT": "8080",
    }
    merged_env = merge_env(base_env, environment or {})

    return DeploymentConfig(
        project_id=project_id,
        region=region,
        image=image,
        service_account_email=service_account_email,
        environment=merged_env,
        labels=default_labels("langflow-cloud-run"),
        annotations={
            "autoscaling.knative.dev/minScale": "0",
            "run.googleapis.com/client-name": "terraform",
        },
    )


def cloud_function_config(
    project_id: str,
    region: str,
    runtime: str,
    entry_point: str,
    source_dir: str,
    service_account_email: str,
    *,
    environment: Mapping[str, str] | None = None,
) -> FunctionConfig:
    """Produce a Cloud Functions configuration for LangFlow batch tasks."""

    base_env = {
        "LANGFLOW_API_URL": "https://example.com/api",
    }
    merged_env = merge_env(base_env, environment or {})

    return FunctionConfig(
        project_id=project_id,
        region=region,
        runtime=runtime,
        entry_point=entry_point,
        source_dir=Path(source_dir),
        service_account_email=service_account_email,
        environment=merged_env,
        labels=default_labels("langflow-cloud-function"),
    )
