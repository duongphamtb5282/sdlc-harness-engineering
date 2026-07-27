---
description: Compliance Engineer (legacy → Security Engineer) — security audit alias.
globs: "claude/agent-roles/compliance-engineer/**"
---

# Compliance Engineer Agent Development

## Legacy Alias
`compliance-engineer` is a legacy alias that redirects to `security-engineer`.

## Key Files
- `claude/agent-roles/compliance-engineer/agent.md` — Claude Code agent stub
- `claude/agent-roles/compliance-engineer/SKILL.md` — Full skill instructions

## Relationship
Compliance Engineer has identical scope to Security Engineer:
- OWASP Top 10, STRIDE, penetration testing
- PII, encryption, regulatory compliance (HIPAA, SOC 2)
- Secrets detection and dependency scanning

## When Editing
- Ensure compliance-engineer and security-engineer agents produce equivalent output
- Compliance-engineer was merged into security-engineer — maintain backward compatibility
- Reference `security-engineer` as the canonical agent in documentation
