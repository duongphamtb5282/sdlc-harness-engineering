<!-- sdlc-automation-agent-id: reference-sources -->
# Reference Sources Protocol

> **Audience:** All agents, hooks, and maintainers.
> **Related:** [new-skills/README.md](../../../new-skills/README.md), [stack-skill-loading.md](./stack-skill-loading.md), [specialist-skill-loading.md](./specialist-skill-loading.md)

## Rule

**Never load, edit, or depend on `new-skills/` at runtime.**

`new-skills/` is a **reference shelf** of upstream repositories. Delivery uses **canonical copies** only:

| Layer | Path |
|-------|------|
| Orchestrator + delivery agents | Repo root: `agents/`, `skills/sdlc-automation-agent/` |
| Universal specialist skills | `skills/_shared/specialist-skills/` |
| Stack / workflow plugins | `plugins/{plugin-name}/skills/` |
| Stack verify snippets | `packs/languages/*`, `packs/clouds/*` |
| Agent skill routing | `plugins/AGENT-SKILL-MAP.yaml`, `agents/*/skill-extensions/registry.yaml` |
| Plugin agent quarantine | `plugins/PLUGIN-AGENT-MAP.yaml`, `skills/_shared/protocols/agent-separation.md` |

## Loading procedure (unchanged)

1. **Specialist skills** → [specialist-skill-loading.md](./specialist-skill-loading.md) → `skills/_shared/specialist-skills/`
2. **Stack plugins** → [stack-skill-loading.md](./stack-skill-loading.md) → `plugins/*/skills/`
3. **Never** substitute `new-skills/…` even if content looks identical

## Maintainer sync (human or explicit script only)

```bash
./scripts/sync-from-new-skills.sh
./scripts/quarantine-plugin-agents.sh   # also runs at end of sync
```

Run from repo root when upstream reference repos change. Commit **canonical** paths after sync.

## Coverage map

Full folder → canonical mapping: [plugins/REFERENCE-MAP.yaml](../../../plugins/REFERENCE-MAP.yaml).

## Optional plugins

| Plugin | Install when |
|--------|----------------|
| `plugins/staff-engineer` | Alternative senior-staff workflow (delegation, forensic debug, worktrees) |
| `plugins/claude-skills-catalog` | Synced by `./scripts/sync-from-new-skills.sh` — 66 extended role skills; see `DEPRECATED-SKILLS.yaml` (e.g. `golang-pro` → use `stack-golang`) |

Delivery agents (including devops, sre, security-engineer): **`agents/`** only — see [AGENTS-ROSTER.md](../../../agents/AGENTS-ROSTER.md). `plugins/production-grade` was removed.

## Violations

If an agent instruction, hook, or doc points to `new-skills/`:

1. Treat as **bug** — update to canonical path
2. If content is missing from canonical copy, **sync** then point to `plugins/` or `skills/_shared/`
