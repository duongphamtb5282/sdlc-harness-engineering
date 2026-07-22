<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Sprint Mode — Scrum Ceremony Dispatcher

Execute a Scrum sprint cycle. Routes to the correct ceremony based on the current lifecycle state. Each ceremony handles its own transitions.

## Trigger Signals

"build sprint", "sprint N", "next sprint", "continue sprint", "resume sprint", "run sprint", "start sprint", "sprint planning", "sprint review", "sprint close"  

## Prerequisites

1. Project must be initialized with Scrum build mode: 
   ``` 
   STATE=$(python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" read "$(pwd)" 2>&1)
   ```
   If this fails with "v1 state detected" or no state file exists:
   - If `.sdlc-automation-agent.yaml` exists with `build_mode: scrum`: run `scrum_state_machine.py init` 
   - If no config: run Init mode first (`/sdlc-automation-agent init`)

2. Read current lifecycle state: 
   ```
   LIFECYCLE_STATE=<extract lifecycle_state from STATE>
   ```

## Ceremony Routing

Route to the correct ceremony based on `lifecycle_state`:

### `INCEPTION`

Inception is not yet complete. Inception mode handles Sprint 0 (Wave 4).
For now, transition to SPRINT_PLANNING:
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" transition "$(pwd)" SPRINT_PLANNING
```
Then fall through to SPRINT_PLANNING below.

### `SPRINT_PLANNING`  

Load and follow the Sprint Planning ceremony:
```
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/ceremonies/sprint-planning.md") 
``` 

Sprint Planning handles:
- PO backlog refinement (adaptive intensity)
- SA architecture auto-detect (conditional)
- Story selection with velocity constraint 
- Sprint Goal confirmation
- QE test specification 
- Transition to SPRINT_EXECUTION via `start_sprint` 

### `SPRINT_EXECUTION`

Execute the story pipeline for all sprint stories. Follow the story-pipeline protocol:
```  
Read("${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/story-pipeline.md")
```

For each story in the sprint backlog (ordered by priority):
1. **SE implements** → story transitions: queued → in_progress → testing
2. **QE tests** → story transitions: testing → reviewing
3. **CR reviews** (adaptive) → story transitions: reviewing → done
4. **DoD evaluation** → result stored in story record

After all stories are processed (all `done` or `blocked`):
```
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" complete_sprint "$(pwd)"
```
This transitions to SPRINT_REVIEW.  

**Infrastructure stories:** Stories tagged as infrastructure (PE) run in parallel with the app story pipeline. Detect by story title/labels containing: "infra", "CI/CD", "Docker", "Terraform", "monitoring", "pipeline".

### `SPRINT_REVIEW`

Load and follow the Sprint Review ceremony: 
```
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/ceremonies/sprint-review.md")
``` 

Sprint Review handles: 
- Preview deployment (auto-detected for web apps)
- TW sprint reports
- Demo organized by Sprint Goal
- Sprint-level DoD overlay (human + auto checks)  
- Stakeholder feedback capture  
- PO backlog updates from feedback  
- Transition to SPRINT_RETRO or SPRINT_CLOSE

### `SPRINT_RETRO`

Load and follow the Sprint Retrospective ceremony:
```
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/ceremonies/sprint-retro.md")
```

Sprint Retro handles:
- Data collection (git, receipts, velocity, cycle time)
- Analysis (went well vs needs improvement)
- Process suggestions (concrete, actionable)
- Apply accepted improvements to config
- Feed-forward to next Sprint Planning  
- Transition to SPRINT_CLOSE  

### `SPRINT_CLOSE`

Load and follow the Sprint Close ceremony:
``` 
Read("${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/ceremonies/sprint-close.md")
```

Sprint Close handles:
- Carry-over policy for incomplete stories
- Sprint metrics summary
- Next decision: Continue / Release / Stop
- Transition to SPRINT_PLANNING (loop) or RELEASE

### `RELEASE`

Release mode (Wave 4). Full regression, security audit, production infrastructure, documentation.

### `COMPLETE`

Project lifecycle is finished. Report final status.

---

## Git Safety Rules (MANDATORY)

These rules apply to all sdlc-automation-agent agents, Claude Code, and automated tooling: 

1. **NEVER commit or push to shared branches** (`dev`, `qa`, `uat`, `main`, `prod`, `staging`, `release`). All work MUST happen on feature branches. 
2. **NEVER create commits without explicit user approval.** Always show the diff and ask before committing.
3. **NEVER push to any remote branch without explicit user approval.** Always ask before running `git push`.  
4. **NEVER create or merge pull requests without explicit user approval.**
5. **NEVER run destructive git operations** (`git push --force`, `git reset --hard`, `git clean -f`, `git checkout .`).
6. **NEVER run database migrations against shared environments** (dev, qa, uat, prod). Migrations can only be run locally. 

If the user says "just do it" or "go ahead", that applies to the current code change only — NOT to committing, pushing, or merging.

---

## Sprint Number Detection 

When the user says "sprint N" or "build sprint 3": 

1. Extract the sprint number from the request 
2. Compare with `current_sprint` in state:
   - If N == current_sprint: resume the current sprint
   - If N == current_sprint + 1: start next sprint (must be in SPRINT_PLANNING)
   - If N > current_sprint + 1: block — "Cannot skip sprints. Current sprint is {current_sprint}."
   - If N < current_sprint: block — "Sprint {N} is already completed."

When the user says "next sprint" or "continue sprint":
- Use current_sprint + 1 if in SPRINT_CLOSE/SPRINT_PLANNING
- Resume current_sprint if in SPRINT_EXECUTION

--- 

## Progress Output 

Print the ceremony header at the start of each ceremony:

```
━━━ Sprint {N} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Stage: {CEREMONY_NAME}
  Goal:  {SPRINT_GOAL}
  Stories: {completed}/{total} done  
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
``` 
