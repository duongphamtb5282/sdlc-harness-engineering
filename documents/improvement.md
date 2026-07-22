# Enhancement Improvement Plan

> **Date:** 2026-07-20  
> **Audit of:** `enhancement/.claude/` and `enhancement/.cursor/`  
> **Total files audited:** 11,623  

---

## Table of Contents

1. [Critical Issues](#1-critical-issues)
2. [Skill Overlaps & Merge Proposals](#2-skill-overlaps--merge-proposals)
3. [GCP Incompleteness](#3-gcp-incompleteness)
4. [Cloud Plugin Empty Stubs](#4-cloud-plugin-empty-stubs)
5. [.cursor/ Gaps](#5-cursor-gaps)
6. [Missing Agent Roles](#6-missing-agent-roles)
7. [Quick Wins](#7-quick-wins)
8. [Implementation Roadmap](#8-implementation-roadmap)

---

## 1. Critical Issues

### 1.1 AWS Internal Skill Duplication

**Problem:** `stack-aws/skills/` has massive internal duplication:

```
stack-aws/skills/
├── amazon-bedrock/             ← original
├── aws-cdk/                    ← original
├── core-skills/                ← DUPLICATE: mirrors all top-level skills
│   ├── amazon-bedrock/         ← same content
│   ├── aws-cdk/                ← same content
│   └── ...
├── specialized-skills/         ← DUPLICATE: mirrors all category skills
│   ├── analytics-skills/       ← same as analytics-skills/ below
│   ├── database-skills/        ← same as database-skills/ below
│   └── ...
├── analytics-skills/           ← original
├── database-skills/            ← original
├── ...
```

Each leaf skill exists in **2 physical locations** with identical SKILL.md content. This is the single biggest cleanup item.

**Fix:** Flatten to single-level structure. Remove `core-skills/` and `specialized-skills/` subdirectories. Keep only one copy of each skill.

```bash
# Before: /skils/core-skills/amazon-bedrock/ + /skills/amazon-bedrock/
# After:  /skills/amazon-bedrock/  (only one copy)
```

### 1.2 Cross-Plugin Skill Overlaps

| Skill | Appears In | Recommended Home | Rationale |
|-------|-----------|-----------------|-----------|
| `jira` | agent-toolkit, project-management, stack-ai-ml | **project-management** | PM is the canonical home |
| `qa-test-planner` | agent-toolkit, project-management, stack-ai-ml | **project-management** | QA planning is PM-adjacent |
| `datadog-cli` | agent-toolkit, stack-ai-ml | **stack-ai-ml** | Observability is AI/ML context |
| `gemini` | agent-toolkit, stack-ai-ml | **stack-ai-ml** | AI model belongs with AI skills |
| `gepetto` | agent-toolkit, stack-ai-ml | **stack-ai-ml** | AI tool, keep with AI |
| `perplexity` | agent-toolkit, stack-ai-ml | **stack-ai-ml** | AI search, keep with AI |
| `prompt-engineer` | claude-skills-catalog, stack-ai-ml | **stack-ai-ml** | stack-ai-ml version is richer (131 skills set) |
| `frontend-design` | design-system, stack-frontend | **design-system** | Design system is the canonical home |

**Action per skill:**
1. Keep the **recommended home** version
2. Remove duplicates from other plugins
3. Or replace duplicates with a symlink/reference: `see plugins/design-system/skills/frontend-design`

### 1.3 .cursor mcp.json Typo

**File:** `enhancement/.cursor/mcp.json`

```json
"github": {
  "command": "gh",
  "args": ["aw", "mcp-server"],  // ← "aw" is likely a typo
}
```

**Fix:** Remove `"aw"` from args. The correct GitHub MCP server invocation is `gh mcp-server` or through the `gh` CLI's built-in extension mechanism.

---

## 2. Skill Overlaps & Merge Proposals

### 2.1 Merge: Duplicate Skills → Single Canonical Location

| Skill Group | Merge Strategy | Target Plugin | Skills Affected |
|------------|---------------|---------------|----------------|
| **Jira skills** | Consolidate all 3 copies into one | `project-management` | jira (was in agent-toolkit, stack-ai-ml, project-management) |
| **QA planning** | Consolidate into PM | `project-management` | qa-test-planner |
| **AI tools** | Keep in AI plugin only | `stack-ai-ml` | datadog-cli, gemini, gepetto, perplexity |
| **Prompt engineer** | Keep richer version | `stack-ai-ml` | prompt-engineer (stack-ai-ml version supersedes claude-skills-catalog) |
| **Frontend design** | Keep in design system | `design-system` | frontend-design (remove from stack-frontend) |

### 2.2 Merge: Generic Skills Across Plugins

These skills have similar themes but different content — worth reviewing for dedup:

| Skill | Found In | Notes |
|-------|---------|-------|
| `security-reviewer` | claude-skills-catalog | Generic — use security-engineer role instead |
| `rag-architect` | claude-skills-catalog | Superseded by stack-ai-ml/rag-* skills (7 skills) |
| `code-review-and-quality` | sdlc-workflows, .cursor/skills | Generic — use code-reviewer role instead |
| `test-driven-development` | sdlc-workflows, .cursor/skills | Generic — use quality-engineer role |
| `test-master` | claude-skills-catalog | Generic — use quality-engineer role |
| `ml-pipeline` | claude-skills-catalog | Superseded by stack-ai-ml/ (131 skills covering full ML lifecycle) |
| `fine-tuning-expert` | claude-skills-catalog | Superseded by stack-ai-ml/fine-tuning-* (4 skills) |
| `mcp-developer` | claude-skills-catalog | Keep in claude-skills-catalog (MCP is cross-cutting) |

**Recommendation:** Replace generic catalog skills with cross-references:
```markdown
> This skill is superseded by `stack-ai-ml`. See `plugins/stack-ai-ml/skills/` for the complete AI/ML skill set.
```

### 2.3 Merge: Stack Plugins → Unified Plugin with Categories

Current state: Skills are scattered across `stack-spring/`, `stack-vue/`, `stack-nuxt/`, `stack-golang/`, `stack-frontend/`.

**Proposal:** Keep current structure but add a **technology index** that maps all stack skills by category:

```
.claude/plugins/
├── TECH-INDEX.md          ← NEW: cross-reference of all tech skills
├── stack-spring/
├── stack-vue/
├── stack-nuxt/
├── stack-golang/
├── stack-frontend/
├── stack-aws/
├── stack-azure/
├── stack-gcp/
└── stack-ai-ml/
```

`TECH-INDEX.md` would contain:
```markdown
# Technology Skill Index

## Frontend
| Skill | Plugin | Stack |
|-------|--------|-------|
| Vue | `stack-vue` | Vue 3 |
| Nuxt | `stack-nuxt` | Nuxt 3 |
| React | `claude-skills-catalog` | React 19 |
| Frontend Design | `design-system` | Cross-cutting |

## Backend
| Skill | Plugin | Stack |
|-------|--------|-------|
| Spring Boot | `stack-spring` | Java 21+ |
| NestJS | `claude-skills-catalog` | Node.js 22+ |
| FastAPI | `claude-skills-catalog` | Python 3.12+ |

## Cloud
| Skill | Plugin | Provider |
|-------|--------|----------|
| Compute | `stack-aws` | AWS EC2, Lambda, ECS, EKS |
| Compute | `stack-azure` | Azure VMs, Functions, AKS |
| Compute | `stack-gcp` | GCP Compute Engine, Cloud Run, GKE |
```

---

## 3. GCP Incompleteness

### 3.1 Missing Skills

GCP has only **16 of ~37 planned skills** (43% complete). Missing:

| Category | Current | Needed | Missing Skills |
|----------|---------|--------|---------------|
| `networking/` | 1 | 4 | `vpc/`, `cloud-cdn/`, `cloud-dns/`, `cloud-nat/` |
| `data-analytics/` | 2 | 5 | `dataflow/`, `dataproc/`, `data-fusion/` |
| `security-identity/` | 1 | 4 | `cloud-kms/`, `security-command-center/`, `certificate-authority/` |
| `devops-cicd/` | 1 | 4 | `cloud-deploy/`, `cloud-source-repositories/`, `artifact-registry/` |
| `observability/` | 1 | 4 | `cloud-logging/`, `cloud-trace/`, `cloud-profiler/` |
| `serverless/` | 1 | 4 | `eventarc/`, `workflows/`, `app-engine/` |
| `migration/` | 0 | 3 | `migrate-to-gcp/`, `transfer-appliance/`, `database-migration-service/` |
| **Total** | **16** | **37** | **21 missing** |

### 3.2 Fix Strategy

Create each missing skill with a minimal SKILL.md following the template:

```markdown
# {Service Name}

{One-paragraph description of the GCP service}.

## Key Concepts
- {Concept 1}
- {Concept 2}
- {Concept 3}

## Common Patterns
- {Pattern 1}
- {Pattern 2}
- {Pattern 3}

## Reference
- [{Service} docs](https://cloud.google.com/{service}/docs)
```

---

## 4. Cloud Plugin Empty Stubs

All 3 cloud plugins have unused placeholder directories:

| Location | Directory | Status |
|----------|-----------|--------|
| `stack-aws/` | `well-architected/` | Empty |
| `stack-aws/` | `templates/` | Empty |
| `stack-aws/` | `verify/` | Empty |
| `stack-azure/` | `well-architected/` | Empty |
| `stack-azure/` | `templates/` | Empty |
| `stack-azure/` | `verify/` | Empty |
| `stack-gcp/` | `well-architected/` | Empty |
| `stack-gcp/` | `templates/` | Empty |
| `stack-gcp/` | `verify/` | Empty |

### 4.1 What to populate

**well-architected/** — One file per WAF pillar:

```
well-architected/
├── operational-excellence.md    # Operations, monitoring, incident response
├── security.md                  # Identity, encryption, compliance
├── reliability.md               # HA, DR, backup, failover
├── performance-efficiency.md    # Right-sizing, caching, CDN
└── cost-optimization.md         # Reserved instances, spot, autoscaling
```

**templates/** — Deployment templates:

```
templates/
├── serverless-app/              # Lambda/Cloud Functions/Function Apps
├── container-microservice/      # ECS/AKS/GKE + CI/CD
└── web-application/             # ALB/App Gateway/LB + compute
```

**verify/** — Cloud verification scripts:

```
verify/
├── terraform-validate.sh        # terraform fmt + validate + plan
├── cloud-cost-check.sh          # Budget alert verification
└── security-baseline.sh         # CIS benchmark checks
```

---

## 5. .cursor/ Gaps

### 5.1 Missing Plugins (14 of 17)

| Missing Plugin | Skills Count | Severity | Action |
|---------------|-------------|----------|--------|
| `stack-ai-ml` | ~145 | **Critical** | Sync from `.claude/plugins/stack-ai-ml/skills/` |
| `delivery-toolkit` | 6 sub-plugins | High | Sync code-review, feature-dev, plugin-dev, PR review |
| `stack-golang` | 43 | High | Go developers need these |
| `system-design` | 22 | High | Architects need these |
| `staff-engineer` | 14 | Medium | Staff+ engineers use these |
| `agent-toolkit` | 43 | Medium | Nice-to-have utilities |
| `sdlc-workflows` | 24 | Medium | Workflow automation |
| `claude-skills-catalog` | 66 | Low | Reference — most skills have better alternatives |
| `stack-frontend` | 27 | Low | Most frontend skills already in .cursor/skills/ |

### 5.2 Missing SKILL.md Files

| Directory | Fix |
|-----------|-----|
| `.cursor/skills/design-system/` | Create `SKILL.md` that cross-references `.claude/plugins/design-system/` |
| `.cursor/skills/project-management/` | Create `SKILL.md` that cross-references `.claude/plugins/project-management/` |
| `.cursor/skills/stack-ai-ml/` | Create `SKILL.md` that cross-references `.claude/plugins/stack-ai-ml/` |

Each should contain:
```markdown
---
name: design-system
description: UI/UX design skills — Figma integration, design tokens, component libraries
---

# Design System Skills

Refer to `.claude/plugins/design-system/skills/` for the full skill set.

Available skills:
- figma
- figma-implement-design
- frontend-design
- ui-design-system
```

### 5.3 Empty Instructions Directory

`.cursor/instructions/cost-control/` exists but has no files.

**Fix:** Copy `model-routing.instructions.md` from `.claude/instructions/cost-control/` into `.cursor/instructions/cost-control/`.

### 5.4 Missing Language Packs

`.cursor/packs/` has clouds/ but no languages/:

| Missing | Skills Affected |
|---------|----------------|
| `packs/languages/dotnet/` | .NET verification |
| `packs/languages/go/` | Go verification |
| `packs/languages/java-spring/` | Spring Boot verification |
| `packs/languages/nodejs-nestjs/` | NestJS verification |

---

## 6. Missing Agent Roles

### 6.1 dotnet-engineer

The design document lists `dotnet-engineer` as an agent role, but it was never created in `enhancement/`.

**Fix:** Create `/agent-roles/dotnet-engineer/` with:

```
dotnet-engineer/
├── agent.md              # Role definition
├── README.md
├── modes/
│   ├── build.md
│   ├── test.md
│   ├── migrate.md
│   └── debug.md
└── phases/
    ├── 01-setup.md
    ├── 02-implement.md
    ├── 03-test.md
    ├── 04-package.md
    └── 05-deploy.md
```

**Note:** Skills already exist in `stack-dotnet/` (ported from `net-skills`), but the role itself doesn't exist.

### 6.2 AWS-specific roles

Detected: `aws-architect`, `aws-devops-engineer`, `aws-security-specialist` in `stack-aws/agent-definitions/`.

These should be registered as proper agent roles under `agent-roles/`:
```
agent-roles/cloud-architect/
├── agent.md              # References AWS, Azure, GCP architect definitions
├── modes/
│   ├── aws-architect.md
│   ├── azure-architect.md
│   └── gcp-architect.md
└── phases/
    ├── 01-cloud-assessment.md
    ├── 02-well-architected.md
    └── 03-migration-planning.md
```

---

## 7. Quick Wins

These can be fixed in minutes and have high impact:

| # | Fix | Effort | Impact |
|---|-----|--------|--------|
| 1 | Fix `gh aw mcp-server` → `gh mcp-server` in `.cursor/mcp.json` | 1 min | Prevents GitHub MCP failure |
| 2 | Create SKILL.md for `.cursor/skills/design-system/` | 5 min | Makes design skills loadable in Cursor |
| 3 | Create SKILL.md for `.cursor/skills/project-management/` | 5 min | Makes PM skills loadable in Cursor |
| 4 | Create SKILL.md for `.cursor/skills/stack-ai-ml/` | 5 min | Makes AI/ML skills loadable in Cursor |
| 5 | Copy cost-control instructions to `.cursor/instructions/` | 2 min | Enables cost routing in Cursor |
| 6 | Remove empty `migration/` directory from GCP | 1 min | Cleanup |
| 7 | Restore ai-ml-engineer agent role files | 3 min | Critical role was missing |
| 8 | Wire `user-prompt-guard.sh` in hooks.json | 5 min | Restores safety prompt scanning |
| 9 | Remove duplicate `UserPromptSubmit` in cost-controller/hooks.json | 2 min | Prevents double-firing classify-task.sh |
| 10 | Register all 17 plugins in plugin.json | 5 min | Makes all plugins discoverable |

---

## 8. Additional Structural Issues

### 8.1 Agent Role Gaps

| Issue | Impact | Fix |
|-------|--------|-----|
| `code-reviewer` missing `phases/` | No delivery phases defined for code review | Create `phases/` with scan → verify → report |
| `research-advisor` missing `phases/` | No delivery phases defined for research | Create `phases/` with discover → analyze → recommend |
| `ai-ml-engineer/phases/` empty dir | Phases exist as separate files not in the expected dir | Clean up directory structure |
| `ai-ml-engineer/modes/` empty dir | Modes dir exists with no content | Remove empty dir or add mode definitions |
| `agents/ai-ml-engineer.md` missing | No agent stub (all other 14 roles have one) | Create minimal stub |
| `research-advisor` uses `reference/` (singular) | Inconsistent with all roles using `references/` (plural) | Rename to `references/` |
| Thin agent.md files (<400 bytes) | data-scientist, devops, frontend-engineer, sre | Expand to match other roles |
| `AGENTS-ROSTER.md` missing | Referenced in docs but not on disk | Create from existing agent list |

### 8.2 Hook Wiring Issues

| Issue | Detail | Fix |
|-------|--------|-----|
| `user-prompt-guard.sh` never called | Main `hooks.json` wires `UserPromptSubmit` → `classify-task.sh`. The old `user-prompt-guard.sh` is orphaned. | Chain both scripts in order: classify-task.sh then user-prompt-guard.sh |
| Duplicate `UserPromptSubmit` hook | Both `hooks/hooks.json` and `hooks/cost-controller/hooks.json` register `UserPromptSubmit` → `classify-task.sh` | Remove the duplicate from `cost-controller/hooks.json` |
| No `PostToolUse` for `Read` | Read operations aren't audited | Add `Read` to PostToolUse matcher pattern |

### 8.3 Plugin Registration

**Problem:** `plugin.json` only references 6 of 17 plugins:

```json
"plugins": [
  "./plugins/stack-aws",
  "./plugins/stack-azure",
  "./plugins/stack-gcp",
  "./plugins/stack-ai-ml",
  "./plugins/design-system",
  "./plugins/project-management"
]
```

**Missing:** agent-toolkit, claude-skills-catalog, delivery-toolkit, sdlc-workflows, stack-frontend, stack-golang, stack-nuxt, stack-spring, stack-vue, staff-engineer, system-design

**Fix:** Add all unregistered plugins that have `.claude-plugin/` directories. For those without, create minimal manifests or use root-skill resolution.

### 8.4 Eng Tools Gaps

| Missing Tool | Purpose | Action |
|-------------|---------|--------|
| `eng/skill-coverage/` | Domain coverage analysis | Create script to inventory all skills by category |
| `eng/sync-to-cursor/` | .claude → .cursor sync | Create sync pipeline script |

### 8.5 Template Gaps

4 of 7 template directories are empty:

### 8.6 Mobile Development: Major Gap

**Current state:** Mobile skills are scattered and thin. No dedicated mobile plugin or agent role exists.

| Platform | Current in Enhancement | Available in Reference (new-skills/) |
|----------|----------------------|-------------------------------------|
| **React Native** | `claude-skills-catalog/skills/react-native-expert` (generic), `stack-frontend/skills/react-native-skills` (basic) | `new-skills/agent-skills-frontend/skills/react-native-skills/` (richer version), `new-skills/claude-skills/skills/react-native-expert/` |
| **Flutter** | `claude-skills-catalog/skills/flutter-expert` (only 1 skill) | `new-skills/claude-skills/skills/flutter-expert/` |
| **Swift/iOS** | `claude-skills-catalog/skills/swift-expert`, `_shared/specialist-skills/programming-languages/swift/`, `stack-aws/skills/aws-sdk-swift-usage` | `new-skills/awesome-copilot/plugins/swift-mcp-development/`, `new-skills/claude-skills/skills/swift-expert/` |
| **Kotlin/Android** | `claude-skills-catalog/skills/kotlin-specialist`, `_shared/specialist-skills/programming-languages/java-kotlin/` | `new-skills/awesome-copilot/plugins/kotlin-mcp-development/`, `new-skills/claude-skills/skills/kotlin-specialist/` |
| **Mobile agent role** | ❌ **None** — mobile is only a mode of `software-engineer/mobile-phases/` (6 phases exist) | Needs to be created |

**Problems:**
1. No `stack-mobile` plugin to group all mobile skills in one place
2. No `mobile-engineer` agent role (mobile is buried in software-engineer modes)
3. Flutter has only 1 skill — lacks widget tree, state management (Riverpod/BLoC), Firebase, platform channels
4. React Native skills are generic — lacks navigation, state management (Redux/Zustand), native modules, Expo
5. Swift has no SwiftUI-specific skills — only general Swift language skills
6. Kotlin has no Jetpack Compose, Android SDK, or Google Play skills — only general Kotlin
7. No mobile-specific CI/CD skills (Fastlane, Codemagic, App Center, TestFlight, Google Play Console)
8. No mobile testing skills (Detox for RN, Patrol for Flutter, XCTest/XCUITest for iOS, Espresso for Android)

**Proposed fix — Create `stack-mobile` plugin:**

```
.claude/plugins/stack-mobile/
├── .claude-plugin/plugin.json
├── skills/
│   ├── react-native/
│   │   ├── SKILL.md
│   │   ├── navigation/
│   │   ├── state-management/
│   │   ├── native-modules/
│   │   └── expo/
│   ├── flutter/
│   │   ├── SKILL.md
│   │   ├── widget-tree/
│   │   ├── state-management/
│   │   ├── firebase/
│   │   └── platform-channels/
│   ├── swift-ios/
│   │   ├── SKILL.md
│   │   ├── swiftui/
│   │   ├── uikit/
│   │   ├── core-data/
│   │   └── app-store-connect/
│   ├── kotlin-android/
│   │   ├── SKILL.md
│   │   ├── jetpack-compose/
│   │   ├── android-sdk/
│   │   └── google-play/
│   └── mobile-cicd/
│       ├── fastlane/
│       ├── codemagic/
│       └── testflight/
├── agent-definitions/
│   ├── react-native-engineer.md
│   ├── flutter-engineer.md
│   ├── ios-engineer.md
│   └── android-engineer.md
└── mobile-phases/           # Shared across all platforms
    ├── 01-analysis.md
    ├── 02-foundation.md
    ├── 03-screens.md
    ├── 04-native-integration.md
    ├── 05-polish.md
    └── 06-testing-release.md
```

**Create agent role: `mobile-engineer`:**

```
agent-roles/mobile-engineer/
├── agent.md                  # Role: mobile engineer (React Native / Flutter / Swift / Kotlin)
├── modes/
│   ├── react-native.md
│   ├── flutter.md
│   ├── ios-swift.md
│   └── android-kotlin.md
├── phases/                   # Reuse software-engineer/mobile-phases/ or symlink
│   ├── 01-analysis.md
│   ├── 02-foundation.md
│   ├── 03-screens.md
│   ├── 04-native-integration.md
│   ├── 05-polish.md
│   └── 06-testing-release.md
└── references/
    ├── platform-comparison.md
    └── app-store-guidelines.md
```

**Port plan from reference folders:**

| Source | Destination | Priority |
|--------|------------|----------|
| `new-skills/agent-skills-frontend/skills/react-native-skills/` | `stack-mobile/skills/react-native/` | P0 |
| `new-skills/awesome-copilot/plugins/kotlin-mcp-development/` | `stack-mobile/skills/kotlin-android/kotlin-mcp/` | P1 |
| `new-skills/awesome-copilot/plugins/swift-mcp-development/` | `stack-mobile/skills/swift-ios/swift-mcp/` | P1 |
| `new-skills/claude-skills/skills/flutter-expert/` | `stack-mobile/skills/flutter/` | P0 |
| `new-skills/claude-skills/skills/react-native-expert/` | `stack-mobile/skills/react-native/` | P0 |
| `new-skills/claude-skills/skills/swift-expert/` | `stack-mobile/skills/swift-ios/` | P0 |
| `new-skills/claude-skills/skills/kotlin-specialist/` | `stack-mobile/skills/kotlin-android/` | P0 |

**Note on software-engineer mobile phases:** The 6 existing mobile phases in `software-engineer/mobile-phases/` should remain as-is for cross-platform coverage, while `stack-mobile` provides platform-specific depth.

### 8.7 TypeScript & Vercel: Scattered and Incomplete

**Current state in enhancement:**

| Area | What Exists | Where | Quality |
|------|------------|-------|---------|
| **TypeScript** | `typescript-pro` | claude-skills-catalog | Generic, single-skill |
| **TypeScript** | `ts-library`, `tsdown` | stack-nuxt | Nuxt-specific, not general |
| **TypeScript** | `openapi-to-typescript` | agent-toolkit | Narrow scope |
| **TypeScript** | `_shared/specialist-skills/programming-languages/javascript-typescript/` | _shared | Comprehensive but deep in shared |
| **TypeScript** | `typescript-mcp-expert.agent.md` | stack-ai-ml/agent-definitions | Agent definition only |
| **Vercel** | `deploy-to-vercel`, `vercel-cli-with-tokens`, `vercel-optimize` | stack-frontend | Only 3 skills, exist only in .claude |
| **.cursor/ Vercel** | ❌ **Nothing** | .cursor/skills/ | **Missing entirely from Cursor** |
| **.cursor/ TypeScript** | `typescript-pro`, `ts-library`, `tsdown` | .cursor/skills/ | Partial — missing tooling skills |

**Available in reference folders to port:**

| Source | Content | Destination |
|--------|---------|-------------|
| `awesome-copilot/plugins/typescript-mcp-development/` | TypeScript MCP server development | `stack-frontend` or new `stack-typescript` |
| `awesome-copilot/skills/typescript-mcp-server-generator/` | TypeScript MCP code generation | `stack-frontend` |
| `awesome-copilot/skills/javascript-typescript-jest/` | TypeScript testing with Jest | `stack-frontend` |
| `new-skills/agent-skills-frontend/skills/deploy-to-vercel/` | Richer Vercel deployment skill | replace existing |
| `new-skills/agent-skills-frontend/skills/vercel-cli-with-tokens/` | Vercel CLI auth and usage | replace existing |
| `new-skills/agent-skills-frontend/skills/vercel-optimize/` | Vercel optimization patterns | replace existing |

**Gaps to fill:**

| Missing Skill | Why It Matters |
|--------------|----------------|
| **TypeScript tooling** (tsconfig, tsup, bun, biome, eslint, prettier) | No consolidated TS tooling skill |
| **TypeScript monorepo** (turborepo, nx, pnpm workspaces) | Modern TS projects use monorepos |
| **Next.js + Vercel deployment** (integrated workflow) | Core skill for Next.js devs |
| **TypeScript testing** (vitest, jest, playwright for TS) | `typescript-pro` doesn't cover testing |
| **Vercel in .cursor/** | 3 Vercel skills exist in .claude but ZERO in .cursor |

**Proposed organization:**

```
Option A: Add to stack-frontend (natural home for frontend/TS/vercel)
  stack-frontend/skills/
    ├── typescript-tooling/       ← NEW
    ├── typescript-monorepo/      ← NEW (from awesome-copilot or new)
    ├── typescript-testing/       ← NEW
    ├── nextjs-vercel-deploy/     ← NEW (integrated workflow)
    ├── deploy-to-vercel/         ← existing (port richer version from reference)
    ├── vercel-cli-with-tokens/   ← existing (port richer version)
    └── vercel-optimize/          ← existing (port richer version)

Option B: Create dedicated stack-vercel plugin
  stack-vercel/
    ├── .claude-plugin/plugin.json
    ├── skills/
    │   ├── deploy/
    │   ├── cli/
    │   ├── optimize/
    │   ├── edge-functions/
    │   ├── analytics/
    │   └── nextjs-integration/
    └── agent-definitions/
        └── vercel-engineer.md
```

**Recommendation:** Option A (add to stack-frontend) — Vercel is inherently a frontend deployment platform, and TypeScript is a frontend language. Adding a separate `stack-vercel` would fragment frontend skills. However, if Vercel skills grow beyond 10+ skills, Option B becomes viable.

**Immediate actions:**
1. Port richer Vercel skills from `new-skills/agent-skills-frontend/` to replace existing thin versions
2. Port TypeScript MCP skills from `awesome-copilot/` to stack-frontend or stack-ai-ml
3. Create missing TypeScript tooling, monorepo, and testing skills
4. Sync all Vercel skills to `.cursor/skills/` (currently zero)

### 8.8 Framework Skills: Next.js, NestJS, React, Vue — Scattered

**Current state in enhancement:**

| Framework | Skills | Where | Quality |
|-----------|--------|-------|---------|
| **Next.js** | `nextjs-developer`, `nextjs-seo`, `nextjs-chatbot`, `nextjs-shadcn`, `ai-app`, `ai-elements` | claude-skills-catalog + stack-frontend | Decent coverage but scattered across plugins. Missing: App Router, server actions, middleware, auth (NextAuth), edge runtime, ISR/SSG patterns |
| **NestJS** | `nestjs-expert` (1 skill), `greenfield-nestjs` template, `packs/languages/nodejs-nestjs/` | claude-skills-catalog + packs | **Very thin** — 1 generic skill for a major backend framework. Missing: modules, guards/interceptors, GraphQL, microservices, testing, Prisma/TypeORM, CQRS |
| **React** | `react-expert`, `react-best-practices`, `react-dev`, `react-useeffect`, `react-native-expert`, `react-native-skills` | claude-skills-catalog + stack-frontend + agent-toolkit | **Scattered** across 3 plugins. Missing: hooks deep-dive, state management (Redux/Zustand), server components, Suspense/streaming, testing (RTL) |
| **Vue** | `stack-vue/` (8 skills), `vue-expert`, `vue-expert-js` | stack-vue + claude-skills-catalog | **Good** — dedicated plugin with 8 well-organized skills (best-practices, router, pinia, testing, debug, JSX, Options API, composables) |
| **Nuxt** | `stack-nuxt/` (21 skills) | stack-nuxt | **Excellent** — full-featured Nuxt plugin with SEO, UI, auth, content, studio, modules |
| **.cursor/ frameworks** | nestjs-expert, vue-best-practices, react-best-practices, all Nuxt skills | .cursor/skills/ | Most framework skills exist in .cursor as flat copies from their respective plugins |

**Available in reference folders:**

| Source | Content | Destination |
|--------|---------|-------------|
| `new-skills/agent-nestjs-skills/` | **Full NestJS plugin** with rules, agents, scripts | Should become `stack-nestjs` plugin |
| `new-skills/claude-code-nextjs-skills/` | Next.js skills (ai-app, ai-elements, chatbot, seo, shadcn) | Merge into stack-frontend |
| `new-skills/claude-skills/skills/{nextjs-developer,nestjs-expert,react-expert}/` | Generic expert skills | Already in claude-skills-catalog |
| `new-skills/vue-skills/` | Vue.js skills | Already in stack-vue |
| `new-skills/nuxt-skills/` | Nuxt.js skills | Already in stack-nuxt |

**Gaps to fill:**

| Missing Skill | Why It Matters |
|--------------|----------------|
| **NestJS module system** (modules, guards, interceptors, pipes, filters) | Core NestJS knowledge — current 1-skill coverage is insufficient |
| **NestJS + GraphQL** (code-first, schema-first, resolvers, subscriptions) | Major NestJS use case |
| **NestJS + microservices** (TCP, Redis, Kafka, RabbitMQ transports) | Enterprise NestJS pattern |
| **NestJS + Prisma/TypeORM** (database integration) | Most common ORM pairing |
| **Next.js App Router** (layouts, loading, error, parallel routes, intercepting) | Next.js 14+ core paradigm — current skills are page-router focused |
| **Next.js server actions & mutations** | Key App Router feature |
| **Next.js auth** (NextAuth/Auth.js, middleware-based protection) | Essential for most apps |
| **React server components** (RSC pattern, 'use client' boundaries) | React 18+ core concept |
| **React state management** (Redux Toolkit, Zustand, Jotai, TanStack Query) | Fragmented across 3 plugins currently |
| **React testing** (React Testing Library, Vitest, MSW, Cypress Component Test) | No dedicated React testing skill |

**Proposed organization:**

```
Option A: Create dedicated stack plugins (recommended for NestJS)
  plugins/
    ├── stack-nestjs/              ← NEW: full NestJS plugin from agent-nestjs-skills
    └── stack-frontend/            ← enhanced: add Next.js App Router, React RSC skills

Option B: Merge NestJS into stack-spring (backend umbrella)
  plugins/
    └── stack-spring/              ← extended: add NestJS alongside Spring Boot
  
Option C: Keep everything in stack-frontend (currently holds Next.js + React)
  plugins/
    └── stack-frontend/            ← extended: add NestJS as backend section
```

**Recommendation:** Create `stack-nestjs` plugin (Option A) — NestJS is a **backend** framework, not frontend. It belongs alongside `stack-spring` as a backend stack plugin. For Next.js and React, enhance `stack-frontend` with the missing skills listed above. Vue and Nuxt are already well-covered.

**Immediate actions:**
1. Create `stack-nestjs` plugin from `new-skills/agent-nestjs-skills/` — covers auth, GraphQL, microservices, Prisma, testing
2. Add Next.js App Router skill + server actions skill + auth skill to `stack-frontend`
3. Add React server components skill + state management skill + testing skill to `stack-frontend`
4. Verify Vue and Nuxt are fully covered (already good)
5. .cursor already has most framework skills — ensure stack-nestjs is synced

### 8.9 Discovery (Reverse Engineering) & Spec-Driven Development

**Current state:** Both Discovery and Spec-Driven Development (SRD) are already present in `enhancement/` from the source migration. What exists:

| Component | Location | Lines | Quality |
|-----------|----------|-------|---------|
| **Discover/Reverse mode** | `skills/sdlc-automation-agent/modes/reverse.md` | 1,140 | **Excellent** — comprehensive 8-step reverse engineering pipeline |
| **SA Discovery phase** | `agent-roles/solution-architect/phases/01-discovery.md` | ~100 | Good |
| **PM Discovery phase** | `agent-roles/product-manager/phases/02-technical-enabler-discovery.md` | ~100 | Good |
| **Design & Discovery** | `plugins/staff-engineer/skills/design-and-discovery/` | ~50 | Staff+ engineer skill |
| **Spec-Driven Dev** | `plugins/sdlc-workflows/skills/spec-driven-development/SKILL.md` | ~200 | **Good** — structured spec-before-code |
| **Spec-Driven SDLC doc** | `docs/spec-driven-sdlc-flow.md` | ~200 | Documentation |

**Verdict:** Both are **well-covered** — no new content needed. Improvements:

| Opportunity | Current | Fix |
|-------------|---------|-----|
| **Discover → .cursor** | Only in `.claude/` | Sync reverse.md to `.cursor/skills/sdlc-automation-agent/modes/` |
| **Spec-driven → .cursor** | Not in `.cursor/` | Sync spec-driven-development skill |
| **Spec-driven workflow** | No workflow YAML definition | Add `spec-driven.yaml` workflow |

**Recommended workflow:**

```yaml
# workflows/spec-driven.yaml
name: spec-driven
description: "Spec-first development pipeline"
stages:
  - id: spec-writing
    agent: product-manager
    model_tier: standard
  - id: spec-review
    agent: solution-architect
    model_tier: premium
    depends_on: [spec-writing]
    gates:
      - id: spec-approved
        type: manual
        prompt: "Review spec before implementation"
  - id: implementation
    agent: software-engineer
    model_tier: standard
    depends_on: [spec-review]
  - id: verification
    agent: quality-engineer
    model_tier: standard
    depends_on: [implementation]
    gates:
      - id: spec-compliance
        type: automatic
        condition: "all_spec_requirements_met"
```

---

## 9. Implementation Roadmap

### Phase 1: Quick Wins (Day 1)

| Step | Action | Files Affected | Est. Time |
|------|--------|---------------|-----------|
| 1.1 | Fix `.cursor/mcp.json` github command | 1 file | 1 min |
| 1.2 | Create SKILL.md for design-system, project-management, stack-ai-ml in .cursor | 3 files | 15 min |
| 1.3 | Copy cost-control instructions to `.cursor/instructions/` | 1 file | 2 min |
| 1.4 | Remove empty GCP migration directory | 1 dir | 1 min |
| 1.5 | Verify ai-ml-engineer role is complete | 8 files | 5 min |

### Phase 2: AWS Deduplication (Day 2)

| Step | Action | Est. Time |
|------|--------|-----------|
| 2.1 | Audit all duplicated skills in stack-aws/core-skills/ and stack-aws/specialized-skills/ | 30 min |
| 2.2 | Remove core-skills/ (all skills exist at top level) | 5 min |
| 2.3 | Remove specialized-skills/ (all skills exist in their category dirs) | 5 min |
| 2.4 | Flatten any remaining nested skill directories | 10 min |
| 2.5 | Re-verify no broken references | 10 min |

### Phase 3: Cross-Plugin Skill Consolidation (Day 3-4)

| Step | Action | Skills Affected | Est. Time |
|------|--------|----------------|-----------|
| 3.1 | Consolidate jira → project-management only | agent-toolkit/jira, stack-ai-ml/jira | 15 min |
| 3.2 | Consolidate qa-test-planner → project-management only | agent-toolkit/qa-test-planner, stack-ai-ml/qa-test-planner | 10 min |
| 3.3 | Consolidate datadog-cli → stack-ai-ml only | agent-toolkit/datadog-cli | 5 min |
| 3.4 | Consolidate gemini, gepetto, perplexity → stack-ai-ml only | agent-toolkit/* | 10 min |
| 3.5 | Consolidate prompt-engineer → stack-ai-ml only | claude-skills-catalog/prompt-engineer | 5 min |
| 3.6 | Consolidate frontend-design → design-system only | stack-frontend/frontend-design | 5 min |
| 3.7 | Add cross-reference notes to deprecated locations | 10 files | 20 min |

### Phase 4: GCP Expansion (Day 5-7)

| Step | Action | New Skills | Est. Time |
|------|--------|-----------|-----------|
| 4.1 | Create networking skills (vpc, cloud-cdn, cloud-dns, cloud-nat) | 3 | 2 hrs |
| 4.2 | Create data-analytics skills (dataflow, dataproc, data-fusion) | 3 | 2 hrs |
| 4.3 | Create security-identity skills (cloud-kms, security-command-center, certificate-authority) | 3 | 2 hrs |
| 4.4 | Create devops-cicd skills (cloud-deploy, cloud-source-repositories, artifact-registry) | 3 | 2 hrs |
| 4.5 | Create observability skills (cloud-logging, cloud-trace, cloud-profiler) | 3 | 1.5 hrs |
| 4.6 | Create serverless skills (eventarc, workflows, app-engine) | 3 | 1.5 hrs |
| 4.7 | Create migration skills (migrate-to-gcp, transfer-appliance, database-migration-service) | 3 | 1.5 hrs |
| 4.8 | Sync updated GCP to .cursor | — | 10 min |

### Phase 5: Cloud Plugin Content (Day 8-9)

| Step | Action | Est. Time |
|------|--------|-----------|
| 5.1 | Create well-architected/ pillar docs for AWS | 2 hrs |
| 5.2 | Create well-architected/ pillar docs for Azure | 2 hrs |
| 5.3 | Create well-architected/ pillar docs for GCP | 2 hrs |
| 5.4 | Create templates/ for each cloud (serverless, container, web) | 3 hrs |
| 5.5 | Create verify/ scripts for each cloud | 2 hrs |

### Phase 6: .cursor/. Sync (Day 10-12)

| Step | Action | Skills Count | Est. Time |
|------|--------|-------------|-----------|
| 6.1 | Sync stack-ai-ml → .cursor/plugins/ | 145 | 1 hr |
| 6.2 | Sync delivery-toolkit → .cursor/plugins/ | 6 sub-plugins | 30 min |
| 6.3 | Sync stack-golang → .cursor/ | 43 | 30 min |
| 6.4 | Sync system-design → .cursor/ | 22 | 20 min |
| 6.5 | Sync staff-engineer → .cursor/ | 14 | 10 min |
| 6.6 | Sync agent-toolkit → .cursor/ (key skills only) | 20 | 30 min |
| 6.7 | Sync sdlc-workflows → .cursor/ | 24 | 15 min |
| 6.8 | Create TECH-INDEX.md in plugins/ | 1 | 30 min |
| 6.9 | Add language packs to .cursor/packs/ | 4 | 20 min |

### Phase 7: Agent Roles (Day 13)

| Step | Action | Est. Time |
|------|--------|-----------|
| 7.1 | Create dotnet-engineer agent role with phases | 1 hr |
| 7.2 | Create cloud-architect agent role (references AWS/Azure/GCP defs) | 1 hr |
| 7.3 | Register new roles in plugin.json and AGENTS.md | 15 min |

### Phase 8: Mobile Development Plugin (Day 14-16) — NEW

| Step | Action | Est. Time |
|------|--------|-----------|
| 8.1 | Create `stack-mobile` plugin with `.claude-plugin/plugin.json` | 30 min |
| 8.2 | Port `react-native-skills` from `new-skills/agent-skills-frontend/` and `claude-skills` | 2 hrs |
| 8.3 | Port `flutter-expert` from `new-skills/claude-skills/` | 2 hrs |
| 8.4 | Port `swift-expert` + `swift-mcp-development` from reference folders | 2 hrs |
| 8.5 | Port `kotlin-specialist` + `kotlin-mcp-development` from reference folders | 2 hrs |
| 8.6 | Create mobile CI/CD skills (Fastlane, Codemagic, TestFlight, Google Play) | 2 hrs |
| 8.7 | Create `mobile-engineer` agent role with 4 modes (RN, Flutter, iOS, Android) | 1 hr |
| 8.8 | Create mobile testing skills (Detox, Patrol, XCTest, Espresso) | 1.5 hrs |
| 8.9 | Sync stack-mobile to .cursor | 15 min |

### Phase 9: TypeScript & Vercel Enhancement (Day 17-18) — NEW

| Step | Action | Est. Time |
|------|--------|-----------|
| 9.1 | Port richer Vercel skills from `new-skills/agent-skills-frontend/` → replace stack-frontend versions | 1 hr |
| 9.2 | Port TypeScript MCP skills from `awesome-copilot/plugins/typescript-mcp-development/` | 1 hr |
| 9.3 | Create TypeScript tooling skill (tsconfig, tsup, bun, biome, eslint, prettier) | 1.5 hrs |
| 9.4 | Create TypeScript monorepo skill (turborepo, nx, pnpm workspaces) | 1 hr |
| 9.5 | Create Next.js + Vercel integrated deployment workflow skill | 1 hr |
| 9.6 | Create TypeScript testing skill (vitest, jest, playwright for TS) | 1 hr |
| 9.7 | Sync all Vercel skills to `.cursor/skills/` (currently zero) | 15 min |
| 9.8 | Sync new TypeScript skills to `.cursor/skills/` | 15 min |

### Phase 10: Framework Skills — NestJS, Next.js, React (Day 19-21) — NEW

| Step | Action | Est. Time |
|------|--------|-----------|
| 10.1 | Create `stack-nestjs` plugin from `new-skills/agent-nestjs-skills/` | 2 hrs |
| 10.2 | Add Next.js App Router skill + server actions + auth to stack-frontend | 2 hrs |
| 10.3 | Add React server components skill + state management to stack-frontend | 2 hrs |
| 10.4 | Add React/Next.js testing skills (RTL, Vitest, MSW, Cypress) | 1.5 hrs |
| 10.5 | Add NestJS GraphQL + microservices + Prisma skills | 2 hrs |
| 10.6 | Verify Vue (8 skills) and Nuxt (21 skills) — already well-covered | 30 min |
| 10.7 | Sync stack-nestjs to .cursor | 15 min |
| 10.8 | Cross-reference framework skills in TECH-INDEX.md | 30 min |

### Phase 11: Discovery & Spec-Driven Workflow (Day 22-23) — NEW

| Step | Action | Est. Time |
|------|--------|-----------|
| 11.1 | Add `spec-driven.yaml` workflow definition | 30 min |
| 11.2 | Sync Discover/Reverse mode to `.cursor/skills/sdlc-automation-agent/modes/` | 15 min |
| 11.3 | Sync spec-driven-development skill to `.cursor/` | 10 min |
| 11.4 | Cross-reference Discovery ↔ Spec-driven in TECH-INDEX.md | 15 min |
| 11.5 | Verify reverse.md migrated correctly (1,140 lines) | 10 min |

### Phase 12: Validation & Polish (Day 24)

| Step | Action | Est. Time |
|------|--------|-----------|
| 12.1 | Run validate-skill.sh across all plugins | 10 min |
| 12.2 | Fix any broken SKILL.md frontmatter | 30 min |
| 12.3 | Verify number consistency: AGENTS.md, crew-welcome.md, README.md | 15 min |
| 12.4 | Final file count audit | 10 min |

---

## Summary of Effort

| Phase | Description | Days | Files Changed/Added |
|-------|-------------|------|-------------------|
| 1 | Quick Wins | 1 | 5 files |
| 2 | AWS Dedup | 1 | ~60 files removed |
| 3 | Skill Consolidation | 2 | ~15 files |
| 4 | GCP Expansion | 3 | 21 new skills |
| 5 | Cloud Content | 2 | 45 new files |
| 6 | .cursor Sync | 3 | ~300 files synced |
| 7 | Agent Roles | 1 | ~15 new files |
| 8 | Mobile Plugin | 3 | ~30 new skills + agent role |
| 9 | **TypeScript & Vercel** | **2** | **~8 new/updated skills** |
| 10 | **Framework Skills** (NestJS, Next.js, React) | **3** | **~10 new skills + plugin** |
| 11 | Discovery & Spec-Driven Workflow | **1** | **~3 files** |
| 12 | Validation & Polish | 1 | Varies |
| **Total** | | **24 days** | **~480 files** |

**Top 10 priorities:**
1. ⚠ Fix `.cursor/mcp.json` typo — breaks GitHub MCP
2. ⚠ Create 3 missing SKILL.md in .cursor — skills invisible to Cursor users
3. ⚠ Deduplicate AWS skills — confusing for developers
4. 📱 Create `stack-mobile` plugin — React Native, Flutter, Swift, Kotlin all scattered
5. 📱 Create `mobile-engineer` agent role — mobile deserves dedicated role, not just SE mode
6. 🔷 Port richer Vercel skills from reference folders + sync to .cursor (currently zero there)
7. 🔷 Create dedicated TypeScript skill ecosystem (tooling, monorepo, testing, MCP)

**For each skill overlap, the rule is:** keep one canonical copy, cross-reference from others.

**For mobile:** consolidate all 4 platforms into a single `stack-mobile` plugin with shared mobile phases and platform-specific depth.

**For TypeScript & Vercel:** enhance `stack-frontend` with TS tooling, monorepo, testing skills, and port richer Vercel skills from reference folders. Sync to .cursor.
