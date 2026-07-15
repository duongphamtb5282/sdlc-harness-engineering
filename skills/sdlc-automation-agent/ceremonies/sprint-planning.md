<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Sprint Planning Ceremony

> **Lifecycle state:** `SPRINT_PLANNING`
> **Participants:** PO, SA (if triggered), QE, Orchestrator
> **Output:** Sprint Backlog with goal, stories in `queued` state, QE test spec

## Adaptive Intensity

Determine planning intensity before starting:

```
STATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" read "$(pwd)") 
SPRINT_NUM=<extract current_sprint from STATE>
SPRINTS_COMPLETED=<extract sprints_completed array from STATE>
```

**Lightweight** (stable backlog, no new feedback from prior Sprint Review): 
- PO confirms pre-refined stories
- Skip SA (unless triggers found)
- Orchestrator presents Sprint Backlog for approval
- QE generates test spec

**Full** (new feedback, scope changes, retro flagged issues):
- PO performs deep refinement
- SA architecture review if triggers found
- New stories created from prior Sprint Review feedback
- Full Sprint Backlog negotiation

**How to decide:** 
- Sprint 1: always **Full** (first sprint, nothing pre-refined)
- Sprint 2+: check if prior sprint had:
  - Stakeholder feedback captured (→ Full) 
  - Retro improvements applied (→ Full) 
  - Carry-over stories (→ Full)
  - None of the above (→ Lightweight)

---  

## Step 1 — PO Reads Context  

The PO agent needs these inputs:
- Prior sprint's stakeholder feedback (from `.sdlc-automation-agent/.orchestrator/sprint-feedback.md` if exists) 
- Retro insights (from `.sdlc-automation-agent/.orchestrator/process-log.md` if exists)
- Current Product Backlog state (from tracker)

``` 
TRACKER_CLI="python3 ${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/tracker/tracker_cli.py --project-dir $(pwd)"

# Get current backlog
${TRACKER_CLI} get-backlog

# Get stories not yet assigned to a sprint
${TRACKER_CLI} query --status TO_DO
```

---

## Step 2 — PO Refines Stories 

Dispatch the Product Owner agent to refine stories for this sprint.

``` 
PO_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "product-owner")
```

Read the PO backend wrapper at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/backends/${PO_BACKEND}.md` and dispatch.

**PO prompt context:**  
- Sprint number: {SPRINT_NUM}
- Prior sprint feedback (if any)
- Retro insights (if any)
- Current backlog (unrefined stories)
- Velocity from prior sprints (for capacity planning) 

**PO output:**
- Refined stories with detailed acceptance criteria (Given/When/Then)
- Priority ordering
- Proposed Sprint Goal
- Capacity recommendation based on velocity 

**Lightweight mode:** PO confirms existing stories are ready. Minimal refinement. 
**Full mode:** PO creates/updates stories, processes feedback into new backlog items.

**Design-PENDING resolution (signal-gated):** For each story in the proposed sprint backlog tagged `[DESIGN-PENDING]`:  

Follow the Design Grooming Protocol at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/design-grooming.md`.

1. Check if `sprint-{N}-preview.md` exists in `.sdlc-automation-agent/design/` — if yes, generate a scoped handoff bundle from the relevant prototype section 
2. If no sprint preview exists, prompt the team to create a targeted prototype in Claude Design for this story (use the story's ACs as the design brief)
3. Store the handoff bundle at `.sdlc-automation-agent/design/{story-id}-design.md` 
4. Attach `design_ref: .sdlc-automation-agent/design/{story-id}-design.md` to the story in the tracker: 
   ```
   ${TRACKER_CLI} update-story {story-id} --field design_ref=".sdlc-automation-agent/design/{story-id}-design.md"
   ```
5. Remove `[DESIGN-PENDING]` tag from story
6. **Guard:** A story tagged `[DESIGN-PENDING]` must NOT enter `queued` state until this is resolved. If the team explicitly opts out of Design for a story, remove the tag manually.

**Skip Design resolution for:** backend-only stories, enabler stories, infra stories — those must not carry `[DESIGN-PENDING]` tags (if they do, strip the tag without generating a bundle).

---

## Step 3 — SA Architecture Review (Conditional)

Follow the SA Auto-Detect Protocol at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/sa-triggers.md`.

For each story in the proposed sprint backlog:
1. Scan story text for architecture trigger signals
2. If ANY triggers found → dispatch SA agent
3. If NO triggers found → skip SA entirely

Also check for periodic architecture health check:
``` 
Read .sdlc-automation-agent.yaml → architecture.health_check_interval (default: 3) 
If SPRINT_NUM % health_check_interval == 0:
  Invoke SA for architecture health check regardless of triggers
```

---

## Step 4 — Team Selects Stories

Present the refined stories to the user for Sprint Backlog confirmation.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SPRINT {N} PLANNING 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Sprint Goal: {PO_PROPOSED_GOAL} 
  Velocity:    {AVG_VELOCITY} stories/sprint (from {N-1} prior sprints)
  Capacity:    {RECOMMENDED_CAPACITY} stories

  Proposed Sprint Backlog:  
  ┌──────────┬──────────────────────────────┬──────────┬────────┐  
  │ Priority │ Story                        │ Size     │ Design │
  ├──────────┼──────────────────────────────┼──────────┼────────┤
  │ 1        │ US-042: User login with MFA  │ M        │ 🎨     │
  │ 2        │ US-043: Password reset       │ S        │        │
  │ 3        │ US-044: Session management   │ M        │        │
  │ 4        │ INFRA-005: Add Redis cache   │ S        │        │ 
  └──────────┴──────────────────────────────┴──────────┴────────┘
  {SA_NOTE: "Architecture signals detected — SA reviewed: new entity (sessions table), new integration (Redis)"}
  {🎨 = Design handoff bundle available at .sdlc-automation-agent/design/{story-id}-design.md — open to review prototype before approving}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 

  Options:
  1. Approve Sprint Backlog (Recommended)
  2. Add stories
  3. Remove stories  
  4. Adjust Sprint Goal
  5. Chat about this
```

**User can override:** Add or remove stories from the sprint. User has final authority over sprint scope.

---

## Step 5 — Sprint Goal Confirmation 

If the user approved in Step 4, the Sprint Goal is confirmed. If they adjusted, use the adjusted goal.

---

## Step 6 — QE Test Specification  

Dispatch the Quality Engineer agent to generate a test plan for this sprint's stories only.  

```
QE_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "quality-engineer")
```

**QE prompt context:**
- Sprint stories (IDs, titles, acceptance criteria)
- Existing test infrastructure
- Test framework from `.sdlc-automation-agent.yaml`

**QE output:**
- Test specification for each story's acceptance criteria 
- Written to `.sdlc-automation-agent/.orchestrator/test-specification-sprint-{N}.md`

---

## Step 7 — Start Sprint

After approval, initialize the sprint in the state machine: 

```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" start_sprint "$(pwd)" {SPRINT_NUM} \
  --goal "{SPRINT_GOAL}" \ 
  --stories '[{"id":"US-042","title":"User login with MFA"},{"id":"US-043","title":"Password reset"},...]' 
```

This creates story records in `queued` state and transitions the lifecycle to `SPRINT_EXECUTION`.

Print:
```
✓ Sprint {N} started — {M} stories queued
  Goal: {SPRINT_GOAL}
  Proceeding to Sprint Execution...
```

The Orchestrator then loads the story-pipeline protocol to begin executing stories.
