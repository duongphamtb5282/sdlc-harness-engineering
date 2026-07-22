# Cloud KMS

Key management service on Google Cloud.

## Key Concepts
- Symmetric and asymmetric keys
- Key rotation: automatic and manual
- HSM-backed keys with Cloud HSM
- Key import from external key management
- CMEK (Customer-Managed Encryption Keys) for Google services
- CSEK (Customer-Supplied Encryption Keys) for Compute Engine

## Common Patterns
- Encrypt data at rest with CMEK for BigQuery, Cloud Storage, Pub/Sub
- Application-level encryption with Cloud KMS API
- Key hierarchy: key ring → key → key version
- Access transparency for key operations

## Reference
- [Cloud KMS docs](https://cloud.google.com/kms/docs)
