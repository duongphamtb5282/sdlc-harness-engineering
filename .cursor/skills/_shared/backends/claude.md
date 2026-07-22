<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Claude Backend Wrapper

> **Audience:** sdlc-automation-agent Orchestrator only. Instructions for dispatching work to Claude subagents.

## Overview

The Claude backend dispatches work via the `Agent()` tool — the built-in Claude Code subagent mechanism. This is the default backend. Execution is always **synchronous**: the Orchestrator blocks until the subagent completes.  

## Capabilities

| Capability | Support | 
|-----------|---------|
| Sync dispatch | Yes |
| Async dispatch | No — Claude subagents are inline |
| Receipt generation | Self-service — subagent writes its own receipt | 
| Prompt format | Full SKILL.md content via Skill() tool loading |
| Protocol injection | Automatic — `crew-inject-protocols.sh` fires on SubagentStart | 
| Receipt validation | Automatic — `crew-verify-receipt.sh` fires on SubagentStop |

## Dispatch Procedure

### Step 1 — Build the Prompt

Construct a self-contained prompt for the `Agent()` call. Follow the **subagent-isolation protocol**: the subagent receives everything it needs to operate independently.

**Prompt structure:**

```
You are the {ROLE_NAME} for the {PROJECT_NAME} project.

## Your Task

{TASK_DESCRIPTION}

Story: {STORY_ID} — {STORY_TITLE}
Acceptance Criteria:
{ACCEPTANCE_CRITERIA}

## Context  

Read these files before starting (in parallel):
- .sdlc-automation-agent.yaml
- .sdlc-automation-agent/.orchestrator/settings.md (if exists)
- .sdlc-automation-agent/.orchestrator/codebase-context.md (if exists) 
{ADDITIONAL_CONTEXT_FILES} 

## Constraints

{SPRINT_CONSTRAINTS}
{PROTECTED_MODULES} 
{ARCHITECTURAL_RULES} 

## Instructions  

Read and follow the full instructions in:
${CLAUDE_PLUGIN_ROOT}/agents/{role-name}/SKILL.md 

## Output

Write your receipt to:
.sdlc-automation-agent/.orchestrator/receipts/{STORY_ID}-{role-abbrev}.json

The receipt MUST include: 
- backend: "claude"
- model: (the model you are running on)
- story_id: "{STORY_ID}"
- All standard receipt fields per the receipt protocol
```

The subagent loads its full SKILL.md via the plugin's skill system. The `crew-inject-protocols.sh` hook fires on SubagentStart and injects all shared protocols automatically.

### Step 2 — Determine Model 

Apply model tier routing based on engagement mode and role importance: 

``` 
model = get_agent_model(role_name)
```

Model tier mapping:

| Agent Role | Autonomous | Controlled | 
|-----------|-----------|-----------|
| product_manager | opus | opus |
| solution_architect | opus | opus |
| compliance_engineer | opus | opus |
| research_advisor | opus | opus |  
| software_engineer | sonnet | sonnet |
| quality_engineer | sonnet | sonnet |
| platform_engineer | sonnet | sonnet |
| technical_writer | sonnet | sonnet |
| code_reviewer | sonnet | sonnet | 

**Controlled mode** surfaces decisions and enforces human gates for the four strategic roles (PM, SA, CE, RA) — it does not upgrade executor roles (SE, QE, PE, TW, CR), which follow orchestrator direction and don't make autonomous decisions. 

The model tier is INDEPENDENT of backend dispatch — it only applies within the Claude backend.

**Tier → model ID pinning (HC0-F2).** Tier aliases above (`opus`, `sonnet`, `haiku`) are resolved to **exact** model IDs via [model-pins.json](model-pins.json). Do not pass alias strings to `Agent()` — pass the resolved exact ID so regulated customers can reproduce behavior audit-to-audit. Current pins: `opus → claude-opus-4-7`, `sonnet → claude-sonnet-4-6`, `haiku → claude-haiku-4-5-20251001`. Update `model-pins.json` when rolling forward — every change is a reviewable diff rather than silent drift. 

### Step 3 — Dispatch via Agent()

```  
Agent(
  prompt = composed_prompt, 
  subagent_type = "general-purpose", 
  model = model,
  description = "{ROLE_NAME}: {STORY_ID} — {STORY_TITLE}"
)
```

The `Agent()` call blocks until the subagent completes. The Orchestrator cannot do other work during this time.

**For parallel dispatch** (e.g., SE backend + SE frontend), use separate Agent() calls. Claude Code manages concurrent subagents via worktree isolation when available. **Concurrency cap (BEA3-F1): the Orchestrator must never have more than `.sdlc-automation-agent.yaml → parallelism.max_concurrent_subagents` Agent() calls in flight.** Default is 3. Before dispatching, count active agent_start events in `events.jsonl` for the current chain_id that have not yet seen a matching subagent_stop; if that count is already at the cap, queue the new dispatch behind an existing one.

**Correlation IDs and depth guard (H9-F1, BEA4-F1).** The plugin's SubagentStart hook (`crew-inject-protocols.sh`) increments a per-project `active-depth` counter in `.sdlc-automation-agent/.orchestrator/active-depth` and blocks with exit 1 when the counter exceeds `MAX_AGENT_DEPTH=3`. SubagentStop (`crew-verify-receipt.sh`) decrements it. A chain_id is minted once per project and persisted in `.sdlc-automation-agent/.orchestrator/chain-id`; every event in `events.jsonl` is tagged with this chain_id plus the current depth. The Orchestrator does not need to set env vars — the counter file is the source of truth. If a subagent is observed to call `Agent()` itself, that is a recursive-delegation attempt and the guard will block it at depth 4.

### Step 4 — Verify Receipt

After `Agent()` returns:

1. **Check receipt exists** at the expected path:
   `.sdlc-automation-agent/.orchestrator/receipts/{STORY_ID}-{role-abbrev}.json`

2. **Validate receipt format**:
   - Required fields: `story_id`, `role`, `backend`, `model`, `artifacts`, `verification_commands`
   - `backend` must be `"claude"`
   - `artifacts` list must be non-empty 
   - Each artifact file must exist on disk 
   - `verification_commands` must contain at least one entry

3. **Hook validation**: The `crew-verify-receipt.sh` hook also fires automatically on SubagentStop and performs its own validation. This is a safety net — do not skip Step 4 in reliance on the hook.

### Step 5 — Return Result

Return the receipt JSON as the dispatch result. If the receipt is valid, the story pipeline can advance to the next stage.

## Error Handling

| Scenario | Action |
|----------|--------|
| Agent() hangs or times out | Claude Code platform manages subagent lifecycle — it will terminate stuck subagents |
| Missing receipt after completion | `crew-verify-receipt.sh` blocks the pipeline (in Autonomous mode) or warns (in Controlled mode) | 
| Invalid receipt (missing fields) | Same hook handles validation; Orchestrator follows the **recovery ladder** below before blocking |
| Subagent fails to load SKILL.md | Check `${CLAUDE_PLUGIN_ROOT}` is set correctly; verify plugin is loaded | 

### Recovery ladder (H3-F1)

When a dispatch fails — missing receipt, invalid receipt, or verification commands fail — the Orchestrator must escalate before marking the story blocked. The tier is computed by `story_pipeline.recommend_recovery_action(state, story_id, role_abbrev)`:

1. **First failure → same-prompt retry**: call `record_retry()`, re-dispatch the identical prompt. Transient issues (tool flake, timeout, missing receipt) usually resolve here.  
2. **Second failure → augmented-prompt retry**: call `record_retry()` again, re-dispatch with the prompt suffix:  
   ```
   ## Previous attempt failed

   Your last dispatch produced the following failure:
   {verbatim failure reason from the hook output}

   Read the failure carefully and correct the issue. Do not repeat the same receipt.
   ``` 
3. **Third failure (retry_cap reached) → transition to blocked**: call `transition_story(state, story_id, "blocked", reason=f"{role} repeated failure after {retry_cap} retries: {last_reason}")`. The `blocked` state requires human unblock.

Cap is `.sdlc-automation-agent.yaml → resilience.story_retry_cap` (default 2). Set to 0 to disable retries.

On successful completion, call `story_pipeline.reset_retries(state, story_id, role_abbrev)` so subsequent failures restart from tier 1.

## Limitations  

- **No async dispatch**: Claude subagents are inline. The Orchestrator blocks during execution.
- **Context budget**: Subagents share the conversation context budget. Very large SKILL.md files or many concurrent subagents can exhaust context.
- **No true parallelism**: Even with worktrees, Claude subagents run within the same process. For true parallel execution, configure eligible roles to use the Codex or Gemini backend.

## When to Use Claude Backend 

Claude backend is the best choice when:
- The role requires deep reasoning (SA architecture decisions, PO backlog refinement)
- The role needs access to Claude Code tools (Skill(), Agent(), file editing with Edit)
- The task requires interactive problem-solving (Debug mode, Explore mode)
- Protocol compliance is critical (Claude understands and follows SKILL.md protocols natively)

Consider switching to an external backend (Codex, Gemini) when:  
- The role is primarily code generation (SE, QE) and can work from a plain-text prompt
- Parallel execution is needed (QE testing story N while SE builds story N+1)
- Cost optimization matters (external backends may have different pricing)  
