# Portable Cursor package (`.cursor`)

Copy this folder into a **product repository root** so Cursor loads rules and skills.

## Install into a product repo

```bash
./scripts/package-cursor.sh
rsync -a --delete .cursor/ /path/to/your-product/.cursor/
```

Open the **product repo** in Cursor.

## Layout

| Path | Contents |
|------|----------|
| `rules/*.mdc` | Always-on / scoped Cursor rules |
| `skills/*/` | Delivery roles + Vue/Nuxt/Spring/React skills |
| `AGENTS.md` | Optional project agent roster |

## Rebuild after merging new skills

```bash
./scripts/sync-from-new-skills.sh   # merges into .claude/
./scripts/package-cursor.sh         # refreshes .cursor/ from .claude/
```

## Excluded

- `new-skills/` — never copied into `.cursor`
