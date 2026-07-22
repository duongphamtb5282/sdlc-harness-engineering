# Portable packages — `.claude` and `.cursor`

Copy these folders into a **product repository** to use the SDLC agents without cloning maintainer tooling.

**Source of truth:** `.claude/` (Claude Code runtime). `.cursor/` is a curated rebuild from `.claude/`.

`new-skills/` is **never** copied into either package.

## Rebuild (maintainers)

```bash
# Merge upstream shelves first (when updated)
./scripts/merge-vue-skills.sh
./scripts/merge-nuxt-skills.sh
./scripts/merge-spring-boot-skills.sh   # optional
./scripts/merge-claude-code-java.sh     # optional
# or: ./scripts/sync-from-new-skills.sh / ./scripts/sync-all.sh

# Validate + refresh packages
./scripts/package-claude.sh   # validates .claude/, refreshes agent stubs
./scripts/package-cursor.sh   # rebuilds .cursor/ from .claude/

# Or one-shot
./scripts/sync-to-cursor.sh [/path/to/product]
```

## Claude Code — `.claude/`

```bash
rsync -a --delete /path/to/agents/.claude/ /path/to/product/.claude/
cd /path/to/product
claude --plugin-dir .claude
# Optional stacks:
claude --plugin-dir .claude \
  --plugin-dir .claude/plugins/stack-vue \
  --plugin-dir .claude/plugins/stack-nuxt
```

| Path | Contents |
|------|----------|
| `skills/` | Orchestrator + `_shared` |
| `agents/` | Role stubs |
| `agent-roles/` | Full role folders |
| `hooks/` | Lifecycle hooks + Python libs |
| `packs/` | Verify snippets |
| `plugins/` | All stack plugins (vue, nuxt, spring, frontend, …) |
| `plugin.json` | Root plugin manifest |

## Cursor — `.cursor/`

```bash
rsync -a --delete /path/to/agents/.cursor/ /path/to/product/.cursor/
# Open the product folder in Cursor
```

| Path | Contents |
|------|----------|
| `rules/*.mdc` | Routing + crew rules |
| `skills/*/` | Roles + Vue/Nuxt/Spring/React curated skills |
| `AGENTS.md` | Optional roster |

## Vue / Nuxt skills

| Upstream (`new-skills/`) | Runtime plugin | Merge script |
|--------------------------|----------------|--------------|
| `skills/` (vuejs-ai) | `.claude/plugins/stack-vue` | `merge-vue-skills.sh` |
| `nuxt-skills/` | `.claude/plugins/stack-nuxt` | `merge-nuxt-skills.sh` |

Propagate to a product `.cursor/skills/`:

```bash
./scripts/sync-stack-vue-nuxt.sh /path/to/product [--with-cursor]
```
