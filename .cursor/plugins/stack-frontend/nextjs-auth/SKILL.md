# Next.js Authentication

Authentication patterns for Next.js applications.

## Key Concepts
- **NextAuth.js / Auth.js**: built-in auth for Next.js with 80+ providers
- **Middleware-based auth**: protect routes at the edge
- **Server session**: getServerSession for server components and API routes
- **Client session**: useSession for client components
- **JWT vs Database**: session strategy comparison
- **OAuth / OIDC**: Google, GitHub, Microsoft, custom providers
- **Credentials**: email/password with bcrypt
- **Magic links**: passwordless email authentication

## Common Patterns
- Middleware-based route protection with redirects
- Server-side session checks in layouts
- API route protection with getServerSession
- Role-based access control (RBAC) in middleware

## Reference
- Auth.js: https://authjs.dev
- Next.js auth: https://nextjs.org/docs/authentication
