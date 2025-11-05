"""Configuration primitives shared across deployment workflows."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Mapping


@dataclass(slots=True)
class DeploymentConfig:
    """Configuration describing a deployable workload."""

    project_id: str
    region: str
    image: str
    service_account_email: str
    environment: Mapping[str, str] = field(default_factory=dict)
    labels: Mapping[str, str] = field(default_factory=dict)
    annotations: Mapping[str, str] = field(default_factory=dict)


@dataclass(slots=True)
class FunctionConfig:
    """Configuration describing a Cloud Functions deployment."""

    project_id: str
    region: str
    runtime: str
    entry_point: str
    source_dir: Path
    service_account_email: str
    environment: Mapping[str, str] = field(default_factory=dict)
    labels: Mapping[str, str] = field(default_factory=dict)


def merge_env(*envs: Mapping[str, str]) -> dict[str, str]:
    """Merge multiple environment dictionaries, latter values winning."""

    result: dict[str, str] = {}
    for env in envs:
        result.update(env)
    return result


def sanitize_label(value: str) -> str:
    """Sanitize label values to satisfy GCP naming requirements."""

    sanitized = value.lower().replace("_", "-")
    return sanitized[:63]


def default_labels(service: str) -> dict[str, str]:
    """Return a consistent label set for Cloud Run/Functions services."""

    return {
        "managed-by": "terraform",
        "component": sanitize_label(service),
        "application": "cloud-run-ai",
    }
