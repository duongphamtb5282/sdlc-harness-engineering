<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Boundary Safety Protocol

Six structural patterns that cause silent failures at system boundaries. Framework-agnostic — applies to any stack. All agents must check for these as structural rules.

---

## Pattern 1 — Framework Abstractions Break at System Boundaries

Every framework has convenience abstractions (client-side router, ORM, state manager). These abstractions assume you stay within their domain. When you cross a boundary — client to server, app to API, internal to external — the abstraction silently fails.

**Rule:** Before using a framework abstraction, verify it works for the target's domain. If the target is outside the framework's routing/rendering layer (API endpoints, external URLs, file downloads, auth flows), fall back to the platform primitive (raw `<a href>`, raw `fetch`, raw redirect). 

**Examples:** 
- Next.js `<Link>` used for API routes (`/api/auth/login`) — silently does client-side navigation instead of full request
- React Router `navigate()` used for external OAuth URLs — breaks the auth flow

---

## Pattern 2 — Delegate to the Framework's Control Flow 

Frameworks with middleware, interceptors, or guards already handle cross-cutting concerns (auth, redirects, logging). Manually implementing the same logic in the UI layer creates a parallel control flow that conflicts with the framework's own.

**Rule:** Wire the UI to the happy path (the protected destination). Let middleware/guards handle the unhappy path. Never bypass or duplicate the framework's control flow.  

**Examples:**
- Login button links to `/api/auth/signin` instead of `/dashboard` (with middleware redirecting unauthenticated users to login)
- Component manually checks auth state and redirects, duplicating what the auth middleware already does

---

## Pattern 3 — Self-Referencing Configuration Creates Infinite Loops

When a system lets you override default behavior with a custom handler, pointing that override back to the default handler creates an infinite loop.

**Rule:** Any configuration that overrides a default path/handler MUST point to a genuinely different implementation. If the override target equals the default, remove the override entirely.

**Examples:**
- NextAuth `signIn` page override pointing to `/api/auth/signin` (which IS the default) — infinite redirect
- Proxy rule that forwards to itself — infinite request loop

---

## Pattern 4 — Global Interceptors Must Be Conditional

Global callbacks, middleware, and interceptors fire for ALL matching events. An unconditional override in a global interceptor breaks every other flow that passes through it. 

**Rule:** Every global interceptor must include conditional logic that distinguishes the target case from pass-through cases. The default behavior for unmatched cases must preserve the original intent.

**Examples:**
- Auth callback that always redirects to `/dashboard` — breaks the "redirect back to original page after login" flow
- API interceptor that always retries on 401 — retries the login request itself, creating a loop 

---  

## Pattern 5 — Test Full User Journeys Across System Boundaries

Unit tests verify individual components. Integration tests verify API contracts. But actual user journeys cross multiple systems. Testing only within system boundaries misses the transitions.

**Rule:** For every multi-system flow (auth, payment, email, webhook), the test plan MUST include at least one end-to-end scenario that traces the complete journey from user action to final state.

**Examples:** 
- Auth test checks token is issued but never checks that the callback redirects to the right page
- Payment test checks Stripe returns success but never checks that the order status updates 

---

## Pattern 6 — Identity Must Be Consistent Across Integrated Systems

When system A triggers system B, system B validates the actor's identity. If A uses a different identity format than B expects, the action silently fails.

**Rule:** Before wiring two systems together, verify the identity chain: what identity does system A send, and what does system B expect?

**Examples:**
- Git commits use local hostname email, but CI/CD requires GitHub-verified email — deployments fail silently 
- API key for staging environment used in production webhook config — all webhooks rejected

---

## Quick Reference

| # | Pattern | One-Liner |
|---|---------|-----------| 
| 1 | Abstractions break at boundaries | Use platform primitives when crossing domains | 
| 2 | Don't duplicate framework control flow | Wire UI to the destination, let middleware handle the rest |
| 3 | Self-referencing config = infinite loop | Overrides must point to something different than the default |
| 4 | Global interceptors must branch | Never return a hardcoded value from a global hook |
| 5 | Test full journeys, not just hops | Verify the user's final state, not intermediate responses |  
| 6 | Identity must match across systems | Verify identity format compatibility at every integration point |
