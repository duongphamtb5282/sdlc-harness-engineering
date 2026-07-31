---
description: Break specs and requirements into ordered, implementable tasks with dependency mapping. Invokes bmad-analyst/PM with planning-and-task-breakdown skill.
---

Run the planning and task breakdown workflow.

## Workflow

1. **Adopt persona** — Load:
   - `agent-v01/protocols/input-validation.md`
   - `agent-v01/protocols/tool-efficiency.md`
   - `agent-v01/BMAD-METHOD/src/bmm-skills/3-solutioning/bmad-create-epics-and-stories/SKILL.md` (canonical BMAD story breakdown)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/4-implementation/bmad-sprint-planning/SKILL.md` (sprint planning companion)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/3-solutioning/bmad-check-implementation-readiness/SKILL.md` (readiness gate)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/3-solutioning/bmad-generate-project-context/SKILL.md` (project-context.md generation)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/4-implementation/bmad-sprint-status/SKILL.md` (sprint status, if mid-sprint)
   - `agent-v01/core-skills/agent-skills-general-sdlc/skills/planning-and-task-breakdown/SKILL.md`

2. **Read inputs** — Load `SPEC.md`, `docs/architecture/`, and `docs/trade-offs/` (risk posture for task ordering). If neither exists, ask user to run `/spec` or `/arch-design` first.

3. **Map dependency graph** — Identify what depends on what:
   ```
   Database schema
     ├── API models/types
     │     ├── API endpoints
     │     │     └── Frontend API client
     │     │           └── UI components
     │     └── Validation logic
     └── Seed data / migrations
   ```

4. **Slice vertically** — Each task delivers one complete, testable feature slice, not a horizontal layer. Align story format with `bmad-create-epics-and-stories` conventions.

5. **Write tasks** with:
   - Task ID and title
   - Dependencies (which tasks block this one)
   - Acceptance criteria
   - Estimated complexity (S/M/L)
   - Verification steps

6. **Output** — Write to:
   - `tasks/plan.md` — Full plan with dependency graph and phase descriptions
   - `tasks/todo.md` — Ordered task list in execution order

7. **QA test cases** — Once stories/tasks are approved, run `/qa` to generate per-story test cases at `docs/qa/test-cases.md` (unit/API/E2E per acceptance criterion). They are the RED-test source for `/build`.

8. **Handoff** — Pass plan + tasks + QA test cases to bmad-engineer for implementation (`/build`)

## Verification
- [ ] Tasks are ordered by dependency (bottom-up)
- [ ] Each task is small enough for one focused session
- [ ] Each task has explicit acceptance criteria
- [ ] Vertical slices (not horizontal layers)
- [ ] QA test cases generated via `/qa` before handoff (no AC left without a test)
- [ ] User has reviewed and approved the plan
