# Agent System Template

## Stack
- **Runtime:** Python 3.12+ or TypeScript
- **Framework:** LangChain / LlamaIndex / CrewAI / LangGraph
- **Memory:** PGVector / Redis / Mem0
- **Tools:** MCP servers, custom tools, API integrations
- **Tracing:** LangSmith / Phoenix / Langfuse
- **CI/CD:** GitHub Actions
- **Infrastructure:** Docker + (AWS ECS / GCP Cloud Run)

## Structure
```
services/
├── agent/            # Agent core (LLM, memory, tools)
│   ├── core/         # Agent loop, state management
│   ├── tools/        # Tool definitions and MCP integrations
│   └── memory/       # Memory systems (buffer, vector, episodic)
├── api/              # Agent API endpoint
├── monitoring/       # Tracing, logging, safety
└── safety/           # Guardrails, content filtering
```

## Usage
```bash
claude "Build a multi-agent system using the agent-system template with LangGraph"
```
