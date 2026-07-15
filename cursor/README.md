# SDLC Agents — Cursor project

Standalone **Cursor** packaging of the SDLC delivery agents, skills, packs, and stack plugins.

This is a **separate project from Claude Code**. There is no `.claude-plugin/`, no `claude-agents/`, and no `new-skills/` shelf.

## Use as its own git repository

```bash
cd cursor
git init
git add .
git commit -m "Initial Cursor SDLC agents project"
git remote add origin git@github.com:YOUR_ORG/sdlc-agents-cursor.git
git push -u origin main
```

Or copy this folder elsewhere first:

```bash
cp -a cursor /path/to/sdlc-agents-cursor
cd /path/to/sdlc-agents-cursor
git init && git add . && git commit -m "Initial import"
```

Open the folder in Cursor (`File → Open Folder`). Skills and rules load from `.cursor/`.

## Layout

| Path | Purpose |
|------|---------|
| `.cursor/rules/*.mdc` | Cursor rules (always-on / glob-scoped) |
| `.cursor/skills/*` | Real copies of skills (no symlinks — safe to move to another git repo) |
| `agents/{role}/` | Canonical delivery roles (14) |
| `skills/sdlc-automation-agent/` | Orchestrator |
| `skills/_shared/` | Protocols, templates, specialist skills |
| `packs/` | Stack verify commands + CI snippets |
| `plugins/` | Stack / workflow / toolkit skills |
| `rules/` | Source markdown for rules (mirrored to `.cursor/rules/`) |
| `docs/` | Architecture & usage docs |
| `hooks/`, `scripts/` | Optional automation |

## Quick start in Cursor

1. Open this repository as the workspace.
2. Ask in natural language, e.g. “Build a Spring Boot + Next.js SaaS on AWS”.
3. Prefer skill **`sdlc-automation-agent`**, or name a role (`solution-architect`, `software-engineer`, …).
4. Declare stack in the product repo via `docs/architecture/tech-stack.yaml` → `packs.*` / `verify.*`.

## Delivery roles

See `agents/AGENTS-ROSTER.md` and `AGENTS.md`.

| Skill | Role |
|-------|------|
| `sdlc-automation-agent` | Orchestrator |
| `product-manager` | Requirements / specs |
| `solution-architect` | ADRs, SAD, tech stack |
| `software-engineer` | Backend implementation |
| `frontend-engineer` | React / Next.js |
| `data-scientist` | AI/ML |
| `quality-engineer` | Tests |
| `devops` | CI/CD, Docker, IaC |
| `sre` | SLOs, runbooks |
| `platform-engineer` | Coordinates devops + sre |
| `security-engineer` | Security (alias: `compliance-engineer`) |
| `code-reviewer` | Review |
| `technical-writer` | Docs |
| `research-advisor` | Brownfield discovery |

## Packs

```yaml
# docs/architecture/tech-stack.yaml (in the product repo)
packs:
  language: java-spring    # packs/languages/java-spring
  frontend: nextjs
  cloud: aws               # packs/clouds/aws + plugins/stack-aws
verify:
  test: "./gradlew test"
  build: "./gradlew bootJar"
```

## Sync to a product repo (e.g. seat-reservation)

Copy this entire `cursor/` folder into the product as `<product>/cursor/`:

```bash
./scripts/sync-to-product.sh /path/to/seat-reservation
```

Then **activate** for Cursor IDE (installs rules + skills into the product root):

```bash
cd /path/to/seat-reservation
bash cursor/scripts/install-into-workspace.sh          # curated skills (default)
bash cursor/scripts/install-into-workspace.sh --full   # all skills
```

Product-specific overlays live in `overlays/seat-reservation/` (tech-stack, project skills, rules).

## Notes

- `.cursor/skills/` are **real directories** (no symlinks). You can `cp -R` or push this folder as its own git repo without broken links.
- Canonical sources also remain under `agents/`, `skills/`, and `plugins/` for reference and packs routing.
- Do not add `new-skills/` — reference-only upstream, not runtime.
- Refresh from the parent agents monorepo (maintainers only): re-run the mirror, then re-copy skills into `.cursor/skills/` (do not use symlinks).
