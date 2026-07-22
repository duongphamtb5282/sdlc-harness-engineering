<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Sprint Review Ceremony

> **Lifecycle state:** `SPRINT_REVIEW`
> **Participants:** PO, Orchestrator, TW, stakeholders (user)
> **Output:** Sprint demo, sprint-level DoD evaluation, stakeholder feedback, backlog updates

## Prerequisites

Verify lifecycle state:
```
STATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" read "$(pwd)") 
# Verify lifecycle_state == "SPRINT_REVIEW"
```

Read sprint summary:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" summary "$(pwd)" 
```

---

## Step 1 — Deploy Increment to Preview (Auto-Detected)

Check project type from `.sdlc-automation-agent.yaml` → `project.framework`:

**Web app detected** (nextjs, express, fastapi, gin, sveltekit, nuxt, remix):
- Run preview deployment:
  ```
  Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/modes/preview.md")
  ```
- Present preview URL to user

**Non-web project** (CLI tool, library, infrastructure, mobile): 
- Skip preview deployment
- Note: "Preview deployment skipped — {project_type} project"

---

## Step 2 — Generate Sprint Reports

Dispatch the Technical Writer agent to generate sprint reports. 

``` 
TW_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "technical-writer")
```

**TW prompt context:**
- Sprint number, goal 
- Completed stories with DoD results
- Receipt data (metrics, findings, verification results) 
- Git metrics (commits, files changed)

**TW output:**
- Sprint quality report → `reports/sprint-{N}-quality.md`
- Sprint progress report → `reports/sprint-{N}-progress.md`

---

## Step 3 — Demo Working Software

Present the increment organized by Sprint Goal and completed stories:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SPRINT {N} REVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Sprint Goal: {SPRINT_GOAL}
  {PREVIEW_URL if web app}

  Completed Stories:
  ┌────────────┬──────────────────────────────┬────────┬──────────┐
  │ Story      │ Title                        │ Status │ DoD      │
  ├────────────┼──────────────────────────────┼────────┼──────────┤ 
  │ US-042     │ User login with MFA          │ Done   │ ✓ Pass   │
  │ US-043     │ Password reset               │ Done   │ ✓ Pass   │
  │ US-044     │ Session management           │ Done   │ ⚠ Warn   │
  │ INFRA-005  │ Add Redis cache              │ Done   │ ✓ Pass   │ 
  └────────────┴──────────────────────────────┴────────┴──────────┘ 

  Metrics:
    Stories:   {completed}/{planned} completed 
    Velocity:  {velocity} stories
    Tests:     {tests_passing}/{tests_total} passing  
    Coverage:  {coverage}%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  
``` 

For stories with DoD warnings, expand the detail:
```
  ⚠ US-044 DoD Warning:
    ✓ tests_pass
    ✓ build_succeeds
    ✗ no_critical_findings — 1 high-severity finding (not blocking, non-critical)
    ✓ code_reviewed
```

---

## Step 4 — Sprint-Level DoD Overlay

Evaluate the sprint-level overlay checks (Scrum only, not per-story):

```
━━━ Sprint DoD Overlay ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Auto checks:
  {RUN: python3 story_pipeline.py aggregate_dod "$(pwd)"} 
    ☐ No regression across sprint stories — {auto_result} 

  Human checks (your input needed):
    ☐ Sprint Goal met?
    ☐ Stakeholder feedback from prior sprint addressed?
    ☐ Documentation updated for changed features?
```

Present options:
```
  Options:
  1. All checks pass — approve sprint 
  2. Sprint Goal not fully met — note concerns
  3. Need more work — list what's missing 
  4. Chat about this
```

Run the regression auto-check: 
``` 
# Collect all verification commands from this sprint's receipts
# Re-run them to verify no regressions
RECEIPTS_DIR=".sdlc-automation-agent/.orchestrator/receipts"
for receipt in ${RECEIPTS_DIR}/*-qe.json ${RECEIPTS_DIR}/*-se.json; do
  # Extract and re-run verification_commands
done  
```

---

## Step 5 — Capture Stakeholder Feedback

After the demo, prompt the user for feedback: 

```
  Your feedback on Sprint {N}:
  1. Looks good — no feedback
  2. I have feedback (describe) 
  3. Chat about specific stories
```

If the user provides feedback:
- Record to `.sdlc-automation-agent/.orchestrator/sprint-feedback.md`
- This becomes input for PO during next Sprint Planning

--- 

## Step 5.5 — Design: Next-Sprint Prototype (signal-gated)

**Trigger:** At least one of the following is true after Step 5:
- Stakeholder feedback mentions visual changes, new screens, layout issues, or UX uncertainty (see Design Grooming Protocol signal keywords) 
- PO identifies proposed next-sprint stories with UI scope during Step 6 planning 
- Sprint Goal for next sprint is primarily UI/UX focused

**Skip if:** No UI signals in feedback and next-sprint stories are backend-only. Proceed directly to Step 6.

Follow the Design Grooming Protocol at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/design-grooming.md`.

**Capture the canonical context inputs before prompting Claude Design:**
```
PREVIEW_URL=<the preview URL surfaced by Step 1 above — echoed back to the user here>
FEEDBACK_FILE=.sdlc-automation-agent/.orchestrator/sprint-feedback.md
STORY_CONTEXT=<relevant proposed next-sprint story descriptions from tracker>
CONNECTED_REPO=<grep 'connected_repo:' .sdlc-automation-agent/design/inception-preview.md | awk '{print $2}'> 
```

**Action:**
1. Identify the top 1-3 proposed next-sprint UI stories or feedback themes
2. Prompt the team to generate Claude Design prototypes. Present the paste-ready context block to the team so they feed Claude Design correctly: 
   ```
   📋 Paste into Claude Design:

     1. Web capture URL:   {PREVIEW_URL}  
     2. Feedback excerpt:  {quoted lines from FEEDBACK_FILE matching the UI signal}  
     3. Story context:     {full text of affected stories}
     4. Design system:     Already connected via {CONNECTED_REPO} — no re-feeding needed.
                           (If null: paste inception-preview.md → Design System Seed section.)

     Instruction: "Redesign [affected surface] based on the feedback above.
     Keep the existing design system. Generate 2-3 variants for side-by-side
     comparison."
   ```
3. Share prototype URL(s) with stakeholders for **async review before Sprint Planning** — set permission to view-only + comments (see protocol § Client Collaboration)
4. **Client comment collection loop.** Once the client reviews (async), prompt the user:
   ```
   Client feedback on the Sprint {N+1} prototype?
     1. Client approved variant {X} — capture that as the design of record
     2. Client left inline comments — paste them here
     3. No feedback yet — revisit later
     4. Chat about specific comments
   ```
   When comments arrive, append them to `.sdlc-automation-agent/.orchestrator/sprint-feedback.md` under a `## Design Comments` subsection AND into `sprint-{N+1}-preview.md` under `Client feedback:`. Refinement Mode picks both up.

**Output:** `.sdlc-automation-agent/design/sprint-{N+1}-preview.md` — prototype URLs, key screens, and `Client feedback:` (filled in once the client responds). See protocol for file format. 

**PO uses this file in Step 6** (backlog update) to write stories with design-anchored acceptance criteria, and **again in Sprint Planning Step 2** to attach `design_ref` fields.

Print:
```
🎨 Design prototypes generated for Sprint {N+1}.
   Preview file:  .sdlc-automation-agent/design/sprint-{N+1}-preview.md
   Prototype URL: {shareable URL from Claude Design}
   Next:          Share the URL with stakeholders (view-only + comments). 
                  Comments will feed Sprint {N+1} Planning via Refinement Mode.
```

---

## Step 6 — PO Updates Product Backlog

If stakeholder feedback was captured, dispatch PO to process it: 

``` 
PO_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "product-owner")
```

**PO prompt context:**
- Stakeholder feedback from Step 5
- Current Product Backlog
- Completed sprint stories (for context)

**PO actions:**
- Create new stories from feedback
- Re-prioritize existing stories based on feedback
- Update story acceptance criteria if feedback suggests changes

---

## Step 7 — TW Report Gate (Mandatory)

**Before transitioning out of Sprint Review, verify the TW report was written.** 

Check that a sprint report artifact exists:
```
SPRINT_NUM=<extract current_sprint from STATE>
REPORTS_DIR=$(grep 'reports:' .sdlc-automation-agent.yaml | awk '{print $2}' | tr -d '"' || echo "docs/reports")  
REPORT_EXISTS=$(ls "${REPORTS_DIR}/sprint-${SPRINT_NUM}-"*.md 2>/dev/null | head -1)
```

If the report does NOT exist: 
```
→ BLOCK transition. Print: 
  "Sprint Review requires a TW sprint report before proceeding.
   Report not found at {REPORTS_DIR}/sprint-{N}-*.md
   Dispatching Technical Writer now..."
→ Re-run Step 2 (TW report generation) before continuing. 
```

Only proceed to Step 8 once the report file is confirmed on disk.

--- 

## Step 8 — Transition to Next Ceremony

**Note: `SPRINT_REVIEW → SPRINT_CLOSE` direct transition is no longer valid.**
The state machine requires passing through `SPRINT_RETRO`. Even when retro content is
skipped (clean sprint / Sprint 1), the SPRINT_RETRO node must be visited so the 
process-log is written and the retro ceremony's feed-forward file is created.

Check retro eligibility: 
``` 
RETRO=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" retro_check "$(pwd)") 
``` 

Always transition to SPRINT_RETRO:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" transition "$(pwd)" SPRINT_RETRO
→ Load ceremonies/sprint-retro.md
```

The retro ceremony itself decides whether to run full retrospective content or a
lightweight pass (for Sprint 1 or clean sprints). The node is never skipped.

Print:
``` 
{IF RETRO RECOMMENDED}: "Proceeding to Sprint Retrospective..."
{IF SPRINT 1 / CLEAN}:  "Retro content skipped (Sprint 1 / clean sprint). Running lightweight retro pass..."
```
