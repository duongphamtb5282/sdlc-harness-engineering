# Cloud Run

Fully managed serverless container platform on Google Cloud.

## Key Concepts
- Container-based serverless (Knative underlying)
- Auto-scaling to zero, pay-per-request
- CPU/memory allocation, concurrency settings
- Cloud Run jobs for batch workloads
- VPC connectivity: Direct VPC, VPC connectors
- Event-driven with Eventarc triggers

## Common Patterns
- REST API services with Cloud Endpoints
- Event-driven microservices with Pub/Sub + Eventarc
- Background job processing with Cloud Run Jobs
- Async worker with task queues

## Reference
- [Cloud Run docs](https://cloud.google.com/run/docs)
