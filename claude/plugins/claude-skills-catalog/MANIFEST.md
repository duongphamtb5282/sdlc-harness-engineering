# Claude Skills Catalog

Canonical copy of `new-skills/claude-skills/skills/` (66 skills). **Do not load `new-skills/` at runtime.**

**Sync:** `./scripts/sync-from-new-skills.sh` (included in default sync)  
**Install:** `claude --plugin-dir plugins/claude-skills-catalog`  
**Load path:** `${CLAUDE_PLUGIN_ROOT}/plugins/claude-skills-catalog/skills/{skill-name}/SKILL.md`

## Skills (66)

| Skill | Domain | Related specialist / stack |
|-------|--------|----------------------------|
| angular-architect | frontend | stack-frontend, specialist frontend |
| api-designer | design | specialist api-design, system-design/api-design |
| architecture-designer | design | **solution-architect** phase 2 (wired); also system-design, specialist architecture-patterns |
| atlassian-mcp | tools | agent-toolkit/jira |
| chaos-engineer | reliability | specialist reliability-engineering |
| cli-developer | backend | stack-golang |
| cloud-architect | cloud | stack-aws, stack-azure, specialist cloud-platforms |
| code-documenter | docs | specialist documentation, agent-toolkit |
| code-reviewer | review | sdlc-workflows/code-review-and-quality |
| cpp-pro | language | specialist programming-languages/cpp |
| csharp-developer | language | specialist csharp-dotnet |
| database-optimizer | database | specialist database, system-design/data-storage |
| debugging-wizard | debug | sdlc-workflows/debugging-and-error-recovery |
| devops-engineer | devops | specialist devops-cicd |
| django-expert | backend | specialist python |
| dotnet-core-expert | backend | specialist csharp-dotnet, packs/languages |
| embedded-systems | domain | — |
| fastapi-expert | backend | specialist python |
| feature-forge | product | sdlc-workflows/spec-driven-development |
| fine-tuning-expert | ai-ml | specialist ai-ml-integration |
| flutter-expert | mobile | specialist mobile |
| fullstack-guardian | fullstack | stack-frontend + backend specialist |
| game-developer | domain | — |
| golang-pro | language | **DEPRECATED** → use `stack-golang` only |
| graphql-architect | api | specialist api-design |
| java-architect | language | specialist java-kotlin |
| javascript-pro | language | specialist javascript-typescript |
| kotlin-specialist | language | specialist java-kotlin |
| kubernetes-specialist | infra | stack-aws/azure, PE skills |
| laravel-specialist | backend | specialist php |
| legacy-modernizer | refactor | sdlc-workflows/incremental-implementation |
| mcp-developer | tools | agent-toolkit |
| microservices-architect | architecture | system-design/service-decomposition |
| ml-pipeline | ai-ml | specialist ai-ml-integration |
| monitoring-expert | observability | specialist monitoring-logging, system-design/observability |
| nestjs-expert | backend | specialist javascript-typescript |
| nextjs-developer | frontend | stack-frontend/next-best-practices |
| pandas-pro | data | specialist python |
| php-pro | language | specialist php |
| playwright-expert | testing | sdlc-workflows/browser-testing-with-devtools |
| postgres-pro | database | specialist database, stack-frontend/postgres-semantic-search |
| prompt-engineer | ai-ml | specialist ai-ml-integration |
| python-pro | language | specialist python |
| rag-architect | ai-ml | specialist ai-ml-integration, stack-frontend/ai-app |
| rails-expert | backend | specialist ruby |
| react-expert | frontend | stack-frontend/react-best-practices |
| react-native-expert | mobile | specialist mobile |
| rust-engineer | language | specialist rust |
| salesforce-developer | domain | — |
| secure-code-guardian | security | specialist security-practices, CE |
| security-reviewer | security | delivery-toolkit/security-guidance |
| shopify-expert | domain | — |
| spark-engineer | data | specialist python / backend |
| spec-miner | product | sdlc-workflows/spec-driven-development |
| spring-boot-engineer | backend | specialist java-kotlin, packs/languages/java-spring |
| sql-pro | database | specialist sql |
| sre-engineer | reliability | specialist reliability-engineering |
| swift-expert | language | specialist swift |
| terraform-engineer | infra | stack-aws CDK/CFN, PE |
| test-master | testing | specialist testing-strategies, sdlc-workflows/TDD |
| the-fool | review | code-reviewer adversarial mode |
| typescript-pro | language | specialist javascript-typescript |
| vue-expert | frontend | stack-frontend (Vue pack when added) |
| vue-expert-js | frontend | stack-frontend |
| websocket-engineer | realtime | specialist realtime-systems |
| wordpress-pro | domain | — |

## Agent loading

Default SDLC agents use **specialist-skills + stack plugins** first. Use this catalog for **deeper role skills** when:

- Tech stack matches a catalog skill (e.g. Java → `spring-boot-engineer`)
- Specialist skill is loaded but task needs framework-specific depth
- User or orchestrator requests explicit catalog skill by name

See [AGENT-SKILL-MAP.yaml](../AGENT-SKILL-MAP.yaml) and per-agent `skill-extensions/registry.yaml` for routing. Add `claude-skills-catalog/{skill}` entries to registries when you want automatic loading.
