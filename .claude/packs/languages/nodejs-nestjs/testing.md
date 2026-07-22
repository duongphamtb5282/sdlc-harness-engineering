# Node.js / NestJS — Testing Pack

> **Pack ID:** `nodejs-nestjs` | **Runner:** Jest + supertest

## Test layers

| Layer | File pattern | Tool |
|-------|--------------|------|
| Unit | `*.spec.ts` next to source | Jest + `@nestjs/testing` |
| E2E | `test/*.e2e-spec.ts` | supertest + `INestApplication` |
| Contract | OpenAPI snapshot or Pact | optional |

## Commands

```bash
npm test                    # unit tests
npm run test:e2e            # e2e
npm run test -- --coverage  # coverage
npm run lint                # eslint
npm run build               # compile check
```

## Unit test pattern

```typescript
const module = await Test.createTestingModule({
  providers: [OrderService, { provide: OrderRepository, useValue: mockRepo }],
}).compile();
const service = module.get(OrderService);
```

## E2E pattern

```typescript
const app = moduleFixture.createNestApplication();
app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
await app.init();
return request(app.getHttpServer()).post('/orders').send(dto).expect(201);
```

## QE expectations

- Every new endpoint: e2e test for success + validation failure (400)
- Services with branching: unit tests per branch
- Auth endpoints: test 401/403 paths
