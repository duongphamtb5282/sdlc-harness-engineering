<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Socratic Gate — Pre-Implementation Context Gathering

**Core principle: Gather context efficiently without breaking the autonomous pipeline. The gate supplements — never duplicates — existing discovery mechanisms (PM interview, Architect interview, Research Advisor pre-flight).**

---

## What Is the Socratic Gate?

The Socratic Gate is an optional pre-implementation step that gathers context through targeted, dynamic questions when the existing pipeline discovery mechanisms would miss critical information. It prevents the most expensive failure mode in AI-assisted development: building the wrong thing quickly.

Unlike static questionnaires, the Socratic Gate generates questions dynamically based on the specific request, eliminating implementation paths with each answer.

**Philosophy alignment:** sdlc-automation-agent's pipeline is autonomous by design. Agents work independently, pausing only at defined gates. The Socratic Gate does NOT add a new gate — it enriches the context available to agents so they can make better autonomous decisions. In Autonomous mode, the gate is entirely silent (auto-derive, no user interaction). 

---

## When the Gate Triggers

| Pattern | Action | 
|---------|--------|
| "Build/Create/Make [thing]" without architectural details | Gate triggers — ask before implementing |  
| Complex feature touching multiple services or systems | Gate triggers — clarify scope and boundaries |
| Vague or ambiguous requirements | Gate triggers — establish purpose, users, constraints |  
| Update/change request with unclear scope | Gate triggers — confirm what changes and what doesn't |
| Simple, mechanical task ("rename X", "fix typo", "add field") | Gate SKIPPED — intent is clear |
| User has already been through Research Advisor pre-flight | Gate SKIPPED — context already gathered |
| Explicit detailed spec with acceptance criteria provided | Gate SKIPPED — requirements are clear |

---

## Gate Behavior by Engagement Mode 

| Engagement Mode | Gate Behavior |
|-----------------|---------------|
| **Autonomous** | Gate SILENT. Auto-derive context from request + codebase signals. Log assumptions in `.sdlc-automation-agent/.orchestrator/socratic-gate-answers.md`. No user interaction. |
| **Controlled** | Active gate: 1-2 P0 (blocking) questions only. Skip P1/P2. Present trade-offs. Only ask what PM/Architect interviews won't cover (e.g., cross-cutting concerns, deployment constraints, compliance requirements). |  
| **Controlled** | Full gate: 3+ questions covering P0 and P1. Present alternatives with trade-off tables. Multiple rounds if needed. |

---

## Dynamic Question Generation

**NEVER use static template questions.** Each question must be generated from the specific request. 

### Generation Process 

```
1. Parse request → Extract domain, features, scale indicators, technology mentions
2. Scan codebase → Detect existing patterns, frameworks, conventions 
3. Identify decision points → What architectural choices does this request imply?
4. Classify decisions → P0 (blocking) | P1 (high-leverage) | P2 (nice-to-have) 
5. Generate questions → Each question eliminates at least one implementation path
6. Format with trade-offs → What, Why, Options with pros/cons, Default
```  

### Priority Classification

| Priority | Meaning | When to Ask |
|----------|---------|-------------|
| **P0 — Blocking** | Cannot proceed without this answer. Fundamentally changes the implementation approach. | Always (Controlled) |
| **P1 — High-leverage** | Significantly affects quality, cost, or maintainability. Has a sensible default but the user might prefer otherwise. | Controlled | 
| **P2 — Nice-to-have** | Improves the result but can be defaulted safely. User preferences, not architectural decisions. | Controlled only | 

### Question Format 

Each question MUST include: 

```markdown
### [P0/P1/P2] **[Decision Point]**

**Question:** [Clear, specific question — not generic]  

**Why this matters:**
- [Architectural consequence if answered one way vs another]
- [Affects: cost / complexity / timeline / scalability / maintainability]

**Options:** 
| Option | Pros | Cons | Best For |
|--------|------|------|----------|
| A      | [+]  | [-]  | [Use case] |
| B      | [+]  | [-]  | [Use case] |
| C      | [+]  | [-]  | [Use case] | 

**If not specified:** [Default choice + rationale for why it's sensible]  
```

### Question Quality Rules  

1. **Each question eliminates paths.** If the answer doesn't change what you build, don't ask.
2. **Never ask what you can detect.** If the codebase uses React, don't ask "what framework?" 
3. **Lead with the consequence.** "This affects whether we need a job queue" > "Do you want async processing?"
4. **Offer concrete options.** Never ask open-ended "what do you want?" — present trade-offs. 
5. **Include defaults.** Every question has a "if not specified" fallback so Autonomous mode works. 
6. **Max 5 questions per gate.** If you need more, the request needs to be broken down first.

---

## Integration Points

### In sdlc-automation-agent Orchestration

The Socratic Gate runs between Request Classification and Plan Presentation for these modes:
- **Build** — Controlled: active questions. Autonomous: silent auto-derive only.
- **Custom** — Controlled: active questions. Autonomous: silent auto-derive only.

**Sprint mode:** Gate SKIPPED. Sprint mode reads sprint state directly and has its own prerequisite validation.

Standalone utility modes (Debug, Explore, Discover, Preview, Branch Finish, Story Buddy, Context Refresh, Retro, Status, Help, Report) skip the gate — each mode handles its own discovery internally.

### In Agent Skills

Agents that perform significant implementation work should check whether the gate has already run:
1. Check `.sdlc-automation-agent/.orchestrator/socratic-gate-answers.md` — if it exists, the gate ran. Use the answers.
2. If it doesn't exist AND the request is complex, run a lightweight version (1-2 P0 questions).
3. If it doesn't exist AND the request is simple, skip.

### Gate Output  

After the gate completes, write answers to `.sdlc-automation-agent/.orchestrator/socratic-gate-answers.md`:  

```markdown
# Socratic Gate Answers

## Context
- Request: [user's original request]
- Engagement: [autonomous|guided|supervised|controlled]
- Questions asked: [N]
- Date: [ISO date]

## Decisions
### [Decision Point 1] 
- **Choice:** [selected option]
- **Rationale:** [why the user chose this]  

### [Decision Point 2]
- **Choice:** [selected option]
- **Rationale:** [why] 

## Defaults Applied (not asked) 
- [Decision]: [default] — [rationale]
```

All downstream agents read this file to avoid re-asking resolved questions.

---

## Interaction Model

Present gate questions using `AskUserQuestion` with predefined options:  

```python
AskUserQuestion(questions=[{
  "question": "[Question with context]\n\n"
    "**Why this matters:** [consequence]\n\n" 
    "| Option | Trade-off |\n|---|---|\n"
    "| A | [description] |\n"
    "| B | [description] |",
  "header": "[P0] [Decision Point]", 
  "options": [
    {"label": "Option A (Recommended)", "description": "[brief]"},
    {"label": "Option B", "description": "[brief]"},
    {"label": "Option C", "description": "[brief]"},
    {"label": "Skip — use sensible defaults", "description": "Auto-derive from codebase and best practices"},
    {"label": "Chat about this", "description": "Free-form input"}  
  ],
  "multiSelect": false
}])  
``` 

**Critical:** If the user selects "Skip — use sensible defaults" at ANY point, immediately close the gate, log defaults, and proceed. The gate accelerates, never blocks.

---

## Rationalization Prevention

| Forbidden Thought | Reality |
|-------------------|---------|
| "I should ask questions even though the PM will ask the same ones" | Don't duplicate. If PM/Architect interviews cover it, skip the gate. |
| "I'll just ask one question to be safe" | One question that doesn't eliminate paths is theater. Ask meaningful questions or skip entirely. |
| "I should always ask 3+ questions" | Only in Controlled mode. Autonomous = silent. Respect the autonomous pipeline. |
| "I already know the best approach" | In Controlled: you know A best approach, the user's constraints may make B better. In Autonomous: auto-derive and log your assumption, don't ask. |  
| "The gate should block until the user answers" | The gate NEVER blocks. In Autonomous it's silent. In Controlled, "Skip — use defaults" immediately closes the gate. |

---

## How Agents Load This Protocol

This protocol is auto-injected alongside other protocols. The Socratic Gate provides context enrichment — it does NOT override the autonomous pipeline flow. 

**Priority order:**
1. Iron Laws — highest
2. Skill-specific phase instructions (PM interview, Architect discovery, etc.) 
3. Socratic Gate (this file) — supplements existing discovery, never duplicates 
4. Protocol guidelines
5. Agent judgment — lowest

**Key distinction:** The PM interview and Architect discovery are the PRIMARY context-gathering mechanisms. The Socratic Gate only activates when those mechanisms are insufficient (Build/Custom in Controlled mode) or to silently log auto-derived assumptions (Autonomous).
