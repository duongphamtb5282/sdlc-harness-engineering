#!/usr/bin/env bash
# Validate SKILL.md / agent stub YAML frontmatter for Claude Code runtime paths.
# Usage: ./scripts/validate-skills-frontmatter.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 << PY
from pathlib import Path
import re
import sys

root = Path("${ROOT}")
issues = []

def check_frontmatter(path: Path, label: str) -> None:
    text = path.read_text()
    stripped = re.sub(r"^<!--.*?-->\s*", "", text, count=1, flags=re.S)
    if not re.match(r"^---\n.*?\n---\s*\n", stripped, re.S):
        issues.append(f"{label}: invalid or missing YAML frontmatter ({path})")
        return
    block = re.match(r"^---\n(.*?)\n---", stripped, re.S).group(1)
    if "name:" not in block:
        issues.append(f"{label}: frontmatter missing 'name' ({path})")

for skill in sorted((root / "agents").glob("*/SKILL.md")):
    check_frontmatter(skill, "agent")

check_frontmatter(root / "skills/sdlc-automation-agent/SKILL.md", "orchestrator")

for stub in sorted((root / "claude-agents").glob("*.md")):
    check_frontmatter(stub, "stub")

symlinks = []
for p in root.rglob("*"):
    if p.is_symlink():
        rel = p.relative_to(root)
        parts = rel.parts
        if parts and parts[0] == "cursor":
            continue
        if "new-skills" in parts:
            continue
        symlinks.append(str(rel))

if symlinks:
    for link in sorted(symlinks):
        issues.append(f"symlink: {link} (use file copies in Claude Code runtime)")

if issues:
    print("Frontmatter / symlink validation FAILED:\n")
    for item in issues:
        print(f"  - {item}")
    sys.exit(1)

print("OK: agent SKILL.md, orchestrator, claude-agents stubs, no runtime symlinks")
PY
