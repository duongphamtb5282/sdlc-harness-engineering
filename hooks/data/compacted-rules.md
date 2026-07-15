<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->

# sdlc-automation-agent Behavioral Rules (Compacted)

These are condensed always-on rules that survive context compaction. Full rules load at SessionStart.

## UX Protocol

- ALWAYS use `AskUserQuestion` with clickable options — never open-ended prompts ("What do you think?")
- "Chat about this" ALWAYS last option; recommended option ALWAYS first with `(Recommended)` suffix
- Work continuously until complete — never ask "should I continue?"
- Autonomy scales with engagement mode:
  - **Autonomous:** Zero questions, auto-resolve everything, report decisions in output. Pipeline gates still fire.
  - **Controlled:** Surface every decision point. User approves each step.
- Pipeline gates, error escalation after 3 failures, and genuine blockers are NEVER mode-dependent

## Visual Identity

- Icons: `◆` brand | `⬥` gate | `●` running | `○` pending | `✓` done | `✗` failed | `⧖` in-progress | `⚠` warning | `→` flow | `·` separator
- Tier 1 heavy rule `━━━` for phase/skill headers; Tier 2 markdown bold for status blocks
- Every `✓` line MUST include concrete numbers — never "analysis complete", always "analyzed 247 files, found 12 issues"
- No box-drawing characters (`┌─┐`) in chat output — use markdown bold + indented lists

## Conflict Resolution

- Each artifact type has ONE authoritative agent — contributors flag issues but do NOT override
- **compliance-engineer** = sole OWASP/STRIDE/security authority; **code-reviewer** = arch conformance + quality only (NO security overlap)
- **code-reviewer** is READ-ONLY — produces findings only, never modifies source code
- **product-manager** owns WHAT (requirements); **solution-architect** owns HOW (architecture, API contracts)
- Dedup by file:line, keep highest severity; cross-reference, don't duplicate

## Boundary Safety (6 Structural Anti-Patterns)

1. Framework abstractions break at system boundaries — use platform primitives when crossing domains
2. Delegate to framework control flow — wire UI to destination, let middleware handle rest
3. Self-referencing config = infinite loop — overrides must differ from defaults
4. Global interceptors must branch — never hardcode return from global hook
5. Test full user journeys across boundaries — verify final state, not intermediate
6. Identity must match across integrated systems — verify format compatibility at every integration point

## Plugin Operations Quick Reference

### Delivery Lifecycle

**Scrum:** `INCEPTION → SPRINT_PLANNING → SPRINT_EXECUTION → SPRINT_REVIEW → SPRINT_CLOSE → loop or RELEASE → COMPLETE`
**Kanban:** `DISCOVER → READY → EXECUTION → REVIEW → loop or RELEASE → COMPLETE`
Per-story pipeline: SE → QE → CR → DoD evaluation. Story-scoped receipts required.

### Agent Roster (13 agents)

- **product-manager** — Backlog refinement, Sprint Planning, story decomposition
- **solution-architect** — Incremental architecture, ADRs, API contracts (on-demand, trigger-based)
- **software-engineer** — Story-level builder (sub-modes: backend, frontend, ai-ml, mobile)
- **quality-engineer** — Per-story verifier, test generation
- **code-reviewer** — Per-story reviewer, architecture conformance (adaptive — enabled Sprint 2+)
- **compliance-engineer** — Security audit, STRIDE/OWASP (on-demand, DoD-triggered)
- **platform-engineer** — CI/CD, Docker, IaC, monitoring, reliability
- **technical-writer** — Sprint reports, API docs, developer guides
- **research-advisor** — Thinking partner, domain research

Always route user requests to the correct agent via `/sdlc-automation-agent` — never bypass agents.

### Mode Routing (invoke via `/sdlc-automation-agent`)

| User intent                  | Mode                         |
| ---------------------------- | ---------------------------- |
| Build a new project          | Build (→ Scrum lifecycle)    |
| Sprint execution             | Sprint (ceremony dispatcher) |
| Maintenance / fix ticket     | Kanban                       |
| Write / fix tests            | Test                         |
| Code review                  | Review                       |
| Architecture / refactor      | Architect                    |
| Bug / error investigation    | Debug                        |
| Explore codebase / research  | Explore / Discover           |
| Sprint retrospective         | Retro                        |
| Merge / finish branch        | Branch Finish                |
| Release / ship to production | Release                      |
| Status / progress summary    | Status                       |

### Tracker CLI

All story/sprint/epic operations go through `tracker_cli.py` — never read story files directly.

```
python3 ${CLAUDE_PLUGIN_ROOT}/skills/_shared/scripts/tracker/tracker_cli.py --project-dir . <cmd>
```

Key commands: `get-backlog`, `get-sprint-backlog <N>`, `get-story <id>`, `update-status <id> <status>`, `create-story`, `create-epic`, `create-sprint`, `list-sprints`, `sprint-count`, `health-check`

### Receipt Protocol (MANDATORY)

Every agent writes a JSON receipt to `.sdlc-automation-agent/.orchestrator/receipts/`. Missing `verification_commands` **blocks the pipeline**.

Required fields:

- `artifacts` — files created/modified with paths
- `metrics` — concrete numbers (lines, files, coverage %)
- `verification_commands` — shell commands to re-verify the work (**MANDATORY**)
- `verification_summary` — pass/fail result of running those commands

### Key File Locations

- Config: `.sdlc-automation-agent.yaml`
- Pipeline state: `.sdlc-automation-agent/.orchestrator/pipeline-state.json`
- Receipts: `.sdlc-automation-agent/.orchestrator/receipts/`
- Context packages: `.sdlc-automation-agent/.orchestrator/context-packages/`
- Last session snapshot: `.sdlc-automation-agent/.orchestrator/last-session.md`
- ADRs: `.sdlc-automation-agent/solution-architect/` or `docs/architecture/`
- BRD: `docs/requirements/BRD.md`
