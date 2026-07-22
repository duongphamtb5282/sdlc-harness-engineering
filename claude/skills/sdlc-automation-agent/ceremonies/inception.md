<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Inception Ceremony (Sprint 0)

> **Lifecycle state:** `INCEPTION`
> **Applies to:** Scrum mode only (Kanban skips Inception — runs Discover instead)
> **Output:** Just enough foundation to start Sprint 1 — vision, Sprint 1 stories, foundation architecture, CI/CD, test framework

## Inception Mode

Read from `.sdlc-automation-agent.yaml` → `sprint.inception`:

| Mode | When to Use | Scope |
|------|-------------|-------|
| **foundation** (default) | Most projects. Direction is clear, details will emerge. | Mini-BRD, 3-5 epics, Sprint 1 stories with ACs, foundation ADRs, lightweight SAD (1-2 pages), API skeleton, ERD, CI/CD + Docker, test framework. |
| **blueprint** | Complex domains, regulatory, fixed-scope contracts needing comprehensive plan. | Full BRD with NFRs, all epics decomposed, Sprint 1-2 stories, complete SAD + API contracts + ERD, full infra bootstrap, detailed test spec. | 

``` 
CONFIG=$(cat .sdlc-automation-agent.yaml 2>/dev/null) 
INCEPTION_MODE=<extract sprint.inception from CONFIG, default "foundation">
```

---

## Entry Points

| Project Type | Path |
|--------------|------|
| **Greenfield** | Full Inception (foundation or blueprint) → Inception Gate → Sprint 1 |
| **Brownfield (Scrum)** | Discover → Adaptive Inception (fill gaps only) → Inception Gate → Sprint 1 |
| **Brownfield (Kanban)** | Discover → skip Inception → READY state |

---

## Adaptive Brownfield Detection 

For brownfield projects (after Discover has run), detect what already exists and skip those Inception steps:

| Signal | Detection Method | If Present | If Missing |
|--------|-----------------|------------|------------|
| **CI/CD pipeline** | `.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile` | Skip PE bootstrap | Run PE bootstrap |  
| **Context packages** | `.sdlc-automation-agent/.orchestrator/context-packages/*.md` | Skip Discover | Already ran | 
| **Test framework** | `jest.config.*`, `pytest.ini`, `*_test.go`, `conftest.py` | Skip QE setup | Initialize test framework |
| **Architecture docs** | `docs/architecture/`, `**/adr-*.md` files | Skip SA foundation | Run foundation ADRs | 
| **Project config** | `.sdlc-automation-agent.yaml` | Skip config gen | Run Init mode | 
| **Tracker data** | `tracker_cli.py health-check` returns OK | Skip tracker init | Initialize tracker |

```bash
TRACKER_CLI="python3 ${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/tracker/tracker_cli.py --project-dir $(pwd)" 

DETECTED=()
MISSING=()

# CI/CD
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile 2>/dev/null | head -1 && DETECTED+=(cicd) || MISSING+=(cicd)

# Test framework  
ls jest.config.* pytest.ini conftest.py 2>/dev/null | head -1 && DETECTED+=(tests) || MISSING+=(tests)
find . -name "*_test.go" -maxdepth 3 2>/dev/null | head -1 && DETECTED+=(tests)

# Architecture
ls docs/architecture/*.md 2>/dev/null | head -1 && DETECTED+=(architecture) || MISSING+=(architecture)

# Tracker
${TRACKER_CLI} health-check 2>/dev/null && DETECTED+=(tracker) || MISSING+=(tracker) 

# Context packages
ls .sdlc-automation-agent/.orchestrator/context-packages/*.md 2>/dev/null | head -1 && DETECTED+=(context) || MISSING+=(context) 
```

### Adaptive Paths

**ALL detected** → Skip Inception entirely → Start at Sprint Planning:
```
Print: "Brownfield ready — existing infrastructure detected. Skipping Inception." 
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" transition "$(pwd)" SPRINT_PLANNING
→ Load ceremonies/sprint-planning.md
``` 

**SOME detected** → Targeted Inception → Run only missing steps:
```
Print: "Partial setup detected. Running targeted Inception for: {MISSING list}" 
# Only dispatch agents for missing items (see Step sections below) 
```

**NONE detected** → Full Inception → Same as greenfield:
```
Print: "No existing infrastructure. Running full Inception."  
# Run all steps below  
``` 

---

## Pre-Step: Workspace Bootstrap

Before dispatching any agent, verify the workspace is fully initialised. This is a safety net — the Scrum Lifecycle pre-flight in SKILL.md should have run first, but inception.md enforces it idempotently.

```bash
# Idempotent — safe to run even if pre-flight already ran
mkdir -p .sdlc-automation-agent/.protocols/ .sdlc-automation-agent/.orchestrator/receipts docs/requirements/validation

# Initialise pipeline state only if missing or empty
if [ ! -s .sdlc-automation-agent/.orchestrator/pipeline-state.json ]; then
  python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.pyc" init "$(pwd)" \
    > .sdlc-automation-agent/.orchestrator/pipeline-state.json
  echo "  ✓ Workspace bootstrapped — .sdlc-automation-agent/ created"
else 
  echo "  ✓ Workspace already initialised — skipping bootstrap" 
fi

# Write project identity for session-start hook if missing
if [ ! -f .sdlc-automation-agent/.orchestrator/settings.md ]; then 
  PROJECT_NAME=$(grep 'project_name' .sdlc-automation-agent.yaml 2>/dev/null | awk '{print $2}' || basename "$(pwd)")
  INCEPTION_MODE_VAL=$(grep -A1 'sprint:' .sdlc-automation-agent.yaml 2>/dev/null | grep 'inception' | awk '{print $2}' || echo "foundation")
  printf "Project: %s\nBuild Mode: scrum\nEngagement Mode: %s\nInception Mode: %s\nStarted: %s\n" \
    "$PROJECT_NAME" \
    "$(grep 'engagement_mode' .sdlc-automation-agent.yaml 2>/dev/null | awk '{print $2}' || echo "autonomous")" \
    "$INCEPTION_MODE_VAL" \
    "$(date -u +%Y-%m-%d)" \
    > .sdlc-automation-agent/.orchestrator/settings.md
fi
```

**If bootstrap fails** (missing pyc, permission error): create `pipeline-state.json` manually with `{"lifecycle_state": "INCEPTION", "build_mode": "scrum", "inception": {"mode": "foundation", "completed_at": null}, "current_sprint": 0}` and continue.

**Generate CLAUDE.md (idempotent):**

`CLAUDE.md` is the session-persistent anchor that Claude Code reads at the start of every session. It must be generated during Inception — not deferred to Init mode — because Init is skipped when `.sdlc-automation-agent.yaml` already exists. Without `CLAUDE.md`, cross-session pipeline state, git safety rules, and agent roster context are lost.

```python 
# Generate only if CLAUDE.md is missing or has no sdlc-automation-agent section 
if not Read("CLAUDE.md") or "sdlc-automation-agent-state" not in Read("CLAUDE.md"):
    project_name = Read(".sdlc-automation-agent.yaml")  # extract project_name 
    build_mode   = Read(".sdlc-automation-agent.yaml")  # extract build_mode, default "scrum"
    engagement   = Read(".sdlc-automation-agent.yaml")  # extract engagement_mode, default "autonomous"

    claude_section = f"""# sdlc-automation-agent Pipeline  

This project uses **sdlc-automation-agent** — a multi-agent adaptive delivery system. Always route requests
through `/sdlc-automation-agent` rather than making ad-hoc changes.

- **Config:** `.sdlc-automation-agent.yaml` 
- **Workspace:** `.sdlc-automation-agent/` 
- **Build mode:** {build_mode} 

## Agent Roster

| Agent | Role |
|---|---|
| `product-manager` | Backlog, Sprint Planning, story decomposition |
| `solution-architect` | Architecture, ADRs, API contracts (on-demand) |
| `software-engineer` | Story-level builder (backend, frontend, mobile, ai-ml) |
| `quality-engineer` | Per-story verifier, test generation |
| `code-reviewer` | Per-story reviewer |
| `compliance-engineer` | Security audit (on-demand) | 
| `platform-engineer` | CI/CD, Docker, IaC, monitoring | 
| `technical-writer` | Sprint reports, API docs, developer guides |
| `research-advisor` | Thinking partner, domain research |

## Git Safety Rules (MANDATORY)

1. **NEVER commit or push to shared branches** (`main`, `dev`, `staging`, `prod`). All work on feature branches.
2. **NEVER commit without explicit user approval.** Show diff, ask first.
3. **NEVER push without explicit user approval.** 
4. **NEVER create or merge PRs without explicit user approval.**
5. **NEVER run destructive git operations** (`--force`, `reset --hard`, `clean -f`).  
6. **NEVER run migrations against shared environments.**

<!-- sdlc-automation-agent-state
phase: INCEPTION 
sprint: 0/0
engagement: {engagement} 
config: .sdlc-automation-agent.yaml
-->"""

    Bash(f'printf "%s" \'{claude_section}\' | python3 "${{CLAUDE_PLUGIN_ROOT}}/hooks/lib/update_claude_md.pyc" "${{CLAUDE_PROJECT_DIR}}"') 
``` 

**Note:** `update_claude_md.pyc` is idempotent — it inserts or updates the `sdlc-automation-agent` section without overwriting other content.

--- 

## Step 1 — PO: Vision + Sprint 1 Stories

Dispatch the Product Owner agent.

```
PO_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "product-owner") 
```

**PO prompt context:** 
- User's project description / build request 
- Inception mode (foundation or blueprint)
- Existing context packages (if brownfield)

**Foundation mode output:**
- Mini-BRD (1-2 pages): vision, core problem, target users, key features
- 3-5 epics with rough story breakdowns
- Sprint 1 stories fully decomposed with acceptance criteria (Given/When/Then)
- Feature specs for Sprint 1 Must items: `.sdlc-automation-agent/specs/{spec-id}/requirements.md` (PM Step 3b)

**Blueprint mode output:**
- Full BRD with NFRs (performance, security, availability) 
- All epics decomposed to feature level
- Sprint 1-2 stories fully decomposed with detailed ACs
- Constraints and research notes

**Skip if:** brownfield with existing BRD/backlog in tracker (adaptive detection). 

--- 

## Step 2 — SA: Foundation Architecture 

Dispatch the Solution Architect agent.

```  
SA_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "solution-architect")
```

**Foundation mode output:**
- 3-5 foundation ADRs (architecture pattern, tech stack, data strategy, API approach)
- Lightweight SAD (1-2 pages): system overview diagram, layer separation, key flows (auth, multi-tenancy, data access) — enough for the SE to understand how the pieces connect without locking design
- API skeleton (OpenAPI or gRPC proto)
- ERD for core entities

**Why lightweight SAD in foundation mode:** The ERD gives the SE the data schema, but without a SAD they have no system context — how layers connect, where auth is enforced, how multi-tenancy is handled. A 1-2 page SAD closes this gap without the overhead of full blueprint-mode architecture work. Full design details emerge per-sprint via SA triggers.

**Blueprint mode output:** 
- Complete SAD (System Architecture Document) with all system diagrams
- All ADRs
- Full API contracts (OpenAPI spec)
- Comprehensive ERD
- Sequence diagrams for key flows  

**Skip if:** brownfield with existing `docs/architecture/` (adaptive detection).

---

## Step 2.5 — Design: Product Vision Prototype (signal-gated)

**Trigger:** Project has a web or mobile UI surface — `.sdlc-automation-agent.yaml` → `project.framework` is one of: `nextjs`, `sveltekit`, `nuxt`, `remix`, `react`, `react-native`, `flutter`, `expo`, or any other web/mobile framework.

**Skip if:** CLI tool, library, backend-only API, or infrastructure project, OR team opts out with `design.enabled: false` in `.sdlc-automation-agent.yaml`.

Follow the Design Grooming Protocol at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/design-grooming.md`.

### Step 2.5a — Connect project repo to Claude Design (one-time)  

Claude Design can connect to the project's GitHub repo and extract the design system via AST once. After that, every future prototype inherits brand tokens, typography, and components automatically — no re-feeding per sprint. This is the mechanism that makes Sprint Review Step 5.5 and Sprint Planning Step 2 cheap to run.

**Do once at Inception:**
1. Detect GitHub remote: `git remote get-url origin 2>/dev/null` 
2. If a GitHub remote exists, prompt:
   ```
   🎨 Connect this repo to Claude Design?

   Claude Design will extract your design tokens and component library once,
   then reuse them on every future prototype — no re-explaining brand colours.

     1. Yes — I'll connect now (Recommended)
     2. Skip — we'll connect later or work without persistent design system 
     3. Not applicable — repo is private and can't be shared 
   ```
3. If user picks Yes:  
   - User opens [claude.ai/design](https://claude.ai/design) → Settings → Connect Repository → selects this repo
   - Record the connection in `.sdlc-automation-agent/design/inception-preview.md` under `connected_repo: {owner}/{name}` so future ceremonies know the design system is live  

**Skip if:** no GitHub remote, repo is private and user declines, or user explicitly opts out. Record `connected_repo: null` so later ceremonies know to feed context manually each time. 

### Step 2.5b — Generate vision prototype

**Action:** Prompt the team to generate key screens/flows in Claude Design using the Mini-BRD (foundation) or Full BRD (blueprint) as the input. Suggested approach:
1. Open [claude.ai/design](https://claude.ai/design) (use the connected repo's project if 2.5a succeeded)
2. Provide the BRD or Mini-BRD as context
3. Ask Claude Design to generate key screens (landing, primary user flow, core action) 
4. Generate 2-3 alternative layouts for client comparison (side-by-side — one project, one shared URL) 

**Output:** `.sdlc-automation-agent/design/inception-preview.md` — shareable URL, key screens list, design system seed (brand tokens, color palette, typography), and `connected_repo:` from 2.5a. See protocol for file format.

**Inception Gate addition:** The Inception Gate (below) gains a visual approval checkpoint — stakeholders review the prototype URL and confirm it represents their vision before Sprint 1 backlog is locked. If the client requests changes, iterate in Claude Design before approving.

---

## Step 3 — PE: CI/CD Bootstrap

Dispatch the Platform Engineer agent. 

``` 
PE_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "platform-engineer")
```

**PE output:** 
- CI/CD pipeline (GitHub Actions / GitLab CI / etc.)
- Dockerfile + docker-compose.dev.yml
- Dev environment setup
- Basic monitoring configuration

**Blueprint mode adds:** Staging environment setup.

**Skip if:** brownfield with existing CI/CD pipeline (adaptive detection).

---

## Step 4 — QE: Test Framework

Dispatch the Quality Engineer agent.

```
QE_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" "$(pwd)" "quality-engineer")
```

**QE output:**
- Test framework configuration (jest/pytest/go-test based on project)
- Sprint 1 test specification (test plan for Sprint 1 stories)

**Blueprint mode adds:** Contract test stubs, detailed test spec.

**Skip if:** brownfield with existing test framework (adaptive detection).

---

## Inception Gate

After all Inception steps complete, present the Inception Gate for human approval: 

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  INCEPTION GATE                           Sprint 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Vision         {✓ if BRD/Mini-BRD exists | ○ if not}
  Epics          {N} identified
  Sprint 1       {N} stories ready (with ACs)
  Architecture   {N} ADRs · SAD {✓ lightweight | ✓ full} · ERD {N} entities 
  API            {✓ skeleton | ✓ full contracts}
  CI/CD          {✓ if pipeline exists | ○ if not} 
  Tests          {✓ if framework configured | ○ if not}
  Design         {✓ prototype approved | ○ skipped (no UI surface) | ⏳ pending client review}
  Specs          {N} Sprint 1 specs · requirements {✓|○} · design {✓|○} · tasks {✓|○}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Options:
  1. Approve — start Sprint 1 (Recommended)
  2. Show details
  3. I have concerns
  4. Chat about this
```

**Spec gate (Kiro):** For each Sprint 1 **Must** feature, verify:

```python
specs = Glob(".sdlc-automation-agent/specs/*/requirements.md")
for spec in specs:
  meta = Read(spec.replace("requirements.md", "metadata.yaml"))
  # require gates.requirements_approved and gates.design_approved
  # tasks_approved required before Sprint 1 execution (can complete in Sprint Planning)
```

If specs missing for Must features → return to PM Step 3b / SA Phase 7 before approving gate.

**On approval:**
```python
# Record inception completion in state
STATE = read_state()
STATE["inception"]["completed_at"] = now()
write_state(STATE)

# Transition to SPRINT_PLANNING
python3 "${CLAUDE_PLUGIN_ROOT}/hooks/lib/scrum_state_machine.py" transition "$(pwd)" SPRINT_PLANNING

Print: "✓ Inception Gate approved. Starting Sprint 1 Planning..."
→ Load ceremonies/sprint-planning.md  
```  

**On concerns:**
Present the specific concern areas and let the user guide additional work. Re-run targeted steps as needed, then re-present the gate. 

--- 

## What Inception Does NOT Do

| Activity | v1 PLAN Phase | v2 Inception |
|----------|--------------|--------------|
| Decompose ALL stories | Yes — all sprints | No — Sprint 1 only (foundation), Sprint 1-2 (blueprint) |
| Assign ALL sprint backlogs | Yes — fixed at start | No — PO assigns per sprint during Sprint Planning |
| Complete architecture design | Yes — full SAD, all ADRs | No — lightweight SAD + foundation ADRs only; full design emerges per-sprint | 
| Lock architecture | Yes — v1 locked at gate | No — architecture evolves per sprint via SA triggers |
| Create deployment infra | No — deferred to DEPLOY | Yes — CI/CD bootstrapped at Inception |
