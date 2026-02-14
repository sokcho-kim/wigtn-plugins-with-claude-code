---
name: state-management
description: Master modern state management with Zustand, Jotai, React Query, and Redux Toolkit. Covers both Web (React/Next.js) and Mobile (React Native) with persistent storage, offline support, and performance patterns.
---

# State Management

Modern state management patterns for React applications — from local component state to global stores, server state synchronization, and mobile-optimized persistence.

## When to Use This Skill

- Setting up global state management in a React or React Native app
- Choosing between Redux Toolkit, Zustand, or Jotai
- Managing server state with React Query or SWR
- Implementing optimistic updates
- Migrating from legacy Redux to modern patterns
- Implementing persistent storage with MMKV (Mobile)
- Managing server state with offline support (Mobile)

## Core Concepts

### State Categories

| Type | Description | Web Solutions | Mobile Solutions |
|------|-------------|--------------|-----------------|
| **Local State** | Component-specific, UI state | useState, useReducer | useState, useReducer |
| **Global State** | Shared across components | Redux Toolkit, Zustand, Jotai | Zustand, Jotai |
| **Server State** | Remote data, caching | React Query, SWR, RTK Query | React Query |
| **Persistent State** | User prefs, tokens | localStorage | MMKV, SecureStore |
| **URL State** | Route parameters, search | React Router, nuqs | Expo Router params |
| **Form State** | Input values, validation | React Hook Form, Formik | React Hook Form |

### Selection Criteria

```
Small app, simple state → Zustand or Jotai
Large app, complex state → Redux Toolkit (Web) / Zustand (Mobile)
Heavy server interaction → React Query + light client state
Atomic/granular updates → Jotai
Mobile persistence needed → Zustand + MMKV
Offline-first mobile → React Query + offline sync
```

### Storage Options (Mobile)

| Storage | Speed | Use Case |
|---------|-------|----------|
| **MMKV** | Fastest | Preferences, small data |
| **SecureStore** | Secure | Auth tokens, sensitive data |
| **SQLite** | Fast queries | Large datasets |

## Quick Start

### Zustand (Web — Simplest)

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

### Zustand + MMKV (Mobile — Persistent)

```bash
npx expo install react-native-mmkv zustand
```

```typescript
// lib/storage.ts
import { MMKV } from 'react-native-mmkv';

export const storage = new MMKV({ id: 'app-storage' });

export const mmkvStorage = {
  getItem: (name: string) => storage.getString(name) ?? null,
  setItem: (name: string, value: string) => storage.set(name, value),
  removeItem: (name: string) => storage.delete(name),
};

// stores/useAppStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { mmkvStorage } from '@/lib/storage';

export const useAppStore = create(
  persist(
    (set) => ({
      theme: 'system',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'app-store',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

## Available Patterns

Load detailed patterns as needed:

### Common (Web & Mobile)

| Pattern | File | Description |
|---------|------|-------------|
| Zustand Slices | `patterns/zustand.md` | Scalable Zustand with slices pattern |
| Jotai Atomic | `patterns/jotai.md` | Atomic state management |
| React Query | `patterns/react-query.md` | Server state with optimistic updates |

### Web Only

| Pattern | File | Description |
|---------|------|-------------|
| Redux Toolkit | `patterns/redux-toolkit.md` | Full RTK setup with TypeScript |
| Combined Pattern | `patterns/combined.md` | Client + server state separation |
| Migration Guide | `patterns/migration.md` | Legacy Redux to RTK migration |

### Mobile Only

| Pattern | File | Description |
|---------|------|-------------|
| Zustand + MMKV | `patterns/zustand-mmkv.md` | Full persistent store setup |
| React Query Offline | `patterns/react-query-offline.md` | Offline-first data fetching |
| Offline Sync | `patterns/offline-sync.md` | Pending mutations and sync |
| Secure Storage | `patterns/secure-storage.md` | SecureStore for auth tokens |

## Best Practices

### Common

**Do's:**
- Colocate state close to where it's used
- Use selectors to prevent unnecessary re-renders
- Separate server state (React Query) from client state (Zustand)

**Don'ts:**
- Don't over-globalize — not everything needs global state
- Don't duplicate server state — let React Query manage it
- Don't mutate directly — use immutable updates

### Mobile-Specific

**Do's:**
- Use MMKV over AsyncStorage (10x faster)
- Separate auth tokens to SecureStore
- Implement offline support

**Don'ts:**
- Don't store large data in MMKV (use SQLite)
- Don't persist derived state
- Don't store sensitive data in MMKV

## Resources

- [Redux Toolkit](https://redux-toolkit.js.org/)
- [Zustand](https://github.com/pmndrs/zustand)
- [Jotai](https://jotai.org/)
- [TanStack Query](https://tanstack.com/query)
- [MMKV](https://github.com/mrousavy/react-native-mmkv)
