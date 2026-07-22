# AWS — Terraform Patterns

## Module layout

```
infra/
  modules/
    vpc/
    ecs-service/
    rds/
  environments/
    dev/
    staging/
    prod/
```

## Rules

- One state backend per environment (S3 + DynamoDB lock)
- No hardcoded account IDs — use `data.aws_caller_identity`
- Tag all resources: `Project`, `Environment`, `ManagedBy = terraform`
- Outputs: ALB DNS, RDS endpoint (sensitive), ECR URL

## ECS service module inputs

- `image_uri`, `cpu`, `memory`, `desired_count`
- `environment` map (non-secret)
- `secrets` from SSM ARNs
- `health_check_path` default `/actuator/health` (Spring) or `/health` (NestJS)

## PE receipt

Must include `terraform validate` exit 0 and `docker build` success when infra changed.
