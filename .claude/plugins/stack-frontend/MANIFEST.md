# stack-frontend — skill manifest

Canonical runtime path: `plugins/stack-frontend/skills/`

Synced via `./scripts/sync-from-new-skills.sh` from two reference repos (merge, not replace):

| Source | Role |
|--------|------|
| `new-skills/claude-code-nextjs-skills` | Next.js, React, shadcn, AI SDK, SEO, cache components |
| `new-skills/agent-skills-frontend` | Vercel Labs — performance, composition, view transitions, deploy, docs voice |

## Skills (28)

### Next.js / React (claude-code-nextjs-skills)

| Skill | Use when |
|-------|----------|
| next-best-practices | App Router, RSC, data patterns |
| react-best-practices | React/Next performance (40+ rules) — **overlaid by Vercel Labs** |
| shadcn | shadcn/ui components |
| cache-components | Next.js cache components |
| nextjs-chatbot | AI chatbot patterns |
| nextjs-seo | SEO metadata |
| nextjs-shadcn | Next + shadcn scaffold |
| frontend-design | UI layout and visual design |
| chrome-devtools | Browser debugging (QE) |
| ai-app, ai-elements, ai-sdk, ai-sdk-6 | AI frontend |
| postgres-semantic-search | RAG / semantic search UI |
| supabase-postgres-best-practices | Supabase + Postgres |
| openai-agents-sdk | OpenAI agents SDK |
| web-design-guidelines | UI/a11y audit — **overlaid by Vercel Labs** |
| skill-creator | Author new skills |
| go, handoff, hetzner-cloud | Adjacent tooling |

### Vercel Labs (agent-skills-frontend)

| Skill | Agent routing |
|-------|---------------|
| composition-patterns | SE frontend, code-reviewer, SA (component architecture) |
| react-view-transitions | SE nextjs, code-reviewer nextjs |
| react-native-skills | SE mobile / React Native |
| vercel-optimize | PE when Vercel cost/performance |
| deploy-to-vercel | PE when Vercel preview deploy |
| vercel-cli-with-tokens | PE with Vercel CLI |
| writing-guidelines | Technical writer |

## Agent map

Full routing: [AGENT-SKILL-MAP.yaml](../AGENT-SKILL-MAP.yaml) → `agents.software-engineer`, `code-reviewer`, `quality-engineer`, `technical-writer`, `platform-engineer`.
