---
name: golang-pro
description: >
  DEPRECATED — use stack-golang plugin instead. Do not load this skill.
  For Go tasks: specialist programming-languages/go + plugins/stack-golang/skills/golang-how-to
  and task-specific golang-* skills (project-layout, testing, error-handling, grpc, …).
license: MIT
metadata:
  deprecated: true
  superseded_by: plugins/stack-golang
  canonical_orchestrator: plugins/stack-golang/skills/golang-how-to
---

# Golang Pro — DEPRECATED

**Do not use this skill.** It is superseded by **`plugins/stack-golang`** (synced from `cc-skills-golang`).

## Load instead

1. **Specialist:** `${CLAUDE_PLUGIN_ROOT}/skills/_shared/specialist-skills/programming-languages/go/SKILL.md`
2. **Orchestrator:** `${CLAUDE_PLUGIN_ROOT}/plugins/stack-golang/skills/golang-how-to/SKILL.md`
3. **Default stack skills (SE):** `golang-project-layout`, `golang-testing`, `golang-error-handling`
4. **On demand:** `golang-grpc`, `golang-concurrency`, `golang-database`, `golang-benchmark`, …

Install: `claude --plugin-dir plugins/stack-golang`

## Topic mapping (old golang-pro → stack-golang)

| Former golang-pro reference | Use stack-golang skill |
|----------------------------|-------------------------|
| project-structure | `golang-project-layout`, `golang-design-patterns` |
| concurrency | `golang-concurrency`, `golang-context` |
| interfaces | `golang-structs-interfaces` |
| testing | `golang-testing` |
| generics | `golang-modernize` |

See `plugins/claude-skills-catalog/DEPRECATED-SKILLS.yaml`.
