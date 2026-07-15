# Agentic AI in Financial Services — LangChain & LangGraph Implementation

End-to-end guide to building **financial agent workflows** with **LangChain** (components) and **LangGraph** (orchestration) integrated with an **LLM**.

**Worked example:** accounting **expense claim** — **validate form** before submit and approval.

**Related docs**

- [RAG + Agent + LangChain + LangGraph](./crawler-rag-agent-langgraph.md) — graph patterns, checkpointer, repo layout
- [SDLC Agent Automation](./sdlc-agent-automation.md) — LangGraph as control plane, HITL, state schema
- [Claude Plugin Guide §12](./claude-plugin-guide.md) — when to use LangGraph vs IDE-only skills
- [RAG.md](./RAG.md) — policy retrieval, citation validation

---

## Table of contents

1. [Why agentic AI in financial services](#1-why-agentic-ai-in-financial-services)
2. [Design principles for regulated domains](#2-design-principles-for-regulated-domains)
3. [Stack: LangChain + LangGraph + LLM](#3-stack-langchain--langgraph--llm)
4. [Reference architecture](#4-reference-architecture)
5. [Worked example: expense claim validate form](#5-worked-example-expense-claim-validate-form)
6. [Validation layers — deterministic vs LLM-assisted](#6-validation-layers--deterministic-vs-llm-assisted)
7. [Policy knowledge — context packages + RAG](#7-policy-knowledge--context-packages--rag)
8. [LangGraph: `validate_claim_graph`](#8-langgraph-validate_claim_graph)
9. [LangChain: tools, chains, structured output](#9-langchain-tools-chains-structured-output)
10. [Repository layout and API](#10-repository-layout-and-api)
11. [Human-in-the-loop and approval subgraph](#11-human-in-the-loop-and-approval-subgraph)
12. [Governance, risk, and compliance](#12-governance-risk-and-compliance)
13. [Implementation roadmap](#13-implementation-roadmap)
14. [How to run](#14-how-to-run)
15. [Testing and evaluation](#15-testing-and-evaluation)
16. [Anti-patterns](#16-anti-patterns)
17. [Extension to other finance use cases](#17-extension-to-other-finance-use-cases)

---

## 1. Why agentic AI in financial services

Financial operations combine **strict rules** (policy, tax, GL coding) with **messy inputs** (receipts, free text, exceptions). Classic automation handles hard rules; humans handle exceptions. **LangGraph** orchestrates multi-step flows (validate → explain → receipt match → HITL); the **LLM** explains and routes; **deterministic code** owns money and verdicts.

| Pain point | Classic automation | LangChain / LangGraph approach |
|------------|-------------------|------------------------------|
| Form errors | Schema validation | L1 validators + LLM **coaching node** |
| Policy interpretation | Manual finance review | **RAG** over policy packs + cite rule IDs |
| Receipt matching | OCR + rigid rules | **ToolNode** (Textract) + compare node |
| GL coding | Lookup tables | Structured LLM output + **COA tool** |
| Long approval flows | BPM only | LangGraph **checkpoint** + `interrupt()` for manager |
| Audit | Spreadsheets | **Validation receipt** in graph state + Postgres |

---

## 2. Design principles for regulated domains

| Principle | LangGraph implementation |
|-----------|-------------------------|
| **Deterministic first** | `run_deterministic_validation` node — pure Python, no LLM |
| **LLM explains, not decides money** | `explain_verdict` node; `post_to_erp` is a separate graph behind HITL |
| **Single source of truth for rules** | `policy/rules-2026-Q2.json` loaded by validation node |
| **Structured outputs** | Pydantic `ValidationResult` via `with_structured_output` |
| **Auditable graph runs** | Postgres checkpointer + `validation_receipt` in state |
| **Least privilege tools** | Receipt read-only; no `approve_claim` tool on validate graph |

```mermaid
flowchart LR
  subgraph deterministic["Deterministic nodes"]
    V[validate_schema]
    R[run_policy_engine]
  end

  subgraph llm["LLM nodes"]
    E[explain_verdict]
    P[policy_rag_answer]
  end

  subgraph hitl["HITL"]
    I[interrupt manager]
  end

  IN[claim input] --> V --> R
  R -->|block/warn| E
  R -->|needs policy cite| P
  E --> OUT[ValidationResult]
  R -->|pass + submit| I
```

---

## 3. Stack: LangChain + LangGraph + LLM

| Layer | Library | Role in expense claim |
|-------|---------|---------------------|
| **Orchestration** | `langgraph` | `validate_claim_graph`, checkpoints, branches, HITL |
| **LLM** | `langchain-openai`, `langchain-anthropic`, or `langchain-aws` | Explain errors, policy Q&A, receipt field extraction |
| **Tools** | `langchain_core.tools` | Wrap validate API, COA lookup, Textract, duplicate hash DB |
| **RAG** | `langchain` retrievers + pgvector | Policy pack chunks with citations |
| **Structured I/O** | `pydantic` + `with_structured_output` | `ValidationResult`, `ReceiptExtraction` |
| **API** | `FastAPI` | `POST /v1/claims/validate`, SSE stream from graph |
| **State** | `langgraph-checkpoint-postgres` | Resume after crash; audit thread_id |

### LangChain vs LangGraph boundary

| Use **LangChain** | Use **LangGraph** |
|-------------------|-------------------|
| Embeddings + vector store for policy docs | Multi-step validate → receipt → explain loop |
| LCEL chain for one-shot RAG answer | Branch on `verdict`: block / warn / pass |
| `@tool` definitions | `ToolNode` + conditional edges |
| Output parsers / structured output | `interrupt()` for manager approval |
| Prompt templates | Retries, failure recovery, parallel receipt OCR |

**Rule:** LangChain = **components**; LangGraph = **orchestration** (same as [crawler-rag-agent-langgraph.md](./crawler-rag-agent-langgraph.md) §5.4).

### LLM selection

| Use case | Model guidance |
|----------|----------------|
| Explain field errors | Fast model (Haiku, GPT-4o-mini) — low cost, high volume |
| Policy RAG with citations | Stronger model + mandatory citation validator node |
| Receipt extraction | Vision-capable model or dedicated OCR + small LLM normalize |

Route via **LiteLLM** or LangChain `init_chat_model` for provider swap without graph rewrite.

---

## 4. Reference architecture

```mermaid
flowchart TB
  subgraph clients["Clients"]
    WEB[Expense web app]
    API[FastAPI gateway]
  end

  subgraph runtime["services/agent-runtime/"]
    G1[validate_claim_graph]
    G2[approval_graph]
    CP[(Postgres checkpointer)]
  end

  subgraph lc["packages/finance-agents/"]
    TOOLS[LangChain tools]
    RAG[Policy retriever]
    CHAINS[LCEL explain chain]
  end

  subgraph core["Core services — deterministic"]
    VAL[Validation engine]
    POL[policy/rules.json]
    OCR[Receipt / Textract]
  end

  subgraph data["Data"]
    PG[(PostgreSQL)]
    S3[(Receipts S3)]
    VEC[(pgvector policy index)]
  end

  subgraph llm["LLM providers"]
    LLM[OpenAI / Anthropic / Bedrock]
  end

  WEB --> API
  API --> G1 & G2
  G1 --> CP
  G2 --> CP
  G1 --> TOOLS --> VAL & OCR
  G1 --> RAG --> VEC
  G1 & G2 --> LLM
  VAL --> POL
  OCR --> S3
  G1 --> PG
```

**Request flow**

1. Client `POST /v1/claims/validate` with claim JSON + optional `receipt_id`.
2. FastAPI starts `validate_claim_graph` with `thread_id = claim_draft_id`.
3. Graph runs deterministic nodes first; LLM nodes only if needed.
4. Response: `ValidationResult` JSON; optional SSE token stream from `explain_verdict`.
5. On submit → `approval_graph` with `interrupt()` until manager approves in UI.

---

## 5. Worked example: expense claim validate form

### 5.1 Form fields (illustrative)

| Field | L1 validation |
|-------|---------------|
| `claimDate` | Required; not future; open fiscal period |
| `amount` | > 0; 2 decimal places; currency required |
| `category` | Enum: meals, travel, lodging, supplies, client_entertainment, mileage, other |
| `costCenter` | Exists; submitter has charge authority |
| `receipts[]` | Required if amount > threshold |
| `mileage.km` | Required if category = mileage |

### 5.2 Policy rules (deterministic engine)

| Rule ID | Verdict |
|---------|---------|
| `POL_MEALS_DAILY_CAP` | `block` |
| `POL_RECEIPT_OVER_25` | `block` |
| `POL_WEEKEND_TRAVEL` | `warn` |
| `POL_DUPLICATE_RECEIPT` | `warn` |
| `POL_GL_MAPPING` | suggest GL code |
| `POL_ENTERTAINMENT_PREAPPROVAL` | `block` |

### 5.3 Output contract (Pydantic)

```python
from enum import Enum
from pydantic import BaseModel, Field

class Verdict(str, Enum):
    pass_ = "pass"
    warn = "warn"
    block = "block"

class FieldError(BaseModel):
    field: str
    code: str
    message: str

class ValidationResult(BaseModel):
    verdict: Verdict
    policy_version: str
    field_errors: list[FieldError] = Field(default_factory=list)
    policy_warnings: list[FieldError] = Field(default_factory=list)
    suggested_gl_code: str | None = None
    receipt_match: str = "not_applicable"  # matched | partial | missing
    duplicate_risk: str = "low"
    ready_to_submit: bool = False
    coaching_message: str | None = None  # from LLM explain node
    audit_note: str
```

---

## 6. Validation layers — deterministic vs LLM-assisted

| Layer | Implementation | LLM? |
|-------|----------------|------|
| **L1 Schema** | Pydantic `ClaimForm` in `validate_schema` node | No |
| **L2 Policy engine** | Python rules reading `rules-2026-Q2.json` | No |
| **L3 Receipt** | Textract tool + field compare node | Optional normalize |
| **L4 Explain / RAG** | `explain_verdict` + policy retriever | Yes |
| **L5 Human** | `approval_graph` + `interrupt()` | No |

**Critical:** L1–L2 live in `packages/finance-core/validation.py`. LangGraph nodes **import** them; the LLM never re-implements caps or date rules.

---

## 7. Policy knowledge — context packages + RAG

### 7.1 Files on disk

```
docs/context-packages/expense-claims/
  02-form-schema.md
  03-policy-rules.md
  06-receipt-requirements.md
policy/
  rules-2026-Q2.json          # deterministic engine input
```

### 7.2 LangChain ingest (index policy for RAG)

```python
# packages/finance-agents/rag/ingest_policy.py
from langchain_community.document_loaders import DirectoryLoader, TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_postgres import PGVector

def ingest_policy_pack(docs_path: str, collection: str = "expense-policy-2026-Q2"):
    loader = DirectoryLoader(docs_path, glob="**/*.md", loader_cls=TextLoader)
    docs = loader.load()
    chunks = RecursiveCharacterTextSplitter(chunk_size=800, chunk_overlap=100).split_documents(docs)
    embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
    PGVector.from_documents(chunks, embeddings, collection_name=collection, connection=settings.DATABASE_URL)
```

### 7.3 Retriever in graph

```python
# packages/finance-agents/rag/policy_retriever.py
from langchain_postgres import PGVector

def get_policy_retriever(policy_version: str):
    return PGVector(
        connection=settings.DATABASE_URL,
        collection_name=f"expense-policy-{policy_version}",
        embedding_function=embeddings,
    ).as_retriever(search_kwargs={"k": 4})
```

LLM policy answers must pass a **citation validator node**: every cited rule ID must exist in `rules-2026-Q2.json`.

---

## 8. LangGraph: `validate_claim_graph`

### 8.1 State schema

```python
from typing import Annotated, TypedDict
from langgraph.graph.message import add_messages

class ClaimValidateState(TypedDict):
    thread_id: str
    claim: dict                    # raw form payload
    policy_version: str
    deterministic_result: dict | None
    receipt_extraction: dict | None
    validation_result: dict | None   # ValidationResult.model_dump()
    messages: Annotated[list, add_messages]  # for explain / chat follow-up
```

### 8.2 Graph diagram

```mermaid
stateDiagram-v2
  [*] --> validate_schema
  validate_schema --> run_policy_engine: schema ok
  validate_schema --> build_result: schema fail
  run_policy_engine --> extract_receipt: has receipt
  run_policy_engine --> explain_verdict: no receipt
  extract_receipt --> explain_verdict
  explain_verdict --> validate_citations: used RAG
  explain_verdict --> build_result: no RAG
  validate_citations --> build_result
  build_result --> [*]
```

### 8.3 Node definitions

| Node | Type | Action |
|------|------|--------|
| `validate_schema` | code | Pydantic `ClaimForm`; set `field_errors` |
| `run_policy_engine` | code | Load `rules-{version}.json`; set verdict |
| `extract_receipt` | ToolNode | `extract_receipt_tool` → Textract / vision |
| `explain_verdict` | LLM | Structured coaching from errors + optional RAG |
| `validate_citations` | code | Rule IDs ⊆ policy JSON |
| `build_result` | code | Merge into `ValidationResult`; write audit row |

### 8.4 Graph implementation (conceptual)

```python
# services/agent-runtime/graphs/validate_claim.py
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolNode
from langgraph.checkpoint.postgres import PostgresSaver

from finance_agents.nodes import (
    validate_schema,
    run_policy_engine,
    explain_verdict,
    validate_citations,
    build_result,
)
from finance_agents.tools.receipt import extract_receipt_tool

def route_after_schema(state: ClaimValidateState) -> str:
    if state.get("deterministic_result", {}).get("schema_ok"):
        return "run_policy_engine"
    return "build_result"

def route_after_policy(state: ClaimValidateState) -> str:
    if state["claim"].get("receipt_ids"):
        return "extract_receipt"
    return "explain_verdict"

def build_validate_claim_graph():
    g = StateGraph(ClaimValidateState)
    g.add_node("validate_schema", validate_schema)
    g.add_node("run_policy_engine", run_policy_engine)
    g.add_node("extract_receipt", ToolNode([extract_receipt_tool]))
    g.add_node("explain_verdict", explain_verdict)
    g.add_node("validate_citations", validate_citations)
    g.add_node("build_result", build_result)

    g.set_entry_point("validate_schema")
    g.add_conditional_edges("validate_schema", route_after_schema)
    g.add_edge("run_policy_engine", "extract_receipt")  # use conditional in production
    g.add_conditional_edges("run_policy_engine", route_after_policy)
    g.add_edge("extract_receipt", "explain_verdict")
    g.add_conditional_edges(
        "explain_verdict",
        lambda s: "validate_citations" if s.get("used_rag") else "build_result",
    )
    g.add_edge("validate_citations", "build_result")
    g.add_edge("build_result", END)
    return g

checkpointer = PostgresSaver.from_conn_string(settings.DATABASE_URL)
validate_claim_graph = build_validate_claim_graph().compile(checkpointer=checkpointer)
```

### 8.5 Compile and register

```python
# services/agent-runtime/graphs/__init__.py
GRAPHS = {
    "validate_claim": validate_claim_graph,
    "approval": approval_graph,
}
```

---

## 9. LangChain: tools, chains, structured output

### 9.1 Tools (wrap deterministic services)

```python
from langchain_core.tools import tool
from finance_core.validation import validate_claim_deterministic
from finance_core.coa import suggest_gl_code

@tool
def run_deterministic_validation(claim_json: str) -> str:
    """Run schema + policy engine. Returns JSON ValidationResult partial."""
    return validate_claim_deterministic(claim_json).model_dump_json()

@tool
def suggest_gl(category: str, department: str) -> str:
    """Lookup GL code from chart of accounts. No posting."""
    return suggest_gl_code(category, department)

@tool
def check_duplicate_receipt(receipt_hash: str, window_days: int = 90) -> str:
    """Return duplicate risk: low | medium | high."""
    ...
```

### 9.2 Explain chain (LCEL)

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

explain_prompt = ChatPromptTemplate.from_messages([
    ("system", """You are a finance assistant. Explain validation results in plain English.
    Cite rule IDs exactly as given. Never override a block verdict.
    Policy version: {policy_version}"""),
    ("human", "Claim: {claim}\nErrors: {errors}\nWarnings: {warnings}"),
])

def explain_verdict(state: ClaimValidateState) -> dict:
  llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
  structured = llm.with_structured_output(ValidationResult)
  dr = state["deterministic_result"]
  chain = explain_prompt | structured
  result = chain.invoke({
      "policy_version": state["policy_version"],
      "claim": state["claim"],
      "errors": dr.get("field_errors", []),
      "warnings": dr.get("policy_warnings", []),
  })
  # Preserve deterministic verdict — LLM only fills coaching_message
  result.verdict = dr["verdict"]
  result.ready_to_submit = dr["verdict"] == "pass"
  return {"validation_result": result.model_dump()}
```

### 9.3 Policy Q&A chain (RAG)

```python
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser

def build_policy_qa_chain(retriever):
    prompt = ChatPromptTemplate.from_template(
        """Answer using only the context. Cite rule IDs like [POL_MEALS_DAILY_CAP].
        Context: {context}
        Question: {question}"""
    )
    return (
        {"context": retriever, "question": RunnablePassthrough()}
        | prompt
        | ChatOpenAI(model="gpt-4o", temperature=0)
        | StrOutputParser()
    )
```

---

## 10. Repository layout and API

```
finance-expense-platform/
  packages/
    finance-core/              # Pydantic models, policy engine (no LLM)
      validation.py
      policy_engine.py
      models.py
    finance-agents/            # LangChain tools, RAG, prompts
      tools/
      rag/
      nodes/                   # LangGraph node functions
      chains/

  services/
    agent-runtime/             # LangGraph graphs + worker
      graphs/
        validate_claim.py
        approval.py
      worker.py                # consumes validate jobs
      tests/
    api/                       # FastAPI
      main.py
      routes/claims.py

  docs/context-packages/expense-claims/
  policy/rules-2026-Q2.json

  docker-compose.yml           # Postgres + pgvector
  pyproject.toml
```

### API endpoints

| Method | Path | Action |
|--------|------|--------|
| `POST` | `/v1/claims/validate` | Invoke `validate_claim_graph`; return `ValidationResult` |
| `GET` | `/v1/claims/validate/{thread_id}/stream` | SSE from `astream_events` (explain tokens) |
| `POST` | `/v1/claims/{id}/submit` | Start `approval_graph` |
| `POST` | `/v1/claims/{id}/approve` | Resume graph after `interrupt()` |
| `POST` | `/v1/admin/policy/reindex` | Re-ingest policy markdown into pgvector |

### FastAPI handler (conceptual)

```python
@router.post("/v1/claims/validate", response_model=ValidationResult)
async def validate_claim(body: ClaimForm, receipt_id: str | None = None):
    config = {"configurable": {"thread_id": body.draft_id}}
    initial = {
        "thread_id": body.draft_id,
        "claim": body.model_dump(),
        "policy_version": settings.POLICY_VERSION,
        "messages": [],
    }
    final = await validate_claim_graph.ainvoke(initial, config)
    return ValidationResult(**final["validation_result"])
```

---

## 11. Human-in-the-loop and approval subgraph

Submit and approve use a **separate graph** so validate stays read-only.

```mermaid
stateDiagram-v2
  [*] --> pre_check
  pre_check --> interrupt_manager: validation pass
  pre_check --> [*]: block
  interrupt_manager --> finance_review: manager approved
  interrupt_manager --> [*]: rejected
  finance_review --> post_erp: approved
  finance_review --> [*]: rejected
  post_erp --> [*]
```

```python
from langgraph.types import interrupt

def interrupt_manager(state):
    decision = interrupt({
        "action": "manager_approval",
        "claim_id": state["claim_id"],
        "amount": state["claim"]["amount"],
    })
    return {"manager_decision": decision}

def post_erp(state):
    if state["finance_decision"] != "approved":
        return state
    # Idempotent ERP post — not LLM
    erp_client.post_expense(state["claim_id"], idempotency_key=state["thread_id"])
    return state
```

Manager approves via API → `graph.invoke(Command(resume={"approved": True}), config)`.

---

## 12. Governance, risk, and compliance

| Risk | Mitigation |
|------|------------|
| LLM changes verdict | `explain_verdict` copies verdict from deterministic node only |
| Hallucinated policy | `validate_citations` node + RAG-only context |
| Duplicate payment | `idempotency_key` on `post_erp`; separate approval graph |
| PII in logs | Redact receipt content in LangSmith / tracing; store hash only |
| Graph non-determinism | Golden tests on L1–L2; LLM evals on explain quality |
| Model swap | LiteLLM / `init_chat_model`; graph unchanged |

### Validation receipt (persisted per graph run)

```json
{
  "thread_id": "draft_abc",
  "graph": "validate_claim",
  "policy_version": "2026-Q2",
  "verdict": "block",
  "rules_fired": ["POL_MEALS_DAILY_CAP"],
  "llm_nodes": ["explain_verdict"],
  "checkpoint_id": "01HY...",
  "created_at": "2026-06-03T10:00:00Z"
}
```

---

## 13. Implementation roadmap

| Phase | Deliverable | Stack |
|-------|-------------|-------|
| **1** | Pydantic models + policy engine + unit tests | Python only |
| **2** | `validate_schema` + `run_policy_engine` nodes; FastAPI `/validate` (no LLM) | LangGraph |
| **3** | `explain_verdict` + structured output | LangChain + LLM |
| **4** | Policy RAG ingest + citation validator | LangChain + pgvector |
| **5** | Receipt `ToolNode` (Textract) | LangChain tools |
| **6** | `approval_graph` + `interrupt()` + UI resume | LangGraph HITL |
| **7** | LangSmith traces, golden evals, ERP post node | Ops |

**MVP:** Phases 1–3 (deterministic validate + LLM coaching).

---

## 14. How to run

### Dependencies

```toml
# pyproject.toml (excerpt)
dependencies = [
  "langgraph>=0.2",
  "langgraph-checkpoint-postgres>=2.0",
  "langchain-core>=0.3",
  "langchain-openai>=0.2",
  "langchain-postgres>=0.0.12",
  "langchain-community>=0.3",
  "fastapi>=0.115",
  "pydantic>=2.0",
  "uvicorn[standard]>=0.32",
]
```

### Local

```bash
docker compose up -d postgres   # pgvector enabled
pip install -e packages/finance-core -e packages/finance-agents -e services/agent-runtime -e services/api

# Index policy docs
python -m finance_agents.rag.ingest_policy docs/context-packages/expense-claims

# Run API + graph
uvicorn api.main:app --reload --port 8080

# Validate
curl -s localhost:8080/v1/claims/validate -H 'Content-Type: application/json' -d '{
  "draft_id": "d1",
  "claimDate": "2026-06-01",
  "category": "meals",
  "amount": 95,
  "currency": "USD",
  "costCenter": "ENG-042"
}'
```

### Environment

```bash
export OPENAI_API_KEY=...
export DATABASE_URL=postgresql://user:pass@localhost:5432/finance_agents
export POLICY_VERSION=2026-Q2
# Optional: LANGCHAIN_TRACING_V2=true LANGCHAIN_API_KEY=... (LangSmith)
```

---

## 15. Testing and evaluation

| Test type | What | Tool |
|-----------|------|------|
| **Unit** | Each `POL_*` rule | `pytest` on `policy_engine.py` |
| **Graph** | Schema fail short-circuits to `build_result` | `pytest` + in-memory checkpointer |
| **Golden claims** | Fixed inputs → fixed verdict | JSON fixtures in `tests/golden/` |
| **LLM eval** | Coaching clarity, no verdict drift | LangSmith datasets / promptfoo |
| **RAG eval** | Citation ⊆ policy index | Custom `validate_citations` tests |

```python
# tests/test_validate_graph.py
async def test_meals_cap_blocks(memory_graph):
    result = await memory_graph.ainvoke(_claim(amount=95, category="meals"), config)
    assert result["validation_result"]["verdict"] == "block"
    assert any(e["code"] == "POL_MEALS_DAILY_CAP" for e in result["validation_result"]["field_errors"])
```

---

## 16. Anti-patterns

| Anti-pattern | Why it fails |
|--------------|--------------|
| Single ReAct agent with all rules in prompt | Non-auditable; verdict drift |
| LLM as only validator | Fails SOX / internal audit |
| `post_erp` inside validate graph | No separation of duties |
| Skipping checkpointer on approval | Cannot resume HITL |
| Policy only in vector DB | L2 engine needs `rules.json`; RAG is supplementary |
| Tracing full receipt images | PII leakage in LangSmith |

---

## 17. Extension to other finance use cases

| Use case | Graph name | Key nodes |
|----------|------------|-----------|
| AP invoice three-way match | `invoice_match_graph` | PO tool, GRN tool, LLM explain mismatch |
| Corporate card reconcile | `card_reconcile_graph` | Bank feed tool, receipt match |
| Vendor onboarding | `vendor_kyc_graph` | Sanctions tool, HITL compliance |
| Policy Q&A only | `policy_qa_graph` | RAG retrieve → generate → cite validate |

Reuse: `finance-core` validators, pgvector policy index, Postgres checkpointer, FastAPI pattern.

---

## Summary

| Layer | Technology |
|-------|------------|
| **Hard rules** | Python policy engine + Pydantic (no LLM) |
| **Orchestration** | LangGraph `validate_claim_graph` + `approval_graph` |
| **LLM** | LangChain chat models — explain, RAG, receipt normalize |
| **Tools** | LangChain `@tool` → APIs, Textract, COA, duplicate DB |
| **Memory** | Policy markdown → pgvector; graph state → Postgres checkpoint |
| **API** | FastAPI invoke + SSE stream |
| **Humans** | `interrupt()` on approval; ERP post after finance sign-off |

Build financial agentic systems by keeping **money and verdicts in code**, and using **LangGraph + LLM** for multi-step flows, explanations, and resumable approvals.
