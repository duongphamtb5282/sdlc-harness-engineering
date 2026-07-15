<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Backend Dispatch Protocol

> **Audience:** sdlc-automation-agent Orchestrator only. This protocol governs how the Orchestrator dispatches work to agent roles using pluggable AI backends.

## Purpose

sdlc-automation-agent v2.0 supports pluggable AI backends per agent role. The Orchestrator (always Claude) dispatches work to roles that may run on Claude (built-in subagent), Codex (external CLI), Gemini (external CLI), or future providers. This protocol defines the dispatch contract, resolution logic, and integration requirements.  

## Backend Resolution

For **every** agent dispatch, resolve the backend before composing the prompt. 

### Resolution Order 

1. Check `.sdlc-automation-agent.yaml` → `agents.roles.{role_name}` (explicit per-role override)
2. Fall back to `agents.default_backend` (project-wide default) 
3. Fall back to `"claude"` (hardcoded ultimate default)

### Resolution via Python Helper 

```  
BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "{role_name}")  
```

The helper normalizes role names (both `software-engineer` and `software_engineer` resolve identically) and validates against the set of known backends.

### Resolution via Inline Logic

If the Python helper is unavailable, resolve inline:

``` 
config = Read(".sdlc-automation-agent.yaml")
agents_config = config.agents or {}
default_backend = agents_config.default_backend or "claude"
roles_map = agents_config.roles or {}
normalized_role = role_name.replace("-", "_")
BACKEND = roles_map.get(normalized_role, default_backend)
```  

## Dispatch Contract 

Every backend wrapper implements these four operations:

### dispatch(role, task, context, mode) → result | job_id

- **role**: Agent role name (e.g., `"software-engineer"`)
- **task**: Self-contained task description (story details, acceptance criteria, constraints) 
- **context**: File paths and artifacts the agent needs access to
- **mode**: `"sync"` (block until complete) or `"async"` (return immediately with job ID)
- **Returns**: 
  - Sync mode → receipt dict (or error) 
  - Async mode → job ID string

### poll(job_id) → status

- Returns: `"running"` | `"completed"` | `"failed"` | `"cancelled"` 
- Only valid for async dispatches. Calling on a sync dispatch is a no-op.

### fetch(job_id) → result

- Returns the result of a completed async job (receipt dict or error details)
- Must only be called after `poll()` returns `"completed"`

### cancel(job_id) → void

- Terminates a running async job 
- Best-effort — the backend may have already completed

## Dispatch Flow

For each agent invocation, the Orchestrator follows these steps:

### Step 1 — Resolve Backend

```
BACKEND = get_agent_backend(role_name)
```

### Step 2 — Read Backend Wrapper

``` 
Read("${CLAUDE_PLUGIN_ROOT}/skills/_shared/backends/{BACKEND}.md")
```

Follow the wrapper's instructions for all subsequent steps.  

### Step 3 — Build the Prompt

**If BACKEND is `"claude"`:**
- Use the role's SKILL.md directly (Claude subagents understand the full format)
- Compose a self-contained Agent() prompt per the subagent-isolation protocol

**If BACKEND is anything else (external CLI):** 
- Extract portable instructions from the role's SKILL.md using the prompt translator:
  ```
  python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/prompt_translator.py" extract "${CLAUDE_PLUGIN_ROOT}/agents/{role_name}/SKILL.md"
  ```
- Combine extracted instructions with task-specific context (story, constraints, output paths) 
- Apply backend-specific formatting per the wrapper's "Prompt Format" section 

### Step 4 — Dispatch

Execute using the backend wrapper's dispatch procedure:  
- **Claude**: `Agent()` call (always sync, blocks until subagent completes)
- **Codex**: shell out to `codex` CLI (sync or async per mode parameter) 
- **Gemini**: shell out to `gemini` CLI (sync or async)

### Step 5 — Collect Result 

- **Claude**: subagent writes receipt directly → read and validate 
- **External backends**: Orchestrator parses CLI output → constructs receipt → writes to receipt path

### Step 6 — Validate Receipt

Verify the receipt:
1. Required fields present: `story_id`, `role`, `backend`, `model`, `artifacts`, `verification_commands`
2. All artifact files exist on disk
3. At least one verification command is present
4. Backend and model fields match the dispatch

For Claude backend, the `crew-verify-receipt.sh` hook also fires on SubagentStop.
For external backends, call the receipt validator explicitly after collecting the result.

## Receipt Integration

All backends must produce receipts in the v2 format:

```json
{
  "story_id": "US-042",
  "role": "software-engineer", 
  "backend": "codex",  
  "model": "gpt-4.1",
  "story_dod": {
    "tests_pass": true,
    "build_succeeds": true,
    "no_critical_findings": true
  },
  "artifacts": [
    "src/services/user-service.ts",
    "src/routes/user-routes.ts" 
  ],
  "verification_commands": [ 
    {
      "command": "npm test -- --testPathPattern=user-service",
      "exit_code": 0, 
      "summary": "12 tests passing" 
    }
  ],
  "metrics": {
    "files_created": 4,
    "files_modified": 2,
    "tests_written": 12, 
    "tests_passing": 12
  },
  "effort": {
    "files_read": 15, 
    "files_written": 6,
    "tool_calls": 42
  },
  "completed_at": "2026-04-12T14:30:00Z" 
}
```

**New v2 fields** (compared to v1):
- `backend` (required): which backend executed the role (`"claude"`, `"codex"`, `"gemini"`, etc.)
- `model` (required): specific model identifier used (`"claude-sonnet-4-6"`, `"gpt-4.1"`, etc.)
- `story_dod` (optional): inline per-story DoD evaluation (populated in Wave 2+) 

**For Claude backend:** The subagent writes the receipt directly (same as v1, with new fields).
**For external backends:** The Orchestrator parses CLI output and writes the receipt on behalf of the backend.

## Error Handling 

| Scenario | Action | 
|----------|--------|
| Backend CLI not installed | BLOCK dispatch. Report to user with install instructions from the wrapper. |
| Dispatch fails (CLI error, crash) | Retry once. If still fails, offer to fall back to Claude backend. |
| Async job timeout (>30 min default) | Cancel the job. Report timeout to user. Suggest sync mode or Claude fallback. |
| Receipt missing after completion | Construct receipt from `git diff` (identify created/modified files). |
| Receipt malformed | Orchestrator rewrites receipt from available output data. |
| Async job conflict (same directory) | WARN user. Recommend worktree isolation (Wave 2+) or sequential dispatch. |

### Fallback Chain

When an external backend fails: 
1. Retry once with the same backend
2. If still fails, ask: "The {backend} backend failed for {role}. Fall back to Claude?"
3. If user approves (or in autonomous mode), re-dispatch via Claude backend
4. Record the fallback in the receipt: `"fallback_from": "codex"` 

## Backend Capabilities Matrix

| Backend | Sync | Async | Self-Receipt | Prompt Format |
|---------|------|-------|-------------|---------------| 
| `claude` | Yes | No | Yes (subagent writes) | Full SKILL.md + Agent() |  
| `codex` | Yes | Yes | No (Orchestrator writes) | Plain text + instructions file |
| `gemini` | Yes | Yes | No (Orchestrator writes) | Plain text + instructions file |
| `opencode` | Yes | Yes | No (Orchestrator writes) | Plain text + instructions file |

## Relationship to Model Tier Routing

Backend dispatch and model tier routing are **orthogonal**:

- `get_agent_backend(role)` → which AI system runs the role
- `get_agent_model(role)` → which model tier within Claude (opus/sonnet/haiku)

When `backend == "claude"`: both apply. The Orchestrator selects the model tier for the Agent() call.
When `backend != "claude"`: only the backend matters. The external CLI handles its own model selection. The `model` receipt field captures what the external CLI actually used.

## Async Job Directory

Background jobs for async dispatches are tracked in `/tmp/sdlc-automation-agent-jobs/`:

```
/tmp/sdlc-automation-agent-jobs/
  {job_id}.pid          # Process ID
  {job_id}.status       # "running" | "completed" | "failed" | "cancelled"
  {job_id}.status.exit  # Exit code (written after completion)
  {job_id}.log          # stdout+stderr capture
  {job_id}.prompt       # Prompt file used for dispatch 
```

Job IDs follow the pattern: `{backend}-{role}-{story_id}-{timestamp}`

Cleanup: Session-end hooks should remove completed job files. The `crew-session-end.sh` hook handles this.
