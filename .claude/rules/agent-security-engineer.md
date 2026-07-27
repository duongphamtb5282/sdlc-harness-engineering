---
description: Security Engineer agent — security audit, OWASP, STRIDE. Scoped to SE agent files.
globs: "claude/agent-roles/security-engineer/**"
---

# Security Engineer Agent Development

## Role
Security audit specialist. OWASP Top 10, STRIDE threat modeling, penetration testing, PII, encryption, regulatory compliance (HIPAA, SOC 2).

## Key Files
- `claude/agent-roles/security-engineer/agent.md` — Claude Code agent stub
- `claude/agent-roles/security-engineer/SKILL.md` — Full skill instructions

## Security-Specific Protocol References
- `input-validation` — Input classification
- `tool-efficiency` — Tool usage patterns
- `visual-identity` — Output formatting
- `freshness-protocol` — Temporal sensitivity (CVEs)
- `receipt-protocol` — Write-after-verify
- `conflict-resolution` — Agent authority hierarchy
- `iron-laws` — Engineering invariants
- `verification-discipline` — Verify before receipt
- `script-output-handling` — Output capture
- `specialist-skill-loading` — Specialist skill loading

## Security Domains
When editing security-engineer, cover these domains:
- OWASP Top 10 (injection, broken auth, XSS, etc.)
- STRIDE threat modeling per service
- Secrets detection (API keys, passwords, tokens)
- Dependency vulnerability scanning
- Authentication/authorization review
- Data encryption (at rest and in transit)
- PII/compliance requirements

## Compliance = Security
`compliance-engineer` is a legacy alias for `security-engineer`. Both should have equivalent capability.

## Do Not
- Security Engineer is the SOLE authority on security findings
- Code Reviewer does NOT perform OWASP review — references security-engineer findings
- Output findings with severity: Critical, High, Medium, Low
