# React Server Components

React Server Components (RSC) architecture and patterns.

## Key Concepts
- **Server vs Client**: RSC run on server, never sent to client
- **'use client'**: boundary marker for client components
- **Async components**: server components can be async, fetching data directly
- **Composition**: server components wrapping client components
- **Props passing**: serializable props across the boundary
- **Streaming**: Suspense boundaries for progressive rendering

## Common Patterns
- Data fetching in server components, passing to client children
- Server components for SEO content, client for interactivity
- Stream loading with Suspense boundaries
- Third-party client wrappers for server component compatibility

## Reference
- React docs: https://react.dev/reference/rsc/server-components
