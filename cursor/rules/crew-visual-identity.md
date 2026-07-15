<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Visual Identity — Design Language

**Aesthetic: Clear · Informative · Structured · Dynamic**

Claude Code renders agent output as markdown in a chat panel. Design for readability in a proportional-font GUI, not monospace CLI alignment. Every visual element earns its place through information, not decoration.

---

## Principles

1. **Information Is the Aesthetic** — Never print a line that doesn't carry information. Beauty comes from data density organized with clarity.
2. **Earned Elevation** — Visual weight must match informational weight. Reserve heavy formatting for genuinely important moments. 
3. **State Must Be Visible** — The user should always know: where they are, what's happening now, and what's next.
4. **Concrete Over Vague** — Never say "analysis complete." Say "analyzed 247 files across 3 services, 12 endpoints." 

---

## Icon Vocabulary

| Icon | Meaning | Usage |
|------|---------|-------|  
| `◆` | Brand mark | Pipeline header only |
| `⬥` | Gate marker | Gate ceremony headers only |
| `●` | Active / running | Agent or phase currently executing |
| `○` | Pending / queued | Agent or phase not yet started |
| `✓` | Complete / success | Step, agent, or phase finished successfully |
| `✗` | Failed / error | Step, agent, or phase failed |
| `⧖` | In progress | Active work step (inside a skill's own output) |
| `⚠` | Warning / degraded | Non-blocking issue, degraded input |
| `→` | Flow / transition | "Starting next phase", handoff indicators |
| `·` | Separator | Inline metric separation: `12 used · 22 completed` | 

**Never mix icons.** `●` is always "running." `✓` is always "done." No synonyms, no alternatives.

---

## Output Tiers

### Tier 1 — Heavy Rule `━━━` (Phase & Skill Headers)  

Used for: phase headers, skill-level section headers, findings summaries. 

```
━━━ Software Engineer ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [1/5] Context & Architecture
    ✓ Read 4 ADRs, 3 API specs, 1 ERD 
    ✓ Identified 4 services, 12 endpoints

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
```

### Tier 2 — Markdown Formatting (Wave Announcements & Status Blocks)

Use bold headers and indented lists instead of ASCII box-drawing characters. Box-drawing characters (`┌─┐`, `╔═╗`) rely on monospace alignment that breaks in proportional-font rendering.

**Do this:** 

```
**Wave A — 6 agents running in parallel**

  ✓ Software Engineer           4 services, 12 endpoints
  ✓ Software Engineer [frontend] 4 page groups, 23 components
  ● Quality Engineer             running...
  ○ Compliance Engineer          pending 
  ○ Software Engineer [review]   pending 
  ○ Platform Engineer            pending 

  2/6 complete
```

---

## Completion Summaries

Every agent completion line MUST include at least one number:

``` 
  ✓ Software Engineer    4 services, 12 endpoints, 2847 lines       ⏱ 3m 41s
  ✓ Compliance Engineer  12 findings (2 Critical, 3 High, 7 Medium)  ⏱ 2m 05s
  ✓ Quality Engineer     147 tests written, 145 passing, 2 failing   ⏱ 1m 23s
```

---  

## Review Ceremony Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⬥ INCEPTION GATE — Architecture Review            ⏱ 3m 12s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 

  Pattern      Modular monolith with event-driven boundaries 
  Stack        TypeScript · NestJS · PostgreSQL · Redis
  Services     4 bounded contexts 
  ADRs         4 architecture decision records

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
```

---  

## Findings Block  

```
  Critical   2    SQL injection in user input handler
                  Hardcoded API key in config.ts
  High       5    Missing rate limiting (3), broken auth check (2)
  Medium     8    —
  Low        3    —
  ─────────────
  Total     18    deduplicated by file:line
```

---

## Anti-Patterns — Never Do These

| Anti-Pattern | Do Instead |
|-------------|-----------|
| Box-drawing characters (`┌─┐`, `╔═╗`) in chat output | Use markdown bold headers + indented lists |
| `✓ Analysis complete` | `✓ Analyzed 247 files, found 12 issues` | 
| Timing on every single step | Time phases, waves, totals only | 
| Box inside a box | One container level per context |
| Decorative separators with no informational content | The data IS the aesthetic |
