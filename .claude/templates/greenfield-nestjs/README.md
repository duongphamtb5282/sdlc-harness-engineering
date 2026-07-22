# Greenfield NestJS Template

## Stack
- **Runtime:** Node.js 22+, TypeScript 5+
- **Framework:** NestJS 11+
- **Database:** PostgreSQL 16+ with Prisma ORM
- **API:** REST + GraphQL (Code First)
- **Auth:** JWT with Passport.js
- **Testing:** Jest + Supertest
- **CI/CD:** GitHub Actions
- **Infrastructure:** Docker + (AWS ECS / Azure Container Apps / GCP Cloud Run)

## Structure
```
src/
├── modules/          # Domain modules (each with controller, service, entity)
├── common/           # Shared utilities, guards, interceptors, filters
├── config/           # Environment configuration
└── main.ts           # Entry point
```

## Usage
```bash
# Load this template
claude "Scaffold a NestJS project using the greenfield-nestjs template"
```
