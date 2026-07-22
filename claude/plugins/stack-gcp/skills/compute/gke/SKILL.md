# Google Kubernetes Engine (GKE)

Managed Kubernetes on Google Cloud. Originated Kubernetes — most feature-rich K8s platform.

## Key Concepts
- Autopilot vs Standard mode
- GKE clusters: zonal, regional, private
- Node pools: Linux, Windows, GPU, TPU
- Workload Identity for GCP service accounts
- GKE Gateway controller, Ingress, Service Mesh (ASM)

## Common Patterns
- Multi-cluster with GKE Hub / Fleet
- Autoscaling with Cluster Autoscaler + HPA + VPA
- GKE Sandbox for untrusted workloads
- Cloud Native Storage with PD CSI, Filestore CSI

## Reference
- [GKE docs](https://cloud.google.com/kubernetes-engine/docs)
