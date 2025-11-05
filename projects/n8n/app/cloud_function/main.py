"""N8N Cloud Function entry point.

This stub provides a starting point for handling Pub/Sub-triggered workflows that extend the primary N8N deployment. Update the
`handle` function with project-specific logic.
"""

from __future__ import annotations

import base64
import json
from collections.abc import Mapping
from typing import Any


def handle(event: Mapping[str, Any], context: Any) -> None:
    """Process a Pub/Sub event emitted from N8N webhooks.

    Args:
        event: Pub/Sub event payload containing a base64 encoded message.
        context: Metadata about the triggering event supplied by Cloud Functions.
    """

    data = event.get("data")
    if not data:
        print("No data provided in Pub/Sub message.")
        return

    payload = json.loads(base64.b64decode(data).decode("utf-8"))
    print(f"Received payload from N8N: {payload}")
