# Agent Memory Solutions

> **Date:** 2026-07-20  
> **Context:** How to give SDLC agents persistent memory across conversations

---

## 1. Why Memory Matters

SDLC agents currently operate **statelessly** — each conversation starts fresh. This means:

- User has to re-explain project context every session
- Past decisions, ADRs, and reasoning are invisible to fresh sessions
- No learning from previous interactions
- No continuity across multi-day development tasks

## 2. Existing Memory Skills (Already Ported)

The `stack-ai-ml` plugin already contains these memory-related skills:

| Skill | Location | What It Provides |
|-------|----------|------------------|
| `agent-memory-systems` | `plugins/stack-ai-ml/skills/agent-memory-systems/` | Full taxonomy: buffer memory, vector memory, episodic memory, procedural memory |
| `agent-memory-mcp` | `plugins/stack-ai-ml/skills/agent-memory-mcp/` | MCP-based memory server integration |
| `conversation-memory` | `plugins/stack-ai-ml/skills/conversation-memory/` | Conversation history management |
| `context-window-management` | `plugins/stack-ai-ml/skills/context-window-management/` | Prompt context optimization |
| `context7-auto-research` | `plugins/stack-ai-ml/skills/context7-auto-research/` | Context7 auto-research integration |

## 3. Memory Architecture Options

### Option A: File-Based Memory (Built-in, Zero Dependencies)

```
.sdlc-automation-agent/.orchestrator/
├── memory/
│   ├── project-context.md           # Project overview, tech stack, decisions
│   ├── session-{date}.md            # Per-session activity log
│   ├── decisions.md                 # Key decisions and rationale
│   └── references.md                # Useful references discovered
```

**How it works:**
- On `SessionStart` hook, load `memory/project-context.md` into context
- On `Stop` hook, append session summary to `memory/session-{date}.md`
- Agents read/write to memory files as they work

**Pros:** Simple, no infra, version-controlled with project
**Cons:** No semantic search, manual organization, scales poorly

### Option B: MCP Memory Server (Recommended)

Use an MCP server that provides persistent memory storage:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-memory-server"],
      "env": {
        "MEMORY_FILE_PATH": "${workspaceFolder}/.sdlc-automation-agent/.orchestrator/memory/mcp-memory.json"
      }
    }
  }
}
```

**How it works:**
- MCP tool `store_memory(key, value, metadata)` — persist information
- MCP tool `recall_memory(query)` — semantic search over stored memories
- MCP tool `forget_memory(key)` — remove outdated information
- Data stored in local JSON file (or SQLite/Postgres for multi-user)

**Pros:** Semantic search, structured data, shared across sessions
**Cons:** Requires MCP server setup, local file still single-user

### Option C: Vector Database Memory (Advanced)

Use a vector database for semantic memory:

| Solution | Type | Setup |
|----------|------|-------|
| **PGVector** | PostgreSQL extension | `CREATE EXTENSION vector;` — reuse existing DB |
| **Qdrant** | Dedicated vector DB | `docker run qdrant/qdrant` — API-based |
| **Chroma** | Embedded vector DB | `pip install chromadb` — local, no infra |
| **LiteLLM Memory** | Managed service | API-based, handles scaling |

**Memory schema:**
```sql
-- PGVector example
CREATE TABLE agent_memory (
    id SERIAL PRIMARY KEY,
    session_id TEXT,
    agent_role TEXT,
    memory_type TEXT,  -- 'decision', 'context', 'reference', 'pattern'
    content TEXT,
    embedding VECTOR(1536),
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);
```

**How it works:**
- Store: embed content → store in vector DB with metadata
- Recall: embed query → cosine similarity search → return top-k
- Update: overwrite by key or expire by TTL

**Pros:** Semantic search, multi-user, scalable, rich metadata
**Cons:** Requires external infra, more complex setup

### Option D: Hybrid Approach (Recommended for SDLC)

```
┌─────────────────────────────────────────────────────────────┐
│                HYBRID MEMORY ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐     ┌──────────────────────┐          │
│  │ FILE-BASED       │     │ MCP MEMORY SERVER     │          │
│  │ (static context) │     │ (dynamic recall)      │          │
│  │                  │     │                       │          │
│  │ • project-context│     │ • decisions archive   │          │
│  │ • tech-stack     │     │ • past reasoning      │          │
│  │ • ADR references │     │ • learned patterns    │          │
│  │ • team-info      │     │ • user preferences    │          │
│  └──────────────────┘     └───────────┬───────────┘          │
│                                       │                       │
│                              ┌────────▼────────┐             │
│                              │ VECTOR EMBEDDINGS│            │
│                              │ (semantic search)│             │
│                              └─────────────────┘             │
│                                                              │
│  SessionStart hook loads: project-context.md + top-5 memories│
│  Stop hook appends: session-summary + store key decisions    │
│  Agents query: recall_memory() for relevant past context     │
└─────────────────────────────────────────────────────────────┘
```

## 4. Implementation Plan

### Phase 1: File-Based Memory (Day 1, Zero Infra)

```bash
# Create memory directory
mkdir -p .sdlc-automation-agent/.orchestrator/memory

# Create project context template
cat > .sdlc-automation-agent/.orchestrator/memory/project-context.md << 'EOF'
# Project Context
- **Name:** {project}
- **Tech Stack:** {stack}
- **Architecture:** {arch}
- **Active Decisions:** {ADRs}
- **Team:** {team}
- **Last Updated:** {date}
EOF

# On SessionStart: load this file into context
# On Stop: append session summary
```

### Phase 2: MCP Memory Server (Day 2)

```bash
# Install and configure
npm init -y
npm install @anthropic/mcp-memory-server
```

Then add to `.cursor/mcp.json` and `.claude/mcp/*/mcp.json`

### Phase 3: Vector Memory (Day 3-5, When Needed)

```bash
# Option: PGVector (if PostgreSQL already in stack)
docker exec -it postgres psql -c "CREATE EXTENSION vector;"
pip install pgvector psycopg2 openai

# Option: LiteLLM (if using managed services)
pip install litellm chromadb
```

## 5. Recommendation

| Project Type | Recommended Approach | Why |
|-------------|---------------------|-----|
| **Small/Personal** | File-based + MCP server | Simple, no infra |
| **Team/Startup** | MCP server + PGVector | Shared memory, semantic search |
| **Enterprise** | Full hybrid (File + MCP + Vector) | Multi-user, audit trail, compliance |

**For this SDLC agent system:** Start with **MCP Memory Server (Option B)** - it provides the best balance of capability and simplicity. The `agent-memory-mcp` skill in `stack-ai-ml` already supports this integration.
