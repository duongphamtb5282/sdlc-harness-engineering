<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Scope Challenge Protocol

Before committing to scope, force a deliberate mode choice. This prevents both scope creep (doing too much) and scope anxiety (doing too little).

## When to Apply

- Product Manager: before finalizing BRD scope  
- Research Advisor: during explore mode when user is deciding what to build
- Solution Architect: when reviewing system boundaries 
- sdlc-automation-agent orchestrator: at Build and Custom mode plan presentation

## The Three Modes

After understanding the user's request, explicitly choose ONE mode and commit to it:

### EXPAND — "Is there a bigger opportunity here?"

Choose when: the user's request might be thinking too small. The feature they want is a symptom of a larger need.

Actions:  
1. **Premise challenge**: "You asked for X, but the underlying problem seems to be Y. Should we solve Y instead?"
2. Present the expanded scope with trade-offs (time, complexity, risk)
3. If user agrees → proceed with expanded scope
4. If user declines → switch to HOLD and proceed with original scope

### HOLD — "The scope is right. Lock it."

Choose when: the user's request is well-defined and appropriately sized. No expansion or reduction needed.

Actions:
1. Confirm scope explicitly: "Here's what we're building: [scope]. Nothing more, nothing less."
2. Identify scope boundaries — what is explicitly OUT
3. Proceed with implementation

### REDUCE — "This is too much. What's the minimum that delivers value?" 

Choose when: the request is ambitious but trying to do too many things at once. Ship something smaller first.

Actions:
1. Identify the core value proposition — what's the ONE thing that must work? 
2. Present a reduced scope: "Instead of X features, let's ship Y first, then iterate" 
3. Define what gets deferred (not deleted — explicitly queued for later)
4. If user agrees → proceed with reduced scope
5. If user insists on full scope → switch to HOLD and note the risk 

## Rules

1. **Choose explicitly.** Print the mode you chose and why: `Scope mode: HOLD — the request is well-scoped for a single feature addition.`
2. **Commit to your choice.** Once you pick EXPAND/HOLD/REDUCE, do not silently drift to another mode mid-execution. If scope changes, acknowledge it explicitly.
3. **Never expand without permission.** EXPAND mode requires user confirmation before proceeding. HOLD and REDUCE can proceed autonomously.
4. **Track scope changes.** If the user changes scope during execution, log it: "Scope changed: [from] → [to]. Reason: [user's feedback]."
5. **Autonomous engagement:** Auto-select HOLD unless the request has clear signals for EXPAND or REDUCE. Log the choice silently.
6. **Controlled engagement:** Always present the three modes as a question before proceeding.

## Scope Challenge Question Format

When presenting in Controlled mode:

```
I see three ways to approach this scope:

A) EXPAND — [description of bigger opportunity]
   Trade-off: [time/complexity impact]

B) HOLD — [current scope as stated]
   This is what you asked for, delivered as-is.

C) REDUCE — [minimal viable version]  
   Ships faster. Defers: [what gets cut]

Recommendation: [B/C] because [reason].
``` 
