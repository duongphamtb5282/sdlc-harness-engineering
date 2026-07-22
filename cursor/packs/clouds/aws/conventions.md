# AWS Cloud Conventions

## Naming
- Resources: `{project}-{env}-{resource-type}-{name}` (e.g., `acme-prod-ec2-app`)
- S3 buckets: `{project}-{env}-{purpose}` (e.g., `acme-prod-logs`)
- IAM roles: `{project}-{env}-{service}-{role}`

## Tagging
```
Environment: dev|staging|prod
Project: {name}
ManagedBy: sdlc-agent
CostCenter: {cost-center}
```

## Security defaults
- S3: Block public access by default, enable versioning
- IAM: Use roles not users for services, least privilege
- Encryption: KMS CMK for all data at rest
- Logging: CloudTrail multi-region, S3 access logs
- VPC: Isolated per environment, flow logs enabled
