#!/usr/bin/env bash
# Replace symlinks with file copies in Claude Code runtime paths (excludes cursor/, new-skills/).
# Usage: ./scripts/materialize-symlinks.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

rel_path() {
  python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$ROOT"
}

materialize() {
  local link="$1"
  local target
  target="$(readlink "$link" 2>/dev/null || true)"
  if [[ -z "$target" ]]; then
    return 0
  fi

  local link_dir abs_target
  link_dir="$(cd "$(dirname "$link")" && pwd)"
  if [[ "$target" = /* ]]; then
    abs_target="$target"
  else
    abs_target="${link_dir}/${target}"
    abs_target="$(cd "$(dirname "$abs_target")" 2>/dev/null && pwd)/$(basename "$abs_target")" || abs_target=""
  fi

  if [[ -n "$abs_target" && ( -f "$abs_target" || -d "$abs_target" ) ]]; then
    rm -f "$link"
    if [[ -d "$abs_target" ]]; then
      cp -R "$abs_target" "$link"
    else
      cp "$abs_target" "$link"
    fi
    echo "  ✓ materialized $(rel_path "$link")"
  else
    rm -f "$link"
    echo "  ✗ removed broken symlink $(rel_path "$link")"
  fi
}

echo "Materializing symlinks under ${ROOT} (excluding cursor/, new-skills/)..."

count=0
while IFS= read -r link; do
  [[ -n "$link" ]] || continue
  materialize "$link"
  count=$((count + 1))
done < <(
  find "$ROOT" -type l \
    ! -path "${ROOT}/cursor/*" \
    ! -path "${ROOT}/new-skills/*" \
    2>/dev/null
)

if [[ "$count" -eq 0 ]]; then
  echo "  (none)"
fi

echo "Done."
