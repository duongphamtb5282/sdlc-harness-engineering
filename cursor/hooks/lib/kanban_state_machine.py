#!/usr/bin/env python3
"""Kanban lifecycle state machine for sdlc-automation-agent."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from _state_store import emit, load_json, orchestrator_dir, project_name, save_json, utc_now

STATES = ("DISCOVER", "READY", "EXECUTION", "REVIEW", "RELEASE", "COMPLETE")

TRANSITIONS = {
    "DISCOVER": {"READY"},
    "READY": {"EXECUTION"},
    "EXECUTION": {"REVIEW"},
    "REVIEW": {"READY", "RELEASE"},
    "RELEASE": {"COMPLETE"},
    "COMPLETE": set(),
}


def state_path(project_dir: Path) -> Path:
    return orchestrator_dir(project_dir) / "lifecycle-state.json"


def default_state(project_dir: Path) -> dict:
    return {
        "mode": "kanban",
        "state": "DISCOVER",
        "active_ticket": None,
        "project": project_name(project_dir),
        "updated_at": utc_now(),
        "tickets": {},
        "history": [],
    }


def read_state(project_dir: Path) -> dict:
    return load_json(state_path(project_dir), default_state(project_dir))


def write_state(project_dir: Path, data: dict) -> None:
    data["updated_at"] = utc_now()
    save_json(state_path(project_dir), data)


def cmd_init(project_dir: Path) -> int:
    data = default_state(project_dir)
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
    current = data.get("state", "DISCOVER")
    allowed = TRANSITIONS.get(current, set())
    if target not in allowed and current != target:
        print(f"Invalid transition {current} -> {target}", file=sys.stderr)
        return 1
    data.setdefault("history", []).append({"from": current, "to": target, "at": utc_now()})
    data["state"] = target
    write_state(project_dir, data)
    emit(data)
    return 0


def cmd_pull_ticket(project_dir: Path, ticket_id: str) -> int:
    data = read_state(project_dir)
    data["active_ticket"] = ticket_id
    data.setdefault("tickets", {})[ticket_id] = {
        "id": ticket_id,
        "status": "in_progress",
        "pulled_at": utc_now(),
    }
    if data.get("state") == "READY":
        data["state"] = "EXECUTION"
    write_state(project_dir, data)
    emit(data)
    return 0


def cmd_complete_ticket(project_dir: Path, ticket_id: str) -> int:
    data = read_state(project_dir)
    ticket = data.setdefault("tickets", {}).get(ticket_id, {"id": ticket_id})
    ticket["status"] = "done"
    ticket["completed_at"] = utc_now()
    data["tickets"][ticket_id] = ticket
    write_state(project_dir, data)
    emit({"ticket_id": ticket_id, "status": "done"})
    return 0


def cmd_summary(project_dir: Path) -> int:
    data = read_state(project_dir)
    tickets = data.get("tickets", {})
    emit(
        {
            "mode": data.get("mode", "kanban"),
            "state": data.get("state"),
            "active_ticket": data.get("active_ticket"),
            "ticket_count": len(tickets),
            "done": sum(1 for t in tickets.values() if t.get("status") == "done"),
            "updated_at": data.get("updated_at"),
        }
    )
    return 0


def cmd_evaluate_dod(project_dir: Path, ticket_id: str) -> int:
    receipts_dir = orchestrator_dir(project_dir) / "receipts"
    roles = ("se", "qe", "cr")
    found = {role: (receipts_dir / f"{ticket_id}-{role}.json").exists() for role in roles}
    emit({"ticket_id": ticket_id, "receipts": found, "dod_met": all(found.values())})
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Kanban lifecycle state machine")
    parser.add_argument("command")
    parser.add_argument("project_dir")
    parser.add_argument("arg", nargs="?", default="")
    args = parser.parse_args()

    project_dir = Path(args.project_dir).resolve()
    cmd = args.command

    if cmd == "init":
        return cmd_init(project_dir)
    if cmd == "read":
        return cmd_read(project_dir)
    if cmd == "transition":
        return cmd_transition(project_dir, args.arg)
    if cmd == "pull_ticket":
        return cmd_pull_ticket(project_dir, args.arg)
    if cmd == "complete_ticket":
        return cmd_complete_ticket(project_dir, args.arg)
    if cmd == "summary":
        return cmd_summary(project_dir)
    if cmd == "evaluate_dod":
        return cmd_evaluate_dod(project_dir, args.arg)

    print(f"Unknown command: {cmd}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
