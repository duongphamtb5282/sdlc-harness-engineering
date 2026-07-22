<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# SA Architecture Auto-Detect Protocol

> **Audience:** sdlc-automation-agent Orchestrator only. Defines when and how to invoke the Solution Architect (SA) during Sprint Planning or Kanban ticket analysis.

## Purpose

In v2, the Solution Architect is an **on-demand specialist** — not a ceremonial participant. The Orchestrator analyzes story/ticket text for architecture signals and invokes SA only when triggered. Most sprints skip SA entirely.  

## Trigger Signals

Scan each story's **title**, **description**, and **acceptance criteria** for these 5 signal patterns. If ANY signal matches, invoke SA for that sprint/ticket. 

### Signal 1 — New Database Entity 

**Keywords:** `new table`, `new entity`, `new model`, `new schema`, `database`, `migration`, `foreign key`, `relationship`, `join table`, `many-to-many`, `one-to-many`, `polymorphic`

**Pattern:** Story introduces a data concept not in the current ERD.

**SA Action:** Update ERD + create migration ADR.

### Signal 2 — New Service or Bounded Context

**Keywords:** `new service`, `new microservice`, `new module`, `bounded context`, `new API`, `new endpoint group`, `separate concern`, `extract service`, `split`, `decompose`

**Pattern:** Story requires a new independently deployable unit or major module.

**SA Action:** Update system design diagram + create service boundary ADR.

### Signal 3 — New External Integration

**Keywords:** `integrate with`, `third-party`, `external API`, `webhook`, `OAuth`, `SSO`, `payment provider`, `email service`, `SMS`, `push notification`, `import from`, `export to`, `sync with`

**Pattern:** Story requires communicating with a system outside the project boundary.

**SA Action:** Create API contract (client-side) + integration ADR + circuit breaker requirements.

### Signal 4 — New Security Requirement

**Keywords:** `authentication`, `authorization`, `role-based`, `RBAC`, `ABAC`, `permission`, `encrypt`, `PII`, `PHI`, `HIPAA`, `GDPR`, `SOC 2`, `audit log`, `compliance`, `multi-tenant`, `tenant isolation`

**Pattern:** Story introduces or changes security/compliance boundaries.

**SA Action:** Create security architecture ADR + update threat model scope.

### Signal 5 — Performance-Critical Story

**Keywords:** `performance`, `latency`, `throughput`, `scale to`, `concurrent`, `real-time`, `streaming`, `batch processing`, `cache`, `CDN`, `load balancer`, `rate limit`, `SLA`, `p99`, `p95` 

**Pattern:** Story has explicit performance requirements or NFR constraints.

**SA Action:** Review NFR alignment + create performance architecture ADR if needed. 

## Detection Procedure  

```  
For each story in the sprint backlog (or the current Kanban ticket):

1. Read story details:
   STORY=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/tracker/tracker_cli.py" \ 
     --project-dir "$(pwd)" get-story "{story_id}")

2. Extract text fields: title + description + acceptance_criteria 

3. Scan for trigger keywords (case-insensitive):
   - Check each signal's keyword list against the combined text
   - Record which signals matched

4. If ANY signal matched:
   TRIGGERS_FOUND=true
   Log: "Architecture signals detected in {story_id}: {signal_names}"
   
5. If NO signals matched: 
   TRIGGERS_FOUND=false 
   Log: "No architecture signals — skipping SA for this sprint/ticket"
``` 

## SA Invocation

When triggers are found, dispatch the SA agent:

```
1. Resolve SA backend: 
   SA_BACKEND=$(python3 "${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/backend/backend_config.py" \
     "$(pwd)" "solution-architect")

2. Read SA backend wrapper:  
   Read("${CLAUDE_PLUGIN_ROOT}/skills/_shared/backends/${SA_BACKEND}.md")

3. Build SA prompt:
   - Include: triggered signals, story text, current architecture docs 
   - Scope: ONLY address the triggered signals, not full architecture review 
   - Output: ADRs, ERD updates, API contracts as applicable

4. Dispatch per backend wrapper instructions

5. SA writes receipt: .sdlc-automation-agent/.orchestrator/receipts/sprint-{N}-sa.json
``` 

## Architecture Health Check (Periodic) 

Independent of per-story triggers, the Orchestrator runs an SA health check every N sprints (configured in `.sdlc-automation-agent.yaml` as `architecture.health_check_interval`, default: 3).  

```
If current_sprint % health_check_interval == 0:
  Invoke SA for architecture health check:
  - Review accumulated ADRs for consistency
  - Check for architecture drift (implementation vs design)
  - Validate NFR compliance across all services
  - Update system diagrams if stale
```

Set `architecture.health_check_interval: 0` to disable periodic health checks.

## No-Trigger Behavior

When no triggers are found and no health check is due:
- SA is **completely skipped** — no agent dispatch, no receipt, no overhead  
- Sprint Planning proceeds directly from PO refinement to story selection  
- This is the **expected path for most sprints** — only exceptional sprints need SA
