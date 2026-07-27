# Deep Spec: Multi-Tenant SaaS Platform — TDD + Technical Tasks

**Spec ID:** `multi-tenant-saas`  
**Status:** approved  
**Version:** 2.0.0  
**Tech Stack:** Java 21 + Spring Boot 3 · Next.js 19 + React · PostgreSQL · AWS ECS + RDS · LangChain4j + Pinecone  
**Methodology:** Test-Driven Development — every feature starts with failing tests, then technical tasks implement to make them pass.

---

## Table of Contents

1. [Requirements (EARS)](#1-requirements)
2. [Behavioral Contracts](#2-behavioral-contracts)
3. [Architecture Design](#3-architecture-design)
4. [TDD Test Specification](#4-tdd-test-specification)
5. [Technical Tasks](#5-technical-tasks)
6. [RAG Evaluation](#6-rag-evaluation)
7. [TDD Execution Protocol](#7-tdd-execution-protocol)

---

## 1. Requirements

### Intent

Build a multi-tenant SaaS platform where each tenant (organization) operates in an isolated workspace with its own users, roles, data, and AI assistant. Tenants can configure role hierarchies, invite users, and each tenant gets a dedicated RAG-powered chat assistant that answers questions from their private knowledge base.

### Scope

| In scope | Out of scope |
|----------|--------------|
| Multi-tenant architecture with data isolation | On-premise deployment |
| Role-based access control (RBAC) with custom roles | Social login providers |
| Per-tenant AI chat assistant (RAG) | Multi-region replication |
| Tenant onboarding & provisioning | Tenant migration between regions |
| User invitation & management | Billing & subscription |
| Tenant-specific knowledge base upload | Audit log export |

---

### Functional Requirements (EARS)

#### Ubiquitous

| ID | Requirement |
|----|-------------|
| REQ-001 | The platform shall enforce data isolation at the database row level using a `tenant_id` column on every tenant-scoped table. |
| REQ-002 | The system shall require authentication for every API request except the tenant login endpoint. |
| REQ-003 | Every API response shall include the tenant context in the response header `X-Tenant-ID`. |
| REQ-004 | The platform shall assign every user exactly one role within their tenant. |
| REQ-005 | The system shall enforce that a user belonging to Tenant A cannot access any data belonging to Tenant B. |
| REQ-006 | The system shall support three built-in roles: `admin`, `editor`, `viewer` with descending permission levels. |
| REQ-007 | The admin role shall have permissions to: manage users, manage roles, manage tenant settings, access AI assistant configuration. |
| REQ-008 | The editor role shall have permissions to: read/write tenant data, upload knowledge base documents, use the AI chat assistant. |
| REQ-009 | The viewer role shall have permissions to: read tenant data, use the AI chat assistant. |
| REQ-010 | The system shall allow tenant admins to create custom roles with a user-defined set of permissions. |
| REQ-011 | The platform shall provide each tenant with a dedicated AI chat assistant that answers questions using only the tenant's uploaded knowledge base. |
| REQ-012 | The AI chat assistant shall return answers with citations pointing to the source document and chunk. |
| REQ-013 | The system shall support uploading documents (PDF, TXT, DOCX, MD) as knowledge base sources. |
| REQ-014 | The system shall chunk uploaded documents, generate embeddings, and store them in a tenant-scoped vector index. |
| REQ-015 | Each tenant's vector data shall be stored in a dedicated Pinecone namespace isolated from all other tenants. |

#### Event-driven

| ID | When | The system shall |
|----|------|------------------|
| REQ-020 | When a new tenant is created | The system shall provision a tenant schema, create the admin user, generate a default role set, and create a dedicated Pinecone namespace. |
| REQ-021 | When a user is invited to a tenant | The system shall generate an invitation token with a 72-hour expiry, send an email with the activation link, and create a `PENDING` user record. |
| REQ-022 | When a user accepts an invitation | The system shall activate the user record, assign the default `viewer` role, and redirect to the tenant workspace. |
| REQ-023 | When a tenant admin creates a custom role | The system shall validate the permission set, persist the role definition, and make it available for user assignment. |
| REQ-024 | When a user's role is changed | The system shall invalidate the user's current session token and require re-authentication with the new permissions. |
| REQ-025 | When a document is uploaded to a tenant's knowledge base | The system shall extract text, split into chunks, generate embeddings via OpenAI, and upsert to the tenant's Pinecone namespace. |
| REQ-026 | When a user sends a message to the AI chat assistant | The system shall embed the query, retrieve the top-5 relevant chunks from the tenant's Pinecone namespace, construct a prompt with context + query, call the LLM, and return the answer with citations. |

#### State-driven

| ID | While | The system shall |
|----|-------|------------------|
| REQ-030 | While a user has role `viewer` | The system shall hide all "Create", "Edit", "Delete" UI elements and reject all mutation API calls with HTTP 403. |
| REQ-031 | While a user has role `editor` | The system shall allow data mutations but hide "User Management" and "Role Management" UI elements. |
| REQ-032 | While tenant storage quota is exceeded | The system shall reject document uploads with HTTP 413 and display a quota warning in the UI. |
| REQ-033 | While AI assistant is processing | The system shall show a typing indicator and disable the send button to prevent duplicate submissions. |

#### Optional

| ID | Where | The system shall |
|----|-------|------------------|
| REQ-040 | Where tenant SSO is enabled (config flag) | The system shall delegate authentication to the tenant's identity provider via OIDC. |
| REQ-041 | Where cross-tenant data sharing is enabled | The system shall allow tenant admins to publish specific documents to a shared knowledge base accessible by all tenants. |

#### Unwanted behavior

| ID | If | Then the system shall |
|----|-----|----------------------|
| REQ-050 | If a user attempts to access a resource in another tenant | The system shall return HTTP 404 (not 403) to avoid leaking tenant existence. |
| REQ-051 | If the Pinecone vector store is unreachable | The system shall return a fallback response: "I'm sorry, the knowledge base is temporarily unavailable" and log the incident. |
| REQ-052 | If document chunking fails (unsupported format, corruption) | The system shall reject the upload with HTTP 422 and a descriptive error message. |
| REQ-053 | If the LLM API returns an error or rate-limit response | The system shall retry up to 2 times with exponential backoff, then return a fallback error to the user. |
| REQ-054 | If an invitation token is expired | The system shall return HTTP 410 Gone with a message: "This invitation has expired. Contact your tenant admin for a new invitation." |

---

### Non-Functional Requirements

| NFR-ID | Requirement | Threshold |
|--------|-------------|-----------|
| NFR-PERF-01 | AI chat response time (p95) | < 3 seconds end-to-end |
| NFR-PERF-02 | API response time excluding AI (p95) | < 300ms |
| NFR-PERF-03 | Document processing throughput | < 30 seconds per 100-page document |
| NFR-SEC-01 | Tenant data isolation | Zero data leakage between tenants |
| NFR-SEC-02 | Authentication | JWT with RS256, 15-minute access token expiry |
| NFR-SCAL-01 | Tenant scale | Support 10,000+ tenants on a single deployment |
| NFR-SCAL-02 | Document storage | 10 GB per tenant, 10k documents per tenant |

---

### Acceptance Criteria

| AC-ID | Refs | Given | When | Then |
|-------|------|-------|------|------|
| AC-001 | REQ-001 | A tenant-scoped table exists | I query with `tenant_id = X` | I only see rows matching `tenant_id = X` |
| AC-002 | REQ-005 | User A (Tenant A) and Resource B (Tenant B) exist | User A requests Resource B | HTTP 404 is returned |
| AC-003 | REQ-010 | Admin user on Tenant A | They create a custom role with "Export" permission | The role is saved and assignable |
| AC-004 | REQ-011 | Tenant has uploaded 5 documents | User asks "What is our refund policy?" | Answer cites documents 2 and 4 with chunk references |
| AC-005 | REQ-020 | A new tenant signup completes | The system provisions the tenant | Tenant schema, roles, and Pinecone namespace exist |
| AC-006 | REQ-021 | Admin invites "user@example.com" | The invitation is sent | Token is created, email is sent, user record is PENDING |
| AC-007 | REQ-025 | User uploads `policy.pdf` (50 pages) | The document is processed | Chunks are in Pinecone namespace, document status = READY |
| AC-008 | REQ-030 | Viewer user is on a page | They look for "Delete" button | Button is not rendered; API mutations return 403 |
| AC-009 | REQ-050 | Attacker guesses tenant ID in URL | They request `/api/tenants/456/data` from tenant 123 | HTTP 404 is returned |
| AC-010 | REQ-053 | LLM API returns 429 rate limit | The system retries | Retry happens after 1s, then 2s; fallback shown after 3 failures |

---

### Open Decisions

| OD-ID | Question | Status |
|-------|----------|--------|
| OD-001 | Tenant storage quota: hard limit or soft limit with overage billing? | OPEN |
| OD-002 | Cross-tenant document sharing: allow-list or full catalog? | OPEN |

---

## 2. Behavioral Contracts

### REQ-001 — Tenant Data Isolation

| Aspect | Specification |
|--------|--------------|
| **Mechanism** | Row-level `tenant_id` column on every tenant-scoped table + filter interceptor that auto-applies `WHERE tenant_id = :current` to queries |
| **Error** | Missing `tenant_id` in JWT → HTTP 401. Cross-tenant access → HTTP 404. |
| **Side effects** | None — filtering is transparent to business logic. |
| **Idempotent** | Yes — reads are always idempotent. |

### REQ-011 — AI Chat Assistant (Per-Tenant RAG)

| Aspect | Specification |
|--------|--------------|
| **Input** | `POST /api/tenants/{tenantId}/chat` body: `{query, history[]}` |
| **Output** | `{answer, citations[{document, chunk, relevance, snippet}], processing_time_ms}` |
| **Error: Client** | Empty query → 422. Query >2000 chars → 422. |
| **Error: Server** | Pinecone timeout → fallback message. LLM rate limit → retry 2x → fallback. |
| **Side effects** | Usage logged to `tenant_usage` table (query count, token count). |
| **Idempotent** | No. |
| **Rate limit** | 30 queries/min/user. 1000 queries/day/tenant. |

### REQ-020 — Tenant Provisioning

| Aspect | Specification |
|--------|--------------|
| **Input** | `POST /api/admin/tenants` body: `{name, domain, admin_email}` |
| **Output** | HTTP 201 `{tenant_id, status: ACTIVE, admin_user_id, pinecone_namespace}` |
| **Error: Client** | Duplicate name → 409. Invalid domain → 422. |
| **Error: Server** | Pinecone namespace creation fails → rollback tenant creation → HTTP 500. |
| **Side effects** | (1) Tenant row created. (2) Admin user created. (3) Default roles seeded. (4) Pinecone namespace created. (5) Welcome email sent. |
| **Idempotent** | No — each call creates a new tenant. |

### REQ-026 — AI Chat Query Pipeline

| Aspect | Specification |
|--------|--------------|
| **Input** | `POST /api/tenants/{id}/chat` body: `{query, history[]}` |
| **Pipeline** | Embed query → Retrieve top-5 chunks (namespace = tenant_id) → Build prompt → Call LLM → Return answer + citations |
| **Min chunks** | Minimum score 0.7. If <3 above threshold, expand to top-10. |
| **Fallback** | Empty namespace → "No documents uploaded yet." |
| **Side effects** | Query logged to `chat_history`. Token count logged to `tenant_usage`. |
| **Idempotent** | No. |

---

## 3. Architecture Design

### System Context

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Next.js)                           │
│  apps/web/                                                          │
│  └─ routes: /[tenantId]/dashboard, /[tenantId]/chat, /[tenantId]/admin │
├─────────────────────────────────────────────────────────────────────┤
│                        API GATEWAY                                    │
│  Routes /api/tenants/{tenantId}/* → validate JWT → extract tenant   │
├────────────────────┬──────────────────────┬─────────────────────────┤
│  IDENTITY SERVICE  │  TENANT SERVICE      │  AI SERVICE              │
│  auth-service      │  tenant-service      │  ai-service              │
│  • JWT auth        │  • Tenant CRUD        │  • Document ingestion    │
│  • User mgmt       │  • RBAC enforcement   │  • Chunking & embedding  │
│  • Invitations     │  • Role definitions   │  • Pinecone CRUD         │
│  • Session mgmt    │  • User-role mapping  │  • RAG query pipeline    │
├────────────────────┼──────────────────────┼─────────────────────────┤
│  PostgreSQL (RDS)  │  PostgreSQL (RDS)     │  Pinecone (Vector DB)    │
│  users, roles,     │  tenants,             │  Namespace per tenant   │
│  invitations       │  documents,           │  tnt_abc123, tnt_def456 │
│                    │  chat_history         │                         │
└────────────────────┴──────────────────────┴─────────────────────────┘
```

### Entity Model (Conceptual)

| Entity | Key Fields | Tenant-Scoped? |
|--------|-----------|----------------|
| `Tenant` | id, name, domain, status, pinecone_namespace | — (root) |
| `TenantSettings` | sso_enabled, ai_model, max_queries_per_day | Yes |
| `User` | id, email, name, status, password_hash | Yes |
| `Role` | id, name, is_system, permissions (JSON) | Yes |
| `UserRole` | user_id, role_id | Yes |
| `Invitation` | email, token, expires_at, status | Yes |
| `Document` | filename, file_type, status, chunk_count, s3_key | Yes |
| `ChatMessage` | query, answer, citations, tokens_used, processing_ms | Yes |

### Tenant Isolation Strategy

| Layer | Mechanism |
|-------|-----------|
| Database | `tenant_id` column on every tenant-scoped table + filter interceptor on all repository queries |
| API | JWT contains `tenant_id`; gateway validates every request matches JWT's tenant |
| Vector Store | Pinecone namespace per tenant (`tnt_{id}`) — isolated at the API level |
| Frontend | Route prefix `/[tenantId]/`; session stores tenant context |

### RBAC Permission Model

```
Built-in roles:
  admin:   read, write, manage_users, manage_roles, ai_chat, export, manage_settings
  editor:  read, write, ai_chat
  viewer:  read, ai_chat

Custom roles: JSON-based permission set defined by tenant admin.
  Example "support": read, ai_chat, export
  Example "manager": read, write, ai_chat, export, manage_users
```

---

### Design Traceability

| REQ-ID | Logical Component | Responsibility |
|--------|------------------|----------------|
| REQ-001 | Tenant Filter | Auto-appends `WHERE tenant_id = :current` to all queries |
| REQ-002 | JWT Auth Filter | Validates JWT on every request except `/auth/login` |
| REQ-004 | UserRole Assignment | Each user has exactly one role record within a tenant |
| REQ-005 | Tenant Filter + Route Guard | Cross-tenant requests blocked at data + API layers |
| REQ-010 | Role CRUD API | Admin creates/edits custom role definitions |
| REQ-011 | RAG Query Pipeline | Embed → Retrieve → Prompt → LLM → Answer |
| REQ-015 | Pinecone Namespace | Each tenant has a dedicated, isolated namespace |
| REQ-020 | Provisioning Workflow | Tenant creation → seed roles → create admin → Pinecone ns |
| REQ-021 | Invitation Service | Generate token → send email → PENDING record |
| REQ-024 | Session Service | Invalidate JWT tokens on role change → force re-auth |
| REQ-025 | Ingestion Pipeline | Upload → chunk → embed → store in tenant namespace |
| REQ-030 | UI Permission Hooks | Conditional render based on user's permission set |
| REQ-050 | 404 Obfuscation | Cross-tenant access returns 404 (not 403) |
| REQ-051 | Fallback Handler | Pinecone unavailable → graceful error message |
| REQ-053 | LLM Retry Client | 2 retries with exponential backoff → fallback |

---

## 4. TDD Test Specification

### TDD Protocol

Every feature follows **Red → Green → Refactor**:

1. **RED** — Write the test first. It fails because no implementation exists.
2. **GREEN** — Implement the minimum code to make the test pass.
3. **REFACTOR** — Clean up while keeping tests green.

Test ordering follows the **TDD Pyramid**:
```
Layer 1: Unit tests (fast, isolated, deterministic) — written FIRST
Layer 2: Integration tests (real DB, real Pinecone test index) — written SECOND
Layer 3: E2E / API tests (full HTTP, browser) — written THIRD
```

No implementation code is written until its corresponding test exists and fails.

---

### Test Suite 1: Tenant Isolation (REQ-001, REQ-005, REQ-050)

These are the **foundation tests** — they enforce the core security invariant. Write and pass these before any feature code.

#### T1-UT-001: TenantFilter appends WHERE clause

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit |
| **File** | `TenantFilterTest.java` |
| **Phase** | RED (write first, before any filter code) |

```
Given a repository query on a tenant-scoped entity
When TenantFilter intercepts the query execution
Then the resulting query includes "WHERE tenant_id = :currentTenant"
```

- [ ] Test fails (RED): no filter exists
- [ ] Test passes (GREEN): filter implemented
- [ ] Refactor: extract tenant extraction to utility

#### T1-UT-002: TenantFilter uses correct tenant from security context

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit |
| **File** | `TenantFilterTest.java` |

```
Given SecurityContext holds tenant_id "tnt_abc123"
When TenantFilter resolves the current tenant
Then the resolved tenant_id equals "tnt_abc123"
```

#### T1-IT-001: Cross-tenant query returns empty result

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `TenantIsolationIntegrationTest.java` |

```
Given Tenant A has 10 documents and Tenant B has 10 documents
When querying documents as Tenant A user
Then exactly 10 documents are returned (not 20)
```

#### T1-IT-002: Cross-tenant API returns 404 (not 403)

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `CrossTenantAccessTest.java` |

```
Given User A (Tenant A) has a valid JWT for Tenant A
When User A calls GET /api/tenants/tenant-b/documents
Then HTTP 404 is returned (not 403, not 401)
And response body does not reveal tenant-b exists
```

#### T1-E2E-001: Attacker cannot enumerate tenants

| Aspect | Detail |
|--------|--------|
| **Layer** | E2E |
| **File** | `CrossTenantAccessTest.java` or separate E2E |

```
Given User A (Tenant A) has a valid JWT
When User A attempts: GET /api/tenants/nonexistent-id/data
And When User A attempts: GET /api/tenants/valid-but-different-id/data
Then both return HTTP 404 with identical response bodies
```

---

### Test Suite 2: RBAC (REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-030, REQ-031)

#### T2-UT-001: Permission evaluator — admin has all permissions

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit |
| **File** | `PermissionEvaluatorTest.java` |

```
Given a user has role "admin" with permissions ["read", "write", "manage_users", "manage_roles", "ai_chat", "export", "manage_settings"]
When checking hasPermission("manage_roles")
Then returns true
```

#### T2-UT-002: Permission evaluator — viewer denied write

```
Given a user has role "viewer" with permissions ["read", "ai_chat"]
When checking hasPermission("write")
Then returns false
```

#### T2-UT-003: Custom roles are evaluated identically to built-in

```
Given a custom role "support" with permissions ["read", "ai_chat", "export"]
When checking hasPermission("export")
Then returns true
(same behavior as admin's export permission)
```

#### T2-IT-001: Viewer mutation API returns 403

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `RbacApiTest.java` |

```
Given a user with role "viewer" has a valid JWT
When they POST /api/tenants/{id}/documents (a mutation)
Then HTTP 403 is returned with error code "FORBIDDEN"
```

#### T2-IT-002: Role change invalidates session

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `SessionInvalidationTest.java` |

```
Given a user has role "viewer" and an active JWT
When admin changes user's role to "editor"
Then the old JWT is invalidated (returns 401 on next request)
And user can login again to get new JWT with editor permissions
```

#### T2-E2E-001: Viewer cannot see edit UI

| Aspect | Detail |
|--------|--------|
| **Layer** | E2E (Playwright) |
| **File** | `rbac-ui.spec.ts` |

```
Given a user with role "viewer" is logged in
When they view the documents page
Then no "Upload", "Edit", or "Delete" buttons/links are visible
And document table shows only "View" action
```

---

### Test Suite 3: Tenant Provisioning (REQ-020, REQ-021, REQ-022, REQ-054)

#### T3-UT-001: Tenant creation returns provisioned resources

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit |
| **File** | `TenantProvisioningTest.java` |

```
Given a tenant creation request with {name: "Acme Corp", admin_email: "admin@acme.com"}
When TenantProvisioningService.provision() is called
Then returns TenantProvisionResult containing:
  - tenant_id (non-null, starts with "tnt_")
  - admin_user_id (non-null)
  - pinecone_namespace (matches tenant_id)
```

#### T3-IT-001: Tenant provisioning creates all resources

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `TenantProvisioningIntegrationTest.java` |

```
Given a valid tenant creation request
When the provisioning workflow completes
Then:
  - tenants table has a row with status = ACTIVE
  - users table has admin user with email = admin@acme.com, status = ACTIVE
  - roles table has 3 rows: admin, editor, viewer for this tenant
  - user_roles has admin user assigned to admin role
  - Pinecone namespace {tenant_id} exists and is queryable
```

#### T3-UT-002: Invitation creates PENDING user

```
Given admin on Tenant A
When they invite "user@example.com" with role "editor"
Then:
  - Invitation record created with status PENDING
  - Token is non-null, 72-hour expiry
  - User record created with status PENDING
```

#### T3-IT-002: Invitation acceptance activates user

```
Given a PENDING invitation with valid token
When POST /api/invitations/accept with the token
Then:
  - User status changes to ACTIVE
  - User has role "viewer" (default)
  - Invitation status changes to ACCEPTED
  - Response is 200 with redirect URL
```

#### T3-UT-003: Expired invitation returns 410

```
Given an invitation token with expires_at in the past
When POST /api/invitations/accept with this token
Then HTTP 410 is returned
And body contains "This invitation has expired"
```

---

### Test Suite 4: Document Ingestion (REQ-013, REQ-014, REQ-025, REQ-052, REQ-032)

#### T4-UT-001: Document upload validates file type

```
Given a document upload request
When file type is "pdf", "txt", "docx", or "md"
Then the upload is accepted (HTTP 201)
When file type is "exe", "zip", or no extension
Then the upload is rejected (HTTP 422)
```

#### T4-IT-001: Document processing pipeline stores chunks

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `IngestionPipelineIntegrationTest.java` |

```
Given a 50-page PDF document is uploaded to Tenant A
When the ingestion pipeline processes it
Then:
  - Document status changes from PENDING → PROCESSING → READY
  - Document has chunk_count > 0
  - Pinecone namespace (tenant_a) has vectors for this document
  - Pinecone namespace (tenant_b) has zero vectors from this document
```

#### T4-UT-002: Storage quota exceeded rejects upload

```
Given Tenant A has 10GB storage_used == 10GB storage_quota
When user uploads a 1MB document
Then HTTP 413 is returned
And error message mentions quota exceeded
```

#### T4-UT-003: Corrupt document returns 422

```
Given a corrupt/non-parseable file is uploaded
When the chunking pipeline processes it
Then:
  - Document status = FAILED
  - Response includes error description
```

---

### Test Suite 5: AI Chat RAG (REQ-011, REQ-012, REQ-015, REQ-026, REQ-033, REQ-051, REQ-053)

#### T5-UT-001: RAG query returns answer with citations from correct tenant

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit (mocked Pinecone + LLM) |
| **File** | `RagSearchServiceTest.java` |

```
Given Tenant A's namespace has chunks about "refund policy"
And Tenant B's namespace has chunks about "shipping policy"
When Tenant A user queries "What is your refund policy?"
Then:
  - Answer is returned (non-null, non-empty)
  - Citations array is non-empty
  - Each citation has document_name, chunk_index, relevance_score
  - No citation references Tenant B documents
```

#### T5-IT-001: RAG with real Pinecone test index

| Aspect | Detail |
|--------|--------|
| **Layer** | Integration |
| **File** | `RagPipelineIntegrationTest.java` |

```
Given Tenant A has 3 documents ingested into real Pinecone test namespace
When Tenant A user sends a query about those documents
Then:
  - Response time < 3000ms (p95)
  - Citations reference the correct documents
  - Citations have relevance_score ≥ 0.7
```

#### T5-UT-002: Empty knowledge base fallback

```
Given Tenant A's Pinecone namespace has zero vectors
When Tenant A user sends a query
Then response is "No documents have been uploaded to the knowledge base yet."
```

#### T5-UT-003: LLM rate limit retry

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit |
| **File** | `LlmClientRetryTest.java` |

```
Given LLM API returns HTTP 429 on first call
When LlmClient.call() is invoked
Then:
  - First call: 429 → wait 1 second
  - Second call: 429 → wait 2 seconds
  - Third call: 429 → return fallback response
  - 3 retry attempts logged
```

#### T5-UT-004: Pinecone unavailable fallback

```
Given Pinecone query throws ServiceUnavailableException
When RAG pipeline executes
Then response is "I'm sorry, the knowledge base is temporarily unavailable"
And incident is logged to the monitoring system
```

#### T5-E2E-001: Chat UI — send message, receive answer

| Aspect | Detail |
|--------|--------|
| **Layer** | E2E (Playwright) |
| **File** | `chat-flow.spec.ts` |

```
Given user is logged in to Tenant A
When they navigate to /tnt_abc123/chat
And type "What is our refund policy?" and click send
Then:
  - Typing indicator is shown while processing
  - Send button is disabled while processing
  - Answer appears in the chat history
  - Citations are displayed below the answer
  - Send button is re-enabled
```

#### T5-E2E-002: Cross-tenant RAG isolation (security)

| Aspect | Detail |
|--------|--------|
| **Layer** | E2E |
| **File** | `rag-isolation.spec.ts` |

```
Given Tenant A has documents about "shipping policy"
And Tenant B has documents about "refund policy"
When Tenant A user asks "What is your refund policy?"
Then answer is "I don't have information about that"
(No cross-tenant leakage — refund docs only exist in Tenant B)
```

---

### Test Suite 6: Frontend RBAC UI (REQ-030, REQ-031, REQ-033)

#### T6-UT-001: usePermissions hook returns correct boolean

| Aspect | Detail |
|--------|--------|
| **Layer** | Unit (frontend) |
| **File** | `permissions.test.ts` |

```
Given current user has role with permissions ["read", "ai_chat"]
When calling can("write")
Then returns false
When calling can("ai_chat")
Then returns true
```

#### T6-UT-002: RBAC component hides children when unauthorized

```
Given a <RequirePermission permission="write"> component wrapping edit form
When user lacks "write" permission
Then component renders null (or "Access Denied")
When user has "write" permission
Then component renders children
```

#### T6-E2E-001: Admin can manage users, viewer cannot

```
Given user with role "admin" is logged in
When they navigate to /[tenantId]/admin/users
Then user management UI is visible (add user, edit roles, remove)

Given a different user with role "viewer"
When they navigate to /[tenantId]/admin/users
Then they are redirected or shown "Access Denied"
```

---

### Test Coverage Summary

| Suite | Focus | Unit | Integration | E2E | Total |
|-------|-------|------|-------------|-----|-------|
| T1 | Tenant Isolation | 2 | 2 | 1 | 5 |
| T2 | RBAC | 3 | 2 | 1 | 6 |
| T3 | Tenant Provisioning | 2 | 2 | 0 | 4 |
| T4 | Document Ingestion | 3 | 1 | 0 | 4 |
| T5 | AI Chat RAG | 4 | 1 | 2 | 7 |
| T6 | Frontend RBAC | 2 | 0 | 1 | 3 |
| **Total** | | **16** | **8** | **5** | **29** |

---

## 5. Technical Tasks

### TDD Execution Order

Tasks are ordered so that **tests are written first**, then the implementation to pass them.

```
For each task:
  1. Write test(s) — RED (test fails)
  2. Implement — GREEN (test passes)
  3. Refactor — CLEAN (tests still pass)
```

---

### Phase 1: Tenant Isolation Infrastructure

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T1 | **Tenant entity + repository with tenant_id** — Create `Tenant` entity and the `TenantFilter` interceptor that auto-applies tenant scoping to all repository queries | REQ-001 | T1-UT-001, T1-UT-002 | All T1 unit tests pass |
| T2 | **Cross-tenant isolation enforcement** — API-level guard that extracts tenant from JWT and rejects requests for other tenants. Returns 404 (not 403) for cross-tenant access | REQ-005, REQ-050 | T1-IT-001, T1-IT-002, T1-E2E-001 | All T1 integration + E2E tests pass |
| T3 | **Database migrations** — Flyway scripts for tenants, tenant_settings tables with tenant_id foreign key constraints | REQ-001 | (verified by integration tests) | Migrations run clean |

### Phase 2: RBAC Engine

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T4 | **User + Role entities + repositories** — users, roles, user_roles, invitations tables with `tenant_id` scoping | REQ-004 | T2-UT-001 | Entities exist, repositories are tenant-scoped |
| T5 | **Permission evaluator** — Evaluates `hasPermission(user, permission)` against role's JSON permission set. Handles built-in and custom roles identically | REQ-006, REQ-007, REQ-008, REQ-009, REQ-010 | T2-UT-001, T2-UT-002, T2-UT-003 | All T2 unit tests pass |
| T6 | **Auth controller + JWT service** — Login endpoint, JWT generation (RS256, 15-min expiry), token validation filter. JWT includes `tenant_id` and `permissions` | REQ-002 | (verified by downstream tests) | Login returns valid JWT with tenant context |
| T7 | **RBAC API guard** — Spring method-level `@RequirePermission` annotation + aspect that checks permission before method execution | REQ-030, REQ-031 | T2-IT-001 | Viewer mutation returns 403 |
| T8 | **Session invalidation on role change** — When user's role changes, current JWT is added to a denylist until expiry; user must re-authenticate | REQ-024 | T2-IT-002 | Old JWT returns 401; new login returns updated JWT |

### Phase 3: Tenant Lifecycle

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T10 | **Tenant provisioning service** — Creates tenant row, seeds default roles, creates admin user, creates Pinecone namespace. Transactional: any failure rolls back all previous steps | REQ-020 | T3-UT-001, T3-IT-001 | All T3 unit + integration tests pass |
| T11 | **Invitation service** — Generate invitation with 72-hour token, send email, create PENDING user. Accept endpoint validates token, activates user, assigns default role | REQ-021, REQ-022, REQ-054 | T3-UT-002, T3-IT-002, T3-UT-003 | All T3 invitation tests pass |

### Phase 4: Document Ingestion

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T20 | **Document upload API** — S3 upload, document metadata record, file type validation, storage quota check | REQ-013, REQ-032 | T4-UT-001, T4-UT-002 | Upload valid files → 201; upload over quota → 413 |
| T21 | **Document chunking pipeline** — Extract text (PDF/TXT/DOCX/MD), split into chunks, generate embeddings via OpenAI, upsert to tenant's Pinecone namespace. Async processing with status tracking | REQ-014, REQ-025, REQ-052 | T4-IT-001, T4-UT-003 | 50-page doc processes in <30s; corrupt file → 422 |

### Phase 5: AI Chat RAG

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T22 | **Pinecone integration** — Namespace-per-tenant configuration, upsert vectors, query by similarity with minimum score threshold. All operations scoped to `namespace = {tenant_id}` | REQ-015 | T5-UT-001 | Queries only return vectors from correct namespace |
| T23 | **RAG query pipeline** — Embed query → retrieve top-5 chunks (min score 0.7, expand to 10 if <3 qualify) → build prompt → call LLM → parse response → return answer + citations | REQ-011, REQ-012, REQ-026 | T5-UT-001, T5-IT-001, T5-UT-002 | Citations reference correct documents; empty KB returns fallback |
| T24 | **LLM client with retry + fallback** — Call OpenAI with 2 retries (1s, 2s exponential backoff). All failures exhausted → return fallback message. Pinecone errors → separate fallback. | REQ-051, REQ-053 | T5-UT-003, T5-UT-004 | 429 retry test passes; fallback message correct |
| T25 | **Chat history + usage logging** — Persist every query/answer pair, track token usage per tenant, enforce per-user (30/min) and per-tenant (1000/day) rate limits | REQ-026 | T5-UT-001 | Queries logged; rate limits enforced |

### Phase 6: Frontend

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T30 | **App router scaffold + auth flow** — `/login` page, JWT storage (httpOnly cookie), tenant context provider, protected route wrapper, `/[tenantId]/` route group | REQ-002 | (verified by downstream tests) | Login redirects to tenant workspace |
| T31 | **RBAC UI components** — `usePermissions()` hook, `<RequirePermission>` wrapper component, conditional rendering based on permission set. Admin sees user management; viewer sees read-only | REQ-030, REQ-031 | T6-UT-001, T6-UT-002, T6-E2E-001 | All T6 tests pass |
| T32 | **Chat UI** — Message list, input with send button, typing indicator, citation display, scroll-to-bottom, disabled state during processing | REQ-033 | T5-E2E-001 | Chat flow E2E passes |
| T33 | **Document upload UI** — Drag-and-drop zone, file type validation, progress indicator, status display per document | REQ-013 | (verified by E2E) | Upload flow works end-to-end |
| T34 | **Admin panel** — User list with role management (invite, change role, remove), role editor (create custom role with permission checkboxes), tenant settings | REQ-007, REQ-010 | T6-E2E-001 | Admin can manage users and roles |

### Phase 7: Infrastructure

| ID | Task | Refs | Test Suite | Acceptance |
|----|------|------|------------|------------|
| T40 | **ECS Fargate service definitions** — Task definitions, service auto-scaling, IAM roles for each microservice | REQ-001 | (verified by deploy) | `terraform validate` passes |
| T41 | **RDS PostgreSQL** — Instance, database creation, connection pooling, security group with least-privilege access | — | (verified by CI) | Schema migrations run on deploy |
| T42 | **Pinecone index + namespace provisioning** — Index creation automation, namespace-per-tenant lifecycle (create on tenant provision, delete on tenant deletion) | REQ-015 | T3-IT-001 | New tenant → namespace exists |
| T43 | **CI/CD pipeline** — GitHub Actions: build → unit tests → integration tests → E2E tests → deploy staging → deploy production | — | (verified by pipeline) | All CI stages pass |

---

## 6. RAG Evaluation

### Golden Test Set

```json
{
  "spec_id": "multi-tenant-saas",
  "test_suites": [
    {
      "name": "cross-tenant-isolation",
      "description": "No data leakage between tenant RAG contexts",
      "tenants": {
        "tenant_a": { "documents": ["shipping-policy.pdf"], "namespace": "tnt_a" },
        "tenant_b": { "documents": ["refund-policy.pdf", "privacy-policy.pdf"], "namespace": "tnt_b" }
      },
      "test_cases": [
        {
          "query": "What is your refund policy?",
          "expected_tenant_a": "I don't have information about that",
          "expected_tenant_b": "contains 'refund' and '30 days'",
          "metric": "tenant_isolation"
        },
        {
          "query": "How do you handle my data?",
          "expected_tenant_a": "I don't have information about that",
          "expected_tenant_b": "contains 'encrypt' and 'at rest'",
          "metric": "tenant_isolation"
        }
      ]
    },
    {
      "name": "retrieval-quality",
      "test_cases": [
        {
          "query": "What file formats are supported for upload?",
          "expected_chunks": ["doc_faq_chunk_3", "doc_faq_chunk_4"],
          "min_relevance": 0.7,
          "metric": "retrieval_precision"
        }
      ]
    }
  ]
}
```

### Evaluation Metrics

```yaml
rag_evaluation:
  metrics:
    retrieval_precision:
      threshold: "> 0.85"
      description: "% of retrieved chunks relevant to the query"
    answer_relevance:
      threshold: "> 0.80"
      description: "% of answers that correctly address the query"
    citation_accuracy:
      threshold: "> 0.90"
      description: "% of citations that support the claim they're attached to"
    latency_p95:
      threshold: "< 3000ms"
      description: "End-to-end RAG query time, 95th percentile"
    tenant_isolation:
      threshold: "zero_leakage"
      description: "No cross-tenant context leakage in any answer"
```

### Evaluation Command

```bash
python3 tests/rag/eval/run-evaluation.py \
  --test-set tests/rag/eval/tenants-golden-set.json \
  --tenant-a-namespace tnt_a \
  --tenant-b-namespace tnt_b \
  --report .sdlc-automation-agent/specs/multi-tenant-saas/rag-eval-report.json
```

---

## 7. TDD Execution Protocol

### Per-Task Workflow

```
┌────────────────────────────────────────────────────────────┐
│ RED:   Write the test                                      │
│        - Test compiles but fails (expected)                │
│        - Commit message: "RED: T1 — tenant filter test"    │
├────────────────────────────────────────────────────────────┤
│ GREEN: Implement the minimum code to pass                  │
│        - Only write code the test requires                 │
│        - No gold-plating, no future-proofing               │
│        - Commit message: "GREEN: T1 — tenant filter impl"  │
├────────────────────────────────────────────────────────────┤
│ REFACTOR: Clean up without changing behavior               │
│        - Extract duplication, rename, simplify             │
│        - Tests must still pass                             │
│        - Commit message: "REFACTOR: T1 — extract utility"  │
└────────────────────────────────────────────────────────────┘
```

### Test Naming Convention

```
{Suite}-{Layer}-{Sequence}: {Description}
  T1    UT/IT/E2E   001     descriptive-name

Examples:
  T1-UT-001: tenant-filter-appends-where-clause
  T2-IT-002: role-change-invalidates-session
  T5-E2E-001: chat-send-message-receive-answer
```

### Quality Gates

| Gate | Checks | Blocks |
|------|--------|--------|
| `test_coverage_pass` | All 29 tests passing; no skipped tests | Merge to main |
| `rag_evaluation_pass` | All 4 metrics meet thresholds | Release |
| `spec_compliance_pass` | Coverage.json maps files to spec'd REQ-IDs | Merge to main |
| `tdd_discipline` | No implementation commit without preceding RED test commit | PR review |

### Task Dependency Graph

```
Phase 1 (Tenant Isolation) ──→ Phase 2 (RBAC) ──→ Phase 3 (Tenant Lifecycle)
                                                            │
                                                            ▼
                                              Phase 4 (Document Ingestion)
                                                            │
                                                            ▼
                                              Phase 5 (AI Chat RAG)
                                                            │
                                                            ▼
                                              Phase 6 (Frontend)
                                                            
Phase 7 (Infrastructure) ──── runs in parallel with Phases 1-6
```

---

*Generated by sdlc-automation-agent Deep Spec · TDD Protocol · 2026-07-28*
