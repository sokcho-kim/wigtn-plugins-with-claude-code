---
name: mobile-state-management
description: Master mobile-optimized state management with Zustand, MMKV, and React Query. Covers persistent storage, offline support, and performance patterns specific to React Native.
---

# Mobile State Management

Optimized state management patterns for React Native with focus on performance, persistence, and offline support.

## When to Use This Skill

- Setting up global state in React Native
- Implementing persistent storage with MMKV
- Managing server state with offline support
- Optimizing state for mobile performance

## Core Concepts

### State Categories (Mobile)

| Type | Description | Solution |
|------|-------------|----------|
| **UI State** | Modals, tabs, loading | Zustand, useState |
| **Server State** | API data, caching | React Query |
| **Persistent State** | User prefs, tokens | MMKV + Zustand |
| **Form State** | Input values | React Hook Form |

### Storage Options

| Storage | Speed | Use Case |
|---------|-------|----------|
| **MMKV** | Fastest | Preferences, small data |
| **SecureStore** | Secure | Auth tokens, sensitive data |
| **SQLite** | Fast queries | Large datasets |

## Quick Start

### MMKV + Zustand Setup

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

| Pattern | File | Description |
|---------|------|-------------|
| Zustand + MMKV | `patterns/zustand-mmkv.md` | Full persistent store setup |
| React Query Offline | `patterns/react-query-offline.md` | Offline-first data fetching |
| Offline Sync | `patterns/offline-sync.md` | Pending mutations and sync |
| Secure Storage | `patterns/secure-storage.md` | SecureStore for auth tokens |
| Form State | `patterns/form-state.md` | React Hook Form patterns |
| Jotai | `patterns/jotai.md` | Atomic state with persistence |

## Best Practices

**Do's:**
- Use MMKV over AsyncStorage (10x faster)
- Separate auth tokens to SecureStore
- Implement offline support
- Use selectors to prevent re-renders

**Don'ts:**
- Don't store large data in MMKV (use SQLite)
- Don't persist derived state
- Don't store sensitive data in MMKV

## Resources

- [Zustand](https://zustand-demo.pmnd.rs/)
- [TanStack Query](https://tanstack.com/query)
- [MMKV](https://github.com/mrousavy/react-native-mmkv)
- [Jotai](https://jotai.org/)
