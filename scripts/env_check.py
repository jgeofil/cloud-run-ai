"""Utility helpers for validating local deployment prerequisites."""

from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path
from typing import Any

from rich.console import Console
from rich.table import Table

console = Console()


def _run_command(command: list[str]) -> tuple[int, str]:
    """Execute a shell command and return the exit code and output."""
    try:
        completed = subprocess.run(
            command,
            check=False,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        return 127, "command not found"

    output = completed.stdout.strip() or completed.stderr.strip()
    return completed.returncode, output


def _check_binary(name: str) -> dict[str, Any]:
    """Check whether a binary exists on PATH and capture version info."""
    path = shutil.which(name)
    status = path is not None
    code, output = _run_command([name, "--version"]) if status else (127, "not installed")

    return {
        "binary": name,
        "status": "available" if status else "missing",
        "details": output,
        "exit_code": code,
        "path": path or "",
    }


def _check_gcloud_project() -> dict[str, Any]:
    """Retrieve the active gcloud project (if configured)."""
    code, output = _run_command([
        "gcloud",
        "config",
        "get-value",
        "project",
    ])
    try:
        project_id = output.strip()
    except AttributeError:
        project_id = ""

    return {
        "binary": "gcloud project",
        "status": "configured" if code == 0 and project_id else "unset",
        "details": project_id or output,
        "exit_code": code,
        "path": "",
    }


def run_checks() -> list[dict[str, Any]]:
    """Execute the suite of environment checks."""
    required_binaries = ["terraform", "gcloud", "uv", "python3"]
    results = [_check_binary(binary) for binary in required_binaries]
    results.append(_check_gcloud_project())
    return results


def main() -> None:
    """Entry point for the environment validation script."""
    results = run_checks()

    table = Table(title="Cloud Run AI Environment Check")
    table.add_column("Component", style="bold")
    table.add_column("Status")
    table.add_column("Details")

    for result in results:
        table.add_row(result["binary"], result["status"], result["details"])

    console.print(table)

    json_report = {
        "results": results,
        "all_passed": all(item["status"] in {"available", "configured"} for item in results),
    }
    output_path = Path(".env-check.json")
    output_path.write_text(json.dumps(json_report, indent=2))
    console.print(f"\nWrote JSON report to {output_path.resolve()}")


if __name__ == "__main__":
    main()
