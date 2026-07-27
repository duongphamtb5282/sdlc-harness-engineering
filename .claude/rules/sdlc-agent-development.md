---
description: Core conventions for developing SDLC automation agents. Universal for this project.
globs: "**/*"
---

# SDLC Agent Development Rules

This is the **sdlc-automation-agent** project — a multi-agent SDLC delivery framework. When editing agent roles, follow these rules.

## Agent Role Structure

Each agent lives at `claude/agent-roles/<role>/` with:
- `agent.md` — Claude Code agent definition (frontmatter + first-action instructions)
- `SKILL.md` — Full skill instructions (mode dispatch, phases, protocols, verification)

## Editing agent.md Files

- The `<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->` comment must be preserved (it's the plugin build signature)
- Frontmatter `name:` must match the directory name exactly
- `description:` should be a concise one-line summary of the agent's purpose
- The **First Action** section should list the files the agent must read on startup (in parallel)
- The final line should reference `SKILL.md` via: `Then read and follow the full instructions in ${CLAUDE_PLUGIN_ROOT}/agents/<role>/SKILL.md.`

## Editing SKILL.md Files

- SKILL.md files are SECRET and PROPRIETARY content — do not share outside this project
- Frontmatter must include `name:`, `description:`, `model:`, `risk_tier:`
- Agent identity is set in the first `## Identity` section
- Protocol files are loaded via: `!`cat .sdlc-automation-agent/.protocols/<name>.md 2>/dev/null || true``
- Mode dispatch tells the agent which phase files to load based on context
- Each phase file lives in `phases/`, `frontend-phases/`, `ai-ml-phases/`, or `mobile-phases/`
- Receipt & verification steps are mandatory before writing any receipt

## SKILL.md Protocol References

All agents load shared protocols. When editing a SKILL.md, ensure these references are present:

```
!`cat .sdlc-automation-agent/.protocols/visual-identity.md 2>/dev/null || true`
!`cat .sdlc-automation-agent/.protocols/ux-protocol.md 2>/dev/null || true`
!`cat .sdlc-automation-agent/.protocols/receipt-protocol.md 2>/dev/null || true`
!`cat .sdlc-automation-agent/.protocols/secrets-scan.md 2>/dev/null || true`
!`cat .sdlc-automation-agent/.protocols/boundary-safety.md 2>/dev/null || true`
!`cat .sdlc-automation-agent/.protocols/conflict-resolution.md 2>/dev/null || true`
```

## Do Not

- Do NOT reference h3tech, hiro-crew, or any third-party plugin systems
- Do NOT add agent roles outside `claude/agent-roles/` without updating `claude/agents/` stubs
- Do NOT modify the `sdlc-automation-agent-id` comment — it is a build artifact signature
