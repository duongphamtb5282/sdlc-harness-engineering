# stack-vue — precedence

> **Audience:** Frontend Engineer, Software Engineer, Quality Engineer.
> **Precedence:** protocols → agent phases → tech-stack.yaml → packs → **stack-vue** → stack-nuxt (if Nuxt) → stack-frontend (React only).

## Detect first

| Signal | Load |
|--------|------|
| `*.vue` + Vite, no Nuxt | `vue-best-practices` (+ router/pinia/testing as needed) |
| `nuxt.config.*` | Prefer **stack-nuxt** first, then stack-vue for Vue fundamentals |
| Options API legacy | `vue-options-api-best-practices` only when project requires it |
| Pinia stores | `vue-pinia-best-practices` |
| Vue Router | `vue-router-best-practices` |

## Conflicts

- Default to **Composition API + `<script setup>` + TypeScript** (`vue-best-practices`).
- Do not mix Options API patterns into Composition API greenfield work.
- When both React and Vue packs exist (polyglot), route by `paths.frontend` / file extension.
