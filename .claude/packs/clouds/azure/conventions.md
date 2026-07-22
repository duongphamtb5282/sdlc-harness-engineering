# Azure Cloud Conventions

## Naming
- Resources: `{prefix}-{env}-{resource-type}-{name}` (e.g., `acme-prod-vm-app`)
- Resource groups: `rg-{project}-{env}-{region}-{purpose}`
- Storage accounts: `{project}{env}{purpose}` (lowercase, no hyphens)

## Tagging
```
Environment: dev|staging|prod
Project: {name}
ManagedBy: sdlc-agent
CostCenter: {cost-center}
```

## Security defaults
- RBAC: Use managed identities, least privilege
- Encryption: Azure Disk Encryption, Storage Service Encryption
- Network: NSG default deny, flow logs enabled
- Key Vault: Soft delete + purge protection
- Defender for Cloud: Enable on all subscriptions
