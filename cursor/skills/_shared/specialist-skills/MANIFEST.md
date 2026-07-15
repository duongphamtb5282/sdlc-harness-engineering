# Specialist Skills Manifest

Curated copy under `skills/_shared/specialist-skills/` (sync from reference shelf via `scripts/sync-from-new-skills.sh`).
Merged as one project — edit skills here; do not depend on `new-skills/` at runtime.

**Copied:** 44 skills + 5 code-reviewer references from `claude-code/plugins/pr-review-toolkit`.

## software-design → Solution Architect

| Skill | Path |
|-------|------|
| architecture-patterns | `software-design/architecture-patterns/` |
| system-design | `software-design/system-design/` |
| api-design | `software-design/api-design/` |
| data-design | `software-design/data-design/` |
| design-patterns | `software-design/design-patterns/` |
| ux-principles | `software-design/ux-principles/` |

## software-engineering → Multiple agents

| Skill | Primary agent |
|-------|---------------|
| code-quality | SE, CR |
| testing-strategies | QE |
| devops-cicd | PE |
| performance-optimization | SE, CR |
| security-practices | CE, CR (reference only for OWASP depth) |
| reliability-engineering | PE |
| documentation | TW |
| internationalization | SE |

## development-stacks

| Skill | Primary agent |
|-------|---------------|
| backend | SE |
| frontend | SE (frontend mode) |
| mobile | SE (mobile mode) |
| database | SE, SA |
| cloud-platforms | PE, SA |
| ai-ml-integration | SE (ai-ml mode) |
| realtime-systems | SE |

## programming-languages → Software Engineer

`java-kotlin`, `python`, `javascript-typescript`, `go`, `rust`, `csharp-dotnet`, `cpp`, `ruby`, `php`, `swift`, `shell-bash`, `sql`

## tools-integrations

| Skill | Primary agent |
|-------|---------------|
| analyze-repo | Research Advisor / reverse mode |
| api-tools | QE, TW |
| automation-scripts | PE |
| development-environment | PE |
| git-workflows | PE, branch-finish |
| monitoring-logging | PE |
| project-management | PM |

## domain-applications (conditional)

`saas-platforms`, `e-commerce`, `application-patterns`, `communication-systems`

## code-reviewer references

Copied to `agents/code-reviewer/references/`:

- `silent-failure-hunter.md`
- `pr-test-analyzer.md`
- `type-design-analyzer.md`
- `code-simplifier.md`
- `comment-analyzer.md`
