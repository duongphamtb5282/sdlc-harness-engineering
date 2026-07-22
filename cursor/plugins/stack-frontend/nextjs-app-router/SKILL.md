# Next.js App Router

Next.js 14+ App Router architecture and patterns.

## Key Concepts
- **File-based routing**: layout.tsx, page.tsx, loading.tsx, error.tsx, not-found.tsx
- **Server Components**: default, async components, RSC payload
- **Client Components**: 'use client', interactivity boundaries
- **Data Fetching**: async server components, fetch cache, revalidation
- **Server Actions**: form mutations, revalidatePath, revalidateTag
- **Middleware**: request rewriting, redirects, auth checks
- **Route Groups**: (marketing), (dashboard), parallel routes @modal
- **Intercepting Routes**: (..) for modal patterns

## Common Patterns
- Co-located data fetching in server components
- Stream loading boundaries with Suspense
- Server actions for form submissions
- Middleware-based authentication and redirects
- Parallel routes for complex layouts

## Reference
- Next.js docs: https://nextjs.org/docs
