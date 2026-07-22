# SDLC Agent System — YAML & Python Reference

> **Why YAML?** Declarative, human-readable configuration — defines *what* to do, not *how*.
> **Why Python?** Stateful logic, data processing, file I/O — handles *how* when YAML isn't enough.

---

## 1. YAML Files — Declarative Configuration (60% of the system)

YAML defines the structure: what agents exist, what workflows to run, how to route, and what gates to check.

### 1.1 `plugin.json` — Root Plugin Manifest

```json
{
  "name": "sdlc-automation-agent",
  "plugins": ["./plugins/stack-aws", "./plugins/stack-ai-ml", ...]
}
```

**Purpose:** Entry point. Tells Claude Code/Cursor which plugins to load at startup.  
**When it runs:** On every session start.  
**How to customize:** Add/remove plugin paths from the `plugins` array.

### 1.2 `.sdlc-automation-agent.yaml` — Project Configuration

```yaml
project:
  name: "my-project"
  language: "typescript"
build_mode: "scrum"
cost_control:
  enabled: true
  daily_limit: 10
```

**Purpose:** Per-project settings. Controls build mode, cost limits, engagement mode, DoD/DoR, plugin selection.  
**When it runs:** Read by orchestrator at session start (if file exists).  
**How to customize:** Copy the template from `SETUP-GUIDE.md` section 4.

### 1.3 `AGENT-WORKFLOW-MAP.yaml` — Agent ↔ Workflow Routing

```yaml
agents:
  product-manager:
    workflows: [greenfield, spec-driven, feature]
    entry_phase: "01-understand-input"
workflows:
  greenfield:
    stages: [requirements, architecture, backend, ...]
    default_agents: [product-manager, solution-architect, ...]
```

**Purpose:** Maps each agent role to the workflows they participate in and which phase they start with. The engine uses this to resolve "which agent runs this stage?"  
**When it runs:** Loaded by `engine.py` when executing a workflow.  
**How to customize:** Add new agents, link them to existing workflows, define their entry phase.

### 1.4 `workflows/*.yaml` — Workflow Definitions (14 files)

```yaml
name: discovery-to-delivery
stages:
  - id: requirements
    agent: product-manager
    model_tier: standard
    gates:
      - id: brd-approved
        type: automatic
        condition: "all_stories_have_acceptance_criteria"
```

**Purpose:** Defines a sequence of stages with agent assignments, model tiers, dependencies, gates, and outputs. Each stage = one agent's work unit.  
**When it runs:** When user invokes a workflow via `claude "Run the {name} workflow"` or `python3 engine.py workflows/{name}.yaml`.  
**Available workflows:**

| File | Stages |
|------|--------|
| `greenfield.yaml` | PM → SA → SE → FE → QE → CR → Security → PE |
| `feature.yaml` | SA → SE → QE → CR |
| `bugfix.yaml` | CR(diagnose) → SE(fix) → QE(verify) |
| `security-review.yaml` | Threat model → Code audit → Remediate → Verify |
| `ai-ml-pipeline.yaml` | Experiment → Data → Train → Evaluate → Deploy |
| `rag-system.yaml` | Architecture → Embedding → Retrieval → Eval → Deploy |
| `agent-system.yaml` | Agent design → Tools → Core → Safety → Test |
| `architecture-review.yaml` | Context → ADR → Conformance |
| `migration.yaml` | Analysis → Data → Code → Test → Review |
| `documentation.yaml` | Audit → Write → Review |
| `spec-driven.yaml` | Spec → Review → Implement → Verify |
| `discovery-to-delivery.yaml` | **8 stages: Discover → Req → Arch → Stories → Validate → Archive → Implement → Test → Review → Deploy** |

**How to customize:** Copy an existing `.yaml`, modify stages, agents, model tiers, add/remove gates.

### 1.5 `workflow-schema.json` — Workflow Validation Schema

```json
{
  "required": ["name", "description", "stages"],
  "properties": {
    "stages": { "items": { "required": ["id", "agent", "model_tier"] } }
  }
}
```

**Purpose:** Ensures all workflow YAML files are valid before execution. Catches missing fields, wrong types.  
**When it runs:** Validated manually or by the engine before executing a workflow.  
**How to customize:** Extend the schema if you add new fields to workflow definitions.

### 1.6 `story-registry-template.yaml` — Story Registry Schema

```yaml
stories:
  US-001:
    title: "Example story"
    acceptance_criteria: ["Criterion 1", "Criterion 2"]
    implementation:
      files: ["services/auth/src/login.ts"]
      tests: ["tests/auth/login.spec.ts"]
    status: pending
```

**Purpose:** Template for tracking user stories from creation through implementation. Each story has acceptance criteria, linked files, tests, and status.  
**When it runs:** Created/updated by `product-manager` during `story-registration` stage.  
**How to customize:** Add new fields (priority, sprint, assignee) to the template.

### 1.7 `hooks.json` — Hook Wiring

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{"type": "command", "command": "bash ..."}] }],
    "UserPromptSubmit": [{ "hooks": [...] }]
  }
}
```

**Purpose:** Wires lifecycle hooks to shell scripts. Controls when cost classification, budget checking, and safety scanning fire.  
**When it runs:** On every session event (start, prompt, tool use, stop).  
**How to customize:** Add new hook events or chain additional scripts.

### 1.8 `.claude-plugin/plugin.json` (23 plugin manifests)

```json
{
  "name": "stack-ai-ml",
  "description": "AI/ML skills",
  "skills": "./skills"
}
```

**Purpose:** Declares each plugin's identity and where its skills live.  
**When it runs:** Loaded at startup by Claude Code/Cursor.  
**How to customize:** Create a new directory with this file to add a new plugin.

### 1.9 `mcp.json` (5 configs + 1 consolidated)

```json
{
  "mcpServers": {
    "jira": { "command": "npx", "args": ["-y", "@agenite/jira-mcp-server"] }
  }
}
```

**Purpose:** Configures MCP servers for external tool integration (Jira, Confluence, Figma, GitHub, Slack, Datadog).  
**When it runs:** When Claude Code/Cursor initializes MCP connections.  
**How to customize:** Add new MCP servers following the same pattern.

---

## 2. Python Files — Logic & State Management (5% of the system)

Python handles what YAML cannot: state machines, file I/O, data processing, condition evaluation.

### 2.1 `workflows/engine.py` — Workflow Execution Engine

```
Input:  workflow YAML + project directory
Process:
  1. Load YAML → get stages, dependencies, gates
  2. Resolve agent roles from AGENT-WORKFLOW-MAP
  3. Execute stages in dependency order
  4. For each stage: load agent.md + SKILL.md + phase instructions
  5. Evaluate gates (automatic: check condition; manual: log for user)
  6. Record cost via BudgetTracker
  7. Persist state to workflow-state.json
Output: completed/blocked status + cost report + state file
```

**Why Python?** Needs YAML parsing (`yaml.safe_load`), dependency graph resolution (DAG traversal), conditional logic (gate evaluation), and file I/O (state persistence). Shell scripts can't do this.

**Key methods:**
- `_invoke_agent(stage)` — loads agent definition + phase instructions + skills
- `_evaluate_gates(stage)` — checks automatic conditions, logs manual gates
- `_load_agent_map()` — reads AGENT-WORKFLOW-MAP.yaml for routing
- `_load_budget()` — initializes BudgetTracker for cost tracking

### 2.2 `hooks/lib/budget_tracker.py` — Cost Tracking

```
Input:  task_type, model, tokens, cost
Process:
  1. Load cost-state.json (or create if not exists)
  2. Accumulate daily spending (reset on new day)
  3. Append session entry
  4. Check limits (80% warning, 100% block, hard stop)
  5. Persist to cost-state.json
Output: budget status (spent, remaining, alerts)
```

**Why Python?** Needs JSON file I/O, floating-point arithmetic, date math, and structured data (nested dicts). Shell with `jq` + `bc` would be brittle.

**Key methods:**
- `record(task, model, tokens, cost)` — save cost event
- `check_limits(daily_limit, session_limit)` — returns spending status + alerts
- `dashboard()` — returns formatted spending display

### 2.3 `workflows/validate-requirements.py` — BRD & Story Validation

```
Input:  story-registry.yaml + docs/requirements/brd.md
Process:
  1. Load story registry → parse all stories
  2. Load BRD → count requirements
  3. For each story: check title, acceptance criteria, format (Given/When/Then)
  4. Check for orphan stories (no linked ADR)
  5. Check implementation status
  6. Generate traceability matrix markdown
Output: validation report + traceability-matrix.md
```

**Why Python?** Needs YAML loading, regex for pattern matching (Given/When/Then), file generation (markdown), and structured error reporting.

**Checks performed:**
| Check | Severity | What it validates |
|-------|----------|-------------------|
| Story registry exists | Error | Is the file present? |
| BRD exists | Warning | Is docs/requirements/brd.md present? |
| Story titles | Error | Every story has a title |
| Acceptance criteria | Error | Every story has ACs |
| Given/When/Then format | Warning | ACs use testable language |
| Linked ADRs | Warning | Stories have architecture context |
| Implementation status | Warning | Completed stories have files |
| Vague criteria | Warning | ACs are long enough |
| Traceability matrix | Info | Generated markdown report |

### 2.4 `workflows/impact-analysis.py` — Story ↔ File Traceability

```
Input:  --story US-001 or --file src/login.ts
Process:
  1. Load story-registry.yaml
  2. Build reverse index: file_path → [story_ids]
  3. If --story: show all files + tests for that story + overlapping stories
  4. If --file: show all stories touching that file
  5. If --report: show top stories by file count + shared files + unimplemented
  6. Persist index to file-story-index.json for fast lookups
Output: impact report + file-story-index.json
```

**Why Python?** Needs data structure manipulation (reverse index building), JSON serialization, and cross-referencing logic.

**Three query modes:**
```bash
python3 impact-analysis.py --story US-001          # What does this story touch?
python3 impact-analysis.py --file services/auth/   # What stories touch this file?
python3 impact-analysis.py --report                # Full impact report
```

### 2.5 `hooks/lib/scrum_state_machine.py` — Sprint State Machine

```
States: inception → planning → execution → review → retro → close
Transitions: validate allowed transitions, reject invalid ones
Persistence: read/write pipeline-state.json
```

**Why Python?** State machines with validation rules need enum-like structures and transition matrices.

### 2.6 `hooks/lib/kanban_state_machine.py` — Kanban State Machine

```
States: backlog → ready → in_progress → review → done
```

**Why Python?** Same rationale as scrum — state transition validation.

### 2.7 `hooks/lib/receipt_validator.py` — Receipt Verification

```
Input:  receipt JSON files from .sdlc-automation-agent/.orchestrator/receipts/
Process: validate required fields, verify artifact existence, check timestamps
```

**Why Python?** JSON schema validation, file system checks.

---

## 3. YAML + Python Interaction Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                       YAML LAYER (declarative)                   │
│                                                                   │
│  plugin.json ───→ loads plugins ───→ .claude-plugin/plugin.json  │
│  hooks.json ────→ wires hooks ────→ classify-task.sh            │
│  workflows/*.yaml → defines stages, agents, gates, model tiers   │
│  AGENT-WORKFLOW-MAP → maps agents → workflows → entry phases     │
│  workflow-schema.json → validates workflow structure              │
│  .sdlc-automation-agent.yaml → project config (cost, modes)      │
│  story-registry-template.yaml → story schema                     │
└────────────────────────────┬────────────────────────────────────┘
                             │ loaded by
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     PYTHON LAYER (execution)                     │
│                                                                   │
│  engine.py ────────── reads YAML → resolves deps → runs stages  │
│  budget_tracker.py ── called by engine.py → tracks costs        │
│  validate-requirements.py ── reads YAML → validates stories      │
│  impact-analysis.py ── reads YAML → traces files ↔ stories      │
│  scrum_state_machine.py ── reads/writes pipeline state           │
│  kanban_state_machine.py ── reads/writes pipeline state          │
│  receipt_validator.py ── validates JSON receipts                 │
└────────────────────────────┬────────────────────────────────────┘
                             │ produces
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     STATE FILES (JSON + YAML)                    │
│                                                                   │
│  cost-state.json ── budget tracking                              │
│  workflow-state.json ── workflow execution status                 │
│  story-registry.yaml ── user stories + traceability              │
│  file-story-index.json ── reverse index for impact analysis      │
│  traceability-matrix.md ── requirements traceability report      │
│  pipeline-state.json ── scrum/kanban state                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. When to Use YAML vs Python

| Task | Use YAML | Use Python | Why |
|------|----------|------------|-----|
| Define workflow stages | ✅ `workflows/*.yaml` | ❌ | Declarative, human-readable |
| Map agents to workflows | ✅ `AGENT-WORKFLOW-MAP.yaml` | ❌ | Simple key-value structure |
| Project configuration | ✅ `.sdlc-automation-agent.yaml` | ❌ | User-editable, version-controlled |
| Hook wiring | ✅ `hooks.json` | ❌ | Event → script mapping |
| Execute a workflow | ❌ | ✅ `engine.py` | Needs graph traversal + state |
| Track costs | ❌ | ✅ `budget_tracker.py` | Needs persistence + math |
| Validate requirements | ❌ | ✅ `validate-requirements.py` | Needs file I/O + validation logic |
| Impact analysis | ❌ | ✅ `impact-analysis.py` | Needs reverse index building |
| State machine | ❌ | ✅ `*_state_machine.py` | Needs transition validation |
| Receipt validation | ❌ | ✅ `receipt_validator.py` | Needs JSON schema checking |
| Agent instructions | ✅ `agent-roles/*/SKILL.md` | ❌ | LLM reads markdown |
| Skill definitions | ✅ `plugins/*/skills/*/SKILL.md` | ❌ | LLM reads markdown |

**Rule of thumb:** If it can be expressed as a table or checklist → YAML.  
If it needs conditions, loops, file I/O, or state → Python.

---

## 5. File Size & Complexity

| File | Lines | Complexity | Why So Many Lines |
|------|-------|------------|-------------------|
| `engine.py` | 260 | High | Workflow engine: YAML parsing, dep graph, agent loading, gate eval, budget tracking, state persistence, status display |
| `validate-requirements.py` | 180 | Medium | 8 validation checks + traceability matrix generation |
| `impact-analysis.py` | 170 | Medium | Reverse index building + 3 query modes + full report |
| `budget_tracker.py` | 120 | Medium | JSON state management + budget limits + dashboard formatting |
| `AGENT-WORKFLOW-MAP.yaml` | 60 | Low | 17 agents × workflows × entry phases + 12 workflow definitions |
| `discovery-to-delivery.yaml` | 100 | Medium | 10 stages with gates, outputs, depends_on, cost estimates |
| `workflow-schema.json` | 50 | Low | JSON schema for validation |

---

## 6. Quick Reference — Most Useful Commands

```bash
# Run a workflow
python3 .claude/workflows/engine.py .claude/workflows/feature.yaml --project .

# Check workflow status
python3 .claude/workflows/engine.py .claude/workflows/feature.yaml --project . --status

# Validate requirements (BRD + stories)
python3 .claude/workflows/validate-requirements.py --project .

# Impact analysis — find stories touching a file
python3 .claude/workflows/impact-analysis.py --file src/api/auth.ts --project .

# Impact analysis — find files for a story
python3 .claude/workflows/impact-analysis.py --story US-001 --project .

# Full impact report
python3 .claude/workflows/impact-analysis.py --report --project .

# Show cost dashboard
python3 -c "import sys; sys.path.insert(0,'.claude/hooks/lib'); from budget_tracker import BudgetTracker; print(BudgetTracker().dashboard())"

# Validate workflow YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.claude/workflows/feature.yaml')); print('Valid YAML')"
```
