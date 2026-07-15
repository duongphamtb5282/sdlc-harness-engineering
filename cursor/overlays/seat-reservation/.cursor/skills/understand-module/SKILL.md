---
name: understand-module
description: Deep-dive into a module in the seat reservation monorepo — architecture, endpoints, dependencies, and risks.
---

# Understand Module

## 1. Locate code

| Domain | Path |
|--------|------|
| Gateway auth | `apps/gateway/src/auth/` |
| Gateway seats | `apps/gateway/src/seats/` |
| Gateway payments | `apps/gateway/src/payments/` |
| Auth | `apps/auth/src/modules/auth/` |
| Seats | `apps/seat-reservation-service/src/seats/` |
| Payments | `apps/payment-service/src/payments/` |
| Worker | `apps/payment-worker/src/worker/` |
| Messaging | `packages/be-core/messaging/` |

## 2. Read service README

Each app has `apps/<name>/README.md` with ports, env vars, and RPC commands.

## 3. Architecture context

Read [docs/architecture.md](../../docs/architecture.md) for system diagram and data flows.

## 4. Report structure

Return: purpose, key files, HTTP + RPC endpoints, DB tables, env vars, upstream/downstream deps, known risks.
