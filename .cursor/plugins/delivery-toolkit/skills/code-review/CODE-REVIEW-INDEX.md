# Code Review Skill Index

Code review skills are distributed across these locations:

## Agent Role
- `agent-roles/code-reviewer/` — Primary code review agent (4 phases, 14 references)

## Plugins
- `delivery-toolkit/skills/code-review/` — PR review toolkit
- `delivery-toolkit/skills/code-review-deep/` — Deep code review with PR analyzer scripts
- `sdlc-workflows/skills/code-review-and-quality/` — Workflow-based code review
- `general-skills/skills/code-review-and-quality/` — General code review patterns

## Language-Specific
- `stack-spring/skills/java-code-review/` — Java/Spring code review
- `stack-nestjs/rules/` — NestJS code review rules (42 rule files)

## Expert Skills
- `claude-skills-catalog/skills/code-reviewer/` — Generic code reviewer expert skill
- `production-grade/skills/code-reviewer/` — Production-grade code review patterns

## Usage
```bash
claude "Act as code-reviewer. Review the current branch changes."
claude "Load java-code-review from stack-spring and review the Java files changed in this PR."
```
