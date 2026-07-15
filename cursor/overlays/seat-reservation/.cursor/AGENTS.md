# CLAUDE.md

Guidance for working in the **Seat Reservation Platform Seat Reservation** monorepo.

## Project Overview

Seat reservation platform: basic auth, seat holds (pessimistic lock), mock Stripe payments, inbox/outbox worker retry. Turborepo + pnpm.

**Architecture**: [docs/architecture.md](../docs/architecture.md)

## Commands

```bash
pnpm install && pnpm build
pnpm dev:reservation
pnpm --filter @seat-reservation/gateway dev
pnpm --filter @seat-reservation/seat-reservation-service dev
pnpm --filter @seat-reservation/auth migration:run
pnpm --filter @seat-reservation/seat-reservation-service migration:run
pnpm --filter @seat-reservation/payment-service migration:run
docker-compose up -d
```

## Apps

- `apps/gateway` — HTTP API, Kafka RPC to backends (port 4000)
- `apps/auth` — JWT + refresh sessions (4003, queue `seat-reservation-auth-service`)
- `apps/seat-reservation-service` — seats API (3102)
- `apps/payment-service` — payments + outbox (3103)
- `apps/payment-worker` — Kafka + BullMQ retry (3104)
- `apps/stripe-mock` — mock Stripe (4242)
- `apps/web` — React UI (5173)
- `packages/be-core/messaging` — Kafka RPC config + topic constants

## Critical patterns

1. **Gateway → services**: Kafka `{ cmd: '...' }` RPC — not HTTP proxy
2. **Seat concurrency**: `pessimistic_write` in repository, 10 min hold TTL
3. **Payments**: inbox idempotency + outbox + webhook HMAC verification
4. **New RPC endpoint**: gateway controller + service ClientProxy + backend `@MessagePattern`

## Infrastructure

`seat-reservation-infra/` — EKS, per-service Secrets Manager paths under `sr/seat-reservation/{env}/secrets/{service}`.

## Skills

`.cursor/skills/*/SKILL.md`
