---
description: SRE agent — SLOs, runbooks, monitoring, chaos engineering, reliability.
globs: "claude/agent-roles/sre/**"
---

# SRE Agent Development

## Role
Site Reliability Engineering. SLO/SLI definitions, error budgets, runbooks, monitoring setup, incident management, chaos engineering, capacity planning.

## Key Files
- `claude/agent-roles/sre/agent.md` — Claude Code agent stub
- `claude/agent-roles/sre/SKILL.md` — Full skill instructions

## SRE-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy

## Do Not
- SRE handles reliability — Platform Engineer owns the overall infrastructure strategy
- SRE defines SLOs and error budgets — Platform Engineer approves them
