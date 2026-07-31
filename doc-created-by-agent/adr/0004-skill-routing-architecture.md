# ADR-0004: Progressive Skill Routing Architecture

**Status:** Proposed
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)

---

## Context

The Nexus Agent Kernel has **~1,800 SKILL.md files** across 6 libraries (claude-skills 66, awesome-copilot 368, agentic-awesome 1,270, SDLC 24, software-skills 56, ruflo 20) plus stacks and supplements.

The current design embeds skill references directly in agent definition files:

```
bmad-engineer.md:  179 lines, 107 table rows, 157 skill refs
bmad-architect.md: 122 lines,  52 table rows,  69 skill refs
bmad-review.md:    105 lines,  40 table rows,  41 skill refs
```

**The problem:** every time ANY agent loads, it reads ALL its context tables — 157 skill refs for the engineer — regardless of the actual task. A "fix a typo" task makes the engineer parse 1,005 words of skill routing metadata it never uses. This is:

1. **Context waste** — ~40% of each agent's definition is routing metadata, not persona/behavior
2. **Latency** — every task pays the full read cost
3. **Maintenance burden** — adding a skill requires editing agent files
4. **Fragmentation** — routing logic scattered across ROUTING-TABLE.yaml + 8 agent files + Mode Dispatch + context tables

## Decision

Adopt a **3-tier progressive disclosure** skill routing architecture:

```
TIER 0: ROUTING-TABLE (already exists, kept)
  → pattern matching: task keywords → persona + cost tier
  → fired once at task start, ~1KB

TIER 1: AGENT STUB (slim down agent files)
  → persona identity + workflow only (no skill tables)
  → each agent keeps ONE compact "skill index card" (top 3-5 skills)
  → fired when persona adopted, ~300-500 words

TIER 2: SKILL INDEX (new — the key innovation)
  → a single machine-readable SKILL-ROUTER.yaml:
      persona → phase → category → skills
  → loaded lazily: only when the agent actually needs to look up a skill
  → fired on-demand, ~0 words for the common path

TIER 3: SKILL PROFILE (per-agent manifest)
  → generated from SKILL-ROUTER.yaml at build time
  → one small file per agent listing ONLY its applicable skills
  → the agent reads this INSTEAD of inline tables
```

## Alternatives Considered

### Alternative 1: Keep current inline tables
- **Pros:** Zero migration
- **Cons:** 157 skill refs loaded every session; doesn't scale past ~2k skills

### Alternative 2: Move everything to ROUTING-TABLE.yaml
- **Pros:** Single routing file
- **Cons:** ROUTING-TABLE would grow to 500+ lines; every agent still reads it; loses per-persona granularity

### Alternative 3: MCP-based skill server
- **Pros:** True on-demand loading, zero context cost
- **Cons:** Requires MCP server always running; adds operational dependency; overkill for static metadata

### Alternative 4 (Chosen): SKILL-ROUTER.yaml + generated per-agent profiles
- **Pros:**
  - Agent files slim to persona-only (~60% reduction)
  - Skill lookup is O(1) via index
  - Adding a skill = update index, not agent files
  - Works without MCP (pure filesystem)
  - Generated profiles guarantee consistency
- **Cons:** One-time migration cost; requires build step

## Consequences

### Positive
- Agent file size reduced ~60% (engineer: 179 → ~70 lines)
- Context cost per task reduced (~40% of agent definition)
- Single source of truth for skill routing
- Adding skills no longer touches agent files

### Negative
- Requires `generate-skill-router.py` build step
- Agents must load Tier-2 index on first skill lookup (one extra read)

### Neutral
- ROUTING-TABLE.yaml remains for task→persona mapping (Tier 0)
- Mode Dispatch in engineer stays for stack→claude-skill (Tier 2 per-stack)

## Compliance Checklist

- [x] Context waste quantified (157 refs in engineer)
- [ ] SKILL-ROUTER.yaml generated
- [ ] Agent stubs slimmed
- [ ] Per-agent profiles generated
- [ ] Validators updated

## Related ADRs

- ADR-0001: Navigation Architecture
- ADR-0002: GraphQL Client Layer
- ADR-0003: State Management
