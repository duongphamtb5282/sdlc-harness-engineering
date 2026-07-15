# AWS — Cloud Pack

> **Pack ID:** `aws` | **IaC:** Terraform preferred

## Default deploy target

**ECS Fargate** + **ALB** + **RDS PostgreSQL** + **ElastiCache Redis** (when cache in tech-stack) + **ECR** for images.

## Service boundaries

| Concern | AWS service |
|---------|-------------|
| Compute | ECS Fargate (avoid EC2 unless required) |
| Registry | ECR |
| Load balancing | ALB + target groups |
| Secrets | SSM Parameter Store / Secrets Manager |
| Object storage | S3 |
| Queue | SQS (+ DLQ) |
| Events | EventBridge |
| Observability | CloudWatch Logs + metrics + alarms |

## Security baseline

- Task roles per service (least privilege); no long-lived access keys in containers
- RDS in private subnets; security groups restrict to ECS tasks only
- S3 buckets block public access unless CDN origin
- Enable encryption at rest (RDS, S3, EBS)
- WAF on ALB for public APIs when compliance requires

## Environments

| Env | Pattern |
|-----|---------|
| dev | smaller Fargate tasks, single AZ OK |
| staging | production-like, scaled down |
| prod | multi-AZ RDS, autoscaling, alarms on 5xx/latency |

## PE verify commands

```bash
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan   # before apply (Controlled mode)
docker build -t app:local .
```
