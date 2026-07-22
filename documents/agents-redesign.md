# SDLC Agent Redesign — Comprehensive Analysis & Proposal

> **Date:** 2026-07-20  
> **Scope:** `.claude/`, `.cursor/`, `new-skills/` integration with awesome-copilot patterns  
> **Goal:** Transform the agent system into a full SDLC delivery platform with hooks, skills, MCP (Jira, Confluence, UI/UX Design), cost-controlled model routing, and AI/ML/LLM/RAG/Agentics/MLOps capabilities

---

## Table of Contents

1. [Current State Analysis](#1-current-state-analysis)
2. [Net-Skills Integration](#2-net-skills-integration)
3. [Awesome-Copilot: Source of Truth](#3-awesome-copilot-source-of-truth)
4. [Cost Control: Model Routing & Task Classification](#4-cost-control-model-routing--task-classification)
5. [Workflow Definition](#5-workflow-definition)
6. [AI/ML/LLM/RAG/Agentics & MLOps Skills](#6-aimlllmragagentics--mlops-skills)
7. [Cloud Design: AWS, Azure, GCP](#7-cloud-design-aws-azure-gcp)
8. [Project Templates](#8-project-templates)
9. [Redesign Proposal](#9-redesign-proposal)
10. [MCP Integration Strategy](#10-mcp-integration-strategy)
11. [Comprehensive Folder Structure](#11-comprehensive-folder-structure)
12. [Implementation Roadmap](#12-implementation-roadmap)

---

## 1. Current State Analysis

### 1.1 `.claude/` Structure (Current)

```
.claude/
├── agent-roles/           # 12 SDLC agent role folders
│   ├── code-reviewer/
│   ├── compliance-engineer/
│   ├── data-scientist/
│   ├── devops/
│   ├── frontend-engineer/
│   ├── platform-engineer/
│   ├── product-manager/
│   ├── quality-engineer/
│   ├── research-advisor/
│   ├── security-engineer/
│   ├── software-engineer/
│   ├── solution-architect/
│   ├── sre/
│   └── technical-writer/
│       └── (each has: modes/ phases/ references/ skill-extensions/)
├── agents/                # Claude Code agent stubs
├── hooks/                 # 8 lifecycle hooks
│   ├── hooks.json          # Hook wiring config
│   ├── session-start.sh
│   ├── session-guard.sh
│   ├── user-prompt-guard.sh
│   ├── pre-tool-guard.sh
│   ├── post-tool-audit.sh
│   ├── post-bash-audit.sh
│   ├── stop-receipt-reminder.sh
│   └── lib/               # Python state machines
├── packs/                 # Verify/language/cloud packs
│   ├── clouds/aws/
│   ├── languages/java-spring/
│   └── languages/nodejs-nestjs/
├── plugins/               # 14 stack plugins (UPDATED with AI/ML, Design, PM)
│   ├── delivery-toolkit/
│   ├── sdlc-workflows/
│   ├── stack-ai-ml/         # NEW: 131 AI/ML skills + MLOps + agent definitions
│   ├── design-system/       # NEW: Figma, UI design system skills
│   ├── project-management/  # NEW: Jira, Linear, QA planning skills
│   ├── stack-aws/
│   ├── stack-azure/
│   ├── stack-frontend/
│   ├── stack-golang/
│   ├── stack-nuxt/
│   ├── stack-spring/
│   ├── stack-vue/
│   ├── agent-toolkit/
│   ├── claude-skills-catalog/
│   ├── staff-engineer/
│   └── system-design/
├── rules/                 # Crew protocol rules
│   ├── crew-freshness.md
│   ├── crew-visual-identity.md
│   ├── crew-conflict-resolution.md
│   ├── crew-flaky-tests.md
│   ├── crew-receipt-protocol.md
│   ├── crew-secrets-scan.md
│   ├── crew-guard.md
│   ├── crew-welcome.md
│   ├── crew-ux.md
│   └── crew-boundary-safety.md
├── skills/                # Orchestrator + shared protocols
│   ├── sdlc-automation-agent/
│   └── _shared/
├── templates/             # NEW: MCP config templates
│   └── mcp/
├── plugin.json            # Root manifest
└── settings.json
```

**Size:** ~39MB (+ new additions)  
**Strengths:** Rich agent roles, comprehensive hooks system, strong plugin catalog, now with AI/ML/RAG skills  
**Gaps:** No MCP integration for Jira/Confluence/Figma, no cost-control model routing, no workflow definitions

### 1.2 `.cursor/` Structure (Current, Updated)

```
.cursor/
├── AGENTS.md               # Cursor SDLC agent roster
├── README.md
├── rules/                  # Cursor rules (.mdc format)
│   ├── crew-*.mdc          # 10 crew protocol rules (ported from .claude)
│   ├── sdlc-cursor-routing.mdc
│   └── ...
├── skills/
│   ├── _shared/            # Shared backends, protocols, templates
│   ├── security-engineer/  # Security audit skill
│   ├── software-engineer/  # SE skill with frontend/ai-ml/mobile modes
│   ├── stack-ai-ml/        # NEW: 131 AI/ML skills + MLOps + agent definitions
│   ├── design-system/      # NEW: Figma, UI design skills
│   ├── project-management/ # NEW: Jira, Linear, QA skills
│   └── ...
└── ...
```

**Size:** ~12MB (+ new additions)  
**Strengths:** Clean Cursor-native rules (.mdc), now has AI/ML/Design/PM skills ported  
**Gaps:** No hooks system, no cost-control, no workflow definitions

### 1.3 New Skills Ported from Reference Folders

The following comprehensive skills have been **copied from `new-skills/` reference folders into `.claude/` and `.cursor/`**:

| Source | Destination | Skills |
|--------|------------|--------|
| `new-skills/claude-code-templates/cli-tool/components/skills/ai-research/` | `.claude/plugins/stack-ai-ml/skills/` + `.cursor/skills/stack-ai-ml/` | 131 AI/ML/LLM/RAG/Agentics skills (see Section 6) |
| `new-skills/sample-claude-code-plugins-for-startups/plugins/aws-dev-toolkit/skills/mlops/` | `.claude/plugins/stack-ai-ml/skills/mlops-aws/` + `.cursor/skills/stack-ai-ml/mlops-aws/` | AWS MLOps pipeline skills |
| `new-skills/claude-code-templates/cli-tool/components/skills/creative-design/` | `.claude/plugins/design-system/skills/` + `.cursor/skills/design-system/` | Figma, Figma-implement-design, frontend-design, UI design-system |
| `new-skills/claude-code-templates/cli-tool/components/skills/ai-research/jira` | `.claude/plugins/project-management/skills/` + `.cursor/skills/project-management/` | Jira MCP skills |
| `new-skills/claude-code-templates/cli-tool/components/skills/workflow-automation/` | `.claude/plugins/project-management/skills/` + `.cursor/skills/project-management/` | Jira-automation, Linear-automation |
| `new-skills/claude-code-templates/cli-tool/components/agents/ai-specialists/` | `.claude/plugins/stack-ai-ml/agent-definitions/` + `.cursor/skills/stack-ai-ml/agent-definitions/` | 48 agent definitions (LLM architect, ML engineer, etc.) |
| `new-skills/claude-code-templates/cli-tool/components/agents/data-ai/` | `.claude/plugins/stack-ai-ml/agent-definitions/` | Data scientist, ML ops engineer definitions |
| `new-skills/claude-code-templates/cli-tool/templates/*/.mcp.json` | `.claude/templates/mcp/` | MCP server config templates (TS, Python, Common) |

> **Note:** `new-skills/` and other reference folders (`Agent-Azure-Skills/`, `awesome-copilot/`, etc.) are **upstream reference only**. They are never loaded at runtime. All skills must be explicitly copied to `.claude/` or `.cursor/` before use.

---

## 2. Net-Skills Integration

(Content from original document, unchanged — see net-skills to .claude/plugins/stack-dotnet/ mapping.)

---

## 3. Awesome-Copilot: Source of Truth

(Content from original document, unchanged — 6 patterns for agent.instruction.md, .agent.md, plugins as features, hooks as self-contained, validation pipeline, MCP-first design.)

---

## 4. Cost Control: Model Routing & Task Classification

### 4.1 Core Principle

Different tasks have vastly different complexity and cost profiles. A simple lint fix should not invoke the same expensive LLM model as a full architecture design. The system must:

1. **Classify** every task into Simple or Complex
2. **Route** to the appropriate model tier
3. **Ask** before switching to a more expensive model when ambiguity exists

### 4.2 Simple vs Complex Task Classification

| Tier | Classification | Characteristics | Examples | Default Model |
|------|---------------|-----------------|----------|---------------|
| **S1** | Trivial | Single-operation, no decision needed, deterministic | Typo fix, variable rename, comment update, import sort | Fast/Cheap |
| **S2** | Simple | Well-scoped, single file, clear requirements, existing pattern | Bug fix with known root cause, add simple validation, update config | Fast/Cheap |
| **S3** | Moderate | Multi-file but well-defined scope, some analysis needed | Add API endpoint following existing pattern, write unit tests for module | Standard |
| **S4** | Complex | Cross-cutting changes, architectural decisions, trade-offs | New feature design, service extraction, performance optimization | Premium |
| **S5** | Strategic | Multi-system, organizational impact, risk of irreversible decisions | Architecture overhaul, database migration strategy, security audit | Premium+ |

### 4.3 Cost Control Gate Protocol

Before every significant task execution, run this classification:

```python
def classify_task_complexity(user_request: str, context: dict) -> str:
    """Returns S1-S5 tier based on request analysis."""
    
    # High-signal keywords that indicate complexity
    COMPLEX_SIGNALS = [
        "architecture", "design", "migrate", "strategy", "security",
        "performance", "scale", "multi-service", "cross-cutting",
        "trade-off", "decision", "evaluate", "compare", "alternative"
    ]
    
    SCOPE_INDICATORS = {
        "single_file": ["fix", "rename", "update", "add field", "typo"],
        "multi_file": ["add feature", "implement", "refactor", "extract"],
        "cross_system": ["architecture", "design", "migrate", "integration"]
    }
    
    # Count complexity signals
    signal_count = sum(1 for s in COMPLEX_SIGNALS if s in user_request.lower())
    
    if signal_count == 0 and len(user_request.split()) < 20:
        return "S1-S2"  # Simple/Fast
    elif signal_count <= 2:
        return "S3"     # Moderate
    else:
        return "S4-S5"  # Complex/Strategic
```

### 4.4 Model Switching Gate

When the system needs to switch to a more expensive model (e.g., from Fast to Premium), it MUST ask the user first:

```
━━━ Model Switch Gate ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Current Task:   {task description}
  Classification: {S1-S5}
  Current Model:  {current model} (${cost}/1K tokens)
  Recommended:    {recommended model} (${cost}/1K tokens)
  Cost Impact:    {estimated additional cost}

  Reason for switch:
  {explanation — e.g., "requires architectural trade-off analysis"}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

```python
AskUserQuestion(questions=[{
  "question": f"This task requires {recommended_model} ({cost_reason}).\n"
              f"Current: {current_model} | Recommended: {recommended_model}\n"
              f"Estimated additional cost: ${estimated_cost}",
  "header": "Model Upgrade Required",
  "options": [
    {"label": f"Switch to {recommended_model} (Recommended)", 
     "description": f"{cost_reason}"},
    {"label": f"Stay on {current_model} — may produce lower quality",
     "description": "Current model may not handle this complexity well"},
    {"label": "Chat about this",
     "description": "Discuss alternatives and trade-offs"}
  ]
}])
```

### 4.5 Default Model Mapping by Task Type

| Task Type | Default Tier | Switch Gate Required? |
|-----------|-------------|----------------------|
| Code review (minor) | Fast | No |
| Code review (security/arch) | → Premium | **Yes** |
| Bug fix (simple) | Fast | No |
| Bug fix (root cause unknown) | → Standard | **Yes** |
| Feature implementation | Standard | No |
| Architecture design | → Premium | **Yes** |
| Documentation | Fast | No |
| Test writing | Standard | No |
| Security audit | → Premium | **Yes** |
| Database migration | → Premium | **Yes** |
| AI/ML model selection | → Premium | **Yes** |
| Prompt engineering | Standard | No |
| RAG implementation | Standard | No |
| Agent system design | → Premium | **Yes** |
| Infrastructure as Code | Standard | No |
| CI/CD pipeline | Standard | No |
| Dependency upgrade (minor) | Fast | No |
| Dependency upgrade (major) | → Standard | **Yes** |

### 4.6 Configuration

The cost control system is configured in `.sdlc-automation-agent.yaml`:

```yaml
cost_control:
  enabled: true
  default_model: "claude-sonnet"        # Fast/cheap default
  premium_model: "claude-opus"          # Expensive for complex tasks
  standard_model: "claude-sonnet"       # Middle tier
  
  thresholds:
    auto_approve_simple: true           # S1-S2: no gate needed
    auto_approve_moderate: false        # S3: only if clear
    ask_before_premium: true            # S4-S5: always ask
    
  budget_alerts:
    daily_limit: $10                    # Warn if approaching
    session_limit: $2                   # Warn per session
    hard_stop: $50                      # Hard stop (requires override)
    
  model_routing:
    "code-review:security": "premium"   # Override: security review = premium
    "code-review:general": "fast"       # Override: general review = fast
    "architecture:*": "premium"         # All architecture = premium
    "debug:simple": "fast"              # Simple debug = fast
```

---

## 5. Workflow Definition

### 5.1 Workflow Architecture

Each SDLC workflow is a defined sequence of agent handoffs with gates between stages. Workflows are defined in `.sdlc-automation-agent/workflows/` as YAML files.

### 5.2 Workflow Types

| Workflow | Trigger | Agents | Gates |
|----------|---------|--------|-------|
| **Greenfield** | New project request | PM → SA → SE → QE → CR → PE | Inception, DoR, DoD |
| **Feature** | Feature addition | SA → SE → QE → CR | Scope, Test, Review |
| **Bugfix** | Bug report | CR(diagnose) → SE(fix) → QE(verify) | Diagnosis, Fix, Regression |
| **Security Review** | Security audit request | SE(sa) → CR → CE | Threat Model, Findings |
| **Architecture Review** | Architecture decision | SA → CR → SE | ADR, Conformance |
| **AI/ML Pipeline** | ML feature request | SA → DS → SE → QE → PE | Experiment, Training, Deploy |
| **RAG System** | RAG implementation | SA → DS → SE → QE → PE | Embeddings, Retrieval, Evaluation |
| **LLM Fine-tune** | Model fine-tune | DS → SE → PE | Data, Training, Serving |
| **Agent System** | Agentic workflow | SA → SE → CR → PE | Agent Design, Tooling, Safety |
| **Migration** | System migration | SA → SE → QE → CR → PE | Analysis, Migration, Verification |
| **Documentation** | Doc generation | TW → CR | Content, Review |
| **Sprint** | Sprint execution | PM → SA → SE → QE → CR → PE | Planning, Review, Retro |

### 5.3 Workflow YAML Definition

```yaml
# .sdlc-automation-agent/workflows/feature.yaml
name: feature-delivery
description: "Standard feature delivery pipeline"
trigger_patterns:
  - "add feature"
  - "implement"
  - "build"
  - "create"

stages:
  - id: architecture
    agent: solution-architect
    model_tier: standard
    gates:
      - id: scope-check
        type: automatic
        condition: "has_clear_requirements"
    outputs:
      - "docs/architecture/ADR-*.md"
      - "docs/api/openapi.yaml"

  - id: implementation
    agent: software-engineer
    model_tier: standard
    depends_on: [architecture]
    gates:
      - id: design-review
        type: manual
        prompt: "Review the architecture design before implementation"
    outputs:
      - "services/**/*.ts"
      - "libs/**/*.ts"

  - id: testing
    agent: quality-engineer
    model_tier: standard
    depends_on: [implementation]
    gates:
      - id: test-plan
        type: automatic
        condition: "coverage > 80%"
    outputs:
      - "tests/**/*.spec.ts"

  - id: review
    agent: code-reviewer
    model_tier: premium
    depends_on: [testing]
    gates:
      - id: review-gate
        type: manual
        prompt: "Code review findings require resolution"
        
  - id: deploy
    agent: platform-engineer
    model_tier: standard
    depends_on: [review]
    gates:
      - id: dod-check
        type: automatic
        condition: "all_critical_findings_resolved"
```

### 5.4 Workflow Cost Estimation

Each workflow stage declares its `model_tier`, enabling pre-execution cost estimation:

```yaml
workflow:
  estimated_cost:
    architecture:  "$0.50-1.00"    # Standard model, ~5-10 turns
    implementation: "$2.00-5.00"   # Standard model, ~20-50 turns
    testing:       "$1.00-2.00"    # Standard model, ~10-20 turns
    review:        "$3.00-5.00"    # Premium model, ~10-15 turns
    deploy:        "$0.50-1.00"    # Standard model, ~5-10 turns
    total:         "$7.00-14.00"   # Estimated range
```

Present this to the user before execution:

```python
AskUserQuestion(questions=[{
  "question": f"This {workflow.name} workflow will run {len(stages)} stages.\n"
              f"Estimated cost: ${estimated_cost}\n"
              f"Stages: {stage_list}\n"
              f"Model routing: {model_tiers}",
  "header": "Workflow Cost Estimate",
  "options": [
    {"label": "Proceed (Recommended)", "description": "Run the full workflow"},
    {"label": "See detailed breakdown", "description": "Review each stage cost"},
    {"label": "Chat about this", "description": "Discuss workflow options"}
  ]
}])
```

### 5.5 Workflow Orchestration Rules

1. **Sequential by default**: Stages run in dependency order
2. **Parallel where possible**: Independent stages (e.g., frontend + backend) run concurrently
3. **Gates block progression**: A failed gate pauses the workflow for user input
4. **Cost-aware scheduling**: Premium model stages are batched to minimize switches
5. **Retry policy**: Each stage retries up to 2 times on transient failure
6. **Timebox**: Each stage has a configurable timeout (default: 15 min per agent turn)
7. **Receipts**: Every completed stage writes a receipt to `.sdlc-automation-agent/.orchestrator/receipts/`

### 5.6 Workflow Cost-Control Integration

Every workflow stage automatically runs through the cost control gate:

1. Stage is classified (S1-S5)
2. Model tier is selected based on classification + workflow overrides
3. If tier > default, the Model Switching Gate fires
4. Accumulated cost is tracked against budget
5. On hitting daily/session limits, user is warned or workflow is paused

---

## 6. AI/ML/LLM/RAG/Agentics & MLOps Skills

### 6.1 Skills Ported to `.claude/plugins/stack-ai-ml/skills/`

131 AI research skills + MLOps have been copied from reference folders. They are organized into the following categories:

#### Agent Frameworks & Patterns (18 skills)
| Skill | Description |
|-------|-------------|
| `agent-evaluation/` | Evaluate agent performance and behavior |
| `agent-manager-skill/` | Multi-agent orchestration management |
| `agent-memory-mcp/` | Agent memory via MCP |
| `agent-memory-systems/` | Memory systems for agents (RAG, vector, episodic) |
| `agent-tool-builder/` | Build custom tools for agents |
| `agents-autogpt/` | AutoGPT-style autonomous agents |
| `agents-crewai/` | CrewAI multi-agent framework |
| `agents-langchain/` | LangChain agent framework |
| `agents-llamaindex/` | LlamaIndex agent framework |
| `ai-agents-architect/` | Design agent architectures |
| `autonomous-agent-patterns/` | Patterns for autonomous agents |
| `autonomous-agents/` | Build autonomous AI agents |
| `computer-use-agents/` | Agents that control computers |
| `crewai/` | CrewAI orchestration deep-dive |
| `dispatching-parallel-agents/` | Run multiple agents in parallel |
| `langgraph/` | LangGraph stateful agent workflows |
| `parallel-agents/` | Parallel agent execution patterns |
| `pydantic-ai/` | Pydantic-based AI agents |
| `subagent-driven-development/` | Subagent-based dev methodology |
| `voice-agents/` | Voice-enabled AI agents |

#### RAG & Vector Search (7 skills)
| Skill | Description |
|-------|-------------|
| `rag-chroma/` | ChromaDB vector store for RAG |
| `rag-engineer/` | Full RAG system engineering |
| `rag-faiss/` | FAISS vector search for RAG |
| `rag-implementation/` | RAG implementation patterns |
| `rag-pinecone/` | Pinecone vector database for RAG |
| `rag-qdrant/` | Qdrant vector search engine |
| `rag-sentence-transformers/` | Sentence transformers for embedding |

#### LLM Ops & Observability (7 skills)
| Skill | Description |
|-------|-------------|
| `llm-ops/` | Production LLM operations |
| `llm-evaluation/` | LLM evaluation frameworks |
| `llm-app-patterns/` | LLM application design patterns |
| `langfuse/` | Langfuse LLM observability |
| `observability-langsmith/` | LangSmith tracing and monitoring |
| `observability-phoenix/` | Arize Phoenix observability |
| `datadog-cli/` | Datadog monitoring integration |

#### MLOps & Training Infrastructure (6 skills)
| Skill | Description |
|-------|-------------|
| `mlops-mlflow/` | MLflow experiment tracking and registry |
| `mlops-tensorboard/` | TensorBoard visualization |
| `mlops-weights-and-biases/` | Weights & Biases experiment tracking |
| `mlops-aws/` | AWS MLOps pipeline (SageMaker, etc.) |
| `llm-ops/` | LLM-specific operations pipeline |
| `inference-serving-vllm/` | vLLM inference serving |

#### Fine-tuning & Training (12 skills)
| Skill | Description |
|-------|-------------|
| `fine-tuning-axolotl/` | Axolotl fine-tuning framework |
| `fine-tuning-llama-factory/` | LLaMA Factory fine-tuning |
| `fine-tuning-peft/` | PEFT parameter-efficient fine-tuning |
| `fine-tuning-unsloth/` | Unsloth optimized fine-tuning |
| `distributed-training-accelerate/` | HuggingFace Accelerate |
| `distributed-training-deepspeed/` | DeepSpeed optimization |
| `distributed-training-megatron-core/` | Megatron-Core training |
| `distributed-training-pytorch-fsdp/` | PyTorch FSDP |
| `distributed-training-pytorch-lightning/` | PyTorch Lightning |
| `distributed-training-ray-train/` | Ray Train distributed training |
| `post-training-grpo-rl-training/` | GRPO reinforcement learning |
| `post-training-verl/` | veRL RL training |

#### Model Architecture (5 skills)
| Skill | Description |
|-------|-------------|
| `model-architecture-litgpt/` | LitGPT model implementation |
| `model-architecture-mamba/` | Mamba state-space models |
| `model-architecture-nanogpt/` | NanoGPT implementation |
| `model-architecture-rwkv/` | RWKV architecture |
| `model-architecture-torchtitan/` | TorchTitan large-scale training |

#### Inference Serving (4 skills)
| Skill | Description |
|-------|-------------|
| `inference-serving-llama-cpp/` | llama.cpp inference |
| `inference-serving-sglang/` | SGLang inference |
| `inference-serving-tensorrt-llm/` | TensorRT-LLM serving |
| `inference-serving-vllm/` | vLLM serving |

#### Model Optimization (6 skills)
| Skill | Description |
|-------|-------------|
| `optimization-awq/` | AWQ weight quantization |
| `optimization-bitsandbytes/` | bitsandbytes quantization |
| `optimization-flash-attention/` | Flash Attention optimization |
| `optimization-gguf/` | GGUF model format |
| `optimization-gptq/` | GPTQ quantization |
| `optimization-hqq/` | HQQ quantization |

#### Prompt Engineering (9 skills)
| Skill | Description |
|-------|-------------|
| `prompt-engineer/` | Prompt engineering fundamentals |
| `prompt-engineering/` | Advanced prompt engineering |
| `prompt-engineering-dspy/` | DSPy prompt optimization |
| `prompt-engineering-guidance/` | Guidance library for structured generation |
| `prompt-engineering-instructor/` | Instructor library for structured output |
| `prompt-engineering-outlines/` | Outlines structured generation |
| `prompt-engineering-patterns/` | Prompt design patterns |
| `prompt-library/` | Reusable prompt templates |
| `prompt-caching/` | Prompt caching strategies |

#### Safety & Alignment (3 skills)
| Skill | Description |
|-------|-------------|
| `safety-alignment-constitutional-ai/` | Constitutional AI |
| `safety-alignment-llamaguard/` | LlamaGuard content safety |
| `safety-alignment-nemo-guardrails/` | NeMo Guardrails |

#### Multimodal (7 skills)
| Skill | Description |
|-------|-------------|
| `multimodal-audiocraft/` | Meta AudioCraft audio generation |
| `multimodal-blip-2/` | BLIP-2 vision-language |
| `multimodal-clip/` | OpenAI CLIP vision-language |
| `multimodal-llava/` | LLaVA vision-language |
| `multimodal-segment-anything/` | Meta SAM segmentation |
| `multimodal-stable-diffusion/` | Stable Diffusion image generation |
| `multimodal-whisper/` | OpenAI Whisper speech |

#### Evaluation (3 skills)
| Skill | Description |
|-------|-------------|
| `evaluation-bigcode-evaluation-harness/` | BigCode evaluation |
| `evaluation-lm-evaluation-harness/` | LM Evaluation Harness |
| `evaluation-nemo-evaluator/` | NeMo Evaluator |

#### AI/ML Agent Definitions (48 files)

Copied to `.claude/plugins/stack-ai-ml/agent-definitions/`:
- `llm-architect.md`, `llms-maintainer.md`, `llm-redteam-specialist.md`
- `machine-learning-engineer.md`, `ml-engineer.md`, `mlops-engineer.md`
- `data-scientist.md`, `data-engineer.md`, `data-analyst.md`
- `computer-vision-engineer.md`, `nlp-engineer.md`, `search-specialist.md`
- `model-evaluator.md`, `ai-engineer.md`, `ai-ethics-advisor.md`
- `prompt-engineer.md`, `prompt-builder.md`
- Plus 31 more (ADR generator, blueprint-mode, semantic-kernel, etc.)

### 6.2 Agent Role: AI/ML Engineer (Proposed)

```yaml
# .claude/agent-roles/ai-ml-engineer/agent.md
name: ai-ml-engineer
description: AI/ML/LLM/RAG/Agentics specialist engineer
modes:
  - llm: LLM integration, prompt engineering, fine-tuning
  - rag: RAG system design, vector stores, retrieval pipelines
  - agentic: Agent frameworks, tool use, multi-agent orchestration
  - ml: Classic ML, training pipelines, model evaluation
  - mlops: Model deployment, monitoring, A/B testing, CI/CD for ML
phases:
  01-requirements-analysis.md
  02-data-preparation.md
  03-model-selection.md
  04-implementation.md
  05-evaluation.md
  06-deployment.md
  07-monitoring.md
```

### 6.3 MLOps Pipeline Definition

MLOps covers the full ML lifecycle beyond just model training:

```yaml
mlops_pipeline:
  stages:
    - data_engineering:
        skills: [data-processing-nemo-curator, data-processing-ray-data]
        tools: [Spark, Ray, Pandas]
    - experiment_tracking:
        skills: [mlops-mlflow, mlops-weights-and-biases, mlops-tensorboard]
        tools: [MLflow, W&B, TensorBoard]
    - training:
        skills: [distributed-training-*, fine-tuning-*, post-training-*]
        tools: [PyTorch, DeepSpeed, Axolotl]
    - evaluation:
        skills: [evaluation-*, llm-evaluation]
        tools: [LM Eval Harness, BigCode]
    - deployment:
        skills: [inference-serving-*, mlops-aws]
        tools: [vLLM, SGLang, SageMaker, Docker]
    - monitoring:
        skills: [observability-*, langfuse, llm-ops]
        tools: [LangSmith, Phoenix, Datadog, Grafana]
    - governance:
        skills: [safety-alignment-*]
        tools: [NeMo Guardrails, LlamaGuard]
```

---

## 7. Cloud Design: AWS, Azure, GCP

### 7.1 Cloud Architecture Principles

Each cloud provider has a unique architecture philosophy, service catalog, and operational model. The SDLC agent system must provide **dedicated, provider-specific plugins** rather than treating cloud as a generic abstraction. Each cloud plugin includes:

- **Well-Architected Framework** alignment (provider-specific pillars)
- **Infrastructure as Code** patterns (CDK/Terraform for AWS, Bicep/ARM for Azure, Deployment Manager/Terraform for GCP)
- **Service catalogs** organized by domain (compute, storage, networking, databases, AI/ML, security, observability)
- **CI/CD pipeline** templates (CodePipeline, Azure DevOps, Cloud Build)
- **Migration** patterns from on-premises or competing clouds
- **Cost management** and optimization practices
- **Compliance** mappings (SOC 2, HIPAA, FedRAMP per provider)
- **Agent role** definitions for cloud-specialist engineers

### 7.2 Current State Assessment

| Aspect | AWS | Azure | GCP |
|--------|-----|-------|-----|
| **Plugin** | `.claude/plugins/stack-aws/` | `.claude/plugins/stack-azure/` | **MISSING** |
| **Skill folders** | 14 core + specialized categories | **192** Azure service skills | **None** |
| **Packs** | `packs/clouds/aws/` (conventions, CI, Terraform) | **MISSING** | **MISSING** |
| **Reference sources** | `new-skills/agent-toolkit-for-aws/` (3 plugins) | `new-skills/Agent-Azure-Skills/` (191 products) | None available |
| **Provider docs in system-design** | Yes | Yes | Yes (10 refs) |
| **Cursor port** | Partial | Partial | **None** |
| **Agent role** | Platform engineer (generic) | Platform engineer (generic) | **None** |

### 7.3 AWS Cloud Design

#### Current State

| Asset | Location | Coverage |
|-------|----------|----------|
| **Core skills** | `.claude/plugins/stack-aws/skills/core-skills/` | 14 skills: Amazon Bedrock, Amplify, CDK, CloudFormation, Containers, IAM, Messaging, Observability, SDK (JS/Python/Swift), Serverless, Sign-in, Billing |
| **Specialized skills** | `.claude/plugins/stack-aws/skills/specialized-skills/` | Analytics, Database, EC2, Migration, Networking, Operations, Security, Serverless, Storage |
| **Verification packs** | `.claude/packs/clouds/aws/` | `conventions.md`, `ci-deploy-snippet.yml`, `terraform-patterns.md` |
| **Reference (new-skills)** | `new-skills/agent-toolkit-for-aws/` | 3 plugins: `aws-core/`, `aws-agents/`, `aws-data-analytics/` + standalone skills |
| **Reference (new-skills)** | `new-skills/sample-claude-code-plugins/.../aws-dev-toolkit/` | 35 skills: API Gateway, Bedrock, DynamoDB, ECS, Lambda, S3, IAM, networking, migration, Well-Architected, etc. |
| **Reference (awesome-copilot)** | `awesome-copilot/plugins/aws-cloud-development/` | AWS cloud development plugin |

#### Proposed Structure

```
.claude/plugins/stack-aws/
├── .claude-plugin/plugin.json
├── skills/
│   ├── core-skills/                  # Existing (14 skills)
│   │   ├── amazon-bedrock/
│   │   ├── aws-amplify/
│   │   ├── aws-cdk/
│   │   ├── aws-cloudformation/
│   │   ├── aws-containers/
│   │   ├── aws-iam/
│   │   ├── aws-messaging-and-streaming/
│   │   ├── aws-observability/
│   │   ├── aws-serverless/
│   │   └── ...
│   ├── specialized-skills/            # Existing (9 categories)
│   │   ├── analytics-skills/
│   │   ├── database-skills/
│   │   ├── ec2-skills/
│   │   ├── migration-and-modernization-skills/
│   │   ├── networking-and-content-delivery-skills/
│   │   ├── operations-skills/
│   │   ├── security-and-identity-skills/
│   │   ├── serverless-skills/
│   │   └── storage-skills/
│   └── well-architected/             # NEW
│       ├── operational-excellence/
│       ├── security/
│       ├── reliability/
│       ├── performance-efficiency/
│       └── cost-optimization/
├── agent-definitions/                # NEW: AWS specialist agents
│   ├── aws-architect.md
│   ├── aws-devops-engineer.md
│   ├── aws-security-specialist.md
│   └── aws-data-engineer.md
├── templates/                        # NEW: AWS project templates
│   ├── serverless-app/
│   ├── ecs-microservice/
│   └── eks-platform/
└── verify/                           # NEW: AWS verification packs
    ├── cdk-verify.sh
    └── cloudformation-verify.sh
```

**Skills to port from reference folders:**

| Source | Skills | Priority |
|--------|--------|----------|
| `new-skills/agent-toolkit-for-aws/plugins/aws-core/skills/` | Core AWS service skills | P0 |
| `new-skills/agent-toolkit-for-aws/plugins/aws-agents/skills/` | AWS agent definitions | P1 |
| `new-skills/agent-toolkit-for-aws/plugins/aws-data-analytics/skills/` | Analytics, Athena, EMR, Redshift, Kinesis | P1 |
| `new-skills/sample-claude-code-plugins/.../aws-dev-toolkit/skills/` | 35 additional AWS skills (API Gateway, Bedrock, DynamoDB, ECS, Lambda, networking, migration, Well-Architected) | P0 |

### 7.4 Azure Cloud Design

#### Current State

| Asset | Location | Coverage |
|-------|----------|----------|
| **Service skills** | `.claude/plugins/stack-azure/skills/` | **192 Azure product skills** (AKS, App Service, Functions, Key Vault, Service Bus, SQL, Storage, Virtual Machines, AI Vision, Databricks, etc.) |
| **Verification packs** | **MISSING** | No `packs/clouds/azure/` |
| **Reference (new-skills)** | `new-skills/Agent-Azure-Skills/` | **191 product skills** with CSVs, reports, SKILL.md (100+ Azure products) |
| **Reference (awesome-copilot)** | `awesome-copilot/plugins/azure-cloud-development/` | Azure cloud development plugin |

#### Proposed Structure

```
.claude/plugins/stack-azure/
├── .claude-plugin/plugin.json
├── skills/                              # Existing (192 skills)
│   ├── azure-active-directory-b2c/
│   ├── azure-ai-vision/
│   ├── azure-aks/
│   ├── azure-api-management/
│   ├── azure-app-service/
│   ├── azure-container-instances/
│   ├── azure-container-registry/
│   ├── azure-cosmos-db/
│   ├── azure-databricks/
│   ├── azure-devops/
│   ├── azure-event-hubs/
│   ├── azure-event-grid/
│   ├── azure-functions/
│   ├── azure-iot-hub/
│   ├── azure-key-vault/
│   ├── azure-kubernetes-service/
│   ├── azure-load-balancer/
│   ├── azure-logic-apps/
│   ├── azure-machine-learning/
│   ├── azure-monitor/
│   ├── azure-redis-cache/
│   ├── azure-service-bus/
│   ├── azure-sql-database/
│   ├── azure-storage-accounts/
│   ├── azure-synapse-analytics/
│   ├── azure-virtual-machines/
│   ├── azure-virtual-network/
│   └── ... (192 total)
├── well-architected/                    # NEW: Azure WAF
│   ├── cost-optimization/
│   ├── operational-excellence/
│   ├── performance-efficiency/
│   ├── reliability/
│   └── security/
├── agent-definitions/                   # NEW: Azure specialist agents
│   ├── azure-architect.md
│   ├── azure-devops-engineer.md
│   ├── azure-security-specialist.md
│   └── azure-data-engineer.md
├── templates/                           # NEW: Azure project templates
│   ├── azure-functions-app/
│   ├── aks-microservice/
│   └── azure-container-apps/
└── verify/                              # NEW: Azure verification packs
    ├── bicep-verify.sh
    └── arm-verify.sh
```

**Gap:** Missing `packs/clouds/azure/` — needs:
- `conventions.md` — Azure naming conventions, tagging strategy
- `bicep-patterns.md` — Bicep infrastructure patterns
- `ci-deploy-snippet.yml` — Azure DevOps CI/CD patterns

### 7.5 GCP Cloud Design

#### Current State

| Asset | Location | Coverage |
|-------|----------|----------|
| **Plugin** | **MISSING** | No `stack-gcp` plugin exists |
| **Service skills** | **MISSING** | No GCP skills exist |
| **Verification packs** | **MISSING** | No `packs/clouds/gcp/` |
| **Provider references** | `.claude/plugins/system-design/skills/*/references/providers/gcp.md` | 10 files (consistency, load-balancing, search, storage, logging, CDN, resilience, counters, scheduling, API design) |
| **Reference sources** | **None** | No GCP skills in new-skills/ or awesome-copilot/ |
| **Cursor port** | **None** | Nothing in .cursor/ |

#### Proposed Structure

```
.claude/plugins/stack-gcp/              # NEW: full GCP plugin
├── .claude-plugin/plugin.json
├── skills/
│   ├── compute/                         # GCP compute
│   │   ├── compute-engine/
│   │   ├── gke/
│   │   ├── cloud-run/
│   │   └── app-engine/
│   ├── storage-database/               # GCP storage
│   │   ├── cloud-storage/
│   │   ├── cloud-sql/
│   │   ├── cloud-spanner/
│   │   ├── bigtable/
│   │   ├── firestore/
│   │   └── bigquery/
│   ├── networking/                      # GCP networking
│   │   ├── vpc/
│   │   ├── cloud-load-balancing/
│   │   ├── cloud-cdn/
│   │   ├── cloud-dns/
│   │   └── cloud-nat/
│   ├── ai-ml/                          # GCP AI/ML (Vertex AI)
│   │   ├── vertex-ai-platform/
│   │   ├── vertex-ai-gemini/
│   │   ├── vertex-ai-agent-builder/
│   │   ├── vertex-ai-llm/
│   │   ├── vertex-ai-vector-search/
│   │   ├── vertex-ai-pipelines/
│   │   └── vertex-ai-model-garden/
│   ├── data-analytics/                  # GCP data
│   │   ├── dataflow/
│   │   ├── dataproc/
│   │   ├── pub-sub/
│   │   └── data-fusion/
│   ├── security-identity/              # GCP security
│   │   ├── iam/
│   │   ├── cloud-kms/
│   │   ├── security-command-center/
│   │   └── certificate-authority/
│   ├── devops-cicd/                    # GCP DevOps
│   │   ├── cloud-build/
│   │   ├── cloud-deploy/
│   │   ├── cloud-source-repositories/
│   │   └── artifact-registry/
│   ├── observability/                  # GCP monitoring
│   │   ├── cloud-monitoring/
│   │   ├── cloud-logging/
│   │   ├── cloud-trace/
│   │   └── cloud-profiler/
│   ├── serverless/                     # GCP serverless
│   │   ├── cloud-functions/
│   │   ├── cloud-run/
│   │   ├── eventarc/
│   │   └── workflows/
│   └── migration/                      # GCP migration
│       ├── migrate-to-gcp/
│       ├── transfer-appliance/
│       └── database-migration-service/
├── well-architected/                   # GCP Architecture Framework
│   ├── system-design/
│   ├── operational-excellence/
│   ├── security-privacy/
│   ├── reliability/
│   └── cost-optimization/
├── agent-definitions/                  # GCP specialist agents
│   ├── gcp-architect.md
│   ├── gcp-devops-engineer.md
│   ├── gcp-data-engineer.md
│   └── gcp-security-specialist.md
├── templates/                          # GCP project templates
│   ├── cloud-run-microservice/
│   ├── gke-platform/
│   └── serverless-data-pipeline/
└── verify/                             # GCP verification packs
    ├── terraform-verify.sh
    └── gcloud-verify.sh
```

### 7.6 Cloud Provider-Agnostic Patterns

While each provider has its own plugin, certain **cross-cutting patterns** apply universally and should be maintained in shared skills:

| Pattern | Shared Location | Provider-Specific Implementations |
|---------|----------------|----------------------------------|
| **Well-Architected Framework** | `_shared/protocols/well-architected.md` | AWS WAF, Azure WAF, GCP Architecture Framework |
| **Infrastructure as Code** | `_shared/protocols/iac-patterns.md` | CDK (AWS), Bicep (Azure), Terraform (all), Pulumi (all) |
| **Container Orchestration** | `_shared/protocols/container-orchestration.md` | EKS (AWS), AKS (Azure), GKE (GCP) |
| **Serverless Architecture** | `_shared/protocols/serverless-patterns.md` | Lambda + API GW (AWS), Functions + APIM (Azure), Cloud Functions + Cloud Run (GCP) |
| **Observability** | `_shared/protocols/observability-patterns.md` | CloudWatch + X-Ray (AWS), Monitor + App Insights (Azure), Cloud Operations (GCP) |
| **Security & Identity** | `_shared/protocols/security-patterns.md` | IAM + KMS + GuardDuty (AWS), Entra ID + Key Vault + Defender (Azure), IAM + Cloud KMS + SCC (GCP) |
| **Cost Management** | `_shared/protocols/cost-management.md` | Cost Explorer (AWS), Cost Management (Azure), Cloud Billing (GCP) |
| **Cloud Migration** | `_shared/protocols/cloud-migration.md` | MGN + DMS (AWS), Azure Migrate (Azure), Migrate to GCP (GCP) |

### 7.7 Cloud Plugin Manifest Template

Each cloud plugin follows the same manifest pattern:

```json
{
  "name": "stack-{provider}",
  "description": "{Provider} cloud skills — compute, storage, networking, databases, AI/ML, security, observability, CI/CD, migration patterns, and Well-Architected Framework guidance.",
  "version": "1.0.0",
  "author": { "name": "Hano Engineering" },
  "license": "MIT",
  "keywords": [
    "{provider}", "cloud", "infrastructure", "iaas", "paas", "saas",
    "{iac-tools}", "{container-orchestration}", "{serverless}"
  ],
  "skills": "./skills",
  "agents": "./agent-definitions"
}
```

### 7.8 Cloud Provider Recommendation Matrix

When a user's request is ambiguous about cloud provider, use this matrix to recommend:

| Criteria | AWS | Azure | GCP |
|----------|-----|-------|-----|
| **Best for** | Broadest service catalog, enterprise, startups | Microsoft shop, enterprise .NET, hybrid cloud | Data/AI/ML, open-source, Kubernetes-native |
| **Compute** | EC2, Lambda, ECS, EKS, Fargate | VMs, Functions, AKS, Container Instances | Compute Engine, Cloud Run, GKE, Cloud Functions |
| **Containers** | ECS (Fargate), EKS | AKS, Container Apps | GKE (originated K8s), Cloud Run |
| **Serverless** | Lambda + API GW + Step Functions | Functions + Logic Apps + APIM | Cloud Functions + Eventarc + Workflows |
| **AI/ML** | SageMaker, Bedrock, Rekognition | Azure ML, OpenAI Service, AI Studio | Vertex AI, Gemini, Agent Builder |
| **Kubernetes** | EKS (managed, AWS-integrated) | AKS (Azure-integrated) | GKE (originated K8s, most features) |
| **.NET** | Moderate (Linux .NET support) | **Best** (native Azure + Visual Studio integration) | Moderate |
| **Java/Spring** | Good (Elastic Beanstalk, ECS) | Good (Azure Spring Apps) | Good (Cloud Run, GKE) |
| **Node.js/Python** | Good (Lambda, Elastic Beanstalk) | Good (Functions, App Service) | Good (Cloud Functions, App Engine) |
| **Data & Analytics** | Redshift, EMR, Athena, Kinesis | Synapse, Data Factory, Databricks | BigQuery, Dataflow, Dataproc, Pub/Sub |
| **Hybrid/On-prem** | Outposts, Storage Gateway | **Best** (Azure Arc, Stack, DevOps Server) | Anthos, Bare Metal Solution |
| **Open-source friendly** | Moderate | Moderate | **Best** (GKE, Istio, Knative, Kubeflow origins) |

### 7.9 Cloud Cost Control Per Provider

Each cloud plugin integrates with the cost control system (Section 4):

```yaml
cost_control:
  model_routing:
    "cloud:aws:architecture": "premium"     # AWS Well-Architected review = premium
    "cloud:aws:deploy": "standard"           # AWS deployment = standard
    "cloud:azure:architecture": "premium"    # Azure architecture = premium
    "cloud:azure:deploy": "standard"         # Azure deployment = standard
    "cloud:gcp:architecture": "premium"      # GCP architecture = premium
    "cloud:gcp:migration": "premium"         # GCP migration = premium
    "cloud:general:iac": "standard"          # Multi-cloud IaC = standard
```

---

## 8. Project Templates

### 8.1 Template Philosophy

Project templates provide **reference implementations** for different technology stacks. They are not meant to be copied verbatim but serve as:
- **Starting points** for new projects
- **Reference patterns** for architecture decisions
- **Integration examples** for MCP tools, CI/CD, and observability

### 8.2 Template Catalog (Future)

> **Note:** These templates are placeholders for future development. Each will be populated when the corresponding technology stack is needed.

| Template | Stack | Status |
|----------|-------|--------|
| `greenfield-dotnet/` | .NET 9+, ASP.NET Core, EF Core, Azure | Reference only |
| `greenfield-nestjs/` | NestJS, TypeScript, PostgreSQL, Docker | Reference only |
| `greenfield-nextjs/` | Next.js 15+, React, Tailwind, Vercel | Reference only |
| `microservice/` | Modular monolith → event-driven microservices | Reference only |
| `cli-tool/` | TypeScript CLI with MCP integration | Reference only |
| `ai-ml-service/` | FastAPI + MLflow + vLLM + RAG pipeline | Reference only |
| `agent-system/` | LangChain/LlamaIndex + MCP tools + agent memory | Reference only |
| `llm-api/` | LLM API gateway, prompt management, guardrails | Reference only |
| `mlops-platform/` | ML training → evaluation → deployment pipeline | Reference only |

### 8.3 Template Structure Convention

Each template follows a consistent structure:

```
templates/{name}/
├── README.md              # What this template covers, when to use
├── ARCHITECTURE.md        # Architecture decisions and rationale
├── template.yaml          # Template metadata (stack, deps, versions)
├── .mcp.json             # MCP server configs for this stack
├── components/            # Reusable components (agents, skills, hooks)
│   ├── agents/            # Agent definitions specific to this stack
│   ├── skills/            # Skills specific to this stack  
│   └── hooks/             # Hooks specific to this stack
├── references/            # Reference docs and patterns
└── examples/              # Example implementations
```

### 8.4 Template Usage Workflow

```yaml
workflow: use-template
stages:
  - id: select-template
    agent: orchestrator
    action: AskUserQuestion with template list
    gate: user-choice
    
  - id: scaffold
    agent: solution-architect
    action: Copy template structure, customize to project
    model_tier: standard
    
  - id: configure-mcp
    agent: platform-engineer
    action: Set up MCP servers from template config
    model_tier: standard
    
  - id: customize
    agent: software-engineer
    action: Adapt template patterns to project requirements
    model_tier: varies by complexity
```

---

## 9. Redesign Proposal

### 9.1 Architecture Principles

1. **Single Source of Truth:** `.claude/` is authoritative. `.cursor/` is a generated subset.
2. **Awesome-Copilot Compatible:** Follow `.agent.md` + `.instructions.md` pattern for interop.
3. **MCP-Native:** Every external integration (Jira, Confluence, Figma) is an MCP server.
4. **Cost-Controlled:** Task complexity classification gates expensive model usage.
5. **Workflow-Defined:** Every pipeline is a declarative YAML workflow with cost estimation.
6. **Feature Plugins, Not Just Stack Plugins:** Group by capability (project management, design, CI/CD, AI/ML) not just tech.
7. **Hooks as Loose Plugins:** Each hook is self-contained with README.md frontmatter.
8. **Validation Gates:** Every artifact type has a schema validator in `eng/`.
9. **AI/ML/LLM/RAG/Agentics Native:** Full ML lifecycle support from training to deployment.
10. **Templates as Reference:** Project templates provide starting points, not copies.

### 9.2 High-Level Architecture

```
agents/                          ← this repo
├── .claude/                     # Claude Code runtime (authoritative)
├── .cursor/                     # Cursor runtime (generated from .claude)
├── new-skills/                  # REFERENCE ONLY — never runtime
├── awesome-copilot/             # REFERENCE ONLY — never runtime
├── eng/                         # Build & validation tools
│   ├── skill-validator/         # Frontmatter/schema validation
│   ├── skill-coverage/          # Domain coverage analysis
│   ├── cost-analyzer/           # Cost estimation per workflow
│   ├── sync-to-cursor/          # .claude → .cursor pipeline
│   └── dashboard/               # Coverage visualization
├── docs/                        # Deep-dive guides
├── scripts/                     # Merge/package/sync
└── config/                      # Shared config schemas
    ├── agent-schema.json
    ├── skill-schema.json
    ├── instruction-schema.json
    ├── workflow-schema.json     # NEW
    └── cost-model-schema.json   # NEW
```

---

## 10. MCP Integration Strategy

(Content from original section 9 with updated plugin list — see original document for full MCP details.)

---

## 11. Comprehensive Folder Structure

### 11.1 Final `.claude/` Complete Structure

```
.claude/
├── agents/                          # Stubs (auto-generated from agent-roles/)
├── agent-roles/                     # 15 delivery agent roles (UPDATED)
│   ├── product-manager/
│   ├── solution-architect/
│   ├── software-engineer/
│   ├── frontend-engineer/
│   ├── quality-engineer/
│   ├── code-reviewer/
│   ├── security-engineer/
│   ├── platform-engineer/
│   ├── dotnet-engineer/
│   ├── ai-ml-engineer/              # NEW: AI/ML/LLM/RAG/Agentics/MLOps
│   ├── data-scientist/
│   ├── technical-writer/
│   ├── research-advisor/
│   └── devops-sre/
├── instructions/                    # Global path-scoped rules
│   ├── project/
│   ├── patterns/
│   ├── design/
│   ├── safety/
│   └── cost-control/               # NEW: Cost control instructions
│       └── model-routing.instructions.md
├── hooks/                          # Self-contained hook plugins
│   ├── session-bootstrap/
│   ├── prompt-classifier/
│   ├── tool-guardian/
│   ├── receipt-enforcer/
│   ├── audit-logger/
│   ├── cost-controller/            # NEW: Cost control + model switching hook
│   └── lib/
├── hooks.json                      # Wiring config
├── mcp/                            # MCP server definitions
│   ├── project-management/mcp.json       # Jira
│   ├── knowledge-base/mcp.json           # Confluence
│   ├── design/mcp.json                   # Figma
│   ├── observability/mcp.json            # Datadog/Grafana
│   └── communications/mcp.json           # Slack
├── packs/
│   ├── clouds/{aws,azure,gcp}/
│   └── languages/{dotnet,java-spring,nodejs-nestjs,go,python,rust}/
├── plugins/
│   ├── orchestration/
│   │   ├── sdlc-automation-agent/
│   │   ├── sdlc-workflows/
│   │   └── ceremony-automation/
│   ├── project-management/          # Jira MCP plugin (POPULATED)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── jira/
│   │   │   ├── jira-automation/
│   │   │   ├── linear-automation/
│   │   │   └── qa-test-planner/
│   │   └── commands/
│   ├── design-system/               # Figma MCP plugin (POPULATED)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── figma/
│   │   │   ├── figma-implement-design/
│   │   │   ├── frontend-design/
│   │   │   └── ui-design-system/
│   │   └── commands/
│   ├── stack-ai-ml/                 # AI/ML/LLM/RAG/Agentics (POPULATED)
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── ai-agents-architect/
│   │   │   ├── agents-langchain/
│   │   │   ├── agents-llamaindex/
│   │   │   ├── agents-crewai/
│   │   │   ├── langgraph/
│   │   │   ├── rag-{chroma,faiss,pinecone,qdrant,implementation}/
│   │   │   ├── llm-{ops,evaluation,app-patterns}/
│   │   │   ├── mlops-{mlflow,wandb,tensorboard,aws}/
│   │   │   ├── fine-tuning-{axolotl,peft,unsloth,llama-factory}/
│   │   │   ├── distributed-training-{deepspeed,megatron,fsdp}/
│   │   │   ├── inference-serving-{vllm,sglang,tensorrt-llm,llama-cpp}/
│   │   │   ├── prompt-engineering{-patterns,-dspy,-guidance,-instructor}/
│   │   │   ├── safety-alignment-{constitutional-ai,llamaguard,nemo-guardrails}/
│   │   │   └── ... (131 total skills)
│   │   ├── agent-definitions/       # 48 AI specialist definitions
│   │   │   ├── llm-architect.md
│   │   │   ├── mlops-engineer.md
│   │   │   ├── prompt-engineer.md
│   │   │   └── ...
│   │   └── commands/
│   ├── security/
│   ├── stacks/
│   │   ├── stack-frontend/
│   │   ├── stack-vue/
│   │   ├── stack-nuxt/
│   │   ├── stack-spring/
│   │   ├── stack-golang/
│   │   ├── stack-dotnet/            # From net-skills
│   │   ├── stack-aws/
│   │   ├── stack-azure/
│   │   └── stack-system-design/
│   ├── ci-cd/
│   ├── observability/
│   └── agent-toolkit/
├── skills/
│   ├── sdlc-automation-agent/
│   └── _shared/
├── templates/                       # Project templates (POPULATED with MCP)
│   ├── mcp/                         # MCP config templates
│   │   ├── mcp-common.json
│   │   ├── mcp-ts.json
│   │   └── mcp-python.json
│   ├── greenfield-dotnet/           # Future
│   ├── greenfield-nestjs/           # Future
│   ├── greenfield-nextjs/           # Future
│   ├── ai-ml-service/               # Future
│   └── agent-system/                # Future
├── plugin.json
└── settings.json
```

### 11.2 Final `.cursor/` Complete Structure

```
.cursor/
├── AGENTS.md
├── README.md
├── instructions/
│   ├── project/
│   ├── patterns/
│   ├── safety/
│   └── cost-control/
├── rules/
│   ├── crew-*.mdc
│   ├── sdlc-cursor-routing.mdc
│   └── mcp-integration.mdc
├── skills/                          # 14 skill domains (UPDATED)
│   ├── _shared/
│   ├── product-manager/
│   ├── solution-architect/
│   ├── software-engineer/
│   ├── frontend-engineer/
│   ├── quality-engineer/
│   ├── code-reviewer/
│   ├── security-engineer/
│   ├── dotnet-engineer/
│   ├── ai-ml-engineer/              # NEW
│   ├── platform-engineer/
│   ├── technical-writer/
│   ├── research-advisor/
│   ├── stack-ai-ml/                 # 131 AI/ML skills (POPULATED)
│   │   ├── ai-agents-architect/
│   │   ├── agents-langchain/
│   │   ├── rag-implementation/
│   │   ├── mlops-aws/
│   │   └── ... (132 total)
│   ├── design-system/               # Figma skills (POPULATED)
│   │   ├── figma/
│   │   ├── figma-implement-design/
│   │   ├── frontend-design/
│   │   └── ui-design-system/
│   └── project-management/          # Jira skills (POPULATED)
│       ├── jira/
│       ├── jira-automation/
│       ├── linear-automation/
│       └── qa-test-planner/
├── mcp.json
└── .gitignore
```

---

## 12. Implementation Roadmap

### Phase 1: Foundation & Cost Control (Week 1-2)

| Step | Action | Outcome |
|------|--------|---------|
| 1.1 | Implement task complexity classifier (S1-S5) | Automated task tiering |
| 1.2 | Create Model Switching Gate with AskUserQuestion | Cost-aware model routing |
| 1.3 | Define default model mapping per task type | Predictable cost behavior |
| 1.4 | Create `cost-control/` instructions directory | Cost governance docs |

### Phase 2: Workflow Definitions (Week 2-3)

| Step | Action | Outcome |
|------|--------|---------|
| 2.1 | Design workflow YAML schema | `workflow-schema.json` |
| 2.2 | Implement workflow parser | Workflow → agent sequence mapper |
| 2.3 | Create cost estimation per workflow stage | Pre-execution cost display |
| 2.4 | Define 12 standard workflow templates | Greenfield, Feature, Bugfix, etc. |
| 2.5 | Add workflow gate conditions | Scope, Test, Review, DoD gates |

### Phase 3: AI/ML Skills Integration — ✅ COMPLETED

| Step | Action | Outcome | Delivered |
|------|--------|---------|-----------|
| 3.1 | ✓ Copy 131 AI research skills to .claude | **Done** | `enhancement/.claude/plugins/stack-ai-ml/skills/` |
| 3.2 | ✓ Copy MLOps skills to .claude | **Done** — AWS MLOps (mlops-aws) | `enhancement/.claude/plugins/stack-ai-ml/skills/mlops-aws/` |
| 3.3 | ✓ Copy AI agent definitions | **Done** — 268+ definitions | `enhancement/.claude/plugins/stack-ai-ml/agent-definitions/` |
| 3.4 | ✓ Copy AI skills to .cursor | **Done** — 132 items | `enhancement/.cursor/skills/stack-ai-ml/` |
| 3.5 | Create `agent-roles/ai-ml-engineer/` with phases | **Done** — 7 phases, 5 modes | `enhancement/.claude/agent-roles/ai-ml-engineer/` |

### Phase 4: Design & PM Skills — ✅ COMPLETED

| Step | Action | Outcome | Delivered |
|------|--------|---------|-----------|
| 4.1 | ✓ Copy Figma/UI design skills to .claude | **Done** — 4 skills | `enhancement/.claude/plugins/design-system/skills/` |
| 4.2 | ✓ Copy Jira/Linear PM skills to .claude | **Done** — 4 skills | `enhancement/.claude/plugins/project-management/skills/` |
| 4.3 | ✓ Copy design + PM skills to .cursor | **Done** | `enhancement/.cursor/skills/` |
| 4.4 | Create `plugins/design-system/.claude-plugin/` | **Done** — plugin.json | `enhancement/.claude/plugins/design-system/.claude-plugin/` |
| 4.5 | Create `plugins/project-management/.claude-plugin/` | **Done** — plugin.json | `enhancement/.claude/plugins/project-management/.claude-plugin/` |

### Phase 5: Cloud Provider Skills (AWS, Azure, GCP) — ✅ COMPLETED

*Replaces original "Project Templates" phase — project templates moved to Phase 6.*

| Step | Action | Outcome | Delivered |
|------|--------|---------|-----------|
| 5.1 | Port AWS skills | **Done** — 26 items + 3 agent defs | `enhancement/.claude/plugins/stack-aws/` |
| 5.2 | Port Azure skills | **Done** — 191 items + 1 agent def | `enhancement/.claude/plugins/stack-azure/` |
| 5.3 | Build GCP plugin from scratch | **Done** — 10 categories, 16 skills + 1 agent def | `enhancement/.claude/plugins/stack-gcp/` |
| 5.4 | Cloud verification packs | **Done** — conventions for all 3 clouds | `enhancement/.claude/packs/clouds/{aws,azure,gcp}/` |
| 5.5 | Well-Architected folders | **Done** — scaffold per provider | `enhancement/.claude/plugins/stack-{aws,azure,gcp}/well-architected/` |
| 5.6 | Sync to .cursor | **Done** — all 3 cloud plugins | `enhancement/.cursor/plugins/` |

### Phase 6: Full Migration & Structure — ✅ COMPLETED

| Step | Action | Outcome | Delivered |
|------|--------|---------|-----------|
| 6.1 | Migrate all 15 agent roles | **Done** (14 source + ai-ml-engineer) | `enhancement/.claude/agent-roles/` |
| 6.2 | Migrate all 17 plugins | **Done** — all source + 6 enhanced plugins | `enhancement/.claude/plugins/` |
| 6.3 | Migrate hooks, packs, skills, rules | **Done** — all source content preserved | `enhancement/.claude/` |
| 6.4 | Create MCP configs (5 domains) | **Done** — Jira, Confluence, Figma, Datadog, Slack, GitHub | `enhancement/.claude/mcp/` + `enhancement/.cursor/mcp.json` |
| 6.5 | Create project templates (7) | **Done** — greenfield-nestjs, -dotnet, ai-ml-service, agent-system, microservice, cli-tool, mcp | `enhancement/.claude/templates/` |
| 6.6 | Create eng/ validation tools | **Done** — validate-skill.sh, skill-schema.json, estimate-cost.sh | `enhancement/.claude/eng/` |
| 6.7 | Root plugin.json v2.0.0 | **Done** — all plugins referenced | `enhancement/.claude/plugin.json` |
| 6.8 | Sync full .cursor | **Done** — 11 .mdc rules, 98 skill dirs, mcp.json, cloud plugins | `enhancement/.cursor/` |

### Final Structure Verification

```
enhancement/
├── .claude/
│   ├── plugin.json                    # Root manifest v2.0.0
│   ├── hooks.json                     # Enhanced hooks (incl. cost-controller)
│   ├── instructions/cost-control/     # S1-S5 classifier + model routing
│   ├── agent-roles/                   # 15 delivery agents
│   ├── agents/                        # Agent stubs
│   ├── hooks/                         # Source hooks + cost-controller
│   ├── mcp/                           # 5 MCP server configs
│   ├── packs/clouds/{aws,azure,gcp}/  # Cloud conventions
│   ├── plugins/                       # 17 plugins (6 enhanced)
│   │   ├── stack-ai-ml/               # 131 skills + 268 agent defs
│   │   ├── stack-aws/                 # 26 items + 3 agent defs
│   │   ├── stack-azure/               # 191 items + 1 agent def
│   │   ├── stack-gcp/                 # 16 skills + 1 agent def
│   │   ├── design-system/             # 4 Figma/UI skills
│   │   ├── project-management/        # 4 Jira/PM skills
│   │   └── 11 more source plugins
│   ├── skills/sdlc-automation-agent/  # Orchestrator
│   ├── templates/                     # 7 project templates
│   ├── workflows/                     # 10 workflow definitions
│   └── eng/                           # Schema + cost validation
│
├── .cursor/
│   ├── AGENTS.md, README.md
│   ├── mcp.json                       # Consolidated MCP config
│   ├── rules/                         # 11 .mdc crew rules
│   ├── skills/                        # 98 skill dirs incl. new ones
│   └── plugins/                       # AWS, Azure, GCP cloud skills
│
└── File counts: .claude/ 6,752 files · .cursor/ 4,871 files · Total: 11,623 files
```

---

## Appendix A: Rule → Instruction Migration Mapping

(Same as original — see Appendix A in original document.)

## Appendix B: MCP Server Quick Reference

| Server | Install | Config Location | Status |
|--------|---------|----------------|--------|
| **Jira** | `npx @agenite/jira-mcp-server` | `.claude/mcp/project-management/mcp.json` | Not configured |
| **Confluence** | `npx @agenite/confluence-mcp-server` | `.claude/mcp/knowledge-base/mcp.json` | Not configured |
| **Figma** | `npx @figma/mcp-server` | `.claude/mcp/design/mcp.json` | Not configured |
| **GitHub** | Built into `gh` CLI | `.claude/mcp/communications/mcp.json` | Not configured |
| **Slack** | `npx @slack/mcp-server` | `.claude/mcp/communications/mcp.json` | Not configured |
| **Datadog** | `npx @datadog/mcp-server` | `.claude/mcp/observability/mcp.json` | Not configured |

## Appendix C: Net-Skills Plugin Mapping

(Same as original — see Appendix C in original document.)

## Appendix D: Cost Control — Model Tier Reference

| Model Tier | Example Models | Use Case | Cost/M token |
|-----------|---------------|----------|-------------|
| **Fast** | Claude Haiku, GPT-4o-mini | Simple edits, lint, docs, trivial fixes | $0.15-0.25 |
| **Standard** | Claude Sonnet, GPT-4o | Feature implementation, test writing, moderate changes | $1.50-3.00 |
| **Premium** | Claude Opus, GPT-4-turbo | Architecture, security audit, complex design | $7.50-15.00 |
| **Premium+** | Claude Opus + extended thinking | Strategic decisions, high-risk migrations | $15.00-30.00 |

> ⚠ Pricing data is approximate and may be outdated. Verify current pricing at provider websites.

## Appendix E: AI/ML Skills Inventory (131 skills)

(Full listing available in `.claude/plugins/stack-ai-ml/skills/` — 131 directories, each with SKILL.md + references + scripts/assets.)

**Category counts:**
- Agent Frameworks: 18
- RAG & Vector Search: 7
- LLM Ops & Observability: 7
- MLOps & Training Infrastructure: 6
- Fine-tuning & Training: 12
- Model Architecture: 5
- Inference Serving: 4
- Model Optimization: 6
- Prompt Engineering: 9
- Safety & Alignment: 3
- Multimodal: 7
- Evaluation: 3
- Infrastructure: 3
- Miscellaneous (research, data, platforms): 41

Total: **131 skill directories** + **1 MLOps-aws** = **132 AI/ML skills** ported to both `.claude/` and `.cursor/`.

---

> **This document is a proposal only.** Do not implement structural changes without reviewing and approving the roadmap. Skills from `new-skills/` and other reference folders have been copied to `.claude/` and `.cursor/` where comprehensive. Reference folders (`new-skills/`, `awesome-copilot/`, `Agent-Azure-Skills/`) are never loaded at runtime — they are upstream sources only.
