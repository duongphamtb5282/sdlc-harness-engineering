# Cloud SQL

Fully managed relational databases on Google Cloud — MySQL, PostgreSQL, SQL Server.

## Key Concepts
- High availability with regional failover replicas
- Automatic storage increase and backups
- Point-in-time recovery (PITR)
- Cloud SQL Insights for query performance
- Private IP with VPC, public IP with authorized networks
- Database flags and parameter tuning

## Common Patterns
- Primary + read replicas for read scaling
- Cross-region replicas for disaster recovery
- Migration from on-prem with Database Migration Service
- Connection pooling with Cloud SQL Proxy

## Reference
- [Cloud SQL docs](https://cloud.google.com/sql/docs)
