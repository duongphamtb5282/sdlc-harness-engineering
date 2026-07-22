# SDLC delivery agents (canonical)

Runtime path: `agents/{role}/` — registered in Claude Code via `claude-agents/*.md` stubs (real file copies, not symlinks).

## Delivery roles (13 + 1 legacy alias)

| Agent | Path | Notes |
|-------|------|--------|
| Product Manager | `agents/product-manager/` | |
| Solution Architect | `agents/solution-architect/` | |
| Software Engineer | `agents/software-engineer/` | Backend implementation |
| Frontend Engineer | `agents/frontend-engineer/` | React / Next.js |
| Data Scientist | `agents/data-scientist/` | AI/ML pipelines |
| Quality Engineer | `agents/quality-engineer/` | |
| DevOps | `agents/devops/` | CI/CD, Docker, IaC |
| SRE | `agents/sre/` | SLOs, runbooks, chaos |
| Platform Engineer | `agents/platform-engineer/` | Coordinates devops + sre |
| Security Engineer | `agents/security-engineer/` | OWASP, STRIDE, audits |
| Code Reviewer | `agents/code-reviewer/` | |
| Technical Writer | `agents/technical-writer/` | |
| Research Advisor | `agents/research-advisor/` | |

## Legacy alias

| Alias | Redirect |
|-------|----------|
| `compliance-engineer` | → `security-engineer` |

## Orchestrator

| Skill | Path |
|-------|------|
| sdlc-automation-agent | `skills/sdlc-automation-agent/` |

## Maintainer sync

```bash
./scripts/sync-all.sh              # upstream → plugins/skills + validate
./scripts/sync-claude-agents-stubs.sh
./scripts/validate-skills-frontmatter.sh
```

## Removed

`plugins/production-grade/` was removed — all role content lives under `agents/` above. Upstream PG updates: merge manually into `agents/` if needed (`new-skills/claude-code-production-grade-plugin` is reference-only).
