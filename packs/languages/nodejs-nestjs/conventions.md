# Node.js / NestJS — Conventions Pack

> **Pack ID:** `nodejs-nestjs` | **Verify:** `npm test`, `npm run build`

## Project layout

```
src/
  main.ts
  app.module.ts
  {feature}/
    {feature}.module.ts
    {feature}.controller.ts
    {feature}.service.ts
    dto/
      create-{feature}.dto.ts
      {feature}-response.dto.ts
    entities/          # TypeORM entities (if used)
    repositories/      # custom repos when needed
test/
  {feature}.e2e-spec.ts
  jest-e2e.json
```

## Standards

- **TypeScript strict**, NestJS 10+, class-validator + class-transformer on DTOs
- **Modules:** one feature per module; export service only when consumed elsewhere
- **Controllers:** thin — delegate to service; use `@ApiTags`, `@ApiOperation` (Swagger)
- **DTOs:** separate create/update/response; never expose entities directly
- **Validation:** `ValidationPipe` global with `whitelist: true`, `forbidNonWhitelisted: true`
- **Errors:** `HttpException` or custom filters; consistent error body shape
- **Config:** `@nestjs/config` + Joi schema validation for env vars
- **DB:** TypeORM or Prisma — pick one per project; migrations required for schema changes
- **Auth:** Passport JWT or guards; `@UseGuards` on controllers, not inline checks

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Business logic in controllers | Move to service |
| `any` on DTOs | Typed DTOs + validation decorators |
| Missing `await` on async service calls | Enable `@typescript-eslint/no-floating-promises` |
| Circular module imports | Extract shared module or use `forwardRef` sparingly |
| E2E tests without DB cleanup | `beforeEach` truncate or testcontainers |

## Scripts (package.json)

```json
{
  "scripts": {
    "build": "nest build",
    "test": "jest",
    "test:e2e": "jest --config ./test/jest-e2e.json",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\"",
    "start:dev": "nest start --watch"
  }
}
```
