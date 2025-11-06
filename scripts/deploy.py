"""Utility helpers for interacting with Google Cloud deployment targets.

This script intentionally keeps logic lightweight while demonstrating how the Google Cloud Python
SDK could be used to orchestrate deployment validations. Extend the functions with project-specific
behaviour (trigger Cloud Build pipelines, poll service revisions, etc.).
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass

from google.cloud import secretmanager, storage


@dataclass
class DeploymentContext:
    """Container for reusable deployment parameters."""

    project_id: str
    region: str
    bucket: str | None = None


def read_secret(project_id: str, secret_name: str, version: str = "latest") -> str:
    """Fetch a secret value from Secret Manager."""

    client = secretmanager.SecretManagerServiceClient()
    resource_name = f"projects/{project_id}/secrets/{secret_name}/versions/{version}"
    response = client.access_secret_version(name=resource_name)
    return response.payload.data.decode("utf-8")


def ensure_bucket(context: DeploymentContext) -> None:
    """Create the staging bucket if it does not exist."""

    if not context.bucket:
        msg = "A bucket name is required to ensure storage resources."
        raise ValueError(msg)

    client = storage.Client(project=context.project_id)
    bucket = client.bucket(context.bucket)
    if bucket.exists():
        print(f"Bucket '{context.bucket}' already present.")
        return

    bucket.create(location=context.region)
    print(f"Created bucket '{context.bucket}' in region '{context.region}'.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Deployment helper utilities")
    parser.add_argument("project_id", help="Target Google Cloud project ID")
    parser.add_argument("region", help="Default region for resources")
    parser.add_argument(
        "--bucket",
        help="Optional staging bucket to create if missing",
    )
    parser.add_argument(
        "--secret",
        help="Secret name to read from Secret Manager",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    context = DeploymentContext(project_id=args.project_id, region=args.region, bucket=args.bucket)

    if args.bucket:
        ensure_bucket(context)

    if args.secret:
        secret_value = read_secret(project_id=args.project_id, secret_name=args.secret)
        print(json.dumps({"secret": args.secret, "value": secret_value}, indent=2))


if __name__ == "__main__":
    main()

