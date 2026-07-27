---
description: Solution Architect agent — system design, API contracts, ADRs, data models. Scoped to SA agent files.
globs: "claude/agent-roles/solution-architect/**"
---

# Solution Architect Agent Development

## Role
System architecture designer. Tech stack decisions, API contracts (OpenAPI/gRPC), data models, ADRs, infrastructure shape.

## Key Files
- `claude/agent-roles/solution-architect/agent.md` — Claude Code agent stub
- `claude/agent-roles/solution-architect/SKILL.md` — Full skill instructions

## SA-Specific Protocol References
When editing SKILL.md, ensure these SA-specific protocols are referenced:
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `visual-identity` — Output formatting (━━━ headers, phase progress)
- `freshness-protocol` — Temporal sensitivity for tech decisions
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — Engineering invariants
- `verification-discipline` — Verify before receipt
- `socratic-gate` — Socratic questioning for design decisions
- `anti-safe-harbor` — Anti-safe-harbor patterns
- `script-output-handling` — Output capture
- `source-attribution` — Source tracking
- `open-decision-registry` — Decision logging
- `specialist-skill-loading` — Loading specialist skills
- `stack-skill-loading` — Stack plugin skill loading
- `tech-pack-loading` — Tech pack conventions

## Phase Files
SA has phase files in `phases/`. When editing, ensure phase ordering is:
1. Context & Requirements Analysis
2. HLD / Architecture Design
3. Tech Stack Selection
4. API Contracts
5. Data Model
6. ADRs

## Do Not
- SA owns HOW to build — does NOT change requirements
- SA produces API contracts — downstream SE implements them faithfully
