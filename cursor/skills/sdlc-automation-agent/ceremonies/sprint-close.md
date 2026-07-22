<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Sprint Close Ceremony

> **Lifecycle state:** `SPRINT_CLOSE`
> **Always runs** — this is bookkeeping, cannot be skipped.
> **Output:** Sprint metrics recorded, carry-over handled, next decision made

## Prerequisites

Verify lifecycle state:
```
STATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" read "$(pwd)") 
# Verify lifecycle_state == "SPRINT_CLOSE"
```

---

## Step 1 — Handle Incomplete Stories

Check for stories not in `done` state: 

```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" list_stories "$(pwd)" queued
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" list_stories "$(pwd)" in_progress
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" list_stories "$(pwd)" testing
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" list_stories "$(pwd)" reviewing
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" list_stories "$(pwd)" blocked
```

If all stories are `done`: skip carry-over handling.

If incomplete stories exist, apply the carry-over policy from `.sdlc-automation-agent.yaml`:

```yaml
sprint:
  carry_over_policy: "move_to_next"  # move_to_next | keep_in_sprint | ask
```  

### Policy: `move_to_next` (default)

```
For each incomplete story:
  1. Update tracker status to TO_DO (reset for next sprint): 
     python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/tracker/tracker_cli.py" \ 
       --project-dir "$(pwd)" update-status {story_id} TO_DO
  2. Log: "↩ Carried over {story_id}: {title} to Sprint {N+1}" 
```

### Policy: `keep_in_sprint` 

```
For each incomplete story:
  Log: "📌 {story_id}: {title} remains archived in Sprint {N}"  
  # No tracker update — story stays in current sprint for reporting
```

### Policy: `ask`

```
For each incomplete story, present:
  {story_id}: {title} — currently {state}
  1. Move to Sprint {N+1}
  2. Keep in Sprint {N} (archive)
  3. Discard (remove from backlog)

Apply user's choice per story.
```

---  

## Step 2 — Record Sprint Metrics

The sprint completion metrics were already calculated when transitioning to SPRINT_REVIEW (via `complete_sprint`). Display the final sprint summary: 

```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" summary "$(pwd)"
```

Present: 
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SPRINT {N} COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 

  Goal:           {SPRINT_GOAL}  
  Stories:        {completed}/{planned} completed  
  Carry-over:     {carry_over_count} stories
  Velocity:       {velocity} stories/sprint (avg across {N} sprints)
  DoD Compliance: {dod_compliance}%
  Cycle Time:     {avg_cycle_time} avg per story

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 3 — Next Sprint Decision

Ask the user what to do next:

```
  What's next?
  1. Continue to Sprint {N+1} (Recommended)  
  2. Release — prepare for production  
  3. Stop for now — pause the project
  4. Chat about this
``` 

**If all epics are done**, the Orchestrator notes this:
```
  Note: All epics appear to be complete. Consider releasing.
  1. Continue to Sprint {N+1} (more features/polish)
  2. Release — prepare for production (Recommended)
  3. Stop for now
  4. Chat about this
```

### Option 1: Continue to Sprint N+1

```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" close_sprint "$(pwd)" \
  --proceed-to SPRINT_PLANNING

Print: "✓ Sprint {N} closed. Starting Sprint {N+1} Planning..."
→ Load ceremonies/sprint-planning.md 
``` 

### Option 2: Release

``` 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" close_sprint "$(pwd)" \
  --proceed-to RELEASE

Print: "✓ Sprint {N} closed. Proceeding to Release preparation..."  
→ Release mode (Wave 4)
```

### Option 3: Stop for now 

``` 
Print: "✓ Sprint {N} closed. Project paused." 
Print: "Run /sdlc-automation-agent to resume — the orchestrator will pick up from Sprint {N+1} Planning."
# Do NOT transition — keep state at SPRINT_CLOSE so next session resumes correctly
```
