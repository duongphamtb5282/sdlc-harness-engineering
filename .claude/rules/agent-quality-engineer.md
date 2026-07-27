---
description: Quality Engineer agent — comprehensive test suites. Scoped to QE agent files.
globs: "claude/agent-roles/quality-engineer/**"
---

# Quality Engineer Agent Development

## Role
Testing specialist. Writes unit, integration, e2e, performance, and contract tests. Per-story verifier in the SE→QE→CR pipeline.

## Key Files
- `claude/agent-roles/quality-engineer/agent.md` — Claude Code agent stub
- `claude/agent-roles/quality-engineer/SKILL.md` — Full skill instructions

## QE-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `receipt-protocol` — Write-after-verify
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — TDD Iron Law
- `verification-discipline` — Verify before receipt
- `script-output-handling` — Output capture
- `specialist-skill-loading` — Specialist skill loading
- `tech-pack-loading` — Tech pack conventions
- `coverage-ratchet` — Coverage ratchet

## Test Types
QE defines tests across these dimensions:
- Unit tests — Fast, deterministic, no external deps
- Integration tests — External deps via testcontainers/mocks
- Contract tests — API contract verification
- E2E tests — Full user journey
- Performance tests — Load/stress profiles

## Test Quality Rules
When writing QE SKILL.md or phases, enforce:
- No `sleep()` for async waits — use explicit wait conditions
- No shared mutable state between tests
- No hardcoded ports, timestamps, or random values
- No reliance on test execution order
- Tests must be runnable in isolation

## Do Not
- QE does NOT modify source code — only writes tests
- QE must verify tests pass before writing receipt
- QE owns test suites exclusively — SE does not override test files
