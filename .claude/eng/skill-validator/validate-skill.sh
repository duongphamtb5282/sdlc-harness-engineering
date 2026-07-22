#!/usr/bin/env bash
# Skill Validator — validates SKILL.md frontmatter and structure
set -euo pipefail

SKILLS_DIR="${1:-./plugins}"
ERRORS=0
PASSED=0

echo "━━━ Skill Validator ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

while IFS= read -r skill; do
  skill_file="$skill/SKILL.md"
  if [ ! -f "$skill_file" ]; then
    continue
  fi

  name=$(basename "$skill")

  # Check frontmatter exists
  if ! head -1 "$skill_file" | grep -q "^---$"; then
    echo "  ✗ $name — missing frontmatter"
    ((ERRORS++))
    continue
  fi

  # Check name field
  if ! grep -q "^name:" "$skill_file"; then
    echo "  ✗ $name — missing 'name:' in frontmatter"
    ((ERRORS++))
    continue
  fi

  # Check description field
  if ! grep -q "^description:" "$skill_file"; then
    echo "  ✗ $name — missing 'description:' in frontmatter"
    ((ERRORS++))
    continue
  fi

  # Check for SKILL.md content (has more than frontmatter + 1 line)
  lines=$(wc -l < "$skill_file")
  if [ "$lines" -lt 5 ]; then
    echo "  ⚠ $name — very short SKILL.md ($lines lines)"
  fi

  ((PASSED++))
done < <(find "$SKILLS_DIR" -maxdepth 3 -type d)

echo ""
echo "━━━ Results ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ $PASSED skills validated"
if [ "$ERRORS" -gt 0 ]; then
  echo "  ✗ $ERRORS skills with errors"
  exit 1
fi
echo "  ✗ 0 errors"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
