#!/usr/bin/env python3
"""Validate agent receipt JSON against receipt-protocol.md."""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

STORY_ID_RE = re.compile(r"^[A-Z]+-\d+$")
VALID_ROLES = {
    "software-engineer",
    "quality-engineer",
    "code-reviewer",
    "compliance-engineer",
    "security-engineer",
    "product-manager",
    "solution-architect",
    "platform-engineer",
    "technical-writer",
    "research-advisor",
    "devops",
    "sre",
    "frontend-engineer",
    "data-scientist",
}


def validate_receipt(receipt_path: Path, project_dir: Path) -> list[str]:
    errors: list[str] = []
    if not receipt_path.exists():
        return [f"Receipt not found: {receipt_path}"]

    try:
        data = json.loads(receipt_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        return [f"Invalid JSON: {exc}"]

    if not isinstance(data, dict):
        return ["Receipt must be a JSON object"]

    for field in ("story_id", "role", "artifacts", "metrics", "verification_commands", "completed_at"):
        if field not in data:
            errors.append(f"Missing required field: {field}")

    story_id = data.get("story_id", "")
    if not isinstance(story_id, str) or not STORY_ID_RE.match(story_id):
        errors.append(f"Invalid story_id: {story_id!r}")

    role = data.get("role", "")
    if role not in VALID_ROLES:
        errors.append(f"Unknown role: {role!r}")

    artifacts = data.get("artifacts", [])
    if not isinstance(artifacts, list) or not artifacts:
        errors.append("artifacts must be a non-empty list")
    else:
        for path in artifacts:
            if not isinstance(path, str):
                errors.append("artifact paths must be strings")
                continue
            full = project_dir / path
            if not full.exists():
                errors.append(f"Artifact missing on disk: {path}")

    metrics = data.get("metrics", {})
    if not isinstance(metrics, dict) or not metrics:
        errors.append("metrics must be a non-empty object")

    verify = data.get("verification_commands", [])
    if not isinstance(verify, list) or not verify:
        errors.append("verification_commands must be a non-empty list")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate SDLC agent receipt")
    parser.add_argument("receipt_path")
    parser.add_argument("project_dir")
    args = parser.parse_args()

    receipt_path = Path(args.receipt_path)
    project_dir = Path(args.project_dir).resolve()
    errors = validate_receipt(receipt_path, project_dir)

    if errors:
        print(json.dumps({"valid": False, "errors": errors}, indent=2))
        return 1

    print(json.dumps({"valid": True, "receipt": str(receipt_path)}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
