---
description: Software Engineer agent — multi-mode backend/frontend/ai-ml/mobile implementation. Scoped to SE agent files.
globs: "claude/agent-roles/software-engineer/**"
---

# Software Engineer Agent Development

## Role
Multi-mode engineering specialist. Backend (default): services, APIs, business logic. Frontend mode: React/Next.js. AI/ML mode: LLM optimization, agents. Mobile mode: React Native/Flutter.

## Key Files
- `claude/agent-roles/software-engineer/agent.md` — Claude Code agent stub
- `claude/agent-roles/software-engineer/SKILL.md` — Full skill instructions
- `claude/agent-roles/software-engineer/phases/` — Backend phase files
- `claude/agent-roles/software-engineer/frontend-phases/` — Frontend phase files
- `claude/agent-roles/software-engineer/ai-ml-phases/` — AI/ML phase files
- `claude/agent-roles/software-engineer/mobile-phases/` — Mobile phase files
- `claude/agent-roles/software-engineer/modes/` — Mode dispatch files
- `claude/agent-roles/software-engineer/tech-packs/` — Tech-specific packs

## SE-Specific Protocol References
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — TDD Iron Law, no debugging without a test
- `verification-discipline` — Verify before receipt
- `anti-safe-harbor` — Anti-safe-harbor patterns
- `script-output-handling` — Output capture
- `specialist-skill-loading` — Specialist skill loading
- `tech-pack-loading` — Tech pack conventions
- `coverage-ratchet` — Coverage ratchet for brownfield

## Mode Dispatch
SE has 4 modes. Each mode reads its own phase files and mode file:
- `backend` (default) → `phases/` phase files
- `frontend` → `modes/frontend.md` + `frontend-phases/`
- `ai-ml` → `modes/ai-ml.md` + `ai-ml-phases/`
- `mobile` → `modes/mobile.md` + `mobile-phases/`

## Phase Files
When editing backend phases, maintain this ordering:
1. `01-context-analysis.md` — Read architecture, validate, create plan
2. `02-service-implementation.md` — Clean architecture layers
3. `03-cross-cutting.md` — Auth, logging, error handling
4. `04-integration.md` — Service-to-service communication
5. `05-local-dev.md` — Docker, seeds, scripts

## Tech Packs
Tech packs in `tech-packs/` are loaded conditionally based on project detection. Each pack has:
- Detection criteria (e.g., `pom.xml` → Java/Spring)
- Conventions for that technology
- Specific patterns to follow

## Parallel Execution
SE supports parallel service implementation (Phase 2b). When editing phase files, ensure:
- Phase 2a (Shared Foundations) gate is checked before spawning parallel agents
- Each service agent reads from `libs/shared/` before writing
- Phase 3 verifies cross-service consistency

## Do Not
- SE implements code — does NOT redesign architecture or change API contracts
- SE must verify build + test before writing receipt
