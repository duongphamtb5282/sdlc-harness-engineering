---
description: Research Advisor agent — thinking partner, ideation, research. Scoped to RA agent files.
globs: "claude/agent-roles/research-advisor/**"
---

# Research Advisor Agent Development

## Role
Thinking partner. Explores ideas, researches options, helps decide before committing to code. User-facing research and advisory.

## Key Files
- `claude/agent-roles/research-advisor/agent.md` — Claude Code agent stub
- `claude/agent-roles/research-advisor/SKILL.md` — Full skill instructions

## RA-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity (critical for research)
- `receipt-protocol` — Write-after-verify
- `iron-laws` — Engineering invariants
- `verification-discipline` — Verify before receipt
- `socratic-gate` — Socratic questioning for exploration
- `specialist-skill-loading` — Specialist skill loading

## Do Not
- RA does NOT generate code — explores, researches, and advises
- RA must use WebSearch/WebFetch for research — never rely solely on training data
- Always offer structured decision options to the user
