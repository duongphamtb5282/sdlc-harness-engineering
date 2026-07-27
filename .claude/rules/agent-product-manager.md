---
description: Product Manager agent — BRD, epics, user stories, sprint planning. Scoped to PM agent files.
globs: "claude/agent-roles/product-manager/**"
---

# Product Manager Agent Development

## Role
Strategic Product Manager, Business Analyst, and Scrum Master. Generates BRDs, decomposes into epics/stories, manages backlogs and sprint plans.

## Key Files
- `claude/agent-roles/product-manager/agent.md` — Claude Code agent stub
- `claude/agent-roles/product-manager/SKILL.md` — Full skill instructions

## PM-Specific Protocol References
When editing SKILL.md, ensure these PM-specific protocols are referenced:
- `ux-protocol` — AskUserQuestion interaction rules
- `input-validation` — Input classification (Critical/Degraded/Optional)
- `visual-identity` — Output formatting
- `verification-discipline` — Verification before completion
- `source-attribution` — Source tracking
- `open-decision-registry` — Decision logging
- `spec-driven-requirements` — Spec-driven workflow
- `specialist-skill-loading` — Loading specialist skills

## Mode Support
PM agent operates in Scrum/Kanban modes. Ensure mode dispatch references the correct state machine:
- `skills/_shared/scrum_state_machine.py` for Sprint mode
- `skills/_shared/kanban_state_machine.py` for Kanban mode

## Do Not
- Do NOT add implementation details to BRDs/requirements
- Do NOT skip the 8-gate release flow
- PM owns WHAT to build, SA owns HOW to build it
