# AGENTS.md — Cursor SDLC delivery

This repository is the **Cursor** runtime for SDLC agents (not Claude Code).

## How work is routed

1. Prefer **`sdlc-automation-agent`** for multi-step delivery (build, sprint, discover, debug, release).
2. For a single concern, invoke the matching role under `.cursor/skills/` (backed by `agents/{role}/`).
3. Load stack packs from `packs/` using `docs/architecture/tech-stack.yaml` / `.sdlc-automation-agent.yaml`.
4. Stack depth lives in `plugins/stack-*`, `plugins/system-design`, `plugins/sdlc-workflows`, etc.

## Roster

| Agent | Path |
|-------|------|
| Product Manager | `agents/product-manager/` |
| Solution Architect | `agents/solution-architect/` |
| Software Engineer | `agents/software-engineer/` |
| Frontend Engineer | `agents/frontend-engineer/` |
| Data Scientist | `agents/data-scientist/` |
| Quality Engineer | `agents/quality-engineer/` |
| DevOps | `agents/devops/` |
| SRE | `agents/sre/` |
| Platform Engineer | `agents/platform-engineer/` |
| Security Engineer | `agents/security-engineer/` |
| Code Reviewer | `agents/code-reviewer/` |
| Technical Writer | `agents/technical-writer/` |
| Research Advisor | `agents/research-advisor/` |

Legacy alias: `compliance-engineer` → `security-engineer`.

Full map: `plugins/AGENT-SKILL-MAP.yaml`, `agents/AGENTS-ROSTER.md`.

## Rules

Always-on and path-scoped rules: `.cursor/rules/*.mdc` (sourced from `rules/`).
