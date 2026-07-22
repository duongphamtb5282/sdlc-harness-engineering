# SDLC Agent System — Setup & Usage Guide

> **Target:** `enhancement/` folder (the redesigned structure)  
> **Version:** 2.0.0  
> **Total skills:** 16,400+ files across .claude/ and .cursor/
> 
> **📖 Architecture doc:** See `ARCHITECTURE.md` for system design, execution flows, and customization guide.

---

## Table of Contents

1. [Quick Start](#1-quick-start)
2. [Plugin Configuration](#2-plugin-configuration)
3. [MCP Server Setup](#3-mcp-server-setup)
4. [YAML Configuration Reference](#4-yaml-configuration-reference)
5. [Standalone Usage Examples](#5-standalone-usage-examples)
6. [SDLC Pipeline Usage](#6-sdlc-pipeline-usage)
7. [Workflow Selection Guide](#7-workflow-selection-guide)
8. [Cost Control & Model Routing](#8-cost-control--model-routing)
9. [Adding New Skills](#9-adding-new-skills)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Quick Start

### Claude Code

```bash
# Install into your project
rsync -a --delete enhancement/.claude/ /path/to/your-project/.claude/

# Start Claude Code with the plugin
cd /path/to/your-project
claude --plugin-dir .claude

# Or with specific stack plugins
claude --plugin-dir .claude \
  --plugin-dir .claude/plugins/stack-aws \
  --plugin-dir .claude/plugins/stack-ai-ml
```

### Cursor

```bash
# Install into your project
rsync -a --delete enhancement/.cursor/ /path/to/your-project/.cursor/

# Open your project in Cursor
cursor /path/to/your-project
```

### First Run

When you first open the project, the `sdlc-automation-agent` orchestrator will:

1. **Detect** your project structure and technology stack
2. **Initialize** `.sdlc-automation-agent.yaml` with defaults
3. **Present** options: Start building, Reverse-engineer first, or Work without pipeline
4. **Route** your request to the right agent(s)

---

## 2. Plugin Configuration

### Available Plugins (19 total)

```
plugins/
├── orchestration/
│   ├── sdlc-automation-agent/     # Main orchestrator (always loaded)
│   ├── sdlc-workflows/            # Workflow automation skills
│   └── delivery-toolkit/          # Feature dev, code review, plugin dev
│
├── stacks/ (technology)
│   ├── stack-aws/                 # AWS cloud (26 skills)
│   ├── stack-azure/               # Azure cloud (191 skills)
│   ├── stack-gcp/                 # GCP cloud (38 skills)
│   ├── stack-ai-ml/               # AI/ML/LLM/RAG/Agentics (131+ skills)
│   ├── stack-frontend/            # Frontend, Next.js, React, Vercel, TypeScript
│   ├── stack-nestjs/              # NestJS backend framework (NEW)
│   ├── stack-mobile/              # React Native, Flutter, Swift, Kotlin (NEW)
│   ├── stack-nuxt/                # Nuxt.js (21 skills)
│   ├── stack-vue/                 # Vue.js (8 skills)
│   ├── stack-spring/              # Spring Boot + Java (37 skills)
│   ├── stack-java/                # Java core skills (NEW, 88 files)
│   ├── stack-golang/              # Go (43 skills)
│   ├── stack-dotnet/              # .NET (326 files, 17 domain plugins)
│   └── stack-nestjs/              # NestJS backend (52 files, 42 rules)
│
├── features/
│   ├── design-system/             # Figma MCP, UI design (NEW)
│   ├── project-management/        # Jira, Linear, QA planning (NEW)
│   ├── system-design/             # Architecture, C4, scaling (22 skills)
│   ├── staff-engineer/            # Staff+ engineering patterns (14 skills)
│   ├── agent-toolkit/             # Agent utilities (43 skills)
│   ├── claude-skills-catalog/     # General expert skills (66 skills)
│   ├── production-grade/          # Production dev patterns (NEW, 108 files)
│   ├── general-skills/            # General-purpose SDLC skills (24 skills, NEW)
│   └── security/                  # Security audit guidance
│
└── packs/
    ├── clouds/aws/                # AWS conventions, Terraform patterns
    ├── clouds/azure/              # Azure naming, Bicep patterns
    ├── clouds/gcp/                # GCP conventions, labels
    ├── languages/java-spring/     # Spring Boot conventions
    └── languages/nodejs-nestjs/   # NestJS conventions
```

### Enabling Plugins

Edit `.sdlc-automation-agent.yaml`:

```yaml
plugins:
  enabled:
    - stack-aws          # For AWS infrastructure
    - stack-ai-ml        # For AI/ML features
    - design-system      # For Figma integration
    - stack-mobile       # For mobile development
```

Or via CLI:

```bash
claude --plugin-dir .claude --plugin-dir .claude/plugins/stack-aws
```

### Plugin Registration (plugin.json)

All **23 plugins** are registered in `.claude/plugin.json`:

```json
{
  "name": "sdlc-automation-agent",
  "plugins": [
    "./plugins/agent-toolkit",
    "./plugins/claude-skills-catalog",
    "./plugins/delivery-toolkit",
    "./plugins/design-system",
    "./plugins/general-skills",
    "./plugins/production-grade",
    "./plugins/project-management",
    "./plugins/sdlc-workflows",
    "./plugins/stack-ai-ml",
    "./plugins/stack-aws",
    "./plugins/stack-azure",
    "./plugins/stack-dotnet",
    "./plugins/stack-frontend",
    "./plugins/stack-gcp",
    "./plugins/stack-golang",
    "./plugins/stack-java",
    "./plugins/stack-mobile",
    "./plugins/stack-nestjs",
    "./plugins/stack-nuxt",
    "./plugins/stack-spring",
    "./plugins/stack-vue",
    "./plugins/staff-engineer",
    "./plugins/system-design"
  ]
}
```

---

## 3. MCP Server Setup

### Configuring MCP Servers

MCP servers enable external tool integration. Configure them in `.claude/mcp/{domain}/mcp.json` or `.cursor/mcp.json`.

#### Jira (Project Management)

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@agenite/jira-mcp-server"],
      "env": {
        "JIRA_HOST": "https://your-domain.atlassian.net",
        "JIRA_USER": "your-email@example.com",
        "JIRA_API_TOKEN": "your-jira-api-token"
      }
    }
  }
}
```

**Setup:**
1. Get Jira API token from https://id.atlassian.com/manage/api-tokens
2. Set env vars: `export JIRA_USER=email` and `export JIRA_API_TOKEN=token`
3. Or store in `.env` file and load via `dotenv`

#### Confluence (Knowledge Base)

```json
{
  "mcpServers": {
    "confluence": {
      "command": "npx",
      "args": ["-y", "@agenite/confluence-mcp-server"],
      "env": {
        "CONFLUENCE_HOST": "https://your-domain.atlassian.net",
        "CONFLUENCE_USER": "your-email@example.com",
        "CONFLUENCE_API_TOKEN": "your-confluence-api-token"
      }
    }
  }
}
```

#### Figma (Design System)

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@figma/mcp-server"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "your-figma-personal-access-token"
      }
    }
  }
}
```

**Setup:**
1. Generate Figma token: Settings > Account > Personal Access Tokens
2. Requires Figma file key from URL: `figma.com/file/{FILE_KEY}/name`

#### GitHub (CI/CD)

```json
{
  "mcpServers": {
    "github": {
      "command": "gh",
      "args": ["mcp-server"],
      "cwd": "${workspaceFolder}"
    }
  }
}
```

**Setup:**
1. Install GitHub CLI: `brew install gh` (macOS) or `apt install gh` (Linux)
2. Authenticate: `gh auth login`
3. Ensure `gh` is in your PATH

#### Slack (Communications)

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@slack/mcp-server"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-bot-token",
        "SLACK_TEAM_ID": "T01234567"
      }
    }
  }
}
```

#### Datadog (Observability)

```json
{
  "mcpServers": {
    "datadog": {
      "command": "npx",
      "args": ["-y", "@datadog/mcp-server"],
      "env": {
        "DATADOG_API_KEY": "your-datadog-api-key",
        "DATADOG_APP_KEY": "your-datadog-app-key"
      }
    }
  }
}
```

### Consolidated .cursor/mcp.json

For Cursor, all MCP servers can be in a single file:

```json
{
  "mcpServers": {
    "jira": { "command": "npx", "args": ["-y", "@agenite/jira-mcp-server"], "env": { "JIRA_HOST": "...", "JIRA_USER": "...", "JIRA_API_TOKEN": "..." } },
    "confluence": { "command": "npx", "args": ["-y", "@agenite/confluence-mcp-server"], "env": { "CONFLUENCE_HOST": "...", "CONFLUENCE_USER": "...", "CONFLUENCE_API_TOKEN": "..." } },
    "figma": { "command": "npx", "args": ["-y", "@figma/mcp-server"], "env": { "FIGMA_ACCESS_TOKEN": "..." } },
    "github": { "command": "gh", "args": ["mcp-server"], "cwd": "${workspaceFolder}" },
    "slack": { "command": "npx", "args": ["-y", "@slack/mcp-server"], "env": { "SLACK_BOT_TOKEN": "...", "SLACK_TEAM_ID": "..." } }
  }
}
```

---

## 4. YAML Configuration Reference

### Main Config: `.sdlc-automation-agent.yaml`

```yaml
# ============================================
# SDLC Automation Agent — Main Configuration
# ============================================

project:
  name: "my-project"                # Required: project name
  type: "greenfield"                 # greenfield | brownfield | migration
  language: "typescript"             # Primary language
  framework: "nestjs"                # Primary framework

# ============================================
# Build Mode
# ============================================
build_mode: "scrum"                  # scrum | kanban

engagement_mode: "autonomous"        # autonomous | controlled
# autonomous: Auto-resolve decisions, ask only for critical items
# controlled: Surface every decision point for user approval

# ============================================
# Definition of Done / Ready
# ============================================
dod:
  test_coverage: 80                  # Minimum test coverage %
  lint_passed: true                  # Must pass linting
  typescript_strict: true            # Must pass strict type check
  security_scan: true               # Must pass security scan
  documentation_updated: true        # Must update docs

dor:
  requirements_clear: true           # Requirements must be clear
  architecture_approved: true        # Architecture must be approved
  dependencies_resolved: true        # Dependencies must be resolved

# ============================================
# Cost Control
# ============================================
cost_control:
  enabled: true                      # Enable cost control
  default_model: "claude-sonnet"    # Fast/cheap default
  premium_model: "claude-opus"      # Expensive for complex tasks
  thresholds:
    auto_approve_simple: true        # S1-S2: no gate needed
    auto_approve_moderate: false     # S3: only if clear
    ask_before_premium: true         # S4-S5: always ask
  budget_alerts:
    daily_limit: 10                  # $10 daily limit
    session_limit: 2                 # $2 per session
    hard_stop: 50                    # $50 hard stop

# ============================================
# Plugin Selection
# ============================================
plugins:
  enabled:
    - stack-aws                      # AWS infrastructure
    - stack-ai-ml                    # AI/ML capabilities
    - stack-mobile                   # Mobile development
    - project-management             # Jira integration
    - design-system                  # Figma integration

# ============================================
# Path Configuration
# ============================================
paths:
  services: "services/"             # Service code
  frontend: "apps/web/"             # Frontend code
  infra: "infra/"                   # Infrastructure code
  docs: "docs/"                     # Documentation
  tests: "tests/"                   # Tests

# ============================================
# MCP Server References
# ============================================
mcp:
  jira: true                        # Enable Jira MCP
  confluence: false                  # Disable Confluence MCP
  figma: false                      # Disable Figma MCP
  slack: true                       # Enable Slack MCP

# ============================================
# Workflow Selection
# ============================================
workflow: "feature"                  # Default workflow

# ============================================
# Tracker Integration
# ============================================
tracker:
  type: "jira"                      # jira | linear | github
  project_key: "PROJ"               # Jira project key
  templates:
    story: ".sdlc-automation-agent/templates/user-story.md"
    bug: ".sdlc-automation-agent/templates/bug.md"
    epic: ".sdlc-automation-agent/templates/epic.md"
```

### Workflow Config Override

You can override specific workflow settings at the project level:

```yaml
# .sdlc-automation-agent/workflows/feature.custom.yaml
stages:
  - id: architecture
    model_tier: standard             # Override: downgrade from premium
    timeout_minutes: 30              # Override: extend timeout
  - id: review
    model_tier: premium              # Keep premium for code review
```

---

## 5. Standalone Usage Examples

### Single Agent: Code Review

```bash
# Load the code reviewer and review the current branch
claude "Act as code-reviewer. Review all changes on this branch against main. Check for security issues, performance problems, and code quality. Report findings only — do not modify code."
```

### Single Agent: Architecture Design

```bash
# Load the solution architect
claude "Act as solution-architect. Design a microservice architecture for a real-time chat system supporting 50k concurrent users. Output ADRs for key decisions. Use C4 diagrams."
```

### Single Agent: AI/ML

```bash
# Ask for AI/ML engineering help
claude "Act as ai-ml-engineer in rag mode. I need to build a RAG system for our internal documentation. Recommend vector database, embedding model, and retrieval strategy. Consider: 100k docs, ~1M chunks, <500ms latency."
```

### Single Agent: Mobile

```bash
# Ask for mobile development help
claude "Act as mobile-engineer in flutter mode. I need to build a cross-platform expense tracker. Generate the main UI components, state management with Riverpod, and local database with SQLite."
```

### Single Agent: Cloud Architecture

```bash
# Ask for cloud architecture
claude "Act as cloud-architect in aws-architect mode. Design a Well-Architected multi-region deployment for our SaaS platform. Current stack: NestJS, PostgreSQL, Redis. Target: 99.99% availability."
```

### Single Agent: Security Audit

```bash
# Security review
claude "Act as security-engineer in pentest mode. Perform a security audit on our user authentication flow. Focus on: JWT handling, session management, rate limiting, and SQL injection prevention."
```

### Single Skill: Prompt Engineering

```bash
# Use a specific AI skill
claude "Load prompt-engineering-patterns from stack-ai-ml. I need to design a chain-of-thought prompt for a customer support agent that handles refund requests."
```

### With MCP: Jira Integration

```bash
# Use Jira MCP
claude "Connect to Jira via MCP. Show me all open high-priority bugs in sprint 5. Summarize them and suggest which ones to tackle first."
```

### With MCP: Figma Design to Code

```bash
# Use Figma MCP
claude "Connect to Figma via MCP. Access file KEY123 and extract the button component styles. Generate the equivalent React component with Tailwind CSS based on the design tokens found."
```

---

### Single Agent: UI/UX Designer

```bash
# Design a new feature from research to implementation
claude "Act as ui-ux-designer in ux-research mode. I need to design a checkout flow for our e-commerce app. Create user personas, journey maps, and wireframes."

# Convert Figma designs to code
claude "Act as ui-ux-designer in design-to-code mode. Connect to Figma via MCP, extract the button component design tokens from file KEY123, and generate React components with Tailwind CSS."

# Build a design system
claude "Act as ui-ux-designer in design-system mode. Create a design token specification for our app covering colors, typography, and spacing. Output as CSS variables and Tailwind config."
```

### Single Agent: Code Review (Enhanced)

```bash
# Standard code review with full pipeline
claude "Act as code-reviewer. Scan the current branch, analyze for security and performance issues, and produce a findings report."

# Language-specific review
claude "Load java-code-review from stack-spring. Review all Java files changed in this PR for concurrency issues and Spring best practices."

# Deep review with PR analyzer
claude "Load code-review-deep from delivery-toolkit. Run the PR analyzer scripts on this branch and report all findings with severity levels."
```

### Requirements Validation

```bash
# Validate BRD against stories
python3 .claude/workflows/validate-requirements.py --project .

# Full requirements check
claude "Run requirements validation. Check that all BRD requirements have linked stories, all stories have testable acceptance criteria, and no stories are orphaned."
```

### Impact Analysis

```bash
# Trace story to files
python3 .claude/workflows/impact-analysis.py --story US-001 --project .

# Find what stories touch a file
python3 .claude/workflows/impact-analysis.py --file services/auth/src/login.ts --project .

# Full impact report
python3 .claude/workflows/impact-analysis.py --report --project .

# Via Claude
claude "Run impact analysis. Show me which user stories are affected if I modify the payment service."
```

### Requirement Versioning

```bash
# Archive current state (auto-run after validation)
cp .sdlc-automation-agent/.orchestrator/story-registry.yaml \
   .sdlc-automation-agent/.orchestrator/story-registry-history/$(date +%Y-%m-%d)-v{N}.yaml

# Compare versions
diff .sdlc-automation-agent/.orchestrator/story-registry-history/v1.yaml \
     .sdlc-automation-agent/.orchestrator/story-registry-history/v2.yaml

# Show BRD change history
git log --oneline docs/requirements/brd.md

# Via Claude
claude "Show me the requirements changelog. What stories were added or modified in the last week?"
```

---

## 6. SDLC Pipeline Usage

### Full Greenfield — Build a New SaaS

```bash
claude "Build a multi-tenant SaaS for appointment scheduling. Stack: NestJS backend, Next.js frontend, PostgreSQL, AWS ECS. Run the full SDLC pipeline: PM → SA → SE → QE → CR → PE. Produce BRD, ADRs, OpenAPI specs, tests, and CI/CD."
```

The orchestrator will:
1. **PM Phase**: Requirements → User stories → BRD
2. **SA Phase**: Architecture → ADRs → Tech stack → API contracts
3. **SE Phase**: Backend services → Frontend pages → Database schema
4. **QE Phase**: Unit tests → Integration tests → E2E tests → Performance tests
5. **CR Phase**: Code quality → Architecture conformance → Security review
6. **PE Phase**: Docker → CI/CD → Infrastructure → Deploy

### End-to-End: Discovery → Requirements → Stories → Implementation

This is the core SDLC pipeline — from understanding an existing codebase through to delivering implemented features.

```bash
claude "Run the discovery-to-delivery pipeline. First reverse-engineer this NestJS codebase to understand the architecture, then work with me to define requirements, create user stories with acceptance criteria, design the architecture, implement story by story, test, review, and deploy."
```

**Pipeline stages:**

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│  DISCOVERY  │ ──→ │ REQUIREMENTS │ ──→ │ ARCHITECTURE│ ──→ │ STORIES      │
│  (SA/revert)│     │  (PM)       │     │  (SA)       │     │  (PM)        │
└─────────────┘     └──────────────┘     └─────────────┘     └──────────────┘
                                                                   │
┌─────────────┐     ┌──────────────┐     ┌─────────────┐           │
│  DEPLOY     │ ←── │  REVIEW      │ ←── │ IMPLEMENT   │ ←─────────┘
│  (PE)       │     │  (CR)        │     │  (SE)       │     story by story
└─────────────┘     └──────────────┘     └─────────────┘
```

**Handoff gates between each stage:**

| Gate | From | To | Check |
|------|------|----|-------|
| System mapped | SA/Discover | PM | Codebase context documented |
| BRD approved | PM | SA | All requirements have acceptance criteria |
| Architecture approved | SA | PM | ADRs written, API contracts complete |
| Stories registered | PM | SE | Stories have IDs linked to tracker |
| Story complete | SE | QE | All acceptance criteria met |
| Review approved | CR | PE | All critical findings resolved |

### Feature Addition — Existing Codebase

```bash
claude "This is an existing NestJS monorepo. First discover and map the codebase structure. Then add a notification module that sends emails when appointments are confirmed. Follow existing patterns. Run tests before done."
```

The orchestrator will:
1. **Discover**: Map codebase structure, dependencies, existing patterns
2. **Design**: Architecture design for the new module
3. **Implement**: Build notification module following existing patterns
4. **Test**: Write tests matching existing style
5. **Verify**: Ensure all tests pass

### Sprint Delivery

```bash
claude "Start sprint 6. Implement stories US-301 (user profile API), US-302 (avatar upload), and US-303 (profile page UI). Assign to SE → QE → CR per story. Track in Jira."
```

### Bug Fix

```bash
claude "Investigate and fix the login timeout issue in production. Diagnose root cause, implement fix, add regression test, verify."
```

### AI/ML Feature

```bash
claude "Build a product recommendation feature using AI/ML. Use our existing product catalog (10k items) and user history. Implement: embedding generation, vector search with Pinecone, and a REST API. Run the ai-ml-pipeline workflow."
```

### RAG System

```bash
claude "Build a RAG system for our technical documentation. Use our 500-page internal wiki. Implement: chunking strategy, embedding with text-embedding-3-small, Qdrant vector store, and a query API with LangChain. Use the rag-system workflow."
```

### Mobile App

```bash
claude "Build a cross-platform mobile app for our e-commerce platform. Use React Native with Expo. Implement: product listing, search, cart, checkout, and order tracking. Use the stack-mobile plugin."
```

### Cloud Migration

```bash
claude "Plan and execute migration from on-premises to AWS. Current: 20 VMs running Java + PostgreSQL. Target: ECS Fargate + RDS Aurora. Use the migration workflow."
```

---

## 7. Workflow Selection Guide

| Workflow | When to Use | Stages | Estimated Cost |
|----------|------------|--------|----------------|
| `greenfield.yaml` | New project from scratch | PM → SA → SE → FE → QE → CR → Security → PE | $23-43 |
| `feature.yaml` | Adding a feature to existing code | SA → SE → QE → CR | $7-13 |
| `bugfix.yaml` | Fixing a bug | CR(diagnose) → SE(fix) → QE(verify) | $3-8 |
| `security-review.yaml` | Security audit | Threat model → Code audit → Remediate → Verify | $16-31 |
| `ai-ml-pipeline.yaml` | ML model training | Experiment → Data → Train → Evaluate → Deploy | $15-34 |
| `rag-system.yaml` | RAG implementation | Architecture → Embedding → Retrieval → Eval → Deploy | $13-25 |
| `agent-system.yaml` | AI agent system | Agent design → Tools → Core → Safety → Test | $20-36 |
| `architecture-review.yaml` | Architecture decision | Context → ADR → Conformance | $6-11 |
| `migration.yaml` | System migration | Analysis → Data → Code → Test → Review | $16-34 |
| `documentation.yaml` | Documentation | Audit → Write → Review | $4-9 |
| `spec-driven.yaml` | Spec-first development | Spec → Review → Implement → Verify | $7-13 |

### How to select a workflow:

```bash
# Explicit workflow selection
claude "Use the greenfield workflow. Build a task management app..."

# Natural language (auto-routed)
claude "I need to migrate our monolith to microservices"  # → migration.yaml
claude "We have a security vulnerability"                    # → security-review.yaml
claude "Train an ML model for fraud detection"               # → ai-ml-pipeline.yaml
```

### Workflow Execution Engine

The workflow engine (`workflows/engine.py`) reads YAML definitions and executes stages:

```
1. Load workflow YAML
2. Resolve stage dependencies (depends_on)
3. Execute each stage by invoking the correct agent
4. Check gates before advancing (automatic + manual)
5. Track status in workflow-state.json
6. Report progress and cost
```

**Status display:**
```
━━━ Workflow: feature-delivery ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ design         Solution Architect     12:30:01  ⏱ 3m
  ⧖ implementation Software Engineer      12:35:01  ⏱ 12m (running)
  ○ testing        Quality Engineer       pending   
  ○ review         Code Reviewer          pending   

  Estimated: $7-13 | Spent: $4.50 | Remaining: $2.50-8.50
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Stage gates block progression until conditions are met:**
```bash
# Manual gate example (requires user approval)
claude "Review the architecture design before proceeding with implementation"

# Automatic gate (evaluated by condition)
# "coverage > 80%" — passes automatically once coverage threshold is met
```

---

## 8. Cost Control & Model Routing

### How It Works

1. Every task is classified S1–S5
2. Classification determines model tier (Fast/Standard/Premium)
3. S4-S5 tasks trigger a Model Switching Gate asking your approval
4. Budget limits are enforced per session and per day

### Complexity Classification

| Tier | Name | Example | Model | Auto-approve? |
|------|------|---------|-------|---------------|
| S1 | Trivial | Typo fix, rename | Fast | Yes |
| S2 | Simple | Bug fix with known cause | Fast | Yes |
| S3 | Moderate | New API endpoint | Standard | Yes |
| S4 | Complex | Feature design, extraction | Premium | **Ask** |
| S5 | Strategic | Architecture, migration | Premium | **Ask** |

### Budget Configuration

```yaml
# In .sdlc-automation-agent.yaml
cost_control:
  enabled: true
  daily_limit: 10                    # Warn at $10/day
  session_limit: 2                   # Warn at $2/session
  hard_stop: 50                      # Hard stop at $50
```

### Override Model for Specific Tasks

```bash
# Override when you know a task needs premium
claude "Use premium model. Design the architecture for our payment system migration."
```

### Cost Dashboard

View your current spending at any time:

```bash
claude "Show me the cost dashboard"
```

```
━━━ Cost Dashboard ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Today:    $4.50 / $10.00  ████░░░░░░  45%
  Session:  $1.20 / $2.00   ██████░░░░  60%
  Remaining until hard stop: $45.50

  Top tasks by cost:
    Architecture review  $2.50  (opus)
    Code implementation  $1.50  (sonnet)
    Bug fix              $0.50  (haiku)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Budget Tracking

Cost is tracked automatically by the budget tracker:

```yaml
# .sdlc-automation-agent/.orchestrator/cost-state.json
{
  "daily": { "spent": 4.50, "date": "2026-07-20" },
  "sessions": [
    { "task": "architecture-review", "model": "claude-opus", "cost": 2.50 },
    { "task": "feature-implement", "model": "claude-sonnet", "cost": 1.50 }
  ]
}
```

Budget alerts fire when approaching limits:
- **80% of daily limit**: Warning notification
- **100% of daily limit**: Ask before any further premium tasks
- **Hard stop**: Block all further task execution until reset

---

## 9. Adding New Skills

### Adding a Single Skill

```bash
# 1. Create the skill directory
mkdir -p .claude/plugins/my-plugin/skills/my-new-skill/

# 2. Create SKILL.md with frontmatter
cat > .claude/plugins/my-plugin/skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: Description of what this skill does
---

# My New Skill

## Key Concepts
- Concept 1
- Concept 2

## Common Patterns
- Pattern 1
- Pattern 2
EOF
```

### Adding a Full Plugin

```bash
# 1. Create plugin structure
mkdir -p .claude/plugins/my-plugin/{.claude-plugin,skills}

# 2. Create plugin manifest
cat > .claude/plugins/my-plugin/.claude-plugin/plugin.json << 'EOF'
{
  "name": "my-plugin",
  "description": "My custom plugin",
  "version": "1.0.0",
  "skills": "./skills"
}
EOF

# 3. Register in plugin.json
# Add "./plugins/my-plugin" to the "plugins" array

# 4. Create skills inside
mkdir .claude/plugins/my-plugin/skills/my-skill/
cat > .claude/plugins/my-plugin/skills/my-skill/SKILL.md << 'EOF'
# My Skill Content
EOF
```

### Adding an Agent Role

```bash
mkdir -p .claude/agent-roles/my-agent/{modes,phases,references}
cat > .claude/agent-roles/my-agent/agent.md << 'EOF'
---
name: my-agent
description: Description of my custom agent
---
EOF
```

---

## 10. Troubleshooting

### MCP Server Not Connecting

```bash
# Test the MCP server directly
npx @agenite/jira-mcp-server --help

# Check environment variables are set
echo $JIRA_API_TOKEN

# Verify the server starts
npx @agenite/jira-mcp-server --check
```

### Plugin Not Loading

```bash
# Verify plugin.json exists
test -f .claude/plugins/my-plugin/.claude-plugin/plugin.json && echo "OK" || echo "Missing"

# Check plugin registration
grep "my-plugin" .claude/plugin.json

# Validate the plugin JSON
python3 -c "import json; json.load(open('.claude/plugins/my-plugin/.claude-plugin/plugin.json'))"
```

### Skill Not Found

```bash
# Check if SKILL.md exists with frontmatter
head -3 .claude/plugins/*/skills/*/SKILL.md

# Run the validator
bash .claude/eng/skill-validator/validate-skill.sh .claude/plugins/

# Verify the skill name matches what you're asking for
grep "^name:" .claude/plugins/*/skills/*/SKILL.md
```

### Cost Control Warnings

```bash
# Check your session spending
# Cost is tracked in the hooks output

# Override cost limits temporarily by editing .sdlc-automation-agent.yaml:
cost_control:
  session_limit: 10                  # Increase session budget
  hard_stop: 100                     # Increase hard stop
```

### Hooks Not Firing

```bash
# Verify hooks.json wiring
python3 -c "
import json
h = json.load(open('.claude/hooks/hooks.json'))
for event, configs in h['hooks'].items():
    for c in configs:
        for hook in c['hooks']:
            print(f'{event}: {hook[\"command\"][:60]}...')
"

# Test a hook directly
bash .claude/hooks/cost-controller/classify-task.sh "Build a new API endpoint"
```
