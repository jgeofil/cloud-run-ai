"""LangFlow Cloud Function entry point.

This HTTP-triggered function can be used to execute lightweight orchestration tasks against the LangFlow Cloud Run service. The
stub simply proxies requests to illustrate the expected structure.
"""

from __future__ import annotations

import os
from typing import Any

import functions_framework
import requests

LANGFLOW_URL = os.getenv("LANGFLOW_URL", "")


@functions_framework.http
def handle(request: Any):
    """Proxy HTTP requests to the LangFlow Cloud Run endpoint.

    Args:
        request: Flask request object provided by Functions Framework.
    """

    if not LANGFLOW_URL:
        return ("LANGFLOW_URL environment variable is not configured", 500)

    target_url = f"{LANGFLOW_URL}{request.path}"
    response = requests.request(
        method=request.method,
        url=target_url,
        headers={key: value for key, value in request.headers if key != "Host"},
        data=request.get_data(),
        params=request.args,
        timeout=30,
    )

    return (response.content, response.status_code, dict(response.headers))
