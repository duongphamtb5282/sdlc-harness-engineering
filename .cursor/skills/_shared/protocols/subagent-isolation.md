<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Subagent Context Isolation Protocol

How the orchestrator (sdlc-automation-agent) should construct subagent prompts to prevent context pollution and maximize task quality.

## The Problem

When subagents inherit the full session context, they suffer from:  
- **Context pollution** — earlier conversation noise dilutes the task
- **Stale references** — files mentioned earlier may have changed 
- **Conflicting instructions** — earlier decisions may not apply to this task
- **Attention dilution** — important details buried in irrelevant history

## The Solution: Controller Pattern

The orchestrator (controller) constructs exactly what each subagent needs. Subagents receive a self-contained prompt — not session history.

### Constructing Subagent Prompts

For each subagent dispatch, the controller must provide: 

```
1. ROLE — What agent this is and what mode it runs in
2. TASK — Complete task description (not a reference to "the earlier plan")
3. CONTEXT — Specific files/artifacts to read (full paths, not "the BRD")
4. CONSTRAINTS — What NOT to do, boundaries, out-of-scope items
5. OUTPUT — Exact artifacts expected, where to write them
6. VERIFICATION — How to prove the task is complete
```

### Good vs Bad Prompts

**BAD (context-dependent):**
``` 
"Continue building the auth service we discussed earlier.
Refer to the architecture we designed." 
```  

**GOOD (self-contained):**
```
"You are Software Engineer [backend mode].

TASK: Implement the authentication service with JWT-based auth. 

CONTEXT — Read these files first:
- .sdlc-automation-agent/solution-architect/architecture.md (auth service section) 
- .sdlc-automation-agent/solution-architect/api-contracts/auth-api.yaml 
- .sdlc-automation-agent/product-manager/brd.md (user stories US-001 through US-005)

CONSTRAINTS:
- Use bcrypt for password hashing (ADR-003) 
- PostgreSQL for user store (ADR-001)
- Do NOT implement OAuth — that's a separate task
- Do NOT modify any existing services

OUTPUT:
- services/auth/ — full service implementation
- Write receipt to .sdlc-automation-agent/.orchestrator/receipts/T3a-software-engineer-auth.json 

VERIFICATION:
- npm test -- --project auth must pass
- npm run build must succeed
- All endpoints in auth-api.yaml must be implemented"
```

### What to Include

| Include | Why | 
|---------|-----|
| Full task text | Subagent doesn't have to search for context |
| Specific file paths to read | No guessing about which files matter |
| Exact output locations | No conflicts between parallel subagents |
| Verification commands | Self-contained definition of "done" | 
| Constraints and boundaries | Prevents scope creep into other tasks |

### What NOT to Include

| Exclude | Why |
|---------|-----|
| Session history | Pollutes with irrelevant earlier conversation | 
| Other agents' tasks | Creates attention split | 
| Completed task details | Not relevant to current task |
| User's original message verbatim | Often too vague — the controller has already refined it | 

## Parallel Agent Dispatch

When dispatching multiple agents in parallel:  

1. **No shared state** — Each agent writes to its own directory
2. **No cross-references** — Agent A should not read Agent B's output mid-flight 
3. **Conflict prevention** — If two agents might modify the same file, serialize them instead 
4. **Independent verification** — Each agent verifies its own work independently

## Model Selection for Subagents

Match model capability to task complexity:

| Task Type | Model | Examples |
|-----------|-------|---------|
| Multi-file implementation + review | Sonnet/standard | Service implementation, test suites, code review |
| Architecture/strategy/security | Opus/capable | Design decisions, backlog refinement, compliance audit, complex debugging |

## Review Agent Isolation

When dispatching review subagents:
- Give the reviewer ONLY the code to review + the spec to review against
- Do NOT give the reviewer the implementer's self-assessment
- The reviewer must form an independent opinion

## Integration with sdlc-automation-agent

The sdlc-automation-agent orchestrator already dispatches agents with `Agent(prompt=..., isolation="worktree")`. This protocol defines what goes INTO that prompt. Every `Agent()` call in sdlc-automation-agent should follow the controller pattern above.
