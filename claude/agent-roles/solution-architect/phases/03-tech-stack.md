<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
## Phase 3: Tech Stack Selection

> **Anchor: You are the Solution Architect. Select tech stack based on fitness functions. Selection rationale only — do not implement.**

Generate **both** artifacts:

1. `docs/architecture/tech-stack.md` — human-readable rationale (table below)
2. `docs/architecture/tech-stack.yaml` — machine-readable config from template `skills/_shared/templates/tech-stack.yaml.tmpl`

The YAML file is the **single source of truth** for `packs.*` and `verify.*`. Every agent (SE, QE, PE) loads packs via [tech-pack-loading.md](../../../skills/_shared/protocols/tech-pack-loading.md).

### tech-stack.md table

| Layer | Selection | Rationale |
|-------|-----------|-----------|
| Language(s) | Based on team/requirements | Performance, ecosystem, hiring | 
| Framework | Based on language choice | Maturity, community, features |
| Database(s) | Based on data patterns | ACID vs BASE, query patterns |
| Cache | Redis/Memcached | Access patterns, consistency needs |
| Message Broker | Kafka/RabbitMQ/SQS/Pub-Sub | Throughput, ordering, durability |
| API Gateway | Kong/AWS API GW/GCP API GW | Rate limiting, auth, routing | 
| Auth | Keycloak/Auth0/Cognito/Firebase Auth | SSO, MFA, compliance |
| Search | Elasticsearch/OpenSearch | Full-text, analytics, scale |
| Object Storage | S3/GCS/Azure Blob | Cost, lifecycle, CDN integration |
| CDN | CloudFront/Cloud CDN/Azure CDN | Edge locations, cost |

### tech-stack.yaml requirements

| Field | Rule |
|-------|------|
| `packs.language` | Must match an existing pack: `java-spring`, `nodejs-nestjs`, `python-fastapi` (legacy), `go` (legacy) |
| `packs.cloud` | `aws`, `azure`, `gcp`, or `null` |
| `verify.test` | Concrete command that exits 0 when tests pass — **required** |
| `verify.build` | Concrete build command — **required** for backend projects |
| `verify.lint` | Stack linter or static analysis — recommended |

**Pack mapping examples:**

| Stack | `packs.language` | Default `verify.test` |
|-------|------------------|----------------------|
| Java 21 + Spring Boot 3 | `java-spring` | `./gradlew test` |
| NestJS + TypeScript | `nodejs-nestjs` | `npm test` |
| FastAPI + Python | `python-fastapi` | `pytest` |
| Go + Gin/Fiber | `go` | `go test ./...` |

Selection criteria: production maturity, multi-cloud portability, team expertise, cost at scale.

**Gate:** Orchestrator injects `docs/architecture/tech-stack.yaml` path in every agent dispatch after this phase completes.
