---
name: preflight-pr
description: Pre-PR checklist for the seat reservation platform. Run before creating a pull request — messaging contracts, migrations, payment idempotency, and CI alignment.
allowed-tools: Read, Grep, Glob, Bash
disable-model-invocation: true
---

# Pre-PR Checklist

Run against current changes before opening a PR.

!`git diff --name-only HEAD~1..HEAD 2>/dev/null || git diff --name-only --cached 2>/dev/null || git diff --name-only`

## 1. Messaging & gateway contracts

If gateway or backend microservice handlers changed:

- [ ] Gateway `ClientProxy.send({ cmd })` matches backend `@MessagePattern({ cmd })` name exactly
- [ ] New consumer group uses constant from `packages/be-core/messaging/service-names.const.ts`
- [ ] `KAFKA_BROKERS` documented in service README if new env var added
- Grep for `{ cmd:` in gateway and matching service

## 2. Seat reservation safety

If `apps/seat-reservation-service/src/seats/` changed:

- [ ] Hold/release still use transaction + `pessimistic_write` for mutations
- [ ] `reserveSeat` only transitions `HELD` → `RESERVED` for correct user
- [ ] No raw SQL introduced in repository (TypeORM API only)

## 3. Payment & idempotency

If `apps/payment-service/` changed:

- [ ] Webhook path verifies HMAC before processing
- [ ] Inbox dedupes on `message_id` / `provider_event_id`
- [ ] Outbox entries have retry limits; worker can reprocess failures
- [ ] Idempotency key on payment intent create is honoured

## 4. Database migrations

If entity files changed:

- [ ] Migration added under correct service (`auth`, `seat-reservation-service`, or `payment-service`)
- [ ] Run: `pnpm --filter @seat-reservation/<service> migration:run` locally
- [ ] Schema name matches env (`auth`, `seat_reservation`, `payment`)

## 5. Frontend API alignment

If gateway response shapes changed:

- [ ] Update `apps/web/src/utils/*Api.ts` clients
- [ ] Seat/payment pages handle new error codes

## 6. CI / deploy alignment

If adding a new deployable app:

- [ ] ECR repo in `seat-reservation-infra/modules/aws_ecr/`
- [ ] Secrets in `seat-reservation-infra/environments/dev/service-secrets.tf`
- [ ] `.github/workflows/deploy-backend.yml` builds and deploys the image
- [ ] Service README exists

## 7. Code quality

- [ ] `pnpm build` passes for affected packages
- [ ] `pnpm lint` passes (if configured for package)
- [ ] No secrets committed in `.env` files

## 8. Report

Summarize as **PASS**, **WARN** (non-blocking), or **FAIL** (blocking).
