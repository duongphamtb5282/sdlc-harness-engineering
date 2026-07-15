---
name: add-entity
description: Scaffold a TypeORM entity and migration in auth, seat-reservation-service, or payment-service.
---

# Add Entity

## 1. Pick owning service

| Schema | Service |
|--------|---------|
| `auth` | `apps/auth` |
| `seat_reservation` | `apps/seat-reservation-service` |
| `payment` | `apps/payment-service` |

## 2. Create entity

Follow `reservation-seat.entity.ts` or `payment-intent.entity.ts` patterns:
- Set `schema` from env var
- Use TypeORM decorators; snake_case column names

## 3. Register module

Add entity to `TypeOrmModule.forFeature([...])` in the feature module.

## 4. Migration

Create timestamped file in `src/database/migrations/` using TypeORM API (`createTable`, `TableIndex`).

Run: `pnpm --filter @seat-reservation/<service> migration:run`

## 5. Repository (optional)

For seat-style data access, add methods to `*.repository.ts` — prefer TypeORM API over raw SQL.
