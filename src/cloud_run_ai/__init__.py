"""Utilities for managing Cloud Run and Cloud Functions deployments for N8N and LangFlow."""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("cloud-run-ai")
except PackageNotFoundError:  # pragma: no cover - package metadata absent during development
    __version__ = "0.0.0"

__all__ = ["__version__"]
