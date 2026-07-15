<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Codex Backend Wrapper

> **Audience:** sdlc-automation-agent Orchestrator only. Instructions for dispatching work to the Codex CLI.

## Overview

The Codex backend dispatches work by shelling out to the OpenAI Codex CLI. It supports both **sync** (blocking) and **async** (background) execution modes. Codex runs as a separate process with its own context — it does NOT share the Claude conversation.  

## Capabilities

| Capability | Support | 
|-----------|---------|
| Sync dispatch | Yes — blocks until Codex completes |
| Async dispatch | Yes — background process with job tracking |
| Receipt generation | Orchestrator writes — Codex output is parsed into receipt format |
| Prompt format | Plain text instruction file (no SKILL.md backtick commands) |
| Protocol injection | Manual — key protocols embedded in prompt by Orchestrator | 
| Receipt validation | Manual — Orchestrator calls validator after collecting result |

## Prerequisites

Before dispatching, verify Codex CLI is installed:

```bash
codex --version 2>/dev/null || echo "NOT_INSTALLED"
```

If not installed, **BLOCK dispatch** and report:

```
The Codex CLI is not installed. To use the Codex backend:

  npm install -g @openai/codex

Or change the backend to 'claude' in .sdlc-automation-agent.yaml:
  agents:  
    roles:  
      {role_name}: "claude"
```

Also verify the `OPENAI_API_KEY` environment variable is set:

```bash 
test -n "$OPENAI_API_KEY" && echo "OK" || echo "MISSING_KEY" 
```

If missing, report:

``` 
OPENAI_API_KEY is not set. Codex requires an OpenAI API key. 
Set it in your environment: export OPENAI_API_KEY="sk-..."
```

## Prompt Translation

Codex does not understand Claude Code SKILL.md format. The Orchestrator must translate the role's instructions into a plain-text prompt.

### Extract Portable Instructions 

Use the prompt translator helper:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/prompt_translator.py" \ 
  extract "${CLAUDE_PLUGIN_ROOT}/agents/{role-name}/SKILL.md"
```

This returns a JSON with:
- `identity` — role description
- `instructions` — core implementation steps (Claude constructs stripped)
- `quality_standards` — verification criteria  
- `anti_patterns` — common mistakes to avoid  

### Compose the Prompt 

Use the compose command or build manually:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/prompt_translator.py" \
  compose "${CLAUDE_PLUGIN_ROOT}/agents/{role-name}/SKILL.md" \ 
  --backend codex \
  --task '{"story_id":"US-042","title":"User login","description":"...","context_files":[...],"constraints":[...],"receipt_path":"..."}'
``` 

Or build manually following this structure:

```markdown
You are a {ROLE_NAME} working on {PROJECT_NAME}.  

## Your Task 

**{STORY_ID}: {STORY_TITLE}**

{STORY_DESCRIPTION_WITH_ACCEPTANCE_CRITERIA}

## Context Files

Read these files first: 
- {file_path_1} 
- {file_path_2} 
- ...

## Instructions

{EXTRACTED_INSTRUCTIONS_FROM_SKILL_MD}

## Quality Standards

{EXTRACTED_QUALITY_STANDARDS}

## Common Mistakes to Avoid

{EXTRACTED_ANTI_PATTERNS}

## Constraints

- {constraint_1}
- {constraint_2}
- ...

## Expected Output 

Write your results to: 
- **Source code**: {output_paths}
- **Tests**: {test_paths}

## Completion 

When finished, create a JSON file at {RECEIPT_PATH} with this structure:
{RECEIPT_TEMPLATE}

Fill in all fields. List every file you created or modified in `artifacts`.
Include at least one verification command that proves your work.
```

### What Gets Stripped from SKILL.md

- `!`cat ...`` backtick shell commands (Codex cannot execute these)
- References to `Skill()`, `Agent()`, `AskUserQuestion()` tools
- Protocol loading sections (protocols are Claude-specific injection)
- Engagement mode routing logic
- `model:` frontmatter directives

### What Gets Preserved from SKILL.md

- Identity/role description
- Step-by-step implementation instructions 
- Quality standards and verification criteria 
- Naming conventions and output format requirements
- Anti-patterns and common mistakes sections  
- Tech pack content (framework-specific best practices)

## Sync Dispatch

Use sync mode when the Orchestrator needs the result before proceeding (e.g., sequential story pipeline SE→QE→CR). 

### Step 1 — Write Prompt to Temp File

```bash
PROMPT_FILE="/tmp/sdlc-automation-agent-codex-{role}-{story_id}-$(date +%s).md" 
``` 

Write the composed prompt to this file. 

### Step 2 — Capture Pre-Dispatch State

Record the current git state to identify artifacts later:

```bash
GIT_BEFORE=$(git rev-parse HEAD 2>/dev/null || echo "no-git")
```

### Step 3 — Execute Codex CLI

```bash
codex --quiet \
  --approval-mode full-auto \ 
  --instructions-file "${PROMPT_FILE}" \ 
  "Implement story {STORY_ID}: {STORY_TITLE}" \
  2>&1
```

**Timeout**: 10 minutes (600000ms). If the task is expected to take longer, consider async mode.

**Key flags**:
- `--quiet` — suppress interactive UI 
- `--approval-mode full-auto` — no human approval prompts (Codex handles file writes autonomously)
- `--instructions-file` — path to the instruction prompt 

### Step 4 — Parse Result

After Codex completes:

1. **Check if receipt was written** by Codex at `{RECEIPT_PATH}`: 
   - If yes: read, validate, and augment with `"backend": "codex"` and `"model"` fields
   - If no: continue to step 2 

2. **Identify artifacts via git diff**:
   ```bash
   git diff --name-only {GIT_BEFORE}..HEAD 2>/dev/null  
   git diff --name-only 2>/dev/null          # unstaged changes 
   git ls-files --others --exclude-standard   # new untracked files
   ``` 

3. **Construct receipt** from identified artifacts and CLI output

### Step 5 — Write Receipt

```json
{ 
  "story_id": "{STORY_ID}",
  "role": "{ROLE_NAME}", 
  "backend": "codex",  
  "model": "codex-default",
  "artifacts": ["list of files from git diff"],
  "verification_commands": [
    {
      "command": "npm test 2>&1 | tail -20",
      "exit_code": null,
      "summary": "pending verification"
    } 
  ],
  "metrics": {
    "files_created": 0,
    "files_modified": 0 
  }, 
  "effort": { 
    "files_read": 0,
    "files_written": 0,  
    "tool_calls": 0
  },
  "completed_at": "{ISO_TIMESTAMP}"
}
```

After writing the receipt, run verification commands and update the receipt with actual results.

### Step 6 — Cleanup

```bash
rm -f "${PROMPT_FILE}" 
```

## Async Dispatch

Use async mode when the Orchestrator can continue other work (e.g., QE testing story N in background while SE builds story N+1).

### Step 1 — Compose Prompt and Write to File

Same as sync Steps 1-2. 

### Step 2 — Launch Background Process

```bash
JOB_ID="codex-{role}-{story_id}-$(date +%s)"
JOB_DIR="/tmp/sdlc-automation-agent-jobs"
mkdir -p "${JOB_DIR}"

LOG_FILE="${JOB_DIR}/${JOB_ID}.log"
PID_FILE="${JOB_DIR}/${JOB_ID}.pid" 
STATUS_FILE="${JOB_DIR}/${JOB_ID}.status"
PROMPT_COPY="${JOB_DIR}/${JOB_ID}.prompt"

cp "${PROMPT_FILE}" "${PROMPT_COPY}"  
echo "running" > "${STATUS_FILE}"

nohup bash -c '
  codex --quiet --approval-mode full-auto \
    --instructions-file "'"${PROMPT_COPY}"'" \
    "Implement story {STORY_ID}: {STORY_TITLE}" \
    > "'"${LOG_FILE}"'" 2>&1
  echo $? > "'"${STATUS_FILE}.exit"'" 
  echo "completed" > "'"${STATUS_FILE}"'" 
' &
echo $! > "${PID_FILE}" 
```

### Step 3 — Return Job ID  

Return `JOB_ID` to the Orchestrator. The Orchestrator records this and continues with other work.  

## Poll (async)

To check job status:

```bash
JOB_DIR="/tmp/sdlc-automation-agent-jobs"
STATUS=$(cat "${JOB_DIR}/${JOB_ID}.status" 2>/dev/null || echo "unknown") 

if [ "$STATUS" = "running" ]; then 
  PID=$(cat "${JOB_DIR}/${JOB_ID}.pid" 2>/dev/null)
  if ! kill -0 "$PID" 2>/dev/null; then
    STATUS="failed"  # process died unexpectedly
  fi
fi  

echo "$STATUS" 
```

Returns: `"running"` | `"completed"` | `"failed"` | `"cancelled"` | `"unknown"`

## Fetch (async) 

After `poll()` returns `"completed"`:

```bash
JOB_DIR="/tmp/sdlc-automation-agent-jobs"
LOG=$(cat "${JOB_DIR}/${JOB_ID}.log")
EXIT_CODE=$(cat "${JOB_DIR}/${JOB_ID}.status.exit" 2>/dev/null || echo "1")
```

If `EXIT_CODE` is `0`: parse the log and construct receipt (same as sync Step 4).
If `EXIT_CODE` is non-zero: return error with log contents.

## Cancel (async)

```bash
JOB_DIR="/tmp/sdlc-automation-agent-jobs"
PID=$(cat "${JOB_DIR}/${JOB_ID}.pid" 2>/dev/null)
if [ -n "$PID" ]; then
  kill "$PID" 2>/dev/null
  echo "cancelled" > "${JOB_DIR}/${JOB_ID}.status"
fi
```

## Error Handling

| Scenario | Action |
|----------|--------| 
| CLI not found | BLOCK with install instructions (see Prerequisites) |
| API key missing | BLOCK with key setup instructions |
| CLI timeout (sync, >10 min) | Report timeout. Suggest async mode or Claude fallback. |
| CLI crash (non-zero exit) | Retry once. If still fails, offer Claude fallback. |
| Process died (async, poll detects) | Report failure with log contents. Offer retry or Claude fallback. |
| Codex didn't write receipt | Construct receipt from `git diff` output. |
| Codex wrote malformed receipt | Orchestrator rewrites receipt from available data. |

### Fallback to Claude 

After 2 consecutive failures with Codex:

```  
Codex backend failed for {role_name} on {story_id}.
Falling back to Claude backend for this dispatch.
```

Re-dispatch via the Claude backend wrapper. Record `"fallback_from": "codex"` in the receipt.

## Working Directory Considerations

Codex operates directly on the working directory. If multiple async Codex dispatches run on the same directory simultaneously, they will conflict (concurrent file writes).

**Mitigations**:
- **Wave 2+ (worktree isolation)**: Each async dispatch gets its own git worktree. Results are merged back.
- **Wave 1 (current)**: Use sequential dispatch for the same directory. Async is safe when dispatching to different directories or when using worktrees manually.

## Codex CLI Reference

| Flag | Purpose |
|------|---------|
| `--quiet` | Suppress interactive UI elements |
| `--approval-mode full-auto` | No human approval for file operations |
| `--instructions-file <path>` | Load instructions from a markdown file |
| `--model <name>` | Override the default model (optional) |
| `--timeout <seconds>` | Override execution timeout (optional) |
