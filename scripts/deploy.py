"""Command line entry points for orchestrating deployments."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Literal

import click

from cloud_run_ai.common.config import DeploymentConfig, FunctionConfig
from cloud_run_ai.langflow.deployment import cloud_function_config as langflow_function_config
from cloud_run_ai.langflow.deployment import cloud_run_config as langflow_cloud_run_config
from cloud_run_ai.n8n.deployment import cloud_function_config as n8n_function_config
from cloud_run_ai.n8n.deployment import cloud_run_config as n8n_cloud_run_config

ProjectName = Literal["n8n", "langflow"]


@click.group()
def cli() -> None:
    """Expose commands for inspecting deployment manifests."""


def _serialize_config(config: DeploymentConfig | FunctionConfig) -> str:
    payload = json.dumps(config.__dict__, default=str, indent=2, sort_keys=True)
    return payload


@cli.command("show-config")
@click.argument("project", type=click.Choice(["n8n", "langflow"]))
@click.option("--target", type=click.Choice(["cloud-run", "cloud-functions"]), default="cloud-run")
@click.option("--project-id", required=True)
@click.option("--region", required=True)
@click.option("--image", default="")
@click.option("--service-account", required=True)
@click.option("--runtime", default="python311")
@click.option("--entry-point", default="main")
@click.option("--source", type=click.Path(path_type=Path), default=Path("."))
def show_config(
    project: ProjectName,
    target: str,
    project_id: str,
    region: str,
    image: str,
    service_account: str,
    runtime: str,
    entry_point: str,
    source: Path,
) -> None:
    """Print the resolved deployment configuration for inspection."""

    if project == "n8n" and target == "cloud-run":
        config = n8n_cloud_run_config(project_id, region, image, service_account)
    elif project == "n8n" and target == "cloud-functions":
        config = n8n_function_config(
            project_id,
            region,
            runtime,
            entry_point,
            str(source),
            service_account,
        )
    elif project == "langflow" and target == "cloud-run":
        config = langflow_cloud_run_config(project_id, region, image, service_account)
    else:
        config = langflow_function_config(
            project_id,
            region,
            runtime,
            entry_point,
            str(source),
            service_account,
        )

    click.echo(_serialize_config(config))


if __name__ == "__main__":
    cli()
