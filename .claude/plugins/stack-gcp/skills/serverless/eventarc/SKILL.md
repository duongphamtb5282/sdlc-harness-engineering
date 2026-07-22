# Eventarc

Serverless event-driven architecture on Google Cloud.

## Key Concepts
- Event ingestion from Google Cloud sources and third-party
- Event filtering with Cloud Audit Logs
- Delivery to Cloud Run, Cloud Functions, GKE, Workflows
- Event formats: CloudEvents standard
- Authentication with IAM and service accounts
- Retry policies and dead-letter queues

## Common Patterns
- Event-driven microservices with Cloud Run
- Audit log-driven workflows (e.g., on IAM change, trigger workflow)
- Third-party event integration (from SaaS via webhook)
- Data processing pipelines triggered by Storage/ Pub/Sub events

## Reference
- [Eventarc docs](https://cloud.google.com/eventarc/docs)
