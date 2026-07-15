<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Kanban Mode — Continuous Ticket Flow

Maintenance and evolution mode for live brownfield projects. Pull ticket → execute → review → loop. On-demand release when ready.

## Trigger Signals

"kanban", "fix ticket", "work on TICKET-xxx", "pull next ticket", "maintenance mode", "implement TICKET-xxx", "pick up next"  

## Prerequisites

1. Project must be brownfield (existing codebase). Kanban is not available for greenfield. 
2. Verify Kanban state:
   ```
   STATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" read "$(pwd)" 2>&1) 
   ```
   If this fails: check if project needs Kanban initialization. 
   - If `.sdlc-automation-agent.yaml` exists with `build_mode: kanban`: run `kanban_state_machine.py init`
   - If no config: run Init mode first, then Discover. 

3. Read lifecycle state:
   ```
   LIFECYCLE_STATE=<extract lifecycle_state from STATE>
   ```

## State Routing

Route to the correct flow based on `lifecycle_state`:

### `DISCOVER`

The codebase hasn't been analyzed yet. Run Discover mode first:
```
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/modes/reverse.md")
```

After Discover completes, transition to READY:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" transition "$(pwd)" READY  
```

### `READY`

Waiting for the next ticket. Two ways to pick work:

**User specifies a ticket:** 
If the user's request includes a ticket ID (e.g., "fix TICKET-123", "implement TICKET-456"): 
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" pull_ticket "$(pwd)" "{TICKET_ID}" \
  --title "{TICKET_TITLE}"
``` 

**Auto-pull from tracker:**
If the user says "pull next ticket" or "what's next":  
```
TRACKER_CLI="python3 ${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/tracker/tracker_cli.py --project-dir $(pwd)"

# Query highest-priority ready ticket
NEXT=$(${TRACKER_CLI} query --status TO_DO --limit 1) 
```

Present the proposed ticket to the user:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KANBAN — Next Ticket
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  {TICKET_ID}: {TICKET_TITLE}
  Priority: {priority}
  Description: {first 2-3 lines}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Options:
  1. Work on this ticket (Recommended)
  2. Pick a different ticket 
  3. Release — prepare for production
  4. Chat about this
``` 

After ticket is confirmed, analyze for SA triggers:
```
Read("${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/sa-triggers.md") 
``` 
If architecture signals detected → dispatch SA before execution.

Transition to EXECUTION:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" transition "$(pwd)" EXECUTION 
``` 

### `EXECUTION` 

Run the per-ticket story pipeline. Follow the story-pipeline protocol:
```
Read("${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/story-pipeline.md")
```

Execute for the current ticket:
1. **SE implements** → ticket transitions: queued → in_progress → testing
2. **QE tests** → ticket transitions: testing → reviewing
3. **CR reviews** (adaptive) → ticket transitions: reviewing → done
4. **DoD evaluation** → result stored in ticket record

```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" evaluate_dod "$(pwd)" "{TICKET_ID}"
``` 

After ticket reaches `done`: 
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" complete_ticket "$(pwd)" "{TICKET_ID}"
``` 

Transition to REVIEW:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" transition "$(pwd)" REVIEW
```

### `REVIEW`

Per-ticket demo to the user.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KANBAN — Ticket Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Ticket:    {TICKET_ID}: {TICKET_TITLE}
  DoD:       {pass/fail with details}
  Artifacts: {list of files created/modified}
  Tests:     {tests_passing}/{tests_total} 

  Throughput: {throughput_7d} tickets/day (7-day window)  
  Avg Cycle:  {avg_cycle_time}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  

  Options:
  1. Pull next ticket (Recommended)
  2. Release — prepare for production 
  3. Retro — analyze recent ticket trends
  4. Chat about this
``` 

**Option 1 — Pull next:** Transition back to READY: 
``` 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" transition "$(pwd)" READY
```
Loop back to the READY section above.

**Option 2 — Release:** Transition to RELEASE:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" transition "$(pwd)" RELEASE
→ Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/modes/release.md")
```

**Option 3 — Retro:** Run the standalone retro mode: 
``` 
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/modes/retro.md")
```
After retro completes, return to READY.

### `RELEASE`

Load release mode:
```  
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/modes/release.md")
```  

### `COMPLETE`

Lifecycle is finished.
``` 
Print: "Kanban lifecycle complete. Project has been released."
``` 

---

## Kanban Metrics

Display throughput and cycle time when the user asks for status:  
```  
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" summary "$(pwd)"
```  

Output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KANBAN BOARD 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Board: 
    Queued:      {N} 
    In Progress: {N}
    Testing:     {N}
    Reviewing:   {N}
    Done:        {N}
    Blocked:     {N}

  Metrics:
    Cumulative:  {N} tickets completed
    Throughput:  {N} tickets/day (7-day window) 
    Avg Cycle:   {time}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

--- 

## Scrum → Kanban Transition 

When a Scrum project goes live and needs to switch to maintenance mode: 

1. Complete current sprint (or Release)
2. User says "switch to kanban" or "maintenance mode"  
3. Execute transition:
   ```
   python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" transition_to_kanban "$(pwd)"
   ```
4. Update `.sdlc-automation-agent.yaml`: `build_mode: kanban`
5. Kanban state machine takes over from READY
6. Sprint history is archived but accessible for metrics

Print:
``` 
✓ Transitioned from Scrum to Kanban
  Sprint history: archived ({N} sprints, velocity {V})
  Cumulative tickets: {N} (from completed sprint stories)
  Ready to pull first maintenance ticket.
```  
