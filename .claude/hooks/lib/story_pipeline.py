#!/usr/bin/env python3
"""Per-story SE -> QE -> CR pipeline state."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from _state_store import emit, load_json, orchestrator_dir, save_json, utc_now

STATES = ("queued", "in_progress", "testing", "reviewing", "done", "blocked")

TRANSITIONS = {
    "queued": {"in_progress", "blocked"},
    "in_progress": {"testing", "blocked"},
    "testing": {"reviewing", "blocked"},
    "reviewing": {"done", "blocked"},
    "blocked": {"queued", "in_progress", "testing", "reviewing"},
    "done": set(),
}


def pipeline_path(project_dir: Path) -> Path:
    return orchestrator_dir(project_dir) / "story-pipeline.json"


def read_pipeline(project_dir: Path) -> dict:
    return load_json(pipeline_path(project_dir), {"stories": {}, "updated_at": utc_now()})


def write_pipeline(project_dir: Path, data: dict) -> None:
    data["updated_at"] = utc_now()
    save_json(pipeline_path(project_dir), data)


def get_story(data: dict, story_id: str) -> dict:
    return data.setdefault("stories", {}).setdefault(
        story_id,
        {"id": story_id, "state": "queued", "history": []},
    )


def cmd_transition(project_dir: Path, story_id: str, target: str, reason: str) -> int:
    if target not in STATES:
        print(f"Unknown state: {target}", file=sys.stderr)
        return 1
    data = read_pipeline(project_dir)
    story = get_story(data, story_id)
    current = story.get("state", "queued")
    allowed = TRANSITIONS.get(current, set())
    if target not in allowed and current != target:
        print(f"Invalid transition {story_id}: {current} -> {target}", file=sys.stderr)
        return 1
    story.setdefault("history", []).append(
        {"from": current, "to": target, "at": utc_now(), "reason": reason or None}
    )
    story["state"] = target
    if reason:
        story["block_reason"] = reason
    elif target != "blocked":
        story.pop("block_reason", None)
    data["stories"][story_id] = story
    write_pipeline(project_dir, data)
    emit(story)
    return 0


def cmd_list_stories(project_dir: Path, state: str) -> int:
    data = read_pipeline(project_dir)
    matches = [
        s for s in data.get("stories", {}).values() if s.get("state") == state
    ]
    emit({"state": state, "count": len(matches), "stories": matches})
    return 0


def cmd_get_story(project_dir: Path, story_id: str) -> int:
    data = read_pipeline(project_dir)
    story = data.get("stories", {}).get(story_id)
    if not story:
        print(f"Story not found: {story_id}", file=sys.stderr)
        return 1
    emit(story)
    return 0


def cmd_unblock(project_dir: Path, story_id: str) -> int:
    data = read_pipeline(project_dir)
    story = data.get("stories", {}).get(story_id)
    if not story:
        print(f"Story not found: {story_id}", file=sys.stderr)
        return 1
    prior = "queued"
    for entry in reversed(story.get("history", [])):
        if entry.get("from") and entry.get("from") != "blocked":
            prior = entry.get("from", "queued")
            break
    return cmd_transition(project_dir, story_id, prior, "")


def cmd_aggregate_dod(project_dir: Path) -> int:
    data = read_pipeline(project_dir)
    stories = data.get("stories", {})
    emit(
        {
            "total": len(stories),
            "done": sum(1 for s in stories.values() if s.get("state") == "done"),
            "blocked": sum(1 for s in stories.values() if s.get("state") == "blocked"),
            "in_flight": sum(
                1
                for s in stories.values()
                if s.get("state") in ("in_progress", "testing", "reviewing")
            ),
        }
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Story pipeline state")
    parser.add_argument("command")
    parser.add_argument("project_dir")
    parser.add_argument("story_id", nargs="?", default="")
    parser.add_argument("target_state", nargs="?", default="")
    parser.add_argument("--reason", default="")
    args = parser.parse_args()

    project_dir = Path(args.project_dir).resolve()
    cmd = args.command

    if cmd == "transition":
        return cmd_transition(project_dir, args.story_id, args.target_state, args.reason)
    if cmd == "list_stories":
        return cmd_list_stories(project_dir, args.story_id)
    if cmd == "get_story":
        return cmd_get_story(project_dir, args.story_id)
    if cmd == "unblock":
        return cmd_unblock(project_dir, args.story_id)
    if cmd == "aggregate_dod":
        return cmd_aggregate_dod(project_dir)

    print(f"Unknown command: {cmd}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
