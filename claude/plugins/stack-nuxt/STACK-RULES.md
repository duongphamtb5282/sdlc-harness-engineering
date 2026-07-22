# stack-nuxt — precedence

> **Audience:** Frontend Engineer, Software Engineer.
> **Precedence:** protocols → tech-stack.yaml → **stack-nuxt** → stack-vue (Vue fundamentals) → do not load stack-frontend React skills for `.vue` work.

## Detect first

| Signal | Load |
|--------|------|
| `nuxt.config.*` | `nuxt` (+ `nuxt-ui` / `nuxt-content` / `nuxthub` as needed) |
| VueUse composables | `vueuse` |
| Vite-only Vue (no Nuxt) | Prefer **stack-vue**; use `vite` / `vitest` from here if helpful |
| Auth with Better Auth | `nuxt-better-auth` |

## Overlap with stack-vue

| Topic | Prefer |
|-------|--------|
| Vue Composition API / SFC style | `stack-vue/vue-best-practices` |
| Nuxt routing, server routes, Nitro | `stack-nuxt/nuxt` |
| Pinia / Vue Router (SPA) | `stack-vue` |
| Testing Vue components | `stack-vue/vue-testing-best-practices` or `stack-nuxt/vitest` |

## Conflicts

- Nuxt file-based routing wins over manual Vue Router setup inside Nuxt apps.
- Do not apply Next.js / React `stack-frontend` skills to Nuxt projects.
