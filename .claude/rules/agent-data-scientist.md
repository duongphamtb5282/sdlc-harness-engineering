---
description: Data Scientist / AI-ML Engineer agent — AI/ML pipelines, LLMs, data processing. Scoped to DS/AI-ML agent files.
globs: "claude/agent-roles/data-scientist/**"
---

# Data Scientist Agent Development

## Role
AI/ML pipeline specialist. LLM optimization, agent frameworks, experiment design, data pipelines, ML infrastructure.

## Key Files
- `claude/agent-roles/data-scientist/agent.md` — Claude Code agent stub
- `claude/agent-roles/data-scientist/SKILL.md` — Full skill instructions

## DS-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity (model IDs, pricing)
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy

## Do Not
- Always use WebSearch for current model IDs and pricing (Tier 1 freshness)
- Annotate cost estimates with "verify current pricing"
- Do NOT use stale model capabilities from training data
