# AI/ML Service Template

## Stack
- **Runtime:** Python 3.12+
- **Framework:** FastAPI + Celery
- **Model:** PyTorch / Transformers / vLLM
- **Tracking:** MLflow / W&B
- **Vector Store:** PGVector / Qdrant / Chroma
- **Inference:** vLLM / SGLang / Triton
- **CI/CD:** GitHub Actions + MLflow registry
- **Infrastructure:** Docker + (AWS SageMaker / Azure ML / GCP Vertex AI)

## Structure
```
services/
├── api/              # FastAPI inference endpoint
├── training/         # Training pipelines
├── embedding/        # Embedding generation
├── rag/              # RAG pipeline (retrieval + generation)
└── monitoring/       # Model monitoring & drift detection
```

## Usage
```bash
claude "Build an AI service using the ai-ml-service template for RAG + LLM inference"
```
