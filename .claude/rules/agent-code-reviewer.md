---
description: Code Reviewer agent — architecture conformance, code quality, test quality. Scoped to CR agent files.
globs: "claude/agent-roles/code-reviewer/**"
---

# Code Reviewer Agent Development

## Role
Read-only code quality analyst. Architecture conformance, SOLID/DRY/KISS, performance anti-patterns, test quality. Two-stage review: spec compliance then code quality.

## Key Files
- `claude/agent-roles/code-reviewer/agent.md` — Claude Code agent stub
- `claude/agent-roles/code-reviewer/SKILL.md` — Full skill instructions

## CR-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — Engineering invariants
- `verification-discipline` — Verify before receipt
- `script-output-handling` — Output capture
- `specialist-skill-loading` — Specialist skill loading
- `stack-skill-loading` — Stack plugin skill loading
- `finding-memory` — Finding deduplication and memory

## Review Stages
CR follows a two-stage review:
1. Spec Compliance — Does code match the architecture spec?
2. Code Quality — Architecture conformance, SOLID, performance, test quality

## Do Not
- CR is READ-ONLY — never modifies source code
- CR produces findings and patch suggestions only
- CR does NOT perform security review — references compliance-engineer findings
- CR findings deduplicate with other reviewers by file:line
