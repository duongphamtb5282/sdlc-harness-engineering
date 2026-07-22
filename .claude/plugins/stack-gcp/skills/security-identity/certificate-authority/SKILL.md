# Certificate Authority Service

Managed private CA service on Google Cloud.

## Key Concepts
- Private CA for internal PKI
- Enterprise-grade with HSM-backed keys
- CA hierarchy: root, subordinate, and delegated
- Certificate templates with custom extensions
- Access policies via IAM condition
- Certificate revocation with CRL/OCSP

## Common Patterns
- mTLS for microservices authentication
- Internal TLS certificate management
- Code signing certificates
- IoT device identity certificates

## Reference
- [CA Service docs](https://cloud.google.com/certificate-authority-service/docs)
