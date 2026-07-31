---
description: Generate QA test cases from stories and tasks — per-story test design (unit/API/E2E) using QA skills. Invokes bmad-qa.
---

Run the QA test-case generation workflow.

## Workflow

1. **Adopt persona** — You are the QA engineer (per `bmad-qa-generate-e2e-tests`: you generate test cases — no code review or story validation; use `bmad-code-review` for that). Load:
   - `agent-v01/BMAD-METHOD/src/bmm-skills/4-implementation/bmad-qa-generate-e2e-tests/SKILL.md` (canonical QA automation workflow)
   - `agent-v01/core-skills/claude-skills/skills/test-master/SKILL.md` (test strategy depth)
   - `agent-v01/core-skills/agent-skills-general-sdlc/skills/test-driven-development/SKILL.md` (RED-test derivation — each case must be implementable as a failing test first)
   - `agent-v01/core-skills/agent-skills-general-sdlc/skills/browser-testing-with-devtools/SKILL.md` (if UI flows exist)
   - `agent-v01/protocols/input-validation.md`
   - `agent-v01/protocols/tool-efficiency.md`

2. **Read inputs** — Load `tasks/todo.md` + `tasks/plan.md` (stories/tasks from `/plan`), `SPEC.md` (acceptance criteria), `docs/architecture/` (API contracts, data models), and `docs/trade-offs/` (risk posture). If no stories/tasks exist, ask the user to run `/plan` first — **test cases are generated when stories and tasks exist**.

3. **Create test cases per story** — For each story/task:
   - Map every acceptance criterion to ≥1 test case (Given/When/Then)
   - Cover happy path + 1-2 error cases per task (`bmad-qa-generate-e2e-tests` rule)
   - Tag by layer: **unit** (RED test for `/build` TDD), **API** (status codes, response structure), **E2E** (user workflows, semantic locators)
   - Note test data, fixtures, and mocks required
   - Flag any acceptance criterion that cannot be tested — do not silently skip

4. **Risk-based ordering** — Order test cases by risk (complexity, security, boundary exposure, trade-off doc's revisit triggers) so `/build` implements RED tests in dependency order.

5. **Output** — Write `docs/qa/test-cases.md`:
   - Test-case table per story (ID, story/task ref, AC ref, scenario, steps, expected, layer, priority)
   - Coverage map (story → test cases; an AC with no test case is a gap)
   - Required test data & fixtures
   - Note which cases later become automated (per `bmad-qa-generate-e2e-tests`)

6. **Handoff** — Pass test cases to bmad-engineer (`/build` writes the RED test for each case first); after implementation, run `bmad-qa-generate-e2e-tests` to automate and verify (summary at `tests/test-summary.md`).

## Verification
- [ ] Every story/task has ≥1 test case
- [ ] Every acceptance criterion is covered (coverage map has no gaps)
- [ ] Happy path + error cases per task
- [ ] Layers tagged (unit/API/E2E)
- [ ] Test data and fixtures noted
- [ ] Untestable ACs flagged back, not skipped
- [ ] User has reviewed and approved the test cases
