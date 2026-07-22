# GCP Cloud Conventions

## Naming
- Resources: `{project}-{env}-{resource-type}-{name}` (e.g., `acme-prod-gce-app`)
- Buckets: `{project}-{env}-{purpose}` (globally unique)
- Service accounts: `{service}@{project}.iam.gserviceaccount.com`

## Labels
```
environment: dev|staging|prod
project: {name}
managed-by: sdlc-agent
cost-center: {cost-center}
```

## Security defaults
- IAM: Use primitive roles sparingly, prefer custom roles
- Encryption: CMEK with Cloud KMS for data at rest
- VPC: Shared VPC, firewall rules default deny
- Cloud Armor: WAF protection on external LBs
- Security Command Center: Enable on all projects
