<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->

# Init Mode

Analyze the project and generate `.sdlc-automation-agent.yaml`. This mode also auto-triggers when any other mode detects that `.sdlc-automation-agent.yaml` does not exist.

1. Detect project structure: language (package.json, go.mod, pyproject.toml, pom.xml, build.gradle), framework (Next.js, NestJS, FastAPI, Spring, Gin), infrastructure (Dockerfile, Terraform, K8s, CI/CD), architecture (monolith/microservices/monorepo)
2. Classify health: greenfield (no code) vs brownfield (existing codebase)
3. Generate `.sdlc-automation-agent.yaml` from the template at `${CLAUDE_PLUGIN_ROOT}/skills/_shared/templates/sdlc-automation-agent.yaml.tmpl`
4. Scaffold tracker description templates into `docs/templates/` (if not already present)
5. Print summary of detected configuration

### Pack detection (write to generated yaml)

| Signal                              | `packs.language` | `project.language` |
| ----------------------------------- | ---------------- | ------------------ |
| `pom.xml` / `build.gradle*`         | `java-spring`    | `java`             |
| `nest-cli.json` / `@nestjs/core`    | `nodejs-nestjs`  | `typescript`       |
| `express` in package.json (no nest) | `nodejs-express` | `javascript`       |
| `pyproject.toml` + fastapi          | `python-fastapi` | `python`           |
| `go.mod`                            | `go`             | `go`               |

| Signal                     | `packs.cloud` |
| -------------------------- | ------------- |
| `provider "aws"` in `*.tf` | `aws`         |
| `provider "azurerm"`       | `azure`       |

### Scaffold spec + steering folders (greenfield)

```python
Bash("mkdir -p .sdlc-automation-agent/specs .sdlc-automation-agent/steering .sdlc-automation-agent/.protocols")
for name, stub in [
  ("product.md", "# Product steering\n\nDomain language, personas, compliance.\n"),
  ("tech.md", "# Tech steering\n\nPointer: docs/architecture/tech-stack.yaml\n"),
  ("structure.md", "# Repo structure rules\n"),
  ("workflow.md", "# Branch, PR, review rules\n"),
]:
  path = f".sdlc-automation-agent/steering/{name}"
  if not Glob(path):
    Write(path, stub)
```

### Scaffold Deep Spec protocol (greenfield)

When deep spec is enabled in `.sdlc-automation-agent.yaml`, copy the protocol file:

```python
proto_src = f"{CLAUDE_PLUGIN_ROOT}/skills/_shared/protocols/deep-spec.md"
proto_dst = ".sdlc-automation-agent/.protocols/deep-spec.md"
if not Glob(proto_dst):
    if Glob(proto_src):
        Bash(f"cp \"{proto_src}\" \"{proto_dst}\"")
        print(f"Deep Spec protocol installed at {proto_dst}")
    else:
        # Generate inline fallback
        Write(proto_dst, """# Deep Spec Protocol

The spec folder is the SINGLE source of truth. Every agent reads it, validates against it, writes back to it.

## Traceability Chain
REQ-ID → Contracts → Design → Tasks → Code → Tests → Receipts

## Gates
- requirements_approved: All REQ-IDs have ACs + behavioral contracts
- design_approved: Traceability table complete + ADRs tagged
- tasks_approved: Every REQ-ID in ≥1 task
- test_coverage_pass: Every REQ-ID has ≥1 test (QE)
- spec_compliance_pass: Code maps to spec'd REQ-IDs (CR)
""")
        print(f"Deep Spec protocol generated at {proto_dst}")
```

Also scaffold template copies for reference:

```python
Bash(f"mkdir -p .sdlc-automation-agent/templates/specs")
for tmpl in ["contracts.tmpl.md", "tests.tmpl.md"]:
    src = f"{CLAUDE_PLUGIN_ROOT}/skills/_shared/templates/specs/{tmpl}"
    dst = f".sdlc-automation-agent/templates/specs/{tmpl}"
    if Glob(src) and not Glob(dst):
        Bash(f"cp \"{src}\" \"{dst}\"")
```

Add deep_spec section to generated `.sdlc-automation-agent.yaml`:

```python
config_text = Read(".sdlc-automation-agent.yaml")
if "deep_spec:" not in config_text:
    deep_spec_block = """

# Deep Spec — spec-driven traceability from requirements through delivery
deep_spec:
  enabled: true
  gates:
    test_coverage: true
    spec_compliance: true
  artifacts:
    contracts: true
    coverage_report: true
"""
    Edit(".sdlc-automation-agent.yaml",
         old="# sdlc-automation-agent configuration",
         new=f"# sdlc-automation-agent configuration{deep_spec_block}")
```

```python
Skill(skill="sdlc-automation-agent:init")
# The init logic reads from: ${CLAUDE_PLUGIN_ROOT}/skills/_shared/templates/sdlc-automation-agent.yaml.tmpl
# Output: .sdlc-automation-agent.yaml at project root
```

After config generation, scaffold tracker description templates into the project. These templates define the section structure used when creating issues in the configured tracker (Jira, GitHub, Teamwork). If a `docs/templates/` directory already exists with templates, skip scaffolding — the user has customized them.

```python
# Scaffold tracker description templates (skip if already present)
# These templates control which ## sections appear in Jira/GitHub/Teamwork issue descriptions.
# The tracker adapters read section headings from these files via _load_template_sections().
templates_dir = "docs/templates"
story_exists = Glob(f"{templates_dir}/story.md")

if not story_exists:
    Bash(f'mkdir -p {templates_dir}')

    # Try to copy built-in defaults from the plugin source (plain .md files).
    # In the published plugin these are encrypted (.md.enc), so copy may fail — that's fine,
    # the scaffolding below generates them inline as a fallback.
    builtin_dir = f"${{CLAUDE_PLUGIN_ROOT}}/skills/_shared/templates/tracker"
    for src_name, dst_name in [("user-story.md", "story.md"), ("task.md", "task.md"), ("epic.md", "epic.md"), ("bug.md", "bug.md")]:
        dst_path = f"{templates_dir}/{dst_name}"
        if not Glob(dst_path):
            # Try plain .md first (dev environment), skip if not found (published plugin uses .enc)
            result = Bash(f'cp "{builtin_dir}/{src_name}" "{dst_path}" 2>/dev/null && echo OK || echo SKIP')
            if "SKIP" in result:
                # Generate minimal template inline as fallback
                # These provide section headings that _load_template_sections() reads
                if dst_name == "story.md":
                    Write(dst_path, """# {{ID}}: {{TITLE}}

## Story

As a {{ROLE}}, I want {{CAPABILITY}}, so that {{BENEFIT}}.

## Acceptance Criteria

* [ ] **AC-01:** Given {{PRECONDITION}}, When {{ACTION}}, Then {{EXPECTED}}

## Business Rules

- {{RULE}}

## Testing Notes

- **Happy path:** {{DESCRIPTION}}
- **Negative:** {{DESCRIPTION}}

## Technical Context

{{NOTES}}

## Dependencies

- {{DEPENDENCY}}
""")
                elif dst_name == "bug.md":
                    Write(dst_path, """# {{ID}}: {{TITLE}}

## Summary

{{DESCRIPTION}}

## Steps to Reproduce

1. {{STEP}}

## Expected Behavior

{{EXPECTED}}

## Actual Behavior

{{ACTUAL}}

## Acceptance Criteria

* [ ] **AC-01: Fix verified** — {{DESCRIPTION}}
* [ ] **AC-02: Regression test** — Automated test prevents recurrence

## Technical Context

{{NOTES}}
""")
                elif dst_name == "task.md":
                    Write(dst_path, """# {{ID}}: {{TITLE}}

## Objective

{{DESCRIPTION}}

## Acceptance Criteria

* [ ] **AC-01:** Given {{PRECONDITION}}, When {{ACTION}}, Then {{EXPECTED}}

## Technical Context

{{NOTES}}

## Testing Notes

- {{DESCRIPTION}}

## Dependencies

- {{DEPENDENCY}}
""")
                elif dst_name == "epic.md":
                    Write(dst_path, """# {{ID}}: {{TITLE}}

## Objective

{{DESCRIPTION}}

## User Impact Statement

{{IMPACT}}

## Feature List

| Feature | Stories | Priority |
|---------|---------|----------|
| {{FEATURE}} | {{STORIES}} | {{PRIORITY}} |

## NFRs

- {{NFR}}

## Technical Context

{{NOTES}}
""")

# Wire scaffolded templates into .sdlc-automation-agent.yaml so adapters use them.
# This ensures Jira/GitHub/Teamwork adapters read section structure from
# the project's templates rather than using hardcoded defaults.
config_text = Read(".sdlc-automation-agent.yaml")
if 'story: ""' in config_text:
    Edit(".sdlc-automation-agent.yaml", old='story: ""', new='story: "docs/templates/story.md"')
    Edit(".sdlc-automation-agent.yaml", old='task: ""', new='task: "docs/templates/task.md"')
    Edit(".sdlc-automation-agent.yaml", old='epic: ""', new='epic: "docs/templates/epic.md"')
    Edit(".sdlc-automation-agent.yaml", old='bug: ""', new='bug: "docs/templates/bug.md"')
```

After config generation, generate lightweight CLAUDE.md and README.md sections:

```python
# Read project name from the just-created .sdlc-automation-agent.yaml
project_name = Read(".sdlc-automation-agent.yaml")  # extract project.name

# Generate CLAUDE.md sdlc-automation-agent section (fenced block — safe to run repeatedly)
claude_section = f"""# sdlc-automation-agent Pipeline

This project uses **sdlc-automation-agent** — a multi-agent adaptive delivery system with 9 specialized agents, pluggable AI backends, and Scrum + Kanban lifecycle support. Always route requests through `/sdlc-automation-agent` rather than making ad-hoc changes.

- **Config:** `.sdlc-automation-agent.yaml`
- **Workspace:** `.sdlc-automation-agent/`
- **Build mode:** {build_mode} (scrum or kanban)

To start: describe what you want to build, or run `/sdlc-automation-agent`.

## Agent Roster

| Agent | Role |
|---|---|
| `product-manager` | Backlog refinement, Sprint Planning, story decomposition |
| `solution-architect` | Incremental architecture, ADRs, API contracts (on-demand) |
| `software-engineer` | Story-level builder (backend, frontend, ai-ml, mobile) |
| `quality-engineer` | Per-story verifier, test generation |
| `code-reviewer` | Per-story reviewer (adaptive intensity) |
| `compliance-engineer` | Security audit, STRIDE/OWASP (on-demand) |
| `platform-engineer` | CI/CD, Docker, IaC, monitoring, reliability |
| `technical-writer` | Sprint reports, API docs, developer guides |
| `research-advisor` | Thinking partner, domain research |

## Mode Routing (via `/sdlc-automation-agent`)

New feature → **Feature** | Sprint work → **Sprint** | Tests → **Test** | Code review → **Review** | Architecture → **Architect** | Bug fix → **Debug** | Security → **Verify** | Deploy → **Deploy** | Research → **Explore** | Performance → **Optimize**

## Tracker CLI

All story/sprint/epic operations go through `tracker_cli.py` — never read story files directly.
```

python3 ${CLAUDE_PLUGIN_ROOT}/skills/\_shared/scripts/tracker/tracker_cli.py --project-dir . <cmd>

```
Commands: `get-backlog`, `get-sprint-backlog <N>`, `get-story <id>`, `update-status <id> <status>`, `create-story`, `list-sprints`

## Receipt Protocol

Every agent writes a JSON receipt to `.sdlc-automation-agent/.orchestrator/receipts/`. Missing `verification_commands` **blocks the pipeline**. Required fields: `artifacts`, `metrics`, `verification_commands`, `verification_summary`.

## Git Safety Rules (MANDATORY)

These rules apply to all sdlc-automation-agent agents, Claude Code, and automated tooling:

1. **NEVER commit or push to shared branches** (`dev`, `qa`, `uat`, `main`, `prod`, `staging`, `release`). All work MUST happen on feature branches.
2. **NEVER create commits without explicit user approval.** Always show the diff and ask before committing.
3. **NEVER push to any remote branch without explicit user approval.** Always ask before running `git push`.
4. **NEVER create or merge pull requests without explicit user approval.**
5. **NEVER run destructive git operations** (`git push --force`, `git reset --hard`, `git clean -f`, `git checkout .`).
6. **NEVER run database migrations against shared environments** (dev, qa, uat, prod). Migrations can only be run locally.

If the user says "just do it" or "go ahead", that applies to the current code change only — NOT to committing, pushing, or merging.

**At the start of every session, ask the user how they'd like to work** using AskUserQuestion:
- "Use sdlc-automation-agent (Recommended)" — route changes through specialized agents
- "Work directly without the plugin" — make changes freely
- "Chat about this" — discuss approach together

<!-- sdlc-automation-agent-state
phase: INIT
sprint: 0/0
engagement: guided
config: .sdlc-automation-agent.yaml
-->"""
Bash(f'printf "%s" \'{claude_section}\' | python3 "${{CLAUDE_PLUGIN_ROOT}}/hooks/lib/update_claude_md.py" "${{CLAUDE_PROJECT_DIR}}"')

# Generate README.md scaffold (greenfield only — skip if README already exists)
if not Glob("README.md"):
    readme_section = f"""# {{project_name}}

> Built with [sdlc-automation-agent](https://github.com/h3tco/sdlc-automation-agent) delivery pipeline.

## Quick Start

_Commands will be added as the pipeline progresses._

## Architecture

_Architecture documentation will be generated during Inception._

## Development

_Development setup will be documented during Sprint Execution._

---

This README is updated automatically as sdlc-automation-agent delivers."""
    Bash(f'printf "%s" \'{readme_section}\' | python3 "${{CLAUDE_PLUGIN_ROOT}}/hooks/lib/update_claude_md.py" "${{CLAUDE_PROJECT_DIR}}" --file README.md')
```

After config generation, offer:

```python
AskUserQuestion(questions=[{
  "question": "Project configured. What next?",
  "options": [
    {"label": "Start building (Recommended)", "description": "Describe what you want to build"},
    {"label": "Reverse-engineer first", "description": "Run Discover mode to understand existing codebase"},
    {"label": "Just configure — done for now"}
  ]
}])
```

**Auto-init in other modes:** Before Step 1 (Request Classification), if `.sdlc-automation-agent.yaml` does not exist, run Init Mode inline and then continue to the requested mode.
