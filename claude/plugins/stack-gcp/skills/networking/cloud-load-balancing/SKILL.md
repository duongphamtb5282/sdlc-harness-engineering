# Cloud Load Balancing

Fully distributed, software-defined load balancing on Google Cloud.

## Key Concepts
- Global vs Regional load balancers
- External (HTTP/S, SSL/TCP, QUIC) and Internal (TCP/UDP)
- Cross-region failover and traffic steering
- Advanced traffic management: URL maps, weighted routing
- Cloud CDN integration
- Security policies and WAF rules

## Common Patterns
- Global multi-region service with anycast
- Internal microservices load balancing
- gRPC load balancing with proxy
- WebSocket and HTTP/2 support

## Reference
- [Cloud Load Balancing docs](https://cloud.google.com/load-balancing/docs)
