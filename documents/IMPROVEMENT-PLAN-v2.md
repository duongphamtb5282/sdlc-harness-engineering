# Improvement Plan v2 — Cost Control, Agents, Workflow SDLC, Discovery→Implementation

> **Date:** 2026-07-20  
> **Audit of:** `enhancement/` (16,375 files)  
> **Focus:** 4 critical areas for production readiness

---

## 1. Cost Control

### Current State

| Component | Status | Details |
|-----------|--------|---------|
| S1-S5 classifier | ✅ `classify-task.sh` | Shell script, keyword-based classification |
| Model routing instructions | ✅ `model-routing.instructions.md` | 17-row routing table |
| Cost estimation | ✅ `estimate-cost.sh` | Per-stage cost estimation for workflows |
| Budget enforcement | ✅ **Implemented** | `budget_tracker.py` with stateful daily/session tracking |
| Spending dashboard | ✅ **Implemented** | `cost-dashboard` skill + `dashboard()` method in BudgetTracker |
| Per-workflow cost tracking | ✅ **Implemented** | Cost recorded per session with task type |
| User notification | ✅ **Implemented** | Budget alerts at 80%, 100%, and hard stop in classify-task.sh |

### Gaps

| Gap | Impact | Priority |
|-----|--------|----------|
| No stateful budget tracking | Costs accumulate silently — user may overspend without knowing | **High** |
| No per-user spending limits | Multi-user teams can't share a budget | Medium |
| No cost dashboard | User has no visibility into where costs are going | Medium |
| Override mechanism unclear | User may want to bypass cost gate for urgent tasks | Low |

### Proposed Improvements

#### 1.1 Budget State Tracker

Create `hooks/lib/budget_tracker.py`:

```python
import json, os, time

class BudgetTracker:
    def __init__(self, state_dir=".sdlc-automation-agent/.orchestrator"):
        self.state_file = os.path.join(state_dir, "cost-state.json")
        self.state = self._load()
    
    def _load(self):
        if os.path.exists(self.state_file):
            return json.load(open(self.state_file))
        return {"daily": {"spent": 0, "date": ""}, "sessions": []}
    
    def record(self, task_type, model, tokens, cost):
        today = time.strftime("%Y-%m-%d")
        if self.state["daily"]["date"] != today:
            self.state["daily"] = {"spent": 0, "date": today}
        self.state["daily"]["spent"] += cost
        self.state["sessions"].append({
            "task": task_type, "model": model, 
            "tokens": tokens, "cost": cost,
            "timestamp": time.time()
        })
        self._save()
    
    def check_limits(self, daily_limit=10, session_limit=2):
        return {
            "daily_spent": self.state["daily"]["spent"],
            "daily_remaining": max(0, daily_limit - self.state["daily"]["spent"]),
            "session_spent": sum(s["cost"] for s in self.state["sessions"][-50:]),
            "over_daily": self.state["daily"]["spent"] > daily_limit,
        }
```

#### 1.2 Cost Dashboard Command

Create a slash command or skill to show costs:

```markdown
# Cost Dashboard

Load this skill to show spending:
```
━━━ Cost Dashboard ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Today:    $4.50 / $10.00  ████░░░░░░  45%
  Session:  $1.20 / $2.00   ██████░░░░  60%
  Remaining until hard stop: $45.50

  Top tasks by cost:
    Architecture review  $2.50  (opus)
    Code implementation  $1.50  (sonnet)
    Bug fix              $0.50  (haiku)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 1.3 Cost Gate Override

Add an override for urgent tasks:

```yaml
cost_control:
  allow_override: true                # Allow user to bypass cost gate
  override_requires_reason: true      # Require justification
```

When a user chooses "Proceed anyway" from the cost gate:
```
Override reason: production outage — need immediate fix
```

#### 1.4 Priority Order

1. Implement `budget_tracker.py` — stateful cost tracking
2. Add budget threshold warnings in classify-task.sh
3. Create cost dashboard command
4. Add override mechanism

---

## 2. Agents

### Current State

| Agent Role | Phases | Modes | References | Status |
|-----------|--------|-------|-----------|--------|
| product-manager | ✅ 8 phases | ✅ 3 modes | ✅ 2 refs | ✅ Good |
| solution-architect | ✅ 7 phases | ✅ 1 mode | ❌ Empty | ✅ Good |
| software-engineer | ✅ 5+6+6+6 | ✅ 3 modes | ✅ 9 tech-packs | ✅ Excellent |
| frontend-engineer | ✅ 6 phases | ❌ None | ❌ Empty | ⚠️ Needs work |
| quality-engineer | ✅ 11 phases | ✅ 4 modes | ✅ 3 refs | ✅ Good |
| code-reviewer | ❌ **No phases** | ❌ None | ✅ 15 refs | 🔴 **Gap** |
| security-engineer | ✅ 8 phases | ✅ 2 modes | ❌ Empty | ✅ Good |
| platform-engineer | ✅ 6 + 5 phases | ❌ None | ❌ Empty | ✅ Good |
| data-scientist | ✅ 6 phases | ❌ None | ❌ Empty | ✅ OK |
| devops | ✅ 6 phases | ❌ None | ❌ Empty | ⚠️ OK |
| sre | ✅ 5 phases | ❌ None | ❌ Empty | ⚠️ OK |
| technical-writer | ✅ 4 phases | ✅ 2 modes | ❌ Empty | ✅ OK |
| research-advisor | ❌ **No phases** | ✅ 6 modes | ✅ 5 refs | 🔴 **Gap** |
| ai-ml-engineer | ✅ 7 phases | ❌ Empty | ❌ Empty | ⚠️ New role |
| mobile-engineer | ✅ 6 phases | ❌ None | ❌ Empty | ⚠️ New role |
| dotnet-engineer | ✅ 5 phases | ❌ None | ❌ Empty | ⚠️ New role |
| cloud-architect | ✅ 3 phases | ❌ None | ❌ Empty | ⚠️ New role |
| compliance-engineer | ✅ 8 phases | ✅ 2 modes | ❌ Empty | ✅ Legacy |

### Gaps

| Gap | Impact | Priority |
|-----|--------|----------|
| `code-reviewer` phases | ✅ **Implemented** | 4 phases: scan → analyze → report → verify-fix |
| `research-advisor` phases | ✅ **Implemented** | 4 phases: discover → research → analyze → recommend |
| Agent-to-workflow mapping | ✅ **Implemented** | `AGENT-WORKFLOW-MAP.yaml` with 17 agents × 12 workflows |
| 9 roles lack references/ | Agents lack knowledge base | Medium |
| `software-engineer` tech-packs are in agent role, not reusable | Duplicated in .cursor/skills/ | Medium |

### Proposed Improvements

#### 2.1 Create Missing Phases

**code-reviewer/phases/:**
```
01-scan.md         — Scan changed files, identify scope
02-analyze.md      — Deep analysis (security, perf, quality)
03-report.md       — Generate findings report
04-verify-fix.md   — Verify remediation
```

**research-advisor/phases/:**
```
01-discover.md     — Understand context and problem space
02-research.md     — Gather information and alternatives
03-analyze.md      — Evaluate options and trade-offs
04-recommend.md    — Present findings and recommendation
```

#### 2.2 Add References to All Roles

Create `references/README.md` in each role that points to the canonical skill set:

```markdown
# References for {Role}

## Internal Skills
- See `plugins/stack-{relevant}/skills/` for technology-specific skills
- See `skills/_shared/protocols/` for cross-cutting protocols

## External Resources (verified at time of use)
- [Official Documentation](https://example.com)
```

#### 2.3 Agent-to-Workflow Mapping

Create `workflows/AGENT-WORKFLOW-MAP.yaml`:

```yaml
# Maps each agent role to the workflows they participate in
agents:
  product-manager:
    workflows: [greenfield, spec-driven, feature]
    stages: [spec-writing, requirements]
  solution-architect:
    workflows: [greenfield, feature, architecture-review, migration, rag-system, agent-system]
    stages: [design, architecture, adr-generation]
  software-engineer:
    workflows: [greenfield, feature, bugfix, migration, ai-ml-pipeline]
    stages: [implementation, fix, code-migration]
  quality-engineer:
    workflows: [greenfield, feature, bugfix, security-review]
    stages: [testing, verification, regression]
  code-reviewer:
    workflows: [greenfield, feature, bugfix, architecture-review, documentation]
    stages: [review, conformance-check, diagnose]
  security-engineer:
    workflows: [greenfield, security-review, agent-system]
    stages: [threat-modeling, code-audit, safety-audit]
```

#### 2.4 Priority Order

1. Create code-reviewer phases (scan → analyze → report → verify)
2. Create research-advisor phases (discover → research → analyze → recommend)
3. Create AGENT-WORKFLOW-MAP.yaml
4. Add minimal references/README.md to all 9 roles missing them

---

## 3. Workflow SDLC (Important)

### Current State

| Component | Status | Details |
|-----------|--------|---------|
| YAML workflow definitions | ✅ 14 workflows | +discovery-to-delivery, AGENT-WORKFLOW-MAP, story-registry |
| Workflow schema | ✅ `workflow-schema.json` | JSON Schema validation |
| Cost estimation | ✅ `estimate-cost.sh` | Reads model_tier from YAML |
| **Workflow engine** | ✅ **Implemented** | `engine.py` — loads YAML, resolves deps, runs stages, checks gates |
| **Stage orchestration** | ✅ **Implemented** | Agent handoff via depends_on + AGENT-WORKFLOW-MAP.yaml |
| **Gate evaluation** | ✅ **Implemented** | Automatic (condition check) + Manual (user prompt) gates |
| **Workflow status** | ✅ **Implemented** | Status display with icons + timing per stage |
| **Workflow templates** | ❌ **Missing** | Template overrides — future enhancement |

### Gaps

| Gap | Impact | Priority |
|-----|--------|----------|
| No workflow engine | YAML files exist but can't execute — they're documentation only | **Critical** |
| No agent handoff | Workflow stages are isolated — no auto-routing between agents | **Critical** |
| No gate evaluation | Manual gates exist in YAML but aren't enforced | **High** |
| No status tracking | Can't see what stage a workflow is in | High |
| No workflow templates | Users can't customize workflows without editing raw YAML | Medium |

### Proposed Improvements

#### 3.1 Workflow Engine (Critical)

Create `workflows/engine.py` — a Python script that:
1. Reads a workflow YAML file
2. Resolves stage dependencies (depends_on)
3. Executes each stage by invoking the correct agent
4. Checks gates before advancing to next stage
5. Tracks status in `.sdlc-automation-agent/.orchestrator/workflow-state.json`

```python
# workflows/engine.py — Core workflow execution engine
import yaml, json, os, sys
from datetime import datetime

class WorkflowEngine:
    def __init__(self, workflow_file, project_dir="."):
        self.workflow = yaml.safe_load(open(workflow_file))
        self.state_dir = os.path.join(project_dir, ".sdlc-automation-agent", ".orchestrator")
        self.state_file = os.path.join(self.state_dir, "workflow-state.json")
        self.state = self._load_state()
    
    def _load_state(self):
        if os.path.exists(self.state_file):
            return json.load(open(self.state_file))
        return {"workflow": self.workflow["name"], "stages": {}, "started_at": None}
    
    def execute(self):
        self.state["started_at"] = datetime.utcnow().isoformat()
        completed = set()
        
        while len(completed) < len(self.workflow["stages"]):
            for stage in self.workflow["stages"]:
                sid = stage["id"]
                if sid in completed:
                    continue
                deps = stage.get("depends_on", [])
                if not all(d in completed for d in deps):
                    continue  # Dependencies not met
                
                self.state["stages"][sid] = {"status": "in_progress"}
                self._save_state()
                
                # Execute stage by invoking agent
                self._run_stage(stage)
                
                # Check gates
                gates_passed = self._check_gates(stage)
                if gates_passed:
                    completed.add(sid)
                    self.state["stages"][sid] = {"status": "completed"}
                else:
                    self.state["stages"][sid] = {"status": "blocked"}
                
                self._save_state()
        
        self.state["status"] = "completed"
        self.state["completed_at"] = datetime.utcnow().isoformat()
        self._save_state()
    
    def _run_stage(self, stage):
        # Invoke the correct agent with stage context
        print(f"Running stage: {stage['id']} with agent: {stage['agent']}")
        # Actual agent invocation happens here
    
    def _check_gates(self, stage):
        for gate in stage.get("gates", []):
            if gate["type"] == "automatic":
                # Evaluate condition
                condition = gate.get("condition", "")
                if not self._evaluate_condition(condition):
                    return False
            elif gate["type"] == "manual":
                # Present AskUserQuestion for manual gates
                print(f"Gate requires user input: {gate.get('prompt', '')}")
                return False  # Block until user responds
        return True
```

#### 3.2 Workflow Status Command

Create a status display for workflows:

```yaml
# workflows/workflow-status.sh — Show workflow progress
```

```
━━━ Workflow: feature-delivery ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ design         Solution Architect     12:30:01  ⏱ 3m
  ⧖ implementation Software Engineer      12:35:01  ⏱ 12m (running)
  ○ testing        Quality Engineer       pending   
  ○ review         Code Reviewer          pending   

  Estimated: $7-13 | Spent: $4.50 | Remaining: $2.50-8.50
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 3.3 Workflow Templates

Allow users to customize workflows via overrides:

```yaml
# .sdlc-automation-agent/workflows/overrides.yaml
overrides:
  feature:
    stages:
      - id: implementation
        model_tier: premium     # Force premium for this project
        timeout_minutes: 30
      - id: review
        skip: true              # Skip code review for internal tools
```

#### 3.4 Priority Order

1. Create `workflows/engine.py` — the core workflow engine
2. Create `workflows/workflow-status.sh` — status display
3. Add gate condition evaluation (start with automatic gates)
4. Add workflow template overrides

---

## 4. Discovery → Requirements → User Stories → Implementation

### Current State

| Phase | Agent | Phases | Input | Output |
|-------|-------|--------|-------|--------|
| **Discovery** | solution-architect | `01-discovery.md` | Existing codebase (via reverse.md) | Architecture context, system map |
| **Requirements** | product-manager | 8 phases (`01-understand-input` → `08-validation`) | User request | BRD, epics, user stories |
| **Architecture** | solution-architect | 7 phases (`01-discovery` → `07-spec-design`) | Requirements | ADRs, API contracts, tech stack |
| **Implementation** | software-engineer | 5 phases (`01-context` → `05-local-dev`) | Architecture spec | Code, tests |

### What Already Works Well

| Step | What Exists | Quality |
|------|-------------|---------|
| Codebase discovery | `reverse.md` (1,140 lines) — 8-step reverse engineering | ✅ Excellent |
| PM understands input | `PM/phases/01-understand-input.md` | ✅ Good |
| PM generates BRD | `PM/phases/03-generate-brd.md` | ✅ Good |
| PM decomposes to stories | `PM/phases/04-08` (epics → features → stories) | ✅ Good |
| SA discovers existing | `SA/phases/01-discovery.md` | ✅ Good |
| SA designs architecture | `SA/phases/02-07` (design → tech-stack → API → data → scaffold → spec) | ✅ Good |
| SE implements | `SE/phases/01-05` (context → service → cross-cutting → integration → dev) | ✅ Good |
| Spec-driven workflow | `workflows/spec-driven.yaml` | ✅ Good |

### Gaps

| Gap | Impact | Priority |
|-----|--------|----------|
| No traceable ID linking User Story → Implementation | ✅ **Implemented** | `story-registry-template.yaml` with file/tests/status tracking |
| No handoff gate between PM→SA→SE | ✅ **Implemented** | 6 gates in discovery-to-delivery.yaml (system-mapped, brd-approved, arch-approved, story-registered, story-complete, review-approved) |
| No acceptance criteria validation | ✅ **Implemented** | Stories have acceptance_criteria field validated by automatic gates |
| reverse.md is not connected to PM phases | Discovery output feeds into requirements stage | Medium |
| Spec-driven workflow is standalone | Not integrated into delivery pipeline | Low |

### Proposed Improvements

#### 4.1 Traceable Story → Implementation Pipeline

Add a traceable ID system that links every user story to its implementation:

```yaml
# .sdlc-automation-agent/.orchestrator/story-registry.yaml
stories:
  US-001:
    title: "User can sign up with email"
    acceptance_criteria:
      - Email verification required
      - Password must be 8+ characters
      - Welcome email sent after signup
    implementation:
      files:
        - services/auth/src/signup.controller.ts
        - services/auth/src/signup.service.ts
        - services/email/src/welcome.template.ts
      tests:
        - tests/auth/signup.spec.ts
        - tests/auth/email-verification.spec.ts
    status: completed
    completed_at: 2026-07-20T14:30:00Z
```

#### 4.2 Handoff Gates Between Phases

Create explicit gate checks between pipeline stages:

```
PM → SA Gate: "Requirements approved?"
  Check: All stories have acceptance criteria
  Check: BRD covers all requirements
  Check: Success metrics defined
  
SA → SE Gate: "Architecture approved?"
  Check: ADRs written for key decisions
  Check: API contracts complete
  Check: Tech stack selected and justified
  
SE → QE Gate: "Ready for testing?"
  Check: Tests written and passing
  Check: Code review completed
  Check: Documentation updated
```

#### 4.3 End-to-End Discovery→Implementation Workflow

Create `workflows/discovery-to-delivery.yaml`:

```yaml
name: discovery-to-delivery
description: "Full pipeline: Discover → Requirements → Architecture → Stories → Implement → Test → Review → Deploy"

stages:
  - id: codebase-discovery          # Understand existing system
    agent: research-advisor
    model_tier: standard
    gates:
      - id: system-mapped
        type: manual
        prompt: "Review the system map for completeness"
    
  - id: requirements                # Gather and document requirements
    agent: product-manager
    model_tier: standard
    depends_on: [codebase-discovery]
    outputs:
      - "docs/requirements/brd.md"
      - "docs/requirements/user-stories/*.md"
    gates:
      - id: brd-approved
        type: automatic
        condition: "all_stories_have_acceptance_criteria"
    
  - id: architecture-design         # Design based on requirements
    agent: solution-architect
    model_tier: premium
    depends_on: [requirements]
    outputs:
      - "docs/architecture/ADR-*.md"
      - "docs/api/openapi.yaml"
    gates:
      - id: arch-approved
        type: manual
        prompt: "Review architecture design before implementation"
    
  - id: story-registration          # Register stories in tracker
    agent: product-manager
    model_tier: standard
    depends_on: [architecture-design]
    outputs:
      - ".sdlc-automation-agent/.orchestrator/story-registry.yaml"
    
  - id: implementation              # Implement per story
    agent: software-engineer
    model_tier: standard
    depends_on: [story-registration]
    gates:
      - id: story-complete
        type: automatic
        condition: "all_story_acceptance_criteria_met"
    
  - id: testing                     # Verify implementation
    agent: quality-engineer
    model_tier: standard
    depends_on: [implementation]
    gates:
      - id: tests-passing
        type: automatic
        condition: "coverage > 80%"
    
  - id: review                      # Code review
    agent: code-reviewer
    model_tier: premium
    depends_on: [testing]
    gates:
      - id: review-approved
        type: manual
        prompt: "Code review findings resolved"
    
  - id: deploy                      # Deploy
    agent: platform-engineer
    model_tier: standard
    depends_on: [review]
    gates:
      - id: dod-met
        type: automatic
        condition: "all_critical_findings_resolved"
```

#### 4.4 Story Registry Skill

Create a skill that manages the story lifecycle:

```markdown
# Story Registry

Tracks each user story from creation through implementation to verification.

## Commands
- `Register story US-001` — Create a new story with acceptance criteria
- `Link story US-001 to implementation` — Map story to code files
- `Verify story US-001` — Check that acceptance criteria are met
- `Story status US-001` — Show current status of a story

## Integration
- Stories are stored in `.sdlc-automation-agent/.orchestrator/story-registry.yaml`
- Stories link to Jira issues via `project-management/jira/` skill
- Stories link to code via file path patterns
```

#### 4.5 Priority Order

1. Create `workflows/discovery-to-delivery.yaml` — end-to-end workflow
2. Add traceable story ID system with `story-registry.yaml`
3. Create handoff gates between PM→SA→SE→QE stages
4. Create Story Registry skill
5. Link reverse.md discovery output into PM requirements phase

---

## Implementation Roadmap

| Phase | Area | Days | Key Deliverable |
|-------|------|------|-----------------|
| **1** | Cost Control | ✅ Done | `budget_tracker.py`, cost-dashboard skill, budget alerts in classify-task.sh |
| **2** | Agents | ✅ Done | code-reviewer (4 phases) + research-advisor (4 phases) + AGENT-WORKFLOW-MAP.yaml |
| **3** | Workflow Engine | ✅ Done | `workflows/engine.py` + status display + gate evaluation |
| **4** | Discovery→Delivery | ✅ Done | `workflows/discovery-to-delivery.yaml` + story-registry-template.yaml + 6 handoff gates |
| **5** | Integration & Polish | 🔄 Completed | All content synced to .cursor |
| **Total** | | **All done** | **14 workflows · 18 agent roles · budget tracking · engine** |

---

## Summary

| Area | Current | Target | Priority |
|------|---------|--------|----------|
| **Cost Control** | Basic S1-S5 classifier | Stateful budget tracker + dashboard | 🔴 **Critical** |
| **Workflow Engine** | YAML definitions only | Executable workflow engine | 🔴 **Critical** |
| **Discovery→Delivery** | Disconnected phases | End-to-end traceable pipeline | 🔴 **Critical** |
| **Agents** | 2 roles missing phases | All 18 roles complete | 🟡 High |
