---
name: add-api-endpoint
description: Scaffold a new API endpoint in gateway + backend microservice with Kafka RPC and optional frontend client.
---

# Add API Endpoint (Seat Reservation)

## 1. Choose target service

- Auth → `apps/auth`
- Seats → `apps/seat-reservation-service`
- Payments → `apps/payment-service`

## 2. Backend microservice handler

Add to `*.microservice.controller.ts`:

```typescript
@MessagePattern({ cmd: 'your_command' })
handler(@Payload() payload: YourDto) {
  return this.service.method(payload);
}
```

## 3. Gateway HTTP + RPC

1. Add method in `apps/gateway/src/<module>/<module>.service.ts`:
   `this.client.send({ cmd: 'your_command' }, payload)`
2. Expose route in `apps/gateway/src/<module>/<module>.controller.ts`

## 4. Frontend (if needed)

Add call in `apps/web/src/utils/*Api.ts` → `/api/...` path on gateway.

## 5. Kafka client subscription

Add the new command to the relevant `*_RPC_COMMANDS` array in `packages/be-core/messaging/kafka-rpc.commands.ts` so gateway/clients call `subscribeToResponseOf` before connect.

## 6. Checklist

- [ ] Command string identical in gateway and backend
- [ ] DTO validation on HTTP layer (gateway) or RPC payload
- [ ] README updated if public API surface changes
