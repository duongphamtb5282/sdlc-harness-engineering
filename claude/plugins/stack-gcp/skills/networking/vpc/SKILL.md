# VPC

Virtual Private Cloud — isolated network environment on Google Cloud.

## Key Concepts
- Projects contain VPC networks (auto-mode or custom-mode)
- Subnets are regional, with primary and secondary IP ranges
- Firewall rules: ingress/egress, target tags, service accounts
- VPC peering and Shared VPC for multi-project connectivity
- Cloud NAT for outbound internet from private instances
- Private Google Access for on-prem to Google APIs

## Common Patterns
- Shared VPC with host/service projects
- Hub-and-spoke with VPC Network Peering
- Private service networking for managed services
- Hybrid connectivity with Cloud VPN or Dedicated Interconnect

## Reference
- [VPC docs](https://cloud.google.com/vpc/docs)
