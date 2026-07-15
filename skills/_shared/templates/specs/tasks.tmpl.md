# Tasks: {{TITLE}}

**Spec ID:** `{{SPEC_ID}}`  
**Requirements:** [requirements.md](./requirements.md)  
**Design:** [design.md](./design.md)  
**Status:** draft | ready | implementing | done

---

## Implementation plan

Tasks are ordered by dependency. Complete one task before starting the next unless marked `[parallel]`.

### Phase 1 — Foundation

- [ ] **T1** — {{TASK_TITLE}}  
  - **Refs:** REQ-01, REQ-02  
  - **Owner:** SE  
  - **Verify:** `{{COMMAND_FROM_TECH_STACK_YAML}}`  
  - **Notes:** {{DETAIL}}

### Phase 2 — Core feature

- [ ] **T2** — {{TASK_TITLE}}  
  - **Refs:** REQ-03  
  - **Owner:** SE  
  - **Verify:** `npm test -- {{PATH}}` / `./gradlew test --tests {{CLASS}}`

### Phase 3 — Tests & hardening

- [ ] **T3** — Add integration tests for AC-01, AC-02  
  - **Refs:** AC-01, AC-02  
  - **Owner:** QE  
  - **Verify:** `{{TEST_COMMAND}}`

### Phase 4 — Deploy (if in scope)

- [ ] **T4** — CI/CD and staging deploy  
  - **Owner:** PE  
  - **Verify:** `terraform validate` / pipeline green

---

## Traceability check

| REQ-ID | Task IDs |
|--------|----------|
| REQ-01 | T1 |
| REQ-02 | T1, T2 |

---

## Execution rules (for SE agent)

1. Pick the **first unchecked** task.
2. Implement only that task's scope.
3. Run the task **Verify** command; do not check the box if it fails.
4. Update this file: `- [x]` and add commit SHA or PR link in Notes.
5. Write receipt to `.sdlc-automation-agent/.orchestrator/receipts/{{STORY_ID}}-se.json`.

---

## Completion

- [ ] All tasks checked
- [ ] All Verify commands passed
- [ ] QE sign-off on AC coverage
