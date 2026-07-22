# SDLC Agent System — Architecture & Customization Guide

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         USER (Claude Code / Cursor)                      │
│              "Build a payment system with Stripe integration"            │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────────┐
│                     ORCHESTRATOR LAYER                                   │
│                                                                          │
│  ┌─────────────────┐   ┌─────────────────┐   ┌───────────────────────┐  │
│  │ Request         │   │ Cost Control     │   │ Workflow Engine      │  │
│  │ Classification  │──▶│ (S1-S5 Classifier)│──▶│ (engine.py)          │  │
│  │ (mode routing)  │   │ + Budget Tracker │   │ Loads YAML           │  │
│  └────────┬────────┘   └─────────────────┘   │ Resolves dependencies│  │
│           │                                   │ Executes stages       │  │
│           ▼                                   │ Evaluates gates       │  │
│  ┌─────────────────┐                          └───────────┬───────────┘  │
│  │ Skill           │                                      │              │
│  │ (sdlc-automation│                                      ▼              │
│  │  -agent)        │                           ┌───────────────────┐    │
│  └─────────────────┘                           │ Handoff Gates      │    │
│                                                 │ (manual/automatic) │    │
│                                                 └───────────┬───────┘    │
└─────────────────────────────────────────────────────────────┬───────────┘
                                                              │
┌─────────────────────────────────────────────────────────────▼───────────┐
│                        AGENT LAYER (18 roles)                           │
│                                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Product  │  │Solution  │  │Software  │  │Frontend  │  │Quality   │  │
│  │ Manager  │──▶│Architect │──▶│Engineer  │──▶│Engineer  │──▶│Engineer  │──▶
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│                                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Code     │  │Security  │  │Platform  │  │AI/ML     │  │Research  │  │
│  │ Reviewer │──▶│Engineer  │──▶│Engineer  │──▶│Engineer  │──▶│Advisor   │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│                                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│  │Mobile    │  │.NET      │  │Cloud     │  │Tech      │                │
│  │Engineer  │  │Engineer  │  │Architect │  │Writer    │                │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘                │
│                                                                          │
│  Each agent has: agent.md + phases/ + modes/ + references/              │
│  Agents are invoked with their SKILL.md (instructions for the LLM)      │
└─────────────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────────────────┐
│                        SKILL LAYER (23 plugins)                          │
│                                                                          │
│  Technology Stacks:   Feature Plugins:    AI/ML Skills:                  │
│  ┌────────┐┌───────┐  ┌────────┐┌──────┐  ┌────────────────────────┐   │
│  │AWS     ││Azure  │  │Design  ││PM    │  │LangChain, LlamaIndex,   │   │
│  │GCP     ││Nuxt   │  │System  ││System│  │RAG, Fine-tuning,        │   │
│  │Spring  ││NestJS │  │Design  ││Staff │  │Prompt Engineering,      │   │
│  │Vue     ││Mobile │  │General ││Prod  │  │MLOps, Safety            │   │
│  │Go      ││.NET   │  │Skills  ││Grade │  │131+ skills              │   │
│  │Java    ││Vercel │  │Catalog ││      │  └────────────────────────┘   │
│  └────────┘└───────┘  └────────┘└──────┘                                │
│                                                                          │
│  Each plugin has: .claude-plugin/plugin.json + skills/                   │
└─────────────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────────────────┐
│                        INFRASTRUCTURE LAYER                              │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────────────┐  │
│  │ MCP Servers  │  │ Hooks        │  │ Configuration                 │  │
│  │              │  │              │  │                               │  │
│  │ • Jira       │  │ • SessionStart│  │ • .sdlc-automation-agent.yaml│  │
│  │ • Confluence │  │ • UserPrompt  │  │ • plugin.json               │  │
│  │ • Figma      │  │ • PreToolUse  │  │ • cost-state.json           │  │
│  │ • GitHub     │  │ • PostToolUse │  │ • workflow-state.json       │  │
│  │ • Slack      │  │ • Stop       │  │ • story-registry.yaml       │  │
│  │ • Datadog    │  │ • CostControl │  │ • AGENT-WORKFLOW-MAP.yaml   │  │
│  └──────────────┘  └──────────────┘  └───────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. The Four Execution Paths

The system can execute work in **4 modes**, each with different architecture:

### Path A: Direct Agent Invocation (Fastest)

```
User → Agent Role (agent.md + SKILL.md) → Result
```

**Example:**
```bash
claude "Act as code-reviewer. Review my current branch for security issues."
```

**Flow:** No orchestrator, no workflow engine — direct agent execution.
**Use when:** Single-purpose task, no pipeline needed.

### Path B: Orchestrator Routing (Auto-classified)

```
User → Orchestrator → Request Classification → Mode Selection → Agent(s) → Result
```

**Example:**
```bash
claude "Review the auth module for vulnerabilities"
```
→ Classified as `security-review` mode
→ Routes to `security-engineer` agent

**Flow:** Orchestrator classifies intent, picks the mode and agent.
**Use when:** Task type is clear but multi-step.

### Path C: Workflow Engine (Multi-stage SDLC)

```
User → Workflow Engine → Stage 1: Agent A → Gate → Stage 2: Agent B → Gate → ...
```

**Example:**
```bash
claude "Run the discovery-to-delivery workflow for our payment system"
```

**Flow:**
```
engine.py loads discovery-to-delivery.yaml
  ↓
Stage 1: research-advisor (discover codebase)
  ↓ Gate: system-mapped (manual)
Stage 2: product-manager (requirements + stories)
  ↓ Gate: brd-approved (auto)
Stage 3: solution-architect (architecture + ADRs)
  ↓ Gate: arch-approved (manual)
Stage 4: product-manager (register stories)
Stage 5: software-engineer (implement)
  ↓ Gate: story-complete (auto)
Stage 6: quality-engineer (test)
  ↓ Gate: tests-passing (auto)
Stage 7: code-reviewer (review)
  ↓ Gate: review-approved (manual)
Stage 8: platform-engineer (deploy)
  ↓ Gate: dod-met (auto)
```

**Use when:** Full SDLC pipeline with handoffs.

### Path D: Discovery → Implementation Pipeline (Traceable)

```
User → reverse.md (discover) → PM (stories + AC) → SA (ADRs) → 
Story Registry (trace IDs) → SE (implement per story) → QE (verify per AC) → CR → PE
```

**Example:**
```bash
claude "Map our existing codebase, then add Stripe payment integration. 
Trace each user story through to implementation."
```

**Flow:** Same as Path C but with `story-registry.yaml` tracking each story's files, tests, and status.
**Use when:** You need traceability from requirement → code → test.

---

## 3. How to Customize

### 3.1 Customizing Agent Behavior

Each agent role is defined by `agent.md` (short descriptor) + `SKILL.md` (full instructions).

**Change agent instructions:**
```bash
# Edit the agent's SKILL.md to change behavior
vim .claude/agent-roles/software-engineer/SKILL.md
```

**Add a new mode to an agent:**
```bash
# 1. Create a mode file
mkdir -p .claude/agent-roles/software-engineer/modes
cat > .claude/agent-roles/software-engineer/modes/my-mode.md << 'EOF'
# My Custom Mode

Specialized configuration for my-mode.

## Instructions
- Always do X before Y
- Follow Z pattern for error handling
EOF

# 2. Update agent.md to reference it
```

**Add phases to an agent:**
```bash
cat > .claude/agent-roles/my-agent/phases/04-custom-phase.md << 'EOF'
# Phase 4: Custom Phase

## Objectives
- What this phase accomplishes

## Activities
- Step 1
- Step 2

## Outputs
- output-file.md
EOF
```

### 3.2 Customizing Workflows

**Edit an existing workflow:**
```bash
# Change model tiers, add gates, modify stages
vim .claude/workflows/feature.yaml
```

**Create a new workflow:**
```bash
cat > .claude/workflows/my-custom.yaml << 'EOF'
name: my-custom
description: "My custom workflow"
stages:
  - id: step-one
    agent: software-engineer
    model_tier: standard
  - id: step-two
    agent: quality-engineer
    model_tier: standard
    depends_on: [step-one]
    gates:
      - id: quality-gate
        type: automatic
        condition: "all_tests_pass"
EOF
```

**Override workflow settings per project:**
```yaml
# .sdlc-automation-agent/workflows/overrides.yaml
overrides:
  feature:
    stages:
      - id: implementation
        model_tier: premium    # Force premium for this project
        timeout_minutes: 30
      - id: review
        skip: true             # Skip review for internal tools
```

### 3.3 Customizing Cost Control

```yaml
# .sdlc-automation-agent.yaml
cost_control:
  enabled: true
  default_model: "claude-sonnet"       # Change default
  premium_model: "claude-opus"         # Change premium
  daily_limit: 20                      # Increase daily budget
  session_limit: 5                     # Increase session budget
  hard_stop: 100                       # Increase hard stop
```

### 3.4 Customizing MCP Integration

```json
// Add a new MCP server to .claude/mcp/{domain}/mcp.json
{
  "mcpServers": {
    "my-custom-mcp": {
      "command": "npx",
      "args": ["-y", "@my/mcp-server"],
      "env": {
        "MY_API_KEY": "${MY_API_KEY}"
      }
    }
  }
}
```

### 3.5 Adding Custom Skills

```bash
# Create a new skill in any plugin
mkdir -p .claude/plugins/general-skills/skills/my-custom-skill
cat > .claude/plugins/general-skills/skills/my-custom-skill/SKILL.md << 'EOF'
---
name: my-custom-skill
description: Description of my custom skill
---
# My Custom Skill

Content goes here.
EOF
```

---

## 4. Why Python? (And When Not to Use It)

### Why Python is Used

The system uses Python for **3 specific purposes** where shell scripts are insufficient:

#### 4.1 State Management (budget_tracker.py)

```python
# Problem: Shell scripts can't persist complex state across sessions
# Solution: Python JSON serializer
class BudgetTracker:
    def __init__(self):
        self.state = self._load()  # Read JSON from disk
    
    def record(self, task, model, tokens, cost):
        self.state["daily"]["spent"] += cost
        self.state["sessions"].append({...})
        self._save()  # Write JSON back
```

**Why not shell?** Shell can't handle nested JSON structures, floating-point arithmetic reliably, or datetime math. A shell-based budget tracker would need `jq`, `bc`, and `date` gymnastics that break across platforms.

#### 4.2 Workflow Engine (engine.py)

```python
# Problem: YAML parsing + dependency graph resolution + state machine
# Solution: Python's yaml library + dict-based DAG resolution
class WorkflowEngine:
    def execute(self):
        stages = yaml.safe_load(open(workflow_file))  # Parse YAML
        completed = set()
        while len(completed) < total:
            for stage in stages:
                deps = stage.get("depends_on", [])
                if all(d in completed for d in deps):
                    # Run this stage
```

**Why not shell?** Shell has no YAML parser, no data structures for directed acyclic graphs, and no clean way to implement a state machine with conditional transitions. The workflow engine needs to:
- Parse YAML → requires `yq` or Python
- Resolve stage dependencies → requires graph traversal
- Track state → requires persistent state
- Handle conditional logic → requires condition evaluation

#### 4.3 Hook State Machines (scrum_state_machine.py, kanban_state_machine.py)

```python
# Problem: Pipeline state transitions with validation
# Solution: Python's enum + state machine pattern
class ScrumStateMachine:
    states = ["inception", "planning", "execution", "review", "retro", "close"]
    transitions = {"execution": ["review", "planning"]}
```

**Why not shell?** State machines with validation rules, rollback, and persistence need data structures shell can't provide.

### 4.4 What NOT to Use Python For

| Task | Use Instead | Reason |
|------|-------------|--------|
| Task classification | **Shell script** (`classify-task.sh`) | Simple keyword matching, no state |
| File operations | **Shell/rsync** | Built-in file system tools faster |
| Hooks wiring | **JSON config** (hooks.json) | Declaration, not logic |
| Skill definitions | **Markdown** (SKILL.md) | LLM reads markdown instructions |
| Agent definitions | **Markdown** (agent.md) | LLM reads markdown instructions |
| Workflow definitions | **YAML** (workflow/*.yaml) | Declarative, human-readable |
| Configuration | **YAML** (.sdlc-automation-agent.yaml) | Declarative, human-readable |

### 4.5 The 90/10 Rule

| Layer | Tool | % of System |
|-------|------|-------------|
| **Declarative config** (YAML, JSON) | Human-readable | 60% |
| **Instructions** (SKILL.md, agent.md) | Markdown | 25% |
| **Shell scripts** (hooks, classify, validate) | Bash | 10% |
| **Python** (engine, tracker, state machines) | Python | **5%** |

Python is only used where **state, logic, or data structures** are required. The vast majority of the system is declarative YAML and Markdown instructions.

---

## 5. Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        REQUEST FLOW                                      │
│                                                                          │
│  User Input                                                              │
│       │                                                                  │
│       ▼                                                                  │
│  ┌──────────┐                                                           │
│  │  Hooks   │  classify-task.sh: S1-S5 classification                  │
│  │  Layer   │  budget_tracker.py: budget check                         │
│  └────┬─────┘  user-prompt-guard.sh: safety scan                       │
│       │                                                                  │
│       ▼                                                                  │
│  ┌──────────────┐                                                        │
│  │ Orchestrator │  sdlc-automation-agent/SKILL.md                       │
│  │  (SKILL.md)  │  → routing-rules.json: classify mode                 │
│  └──────┬───────┘  → select agent(s) based on mode                     │
│         │                                                                │
│         ├──────────────────────────────┐                               │
│         │  (simple)                    │  (complex)                     │
│         ▼                              ▼                                │
│  ┌──────────────┐            ┌──────────────────┐                      │
│  │ Single Agent │            │ Workflow Engine  │                      │
│  │ (agent.md +  │            │ (engine.py)      │                      │
│  │  SKILL.md)   │            │  ↓               │                      │
│  └──────┬───────┘            │ Load YAML        │                      │
│         │                    │ Resolve deps     │                      │
│         │                    │ Run stage → gate │                      │
│         │                    │ → next stage    │                      │
│         │                    │ Track state      │                      │
│         │                    └────────┬─────────┘                      │
│         │                             │                                │
│         ▼                             ▼                                │
│  ┌──────────────────────────────────────────────────────┐              │
│  │  Agent Execution (per stage or direct)                │              │
│  │                                                       │              │
│  │  1. Load agent.md (role definition)                   │              │
│  │  2. Load SKILL.md (detailed instructions)             │              │
│  │  3. Load relevant plugin skills (technology context)  │              │
│  │  4. Load references/ (knowledge base)                 │              │
│  │  5. Execute task                                      │              │
│  │  6. Write receipt (proof of completion)               │              │
│  │  7. Return outputs                                    │              │
│  └──────────────────────────────────────────────────────┘              │
│                                                                          │
│  Outputs flow back:                                                      │
│  Agent Result → Workflow Engine → Next Stage (or complete)              │
│  Agent Result → Direct Response (if no workflow)                        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 6. File Location Reference

| What | Where | Format |
|------|-------|--------|
| Agent role definitions | `.claude/agent-roles/{role}/agent.md` | Markdown (frontmatter) |
| Agent instructions | `.claude/agent-roles/{role}/SKILL.md` | Markdown |
| Agent phases | `.claude/agent-roles/{role}/phases/*.md` | Markdown |
| Agent modes | `.claude/agent-roles/{role}/modes/*.md` | Markdown |
| Plugin manifest | `.claude/plugins/{plugin}/.claude-plugin/plugin.json` | JSON |
| Plugin skills | `.claude/plugins/{plugin}/skills/{skill}/SKILL.md` | Markdown |
| Workflow definitions | `.claude/workflows/*.yaml` | YAML |
| Workflow engine | `.claude/workflows/engine.py` | Python |
| Agent-workflow map | `.claude/workflows/AGENT-WORKFLOW-MAP.yaml` | YAML |
| Story registry | `.claude/workflows/story-registry-template.yaml` | YAML |
| Hooks wiring | `.claude/hooks/hooks.json` | JSON |
| Hook scripts | `.claude/hooks/{hook}/*.sh` | Shell |
| State machines | `.claude/hooks/lib/*.py` | Python |
| Budget tracker | `.claude/hooks/lib/budget_tracker.py` | Python |
| Orchestrator | `.claude/skills/sdlc-automation-agent/SKILL.md` | Markdown |
| MCP configs | `.claude/mcp/{domain}/mcp.json` | JSON |
| Cost control instructions | `.claude/instructions/cost-control/model-routing.instructions.md` | Markdown |
| Main config | `.sdlc-automation-agent.yaml` | YAML |
| Root manifest | `.claude/plugin.json` | JSON |
| Cost state | `.sdlc-automation-agent/.orchestrator/cost-state.json` | JSON |
| Workflow state | `.sdlc-automation-agent/.orchestrator/workflow-state.json` | JSON |

---

## 7. Execution Flow Examples

### Example: Simple Code Review

```bash
claude "Review this PR for security issues"
```
```
1. UserPromptSubmit hook fires
2. classify-task.sh: S3 (moderate), claude-sonnet
3. budget_tracker.check_limits(): $2.50/$10 today — OK
4. Orchestrator classifies → "debug" mode
5. Routes to code-reviewer agent
6. Loads agent-roles/code-reviewer/SKILL.md
7. Loads plugins/delivery-toolkit/skills/code-review/
8. Loads phases: 01-scan → 02-analyze → 03-report
9. Executes review
10. Writes receipt
```

### Example: Full Discovery-to-Delivery Pipeline

```bash
claude "Run the full SDLC pipeline for adding user billing"
```
```
1. UserPromptSubmit hook fires
2. classify-task.sh: S4 (complex), claude-opus
3. budget_tracker: $4/$10 — OK, but premium gate fires
4. Gate: "This task requires opus ($7.50/1K). Approve?" → Yes
5. Orchestrator classifies → "build" mode → greenfield
6. Workflow Engine loads discovery-to-delivery.yaml
7. engine.py resolves dependency graph (8 stages)
8. engine.py starts first available stage
9. Stage: codebase-discovery → research-advisor
10. Stage complete → Gate: system-mapped (manual review)
11. User approves → Stage: requirements → product-manager
12. ...continues through all 8 stages...
13. Final gate: dod-met → auto-verified
14. engine.py marks workflow complete
```
