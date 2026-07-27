# sdlc-automation-agent — Single-Machine Install

Install the full multi-agent SDLC delivery system on one machine.

## Quick Install

```bash
# From the project root:
bash scripts/install-agents.sh
```

This installs everything:
- **19 agent roles** — PM, SA, SE, QE, CR, CE, FE, PE, DevOps, SRE, TW, RA, DS, etc.
- **24 stack/delivery plugins** — frontend, backend, cloud, workflows, AI/ML
- **7 hooks** — session start, tool guards, audit logging
- **15 agent stubs** — registered with Claude Code
- **13+ shared protocols** — visual identity, UX, receipt, boundary safety, freshness, etc.
- **Deep Spec** — spec-driven traceability from requirements through delivery
- **Per-agent rules** — `.claude/rules/` scoped to each agent role

## After Install

1. Open any project in Claude Code
2. Describe what you want to build — the orchestrator auto-routes to the right agents
3. Or run `/sdlc-automation-agent` explicitly

## Adding Deep Spec to an Existing Project

```bash
bash scripts/install-deep-spec.sh
```

This scaffolds `.sdlc-automation-agent/.protocols/deep-spec.md`, spec templates, and config.

## Uninstall

```bash
# Remove agent stubs
rm ~/.claude/agents/sdlc-*.md

# Remove plugin
rm -rf ~/.claude/plugins/sdlc-automation-agent

# Remove from settings
# Edit ~/.claude/settings.json — remove sdlc-automation-agent from enabledPlugins
```

## File Reference

| Path | Purpose |
|------|---------|
| `install-agents.sh` | Full system install (19 agents + 24 plugins + hooks + rules) |
| `install-deep-spec.sh` | Deep Spec add-on for spec-driven traceability |
