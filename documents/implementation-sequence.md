# Implementation Sequence

Following `improvement.md` Final Coverage — 12 phases completed.

## ✅ Phase 1: Quick Wins — COMPLETE

| Step | Status | Action |
|------|--------|--------|
| 1.1 | ✅ Done | Fix `.cursor/mcp.json` github command (`aw mcp-server` → `mcp-server`) |
| 1.2 | ✅ Done | Create SKILL.md for design-system, project-management, stack-ai-ml in .cursor |
| 1.3 | ✅ Done | Copy cost-control instructions to `.cursor/instructions/` |
| 1.4 | ✅ Done | Remove empty GCP migration directory |
| 1.5 | ✅ Done | Restore ai-ml-engineer role (7 phases) |
| 1.6 | ✅ Done | Wire `user-prompt-guard.sh` into hooks.json |

## ✅ Phase 2: AWS Deduplication — COMPLETE

Removed core-skills/ (14 duplicated items) and specialized-skills/ (9 duplicated categories). 23 unique skills remaining at flat level.

## ✅ Phase 3: Cross-Plugin Skill Consolidation — COMPLETE

| Skill | From | To |
|-------|------|-----|
| jira | agent-toolkit, stack-ai-ml | project-management only |
| qa-test-planner | agent-toolkit, stack-ai-ml | project-management only |
| datadog-cli | agent-toolkit | stack-ai-ml only |
| gemini, gepetto, perplexity | agent-toolkit | stack-ai-ml only |
| prompt-engineer | claude-skills-catalog | stack-ai-ml only |
| frontend-design | stack-frontend | design-system only |

## ✅ Phase 4: GCP Expansion — COMPLETE

Added 21 missing skills across 7 categories (networking: 4, data-analytics: 3, security: 3, devops: 3, observability: 3, serverless: 3, migration: 3). Total GCP skills: 38.

## ✅ Phase 5: Cloud Plugin Content — COMPLETE

Created 5 well-architected pillars x 3 clouds = 15 files, 3 templates x 3 clouds = 9 files, 2 verify scripts x 3 clouds = 6 files.

## ✅ Phase 6: .cursor Sync — COMPLETE

Synced stack-ai-ml, system-design, staff-engineer, stack-golang, stack-frontend, sdlc-workflows, agent-toolkit, GCP, plus all cloud content.

## ✅ Phase 7: Agent Roles — COMPLETE

Created dotnet-engineer (5 phases) + cloud-architect (3 phases).

## ✅ Phase 8: Mobile Plugin — COMPLETE

Created stack-mobile plugin (skills: react-native, flutter, swift-ios, kotlin-android, mobile-cicd) + mobile-engineer role (6 phases).

## ✅ Phase 9: TypeScript & Vercel — COMPLETE

Created typescript-tooling, typescript-monorepo, typescript-testing, nextjs-app-router, nextjs-auth, react-server-components, react-state-management skills.

## ✅ Phase 10: Framework Skills — COMPLETE

Created stack-nestjs plugin (5 skill areas: fundamentals, auth-security, graphql, microservices, database). Registered all 19 plugins in plugin.json.

## ✅ Phase 11: Discovery & Spec-Driven — COMPLETE

Added spec-driven.yaml workflow, synced reverse.md and spec-driven-development to .cursor.

## ✅ Phase 12: Validation — COMPLETE

0 validation errors.

## ✅ Phase 13: MUST PORT Items — COMPLETE

| # | Item | Source | Size | Status |
|---|------|--------|------|--------|
| 1 | **Production Grade Plugin** | `new-skills/claude-code-production-grade-plugin/` | 108 files | ✅ Ported to `plugins/production-grade/` |
| 2 | **.NET Skills** | `new-skills/net-skills/plugins/` (17 plugins) | 326 files | ✅ Ported to `plugins/stack-dotnet/skills/` |
| 3 | **General Agent Skills** | `new-skills/agent-skills-general/` | 30 files | ✅ Ported to `plugins/general-skills/skills/` (24 skills) |
| 4 | **Reference Maps** | Old `.claude/plugins/` | 3 files | ✅ Copied AGENT-SKILL-MAP.yaml, PLUGIN-AGENT-MAP.yaml, REFERENCE-MAP.yaml |
| 5 | **.cursor Missing Plugins** | 8 plugins | 8 synced | ✅ All major plugins now in `.cursor/plugins/` (20 total) |
| 6 | **Plugin Registration** | 3 new plugins | 22 total | ✅ production-grade, stack-dotnet, general-skills registered in plugin.json |
| 7 | **SETUP-GUIDE.md Updated** | Plugin listing + registration | Updated | ✅ Added new plugins to documentation |

### Final Structure
- **.claude/**: 6,803 files | **.cursor/**: 9,626 files | **Total**: 16,429 files
- **Plugins**: 23 registered
- **Agent roles**: 19
- **Workflows**: 12
- **MCP configs**: 5

## ✅ Phase 14: MEDIUM Priority — COMPLETE

| # | Item | Source | Result |
|---|------|--------|--------|
| 6 | **NestJS Deep Skills** | `new-skills/agent-nestjs-skills/` | 42 rule files ported to `plugins/stack-nestjs/rules/` |
| 7 | **stack-aws .cursor cleanup** | 944→466 files | Removed 478 duplicate files, aligned with .claude |
| 8 | **Java Skills** | `new-skills/claude-code-java/` | 88 files ported to new `plugins/stack-java/` |
| 9 | **Code Review Skill** | `new-skills/code-review-skill/` | 43 files to `plugins/delivery-toolkit/skills/code-review-deep/` |

## ✅ Phase 15: LOW Priority — COMPLETE

| # | Item | Source | Result |
|---|------|--------|--------|
| 10 | **Claude Code Templates** | `new-skills/claude-code-templates/` | 64 MCP configs ported to `templates/mcp/claude-code/` |
| 11 | **Startup Plugins** | `sample-claude-code-plugins/` | Skipped (reference only) |
| 12 | **Awesome Copilot** | `awesome-copilot/` | Already ported ✅ |

### Grand Final
- **Total files**: 16,429 | **All gaps closed** | **All phases complete**
|------|--------|--------|
| 1.1 | ✅ Done | Fix `.cursor/mcp.json` github command (`aw mcp-server` → `mcp-server`) |
| 1.2 | ✅ Done | Create SKILL.md for design-system, project-management, stack-ai-ml in .cursor |
| 1.3 | ✅ Done | Copy cost-control instructions to `.cursor/instructions/` |
| 1.4 | ✅ Done | Remove empty GCP migration directory |
| 1.5 | ⏳ Pending | Verify ai-ml-engineer role complete (restore phase files) |
| 1.6 | ✅ Done | Wire `user-prompt-guard.sh` into hooks.json |

## ⏳ Phase 2: AWS Deduplication (Day 2)

Remove core-skills/ and specialized-skills/ duplicate directories from stack-aws.

## ⏳ Phase 3: Cross-Plugin Skill Consolidation (Day 3-4)

| Skill | From | To |
|-------|------|-----|
| jira | agent-toolkit, stack-ai-ml | project-management only |
| qa-test-planner | agent-toolkit, stack-ai-ml | project-management only |
| datadog-cli | agent-toolkit | stack-ai-ml only |
| gemini, gepetto, perplexity | agent-toolkit | stack-ai-ml only |
| prompt-engineer | claude-skills-catalog | stack-ai-ml only |
| frontend-design | stack-frontend | design-system only |

## ⏳ Phase 4: GCP Expansion (Day 5-7)

Add 21 missing GCP skills across 7 categories.

## ⏳ Phase 5: Cloud Plugin Content (Day 8-9)

Create well-architected/, templates/, verify/ for AWS, Azure, GCP.

## ⏳ Phase 6: .cursor Sync (Day 10-12)

Sync all plugins + agent definitions to .cursor.

## ⏳ Phase 7: Agent Roles (Day 13)

Create dotnet-engineer + cloud-architect roles.

## ⏳ Phase 8: Mobile Plugin (Day 14-16)

Create stack-mobile + mobile-engineer role.

## ⏳ Phase 9: TypeScript & Vercel (Day 17-18)

Enhance TS tooling, monorepo, testing + Vercel skills.

## ⏳ Phase 10: Framework Skills (Day 19-21)

Create stack-nestjs, enhance Next.js App Router, React RSC.

## ⏳ Phase 11: Discovery & Spec-Driven (Day 22-23)

Add spec-driven.yaml workflow + .cursor sync.

## ⏳ Phase 12: Validation (Day 24)

Run validate-skill.sh, fix issues, final audit.
