<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Story Pipeline Protocol

> **Audience:** sdlc-automation-agent Orchestrator only. Defines how each story/ticket flows through the SE → QE → CR pipeline with backend-aware dispatch.

## Overview

Each story runs through a fixed pipeline: **SE implements → QE tests → CR reviews → DoD evaluation**. The Orchestrator drives this loop for every story, whether in Scrum (sprint-scoped batches) or Kanban (continuous pull).  

The pipeline uses story sub-states managed by `story_pipeline.py`:
```
queued → in_progress → testing → reviewing → done
                  ↘      ↘         ↘
                   → → → blocked → → →
```

## Pipeline Stages

### Stage 1 — SE Implementation (queued → in_progress → testing) 

**Trigger**: Story is in `queued` state, ready for implementation.

**Step 1a — Transition to in_progress**:
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" transition "$(pwd)" "{story_id}" in_progress
``` 

**Step 1b — Resolve SE backend**:
```bash
SE_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "software-engineer")
```

**Step 1c — Dispatch**:

Read the backend wrapper at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/backends/${SE_BACKEND}.md` and follow its dispatch procedure.

**If Claude backend**:  
- Build self-contained Agent() prompt per the claude.md wrapper
- Include: story ID, title, acceptance criteria, context files, constraints  
- Subagent reads `${CLAUDE_PLUGIN_ROOT}/agents/software-engineer/SKILL.md`  
- Subagent writes receipt to `.sdlc-automation-agent/.orchestrator/receipts/{story_id}-se.json`

**If external backend** (codex/gemini):
- Extract instructions via `prompt_translator.py extract` 
- Compose prompt per the backend wrapper's format
- Dispatch (sync preferred for pipeline ordering; async if backend is slow) 
- On completion: Orchestrator constructs receipt if backend didn't write one

**Step 1d — Validate receipt**:
```bash 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/receipt_validator.py" \
    ".sdlc-automation-agent/.orchestrator/receipts/{story_id}-se.json" "$(pwd)"
```

**Step 1e — Transition to testing**:
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" transition "$(pwd)" "{story_id}" testing
```

**On failure**: Retry once. If still fails, block the story:
```bash
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" transition "$(pwd)" "{story_id}" blocked \
    --reason "SE dispatch failed: {error_details}"
```

---

### Stage 2 — QE Testing (testing → reviewing) 

**Trigger**: Story transitions to `testing` (SE receipt exists).

**Step 2a — Resolve QE backend**:
```bash
QE_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "quality-engineer")
``` 

**Step 2b — Build QE prompt context**:

The QE prompt must include:
- Story ID, title, acceptance criteria
- SE receipt artifacts (so QE knows what files to test)
- Test framework from `.sdlc-automation-agent.yaml` (e.g., jest, pytest, go-test) 
- Test infrastructure paths (e.g., `tests/`, existing test utilities) 

**Step 2c — Dispatch QE** per the backend wrapper instructions.

**Step 2d — Validate receipt**: `{story_id}-qe.json`  

**Step 2e — Transition to reviewing**:
```bash 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" transition "$(pwd)" "{story_id}" reviewing
``` 

--- 

### Stage 3 — CR Review (reviewing → done) [Adaptive]

**Trigger**: Story transitions to `reviewing` (QE receipt exists).

**Step 3a — Check adaptive intensity**:

Determine if CR is required at the current DoD intensity level.

For Scrum:
```bash
SPRINT_NUM=$(python3 -c "
import json, sys
state = json.load(open('.sdlc-automation-agent/.orchestrator/pipeline-state.json'))
print(state.get('current_sprint', 1))
")
```

For Kanban:
```bash
TICKET_NUM=$(python3 -c " 
import json, sys 
state = json.load(open('.sdlc-automation-agent/.orchestrator/pipeline-state.json'))
print(state.get('cumulative_ticket_number', 1))
")
```

**Intensity rules**:
- `early` (Sprint 1 / tickets 1-5): **SKIP CR** — transition directly to `done`
- `growing` (Sprint 2-3 / tickets 6-15): **Run CR**
- `mature` (Sprint 4+ / tickets 16+): **Run CR**
- `release`: **Run CR at max depth** 

**If skipping CR**:
```bash 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" transition "$(pwd)" "{story_id}" done
```
Proceed directly to Stage 4 (DoD evaluation). 

**If running CR**:  
- Resolve CR backend
- Build CR prompt with SE artifacts + QE test results
- Dispatch per backend wrapper
- Validate receipt: `{story_id}-cr.json`
- Transition to `done`

--- 

### Stage 4 — DoD Evaluation (after story reaches done)

After a story reaches `done`, evaluate its Definition of Done:

For Scrum:
```bash 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" evaluate_dod "$(pwd)" "{story_id}"
```

For Kanban:
```bash 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/kanban_state_machine.py" evaluate_dod "$(pwd)" "{story_id}"
```

The DoD result is stored in the story record's `dod` field. If critical DoD checks fail, the Orchestrator flags this for the Sprint Review (Scrum) or ticket Review (Kanban).

---

## Batch Execution (Scrum — Sprint Mode)

During SPRINT_EXECUTION, the Orchestrator processes all sprint stories through the pipeline. 

**Sequential execution** (default — safe, no file conflicts):
```
for each story in sprint_backlog (ordered by priority):  
    Stage 1: SE implements story  
    Stage 2: QE tests story
    Stage 3: CR reviews story (if applicable)
    Stage 4: DoD evaluation
```

**Async pipelining** (when SE uses an async-capable external backend):
```
Story 1: SE(sync) →  QE(sync) →  CR(sync)  → DoD
Story 2:     SE(async, started after Story 1 SE) → QE(sync, after SE done) → CR → DoD
Story 3:         SE(async, started after Story 2 SE) → ... 
```

When the SE backend supports async dispatch (e.g., Codex), the Orchestrator can start SE work on the next story while QE/CR work on the current story. This overlaps SE and QE work across stories.

**Infrastructure stories**: Stories tagged as infrastructure (PE stories) run in parallel with the app story pipeline. The Orchestrator dispatches PE work via the Platform Engineer agent independently.

--- 

## Continuous Execution (Kanban Mode)

In EXECUTION state, tickets are processed one at a time:

``` 
1. Ticket is in current_stories with state "queued" 
2. Run through SE → QE → CR → DoD pipeline
3. On completion: complete_ticket moves it to tickets_completed
4. Transition lifecycle to REVIEW for per-ticket demo
5. After review: loop back to READY (pull next) or RELEASE
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| SE dispatch fails | Retry once. If still fails, block story with reason. Offer Claude fallback. |
| QE dispatch fails | Block story. Do not proceed to CR. |
| CR dispatch fails | Mark CR as skipped. Story can still reach `done` — DoD notes CR was unavailable. |
| DoD critical check fails | Story is marked `done` but flagged. Sprint Review / ticket Review highlights it. |
| Story blocked mid-pipeline | Record `blocked_from` state. Orchestrator can `unblock` to resume from where it left off. |
| Backend fallback | If external backend fails twice, fall back to Claude. Record `fallback_from` in receipt. |

## Blocked Story Recovery

When a story is blocked:
```bash  
# Check blocked stories
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" list_stories "$(pwd)" blocked

# Unblock (restores to the state it was blocked from)
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/story_pipeline.py" unblock "$(pwd)" "{story_id}"

# Resume the pipeline from the restored state
```

The `unblock` action restores the story to its `blocked_from` state (e.g., if blocked during `testing`, it returns to `testing` so QE can retry). 
