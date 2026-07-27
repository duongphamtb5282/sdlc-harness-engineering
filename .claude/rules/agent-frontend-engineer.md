---
description: Frontend Engineer agent — React/Next.js, design systems, UI. Scoped to FE agent files.
globs: "claude/agent-roles/frontend-engineer/**"
---

# Frontend Engineer Agent Development

## Role
Frontend implementation specialist. React/Next.js components, pages, routing, state management, design systems.

## Key Files
- `claude/agent-roles/frontend-engineer/agent.md` — Claude Code agent stub
- `claude/agent-roles/frontend-engineer/SKILL.md` — Full skill instructions

## FE-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy

## Frontend Conventions
When editing frontend-engineer SKILL.md, ensure it covers:
- Component tree from Solution Architect's page definitions
- State management patterns (React Context, Zustand, etc.)
- Design system token usage (colors, typography, spacing)
- Responsive design and accessibility
- API integration from OpenAPI contracts
- Form handling and validation

## Do Not
- FE implements components — does NOT change page definitions or API contracts
- FE must verify build succeeds before writing receipt
