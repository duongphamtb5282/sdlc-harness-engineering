#!/usr/bin/env python3
"""Idempotently merge a markdown section into CLAUDE.md or README.md."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

MARKER_START = "<!-- sdlc-automation-agent:begin -->"
MARKER_END = "<!-- sdlc-automation-agent:end -->"


def merge_section(existing: str, section: str) -> str:
    block = f"{MARKER_START}\n{section.rstrip()}\n{MARKER_END}"
    pattern = re.compile(
        re.escape(MARKER_START) + r".*?" + re.escape(MARKER_END),
        re.DOTALL,
    )
    if pattern.search(existing):
        return pattern.sub(block, existing)
    if existing and not existing.endswith("\n"):
        existing += "\n"
    return existing + "\n" + block + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Update CLAUDE.md with SDLC section")
    parser.add_argument("project_dir")
    parser.add_argument("--file", default="CLAUDE.md")
    args = parser.parse_args()

    section = sys.stdin.read()
    if not section.strip():
        print("No section content on stdin", file=sys.stderr)
        return 1

    project_dir = Path(args.project_dir).resolve()
    target = project_dir / args.file
    existing = target.read_text(encoding="utf-8") if target.exists() else ""
    target.write_text(merge_section(existing, section), encoding="utf-8")
    print(f"Updated {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
