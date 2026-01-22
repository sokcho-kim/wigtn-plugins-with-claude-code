---
name: react-state-management
description: Master modern React state management with Redux Toolkit, Zustand, Jotai, and React Query. Use when setting up global state, managing server state, or choosing between state management solutions.
---

# React State Management

Modern React state management patterns, from local component state to global stores and server state synchronization.

## When to Use This Skill

- Setting up global state management in a React app
- Choosing between Redux Toolkit, Zustand, or Jotai
- Managing server state with React Query or SWR
- Implementing optimistic updates
- Migrating from legacy Redux to modern patterns

## Core Concepts

### State Categories

| Type | Description | Solutions |
|------|-------------|-----------|
| **Local State** | Component-specific, UI state | useState, useReducer |
| **Global State** | Shared across components | Redux Toolkit, Zustand, Jotai |
| **Server State** | Remote data, caching | React Query, SWR, RTK Query |
| **URL State** | Route parameters, search | React Router, nuqs |
| **Form State** | Input values, validation | React Hook Form, Formik |

### Selection Criteria

```
Small app, simple state → Zustand or Jotai
Large app, complex state → Redux Toolkit
Heavy server interaction → React Query + light client state
Atomic/granular updates → Jotai
```

## Quick Start

### Zustand (Simplest)

```typescript
// store/useStore.ts
import { create } from "zustand";

interface AppState {
  user: User | null;
  theme: "light" | "dark";
  setUser: (user: User | null) => void;
  toggleTheme: () => void;
}

export const useStore = create<AppState>((set) => ({
  user: null,
  theme: "light",
  setUser: (user) => set({ user }),
  toggleTheme: () =>
    set((state) => ({
      theme: state.theme === "light" ? "dark" : "light",
    })),
}));

// Usage
function Header() {
  const { user, toggleTheme } = useStore();
  return <button onClick={toggleTheme}>Toggle</button>;
}
```

## Available Patterns

Load detailed patterns as needed:

| Pattern | File | Description |
|---------|------|-------------|
| Redux Toolkit | `patterns/redux-toolkit.md` | Full RTK setup with TypeScript |
| Zustand Slices | `patterns/zustand-slices.md` | Scalable Zustand with slices pattern |
| Jotai Atomic | `patterns/jotai.md` | Atomic state management |
| React Query | `patterns/react-query.md` | Server state with optimistic updates |
| Combined Pattern | `patterns/combined.md` | Client + server state separation |
| Migration Guide | `patterns/migration.md` | Legacy Redux to RTK migration |

## Best Practices

**Do's:**
- Colocate state close to where it's used
- Use selectors to prevent unnecessary re-renders
- Separate server state (React Query) from client state (Zustand)

**Don'ts:**
- Don't over-globalize - not everything needs global state
- Don't duplicate server state - let React Query manage it
- Don't mutate directly - use immutable updates

## Resources

- [Redux Toolkit](https://redux-toolkit.js.org/)
- [Zustand](https://github.com/pmndrs/zustand)
- [Jotai](https://jotai.org/)
- [TanStack Query](https://tanstack.com/query)
