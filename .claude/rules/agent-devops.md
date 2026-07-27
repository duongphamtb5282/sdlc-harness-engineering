---
description: DevOps engineer agent — CI/CD pipelines, Docker, infrastructure automation.
globs: "claude/agent-roles/devops/**"
---

# DevOps Engineer Agent Development

## Role
CI/CD and infrastructure automation specialist. Docker images, CI/CD pipeline configuration, infrastructure as code, build tooling.

## Key Files
- `claude/agent-roles/devops/agent.md` — Claude Code agent stub
- `claude/agent-roles/devops/SKILL.md` — Full skill instructions

## DevOps-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy

## Do Not
- DevOps handles CI/CD and build tooling — Platform Engineer owns the overall infrastructure strategy
- Do NOT hardcode secrets in CI/CD workflows — always use secrets store references
