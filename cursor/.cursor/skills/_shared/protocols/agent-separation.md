<!-- sdlc-automation-agent-id: agent-separation -->
# Agent Separation Protocol

> **Audience:** All agents, maintainers, and plugin authors.
> **Related:** [reference-sources.md](./reference-sources.md), [plugins/PLUGIN-AGENT-MAP.yaml](../../../plugins/PLUGIN-AGENT-MAP.yaml)

## Rule

This repo has **one delivery agent layer** and **one skills layer**. Do not mix them.

| Layer | Path | Auto-loaded by Claude Code? |
|-------|------|----------------------------|
| **SDLC delivery agents (9 roles)** | `agents/{role}/` | Yes — via root `claude-agents/*.md` stubs |
| **Orchestrator** | `skills/sdlc-automation-agent/` | Yes — root plugin skill |
| **Plugin skills** | `plugins/*/skills/` | Yes — when plugin installed |
| **Quarantined upstream agents** | `plugins/*/reference/agents/` | **No** — maintainer reference only |
| **new-skills/** | `new-skills/` | **No** — sync source only; not part of runtime |

## Loading procedure

1. **Orchestrator dispatch** → `${CLAUDE_PLUGIN_ROOT}/agents/{role}/SKILL.md`
2. **Role references (waves)** → `agents/{role}/references/*.md` per `skill-extensions/registry.yaml`
3. **Stack/workflow skills** → [stack-skill-loading.md](./stack-skill-loading.md)
4. **Never** load `plugins/*/agents/` or `new-skills/` at runtime

## Plugin install contract

| Plugin type | plugin.json |
|-------------|-------------|
| Root orchestrator | `"skills": "./skills"`, `"agents": "./claude-agents"` |
| Stack plugins (frontend, golang, aws, …) | `"skills"` only — **no** `"agents"` |
| Workflow plugins (sdlc-workflows) | `"skills"` + `"commands"` — **no** `"agents"` |
| Optional alt workflows (system-design, staff-engineer) | `"skills"` + `"commands"` — personas in `reference/agents/` |

## Slash commands (/ship, /webperf)

Commands dispatch **canonical agents** by loading reference playbooks:

| Command persona | Canonical agent | Reference file |
|-----------------|-----------------|----------------|
| code-reviewer | `agents/code-reviewer/` | `references/general-review-framework.md` |
| test-engineer | `agents/quality-engineer/` | `references/test-engineer-perspective.md` |
| security-auditor | `agents/security-engineer/` | `references/security-auditor-perspective.md` |
| web-performance-auditor | `agents/code-reviewer/` | `references/web-performance-auditor.md` |

Use `Agent()` with a prompt that includes the reference path — do not rely on duplicate plugin subagent names.

## Maintainer sync

After `./scripts/sync-from-new-skills.sh`:

```bash
./scripts/quarantine-plugin-agents.sh
```

This absorbs plugin agent content into `agents/*/references/` and moves `plugins/*/agents/` to `plugins/*/reference/agents/`.

## Violations

If a plugin reintroduces `agents/code-reviewer.md` at a runtime path:

1. Run `./scripts/quarantine-plugin-agents.sh`
2. Remove `"agents"` from that plugin's `plugin.json`
3. Update [PLUGIN-AGENT-MAP.yaml](../../../plugins/PLUGIN-AGENT-MAP.yaml)
