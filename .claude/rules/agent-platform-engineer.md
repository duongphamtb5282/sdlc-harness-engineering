---
description: Platform Engineer agent — infrastructure, CI/CD, Docker, K8s, Terraform. Scoped to PE agent files.
globs: "claude/agent-roles/platform-engineer/**"
---

# Platform Engineer Agent Development

## Role
Infrastructure and deployment engineering. Docker, containerization, Terraform/IaC, Kubernetes, CI/CD pipelines, monitoring, infrastructure security.

## Key Files
- `claude/agent-roles/platform-engineer/agent.md` — Claude Code agent stub
- `claude/agent-roles/platform-engineer/SKILL.md` — Full skill instructions

## PE-Specific Protocol References
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `receipt-protocol` — Write-after-verify
- `boundary-safety` — System boundary patterns
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — Engineering invariants
- `verification-discipline` — Verify before receipt
- `script-output-handling` — Output capture
- `specialist-skill-loading` — Specialist skill loading
- `tech-pack-loading` — Tech pack conventions
- `ephemeral-environments` — Ephemeral environment management

## Coverage
Platform Engineer covers BOTH:
- **infrastructure provisioning** (CI/CD, Docker, K8s, Terraform)
- **reliability engineering** (SLOs, runbooks, monitoring, chaos engineering)

## Do Not
- PE coordinates DevOps + SRE — delegates CI/CD to DevOps, reliability to SRE
- PE is the sole authority on infrastructure and SLO definitions
