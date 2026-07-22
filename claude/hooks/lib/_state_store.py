#!/usr/bin/env python3
"""Shared JSON state helpers for SDLC lifecycle hooks."""
from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def orchestrator_dir(project_dir: str | Path) -> Path:
    return Path(project_dir) / ".sdlc-automation-agent" / ".orchestrator"


def load_json(path: Path, default: dict[str, Any]) -> dict[str, Any]:
    if not path.exists():
        return dict(default)
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if isinstance(data, dict):
            return data
    except (json.JSONDecodeError, OSError):
        pass
    return dict(default)


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def project_name(project_dir: Path) -> str:
    yaml_path = project_dir / ".sdlc-automation-agent.yaml"
    if yaml_path.exists():
        for line in yaml_path.read_text(encoding="utf-8", errors="ignore").splitlines():
            if line.strip().startswith("name:"):
                return line.split(":", 1)[1].strip().strip('"').strip("'")
    return project_dir.name


def emit(obj: Any) -> None:
    print(json.dumps(obj, indent=2))
