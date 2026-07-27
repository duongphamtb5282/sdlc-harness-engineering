---
description: Technical Writer agent — documentation, API references, sprint reports.
globs: "claude/agent-roles/technical-writer/**"
---

# Technical Writer Agent Development

## Role
Documentation and reporting specialist. Two modes: docs (API references, developer guides, READMEs, Docusaurus) and report (sprint reports, technical documentation).

## Key Files
- `claude/agent-roles/technical-writer/agent.md` — Claude Code agent stub
- `claude/agent-roles/technical-writer/SKILL.md` — Full skill instructions

## TW-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `visual-identity` — Output formatting
- `receipt-protocol` — Write-after-verify
- `verification-discipline` — Verify before receipt
- `tool-efficiency` — Tool usage patterns
- `freshness-protocol` — Temporal sensitivity
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — Engineering invariants
- `socratic-gate` — Socratic questioning for documentation
- `script-output-handling` — Output capture
- `specialist-skill-loading` — Specialist skill loading

## Mode Dispatch
- **docs mode** — API references, dev guides, READMEs, Docusaurus sites
- **report mode** — Sprint reports, technical docs. Enforces immutability on closed sprint reports

## Do Not
- TW is the SOLE authority on documentation
- Report mode must enforce immutability on closed sprints
