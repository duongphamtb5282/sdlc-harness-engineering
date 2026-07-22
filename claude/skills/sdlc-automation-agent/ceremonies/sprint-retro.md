<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Sprint Retrospective Ceremony

> **Lifecycle state:** `SPRINT_RETRO`
> **Adaptive** — skipped if sprint went smoothly (decision made in Sprint Review).
> **Participants:** Orchestrator (facilitator), all agents (data sources)
> **Output:** Process improvements applied, feed-forward to next Sprint Planning

## Prerequisites

This ceremony only runs if `retro_check` recommended it during Sprint Review. If you're here, the sprint had issues worth discussing.

```
STATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" read "$(pwd)")
# Verify lifecycle_state == "SPRINT_RETRO"
```

---

## Step 1 — Data Collection 

Gather metrics from multiple sources:

### Git Metrics
```bash
# Commits this sprint (approximate: since last sprint close timestamp)
LAST_SPRINT_END=<extract sprints_completed[-1].completed_at from STATE>
git log --oneline --after="${LAST_SPRINT_END}" | wc -l

# Files changed
git diff --stat HEAD~$(git log --oneline --after="${LAST_SPRINT_END}" | wc -l) HEAD 2>/dev/null

# Code churn (lines added/removed)
git diff --shortstat HEAD~$(git log --oneline --after="${LAST_SPRINT_END}" | wc -l) HEAD 2>/dev/null
```

### Receipt Data
```bash  
# Collect all receipts for current sprint's stories
RECEIPTS_DIR=".sdlc-automation-agent/.orchestrator/receipts"
STORIES=<extract current_stories[].id from STATE>

for story_id in ${STORIES}; do 
  python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" get_story "$(pwd)" ${story_id} 
done
```

Extract from receipts:
- Findings count (critical/high/medium/low) from CR and CE receipts 
- Test counts and coverage from QE receipts
- Verification command results from all receipts 

### Velocity & Cycle Time
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" summary "$(pwd)"
```  

Extract:
- Stories completed vs planned
- Average cycle time per story
- Stories that were blocked (from pipeline_log)

### DoD Compliance
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" aggregate_dod "$(pwd)" 
```

---

## Step 2 — Analysis

Present findings in two categories:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SPRINT {N} RETROSPECTIVE 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  What went well: 
    ✓ {observation_1}  (e.g., "All critical DoD checks passed")
    ✓ {observation_2}  (e.g., "Average cycle time decreased 15% from Sprint N-1") 
    ✓ {observation_3}  (e.g., "Zero critical security findings")

  What needs improvement:
    ✗ {issue_1}  (e.g., "2 stories blocked due to missing API contract")
    ✗ {issue_2}  (e.g., "3 carry-over stories — velocity overestimated")  
    ✗ {issue_3}  (e.g., "QE cycle time 40% of total — test suite growing slow")  

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
```

**Analysis rules:**
- "Went well" = high completion rate (>80%), few findings, fast cycle times, no blocked stories
- "Needs improvement" = carry-over stories, blocked stories, high finding count, slow cycle times, DoD failures

---

## Step 3 — Process Suggestions

Based on the analysis, propose **concrete, actionable** improvements. Each suggestion must be specific enough to apply immediately.

**Suggestion categories:**

### Adjust Verification Intensity
- If too many false-positive CR findings → "Reduce CR scope to architecture conformance only"
- If critical security findings emerged late → "Enable CE from this sprint (increase DoD intensity)"
- If test suite is slow → "Split QE into unit-only (per story) and integration (sprint review)" 

### Adjust Agent Backends 
- If SE cycle time is bottleneck → "Consider switching SE to Codex backend for parallel story execution"
- If QE is slow but stories are simple → "Switch QE to Codex for faster test generation"

### Adjust Sprint Capacity 
- If carry-over > 20% → "Reduce Sprint {N+1} capacity from {X} to {X * 0.8} stories"
- If 100% completion with margin → "Consider increasing Sprint {N+1} capacity by 1-2 stories"

### Process Changes
- If blocked stories → "Ensure SA reviews dependencies before Sprint Planning"
- If DoD compliance < 80% → "Add mandatory CR review for all stories (remove adaptive skip)"

Present suggestions:
```
  Suggested Improvements for Sprint {N+1}:

  1. [CAPACITY] Reduce sprint capacity from 6 to 5 stories
     Reason: 2 carry-over stories suggest overcommitment

  2. [BACKEND] Switch QE to Codex backend
     Reason: QE cycle time was 40% of total — async QE would reduce wall time

  3. [PROCESS] Require SA review for stories with external dependencies
     Reason: 2 stories blocked due to missing API contracts 

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  

  Options:
  1. Accept all improvements 
  2. Select specific improvements
  3. Skip all — no changes
  4. Chat about this 
```

---

## Step 4 — Apply Improvements 

For each accepted improvement: 

### Config changes (update `.sdlc-automation-agent.yaml`):  
- Capacity changes → update `sprint.velocity`
- Backend changes → update `agents.roles.{role}`
- DoD changes → update `dod.story.auto_check` items

### Process log entry:
Record each improvement in the state:
```python
# The Orchestrator records accepted improvements
# These are stored in pipeline-state.json → process_log
{ 
  "sprint": N, 
  "improvement": "Reduced sprint capacity from 6 to 5",
  "category": "capacity",
  "applied": true
}
```

Write process log to human-readable file:  
```
# Append to .sdlc-automation-agent/.orchestrator/process-log.md 

## Sprint {N} Retrospective — {date}

### Accepted Improvements
- [CAPACITY] Reduced sprint capacity from 6 to 5 stories 
- [BACKEND] Switched QE to Codex backend

### Declined 
- [PROCESS] SA review for external dependencies — deferred
```

---  

## Step 5 — Feed-Forward  

Prepare context for next Sprint Planning:

Write retro insights to `.sdlc-automation-agent/.orchestrator/retro-insights-sprint-{N}.md`: 
```markdown
# Sprint {N} Retro Insights (Feed-Forward)

## For PO (Sprint Planning):
- Velocity adjustment: {N} stories recommended for Sprint {N+1} 
- Carry-over stories: {list of story IDs to re-plan}
- New stories from feedback: {list if any} 

## For Orchestrator (Ceremony Intensity): 
- Planning intensity: {Full/Lightweight recommendation}
- DoD adjustments: {any changes applied}
- Backend changes: {any role backend switches}
```

---

## Step 6 — Transition to Sprint Close

```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" transition "$(pwd)" SPRINT_CLOSE 

Print: "✓ Retrospective complete. Proceeding to Sprint Close..."
→ Load ceremonies/sprint-close.md
```
