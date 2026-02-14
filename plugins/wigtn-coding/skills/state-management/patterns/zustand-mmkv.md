# Zustand with MMKV Persistence

Complete Zustand store setup with MMKV for fast persistent storage.

## Store Configuration

```typescript
// stores/useAppStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { mmkvStorage } from '@/lib/storage';

interface User {
  id: string;
  email: string;
  name: string;
}

interface AppState {
  // Auth
  user: User | null;
  token: string | null;

  // Preferences
  theme: 'light' | 'dark' | 'system';
  notifications: boolean;

  // Actions
  setUser: (user: User | null, token?: string) => void;
  setTheme: (theme: 'light' | 'dark' | 'system') => void;
  toggleNotifications: () => void;
  logout: () => void;
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      token: null,
      theme: 'system',
      notifications: true,

      // Actions
      setUser: (user, token) => set({
        user,
        token: token ?? get().token
      }),

      setTheme: (theme) => set({ theme }),

      toggleNotifications: () => set((state) => ({
        notifications: !state.notifications
      })),

      logout: () => set({
        user: null,
        token: null
      }),
    }),
    {
      name: 'app-store',
      storage: createJSONStorage(() => mmkvStorage),
      partialize: (state) => ({
        // Only persist these fields
        user: state.user,
        token: state.token,
        theme: state.theme,
        notifications: state.notifications,
      }),
    }
  )
);
```

## Optimized Selectors

```typescript
// Selectors for optimized re-renders
export const useUser = () => useAppStore((state) => state.user);
export const useToken = () => useAppStore((state) => state.token);
export const useTheme = () => useAppStore((state) => state.theme);
export const useIsAuthenticated = () => useAppStore((state) => !!state.token);

// Usage
function Header() {
  const user = useUser(); // Only re-renders when user changes
  return <Text>{user?.name}</Text>;
}
```

## Multiple Stores Pattern

```typescript
// stores/useUIStore.ts - Non-persistent UI state
export const useUIStore = create<UIState>((set) => ({
  modalOpen: false,
  sidebarOpen: true,
  openModal: () => set({ modalOpen: true }),
  closeModal: () => set({ modalOpen: false }),
}));

// stores/useSettingsStore.ts - Persistent settings
export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      language: 'en',
      fontSize: 16,
      setLanguage: (lang) => set({ language: lang }),
    }),
    {
      name: 'settings-store',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```
