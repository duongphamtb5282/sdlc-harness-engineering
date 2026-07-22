#!/usr/bin/env python3
"""Scrum lifecycle state machine for sdlc-automation-agent."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from _state_store import emit, load_json, orchestrator_dir, project_name, save_json, utc_now

STATES = (
    "INCEPTION",
    "SPRINT_PLANNING",
    "SPRINT_EXECUTION",
    "SPRINT_REVIEW",
    "SPRINT_CLOSE",
    "RELEASE",
    "COMPLETE",
)

TRANSITIONS = {
    "INCEPTION": {"SPRINT_PLANNING"},
    "SPRINT_PLANNING": {"SPRINT_EXECUTION"},
    "SPRINT_EXECUTION": {"SPRINT_REVIEW"},
    "SPRINT_REVIEW": {"SPRINT_CLOSE"},
    "SPRINT_CLOSE": {"SPRINT_PLANNING", "RELEASE"},
    "RELEASE": {"COMPLETE"},
    "COMPLETE": set(),
}


def state_path(project_dir: Path) -> Path:
    return orchestrator_dir(project_dir) / "lifecycle-state.json"


def default_state(project_dir: Path) -> dict:
    return {
        "mode": "scrum",
        "state": "INCEPTION",
        "sprint_number": 0,
        "project": project_name(project_dir),
        "updated_at": utc_now(),
        "history": [],
    }


def read_state(project_dir: Path) -> dict:
    return load_json(state_path(project_dir), default_state(project_dir))


def write_state(project_dir: Path, data: dict) -> None:
    data["updated_at"] = utc_now()
    save_json(state_path(project_dir), data)


def cmd_init(project_dir: Path, args: argparse.Namespace) -> int:
    data = default_state(project_dir)
    data["state"] = "INCEPTION"
    data["sprint_number"] = 1
    write_state(project_dir, data)
    emit(data)
    return 0


def cmd_read(project_dir: Path) -> int:
    emit(read_state(project_dir))
    return 0


def cmd_transition(project_dir: Path, target: str) -> int:
    target = target.upper()
    if target not in STATES:
        print(f"Unknown state: {target}", file=sys.stderr)
        return 1
    data = read_state(project_dir)
    current = data.get("state", "INCEPTION")
    allowed = TRANSITIONS.get(current, set())
    if target not in allowed and current != target:
        print(f"Invalid transition {current} -> {target}", file=sys.stderr)
        return 1
    data.setdefault("history", []).append({"from": current, "to": target, "at": utc_now()})
    data["state"] = target
    write_state(project_dir, data)
    emit(data)
    return 0


def cmd_complete_sprint(project_dir: Path) -> int:
    data = read_state(project_dir)
    data["sprint_number"] = int(data.get("sprint_number", 0)) + 1
    data.setdefault("history", []).append(
        {"event": "complete_sprint", "sprint": data["sprint_number"], "at": utc_now()}
    )
    write_state(project_dir, data)
    emit(data)
    return 0


def cmd_close_sprint(project_dir: Path) -> int:
    return cmd_transition(project_dir, "SPRINT_CLOSE")


def cmd_summary(project_dir: Path) -> int:
    data = read_state(project_dir)
    emit(
        {
            "mode": data.get("mode", "scrum"),
            "state": data.get("state"),
            "sprint_number": data.get("sprint_number", 0),
            "project": data.get("project"),
            "updated_at": data.get("updated_at"),
        }
    )
    return 0


def cmd_evaluate_dod(project_dir: Path, story_id: str) -> int:
    receipts_dir = orchestrator_dir(project_dir) / "receipts"
    roles = ("se", "qe", "cr")
    found = {
        role: (receipts_dir / f"{story_id}-{role}.json").exists() for role in roles
    }
    emit(
        {
            "story_id": story_id,
            "receipts": found,
            "dod_met": all(found.values()),
            "note": "Full DoD also requires verify commands in receipts — use receipt_validator.py",
        }
    )
    return 0


def cmd_transition_to_kanban(project_dir: Path) -> int:
    data = read_state(project_dir)
    data["mode"] = "kanban"
    data["state"] = "DISCOVER"
    data.setdefault("history", []).append({"event": "transition_to_kanban", "at": utc_now()})
    write_state(project_dir, data)
    emit(data)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Scrum lifecycle state machine")
    parser.add_argument("command")
    parser.add_argument("project_dir")
    parser.add_argument("arg", nargs="?", default="")
    parser.add_argument("--reason", default="")
    args = parser.parse_args()

    project_dir = Path(args.project_dir).resolve()
    cmd = args.command

    if cmd == "init":
        return cmd_init(project_dir, args)
    if cmd == "read":
        return cmd_read(project_dir)
    if cmd == "transition":
        return cmd_transition(project_dir, args.arg)
    if cmd == "complete_sprint":
        return cmd_complete_sprint(project_dir)
    if cmd == "close_sprint":
        return cmd_close_sprint(project_dir)
    if cmd == "summary":
        return cmd_summary(project_dir)
    if cmd == "evaluate_dod":
        return cmd_evaluate_dod(project_dir, args.arg)
    if cmd == "transition_to_kanban":
        return cmd_transition_to_kanban(project_dir)

    print(f"Unknown command: {cmd}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
