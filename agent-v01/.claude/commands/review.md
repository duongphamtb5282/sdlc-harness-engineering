---
description: Run BMAD multi-lens code review — quality, security, architecture, dependency. Produces unified report with deduplicated findings.
---

Run the BMAD multi-lens review workflow.

## Workflow

1. **Adopt persona** — You are the bmad-review agent. Load:
   - `agent-v01/protocols/conflict-resolution.md`
   - `agent-v01/protocols/boundary-safety.md`
   - `agent-v01/protocols/receipt-protocol.md`
   - `agent-v01/BMAD-METHOD/src/core-skills/bmad-review/SKILL.md` (canonical BMAD multi-lens review)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/4-implementation/bmad-code-review/SKILL.md` (adversarial code review)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/4-implementation/bmad-retrospective/SKILL.md` (post-epic review — lessons + success assessment)
   - `agent-v01/agent-skills/bmad-code-review`
   - `agent-v01/supplements/code-review`
   - `agent-v01/core-skills/claude-skills/skills/code-reviewer/SKILL.md`
   - `agent-v01/core-skills/claude-skills/skills/security-reviewer/SKILL.md`
   - `agent-v01/core-skills/agent-skills-general-sdlc/skills/security-and-hardening/SKILL.md`

2. **Load changed files** — Use `$ARGUMENTS` as the target path, or default to current changes.

3. **Run 4 lenses** (independently, then merge):
   - **Quality** — SOLID, DRY, test coverage, maintainability, Flutter/Dart best practices
   - **Security** — OWASP Top 10, secrets, injection, auth exposures (reference security-and-hardening skill)
   - **Architecture** — Boundary Safety Patterns 1-6, modular boundaries, DI patterns
   - **Dependency** — Supply chain, outdated packages, license issues, overrides

4. **Deduplicate** — Per conflict-resolution rules:
   - Same file:line → keep highest severity
   - Cross-reference instead of duplicating
   - Security findings get authoritative weight

5. **Output** — Write `BMAD-REVIEW-REPORT.md` using the template at `agent-v01/references/templates/review-template.md`

6. **Write receipt** — To `agent-v01/protocols/receipts/{review-name}.json`

## Verification
- [ ] All 4 lenses are applied
- [ ] Findings are deduplicated
- [ ] Each finding has file:line, severity, and recommendation
- [ ] Receipt is written
