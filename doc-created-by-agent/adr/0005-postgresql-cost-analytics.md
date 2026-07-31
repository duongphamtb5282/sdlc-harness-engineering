# ADR-0005: PostgreSQL for Cost Analytics (replacing SQLite for dashboard data)

**Status:** Proposed
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)

---

## Context

The kernel currently stores all state in SQLite (`.swarm/memory.db` — 39 tables from ruflo's memory system). The future need: **a dashboard to view cost per run (tokens)**.

Current state analysis:
- SQLite holds **memory** data (trajectories, patterns, episodes) — NO cost/token data exists
- Claude Code **jsonl transcripts** DO contain usage data (input/output tokens per request)
- Ruflo's **cost-tracker plugin** already parses these into token counts + USD attribution per agent/model/task
- The cost data flows: jsonl → cost-tracker → (currently ephemeral/plugin-scoped)

**The question:** replace SQLite with PostgreSQL?

## Decision

**Do NOT replace SQLite for memory.** Keep SQLite for ruflo's operational memory (single-node, embedded, fast). **ADD PostgreSQL as a separate cost-analytics store** — a write-once, query-many warehouse:

```
CURRENT:                              PROPOSED:
┌─────────────────────┐              ┌─────────────────────┐   ┌──────────────────┐
│ Claude Code jsonl   │              │ Claude Code jsonl   │   │ Dashboard (web)  │
│ (usage per request) │              │ (usage per request) │──▶│ cost/run charts  │
└─────────┬───────────┘              └─────────┬───────────┘   │ per agent/run    │
          ▼                                    ▼               │ tokens + USD     │
┌─────────────────────┐              ┌─────────────────────┐   └──────────────────┘
│ SQLite .swarm/memory│              │ SQLite (memory)     │        ▲
│ (39 tables, no cost)│              │ (unchanged)         │        │
└─────────────────────┘              └─────────────────────┘   ┌───┴───────────┐
                                                               │ PostgreSQL    │
                                                               │ cost-analytics│
                                                               │ (new)         │
                                                               └───────────────┘
```

**Why PostgreSQL (not just upgrading SQLite):**
1. **Concurrent readers** — dashboard queries while agents write
2. **Aggregation** — GROUP BY over millions of token rows (SQLite struggles)
3. **Time-series** — cost per run/day/week/month, window functions
4. **Multi-user** — multiple developers, teams, CI runners
5. **Retention** — partition by month, prune old data

## Alternatives Considered

### Alternative 1: Keep SQLite + add tables
- **Pros:** Zero infra; same file
- **Cons:** No concurrent dashboard reads while agents write; weak aggregation on large datasets; single-machine only

### Alternative 2: Replace ruflo memory with PostgreSQL
- **Pros:** One DB
- **Cons:** Ruflo's memory system is **tuned for SQLite** (sql.js fallback, better-sqlite3 bridge, WAL handling on Intel Mac was painful). Breaking it risks the entire harness. Memory is high-write/low-query; analytics is low-write/high-query — different workloads.

### Alternative 3 (Chosen): Separate PostgreSQL cost-analytics DB
- **Pros:**
  - Memory (SQLite) untouched — harness keeps working
  - Cost data in a proper analytics store from day 1
  - Dashboard can query concurrently
  - Clean separation: operational vs analytical
- **Cons:** Two storage systems to operate; cost-tracker needs a new sink

## Consequences

### Positive
- Dashboard-ready data model (runs, token usage, costs)
- Concurrent dashboard + agents
- Time-series aggregation (per run / day / model / agent)
- Retention policies (partition + prune)

### Negative
- Requires PostgreSQL instance (local Docker or managed)
- Cost-tracker plugin needs a PostgreSQL sink (new code)
- Migration of historical cost data (jsonl backfill)

### Neutral
- Memory stays in SQLite — no harness risk

## Compliance Checklist

- [x] Workload separation justified (operational vs analytical)
- [x] Boundary Safety Pattern 1: platform primitives at boundaries (SQL for analytics, ruflo's own for memory)
- [x] Concurrent access design
- [ ] Data model designed (see architecture doc)
- [ ] Migration path defined

## Related ADRs

- ADR-0004: Progressive Skill Routing Architecture
- ADR-0002: GraphQL Client Layer
