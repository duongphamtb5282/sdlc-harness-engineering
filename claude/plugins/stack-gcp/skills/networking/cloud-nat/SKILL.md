# Cloud NAT

NAT gateway for Google Cloud — outbound connectivity for private instances.

## Key Concepts
- Managed NAT service, no manual instances
- NAT IP addresses: automatic or manual
- Port exhaustion monitoring and alerting
- NAT rules for traffic filtering
- Per-subnet NAT configuration

## Common Patterns
- Outbound internet for private GKE nodes
- Software update access for private VMs
- API access to external services from private networks
- NAT with Cloud Router for dynamic routing

## Reference
- [Cloud NAT docs](https://cloud.google.com/nat/docs)
