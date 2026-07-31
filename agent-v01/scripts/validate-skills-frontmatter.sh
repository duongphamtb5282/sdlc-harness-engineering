#!/usr/bin/env bash
# Validate SKILL.md / agent stub YAML frontmatter for the agent-v01 structure.
# Checks: agents/*.md, agent-skills/*/SKILL.md, and no symlinks in runtime dirs.
# Usage: ./agent-v01/validate-skills-frontmatter.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

python3 << PY
from pathlib import Path
import re
import sys

root = Path("${ROOT}")
ag = root / "agent-v01"
issues = []

def check_frontmatter(path: Path, label: str) -> None:
    if not path.exists():
        issues.append(f"{label}: missing file ({path})")
        return
    text = path.read_text()
    stripped = re.sub(r"^<!--.*?-->\s*", "", text, count=1, flags=re.S)
    if not re.match(r"^---\n.*?\n---\s*\n", stripped, re.S):
        issues.append(f"{label}: invalid or missing YAML frontmatter ({path})")
        return
    block = re.match(r"^---\n(.*?)\n---", stripped, re.S).group(1)
    if "name:" not in block:
        issues.append(f"{label}: frontmatter missing 'name' ({path})")

# 1. Agent persona definitions
for stub in sorted((ag / "agents").glob("*.md")):
    check_frontmatter(stub, "agent")

# 2. BMAD persona skills (agent-skills/*/SKILL.md)
for skill in sorted((ag / "agent-skills").glob("*/SKILL.md")):
    check_frontmatter(skill, "skill")

# 3. Stack skill entries (stacks/*/*/SKILL.md — one level deep)
for skill in sorted((ag / "stacks").glob("*/*/SKILL.md")):
    check_frontmatter(skill, "stack-skill")

# 4. No symlinks in the runtime structure (direct-copy policy)
symlinks = []
for p in ag.rglob("*"):
    if p.is_symlink():
        rel = str(p.relative_to(root))
        # Upstream content repos may contain internal symlinks — only flag structure dirs
        if not ("core-skills" in rel or "BMAD-METHOD" in rel):
            symlinks.append(rel)

if symlinks:
    for link in sorted(symlinks):
        issues.append(f"symlink: {link} (use file copies in agent-v01 structure)")

if issues:
    print("Frontmatter / symlink validation FAILED:\n")
    for item in issues:
        print(f"  - {item}")
    sys.exit(1)

print("OK: agents, agent-skills, stack SKILL.md frontmatter valid; no structure symlinks")
PY
