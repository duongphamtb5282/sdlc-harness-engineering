---
name: react-state-management
description: Frontend/TS skill for react-state-management
---
# React State Management

State management patterns and libraries for React.

## Key Concepts
- **React built-in**: useState, useReducer, useContext, useSyncExternalStore
- **Redux Toolkit**: slices, createAsyncThunk, RTK Query
- **Zustand**: minimal, hook-based store
- **Jotai**: atomic state management
- **TanStack Query**: server state, caching, background refetching
- **Zustand + TanStack Query**: recommended modern stack

## Common Patterns
- Global UI state with Zustand (theme, modals, sidebar)
- Server state with TanStack Query (API data, caching)
- URL state with next/navigation (search params, filters)
- Form state with React Hook Form + Zod validation
- Atomic state with Jotai for complex dependency graphs

## Reference
- Redux Toolkit: https://redux-toolkit.js.org
- Zustand: https://zustand-demo.pmnd.rs
- TanStack Query: https://tanstack.com/query
