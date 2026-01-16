---
name: mobile-state-management
description: Master mobile-optimized state management with Zustand, MMKV, and React Query. Covers persistent storage, offline support, and performance patterns specific to React Native.
---

# Mobile State Management

Optimized state management patterns for React Native applications with focus on performance, persistence, and offline support.

## When to Use This Skill

- Setting up global state in React Native
- Implementing persistent storage with MMKV
- Managing server state with offline support
- Optimizing state for mobile performance
- Syncing state across app restarts

## Core Concepts

### 1. State Categories (Mobile)

| Type | Description | Solution |
|------|-------------|----------|
| **UI State** | Modals, tabs, loading | Zustand, useState |
| **Server State** | API data, caching | React Query |
| **Persistent State** | User prefs, tokens | MMKV + Zustand |
| **Form State** | Input values | React Hook Form |
| **Navigation State** | Current screen | Expo Router |

### 2. Storage Options

| Storage | Speed | Use Case |
|---------|-------|----------|
| **MMKV** | Fastest | Preferences, tokens, small data |
| **AsyncStorage** | Slow | Legacy, simple needs |
| **SQLite** | Fast for queries | Large datasets |
| **SecureStore** | Secure | Auth tokens, sensitive data |

## Quick Start

### MMKV + Zustand Setup

```bash
npx expo install react-native-mmkv zustand
```

```typescript
// lib/storage.ts
import { MMKV } from 'react-native-mmkv';

export const storage = new MMKV({
  id: 'app-storage',
  encryptionKey: 'your-encryption-key', // Optional
});

// Zustand storage adapter
export const mmkvStorage = {
  getItem: (name: string) => {
    const value = storage.getString(name);
    return value ?? null;
  },
  setItem: (name: string, value: string) => {
    storage.set(name, value);
  },
  removeItem: (name: string) => {
    storage.delete(name);
  },
};
```

## Patterns

### Pattern 1: Zustand with MMKV Persistence

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

// Selectors for optimized re-renders
export const useUser = () => useAppStore((state) => state.user);
export const useToken = () => useAppStore((state) => state.token);
export const useTheme = () => useAppStore((state) => state.theme);
export const useIsAuthenticated = () => useAppStore((state) => !!state.token);
```

### Pattern 2: React Query with Offline Support

```typescript
// lib/queryClient.ts
import { QueryClient } from '@tanstack/react-query';
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister';
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';
import { mmkvStorage } from '@/lib/storage';
import NetInfo from '@react-native-community/netinfo';
import { onlineManager } from '@tanstack/react-query';

// Set up online status listener
onlineManager.setEventListener((setOnline) => {
  return NetInfo.addEventListener((state) => {
    setOnline(!!state.isConnected);
  });
});

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24, // 24 hours
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 2,
      refetchOnWindowFocus: false, // Not applicable to mobile
      networkMode: 'offlineFirst',
    },
    mutations: {
      networkMode: 'offlineFirst',
    },
  },
});

// AsyncStorage persister using MMKV
const asyncStoragePersister = createAsyncStoragePersister({
  storage: {
    getItem: async (key) => mmkvStorage.getItem(key),
    setItem: async (key, value) => mmkvStorage.setItem(key, value),
    removeItem: async (key) => mmkvStorage.removeItem(key),
  },
  throttleTime: 1000,
});

// Provider wrapper
export function QueryProvider({ children }: { children: React.ReactNode }) {
  return (
    <PersistQueryClientProvider
      client={queryClient}
      persistOptions={{ persister: asyncStoragePersister }}
      onSuccess={() => {
        // Resume mutations after persistence restore
        queryClient.resumePausedMutations();
      }}
    >
      {children}
    </PersistQueryClientProvider>
  );
}

// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api';

export const userKeys = {
  all: ['users'] as const,
  list: (filters?: UserFilters) => [...userKeys.all, 'list', filters] as const,
  detail: (id: string) => [...userKeys.all, 'detail', id] as const,
};

export function useUsers(filters?: UserFilters) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => api.getUsers(filters),
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => api.getUser(id),
    enabled: !!id,
  });
}

// Optimistic update mutation
export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.updateUser,
    onMutate: async (newUser) => {
      // Cancel any outgoing refetches
      await queryClient.cancelQueries({ queryKey: userKeys.detail(newUser.id) });

      // Snapshot current value
      const previousUser = queryClient.getQueryData(userKeys.detail(newUser.id));

      // Optimistically update
      queryClient.setQueryData(userKeys.detail(newUser.id), newUser);

      return { previousUser };
    },
    onError: (err, newUser, context) => {
      // Rollback on error
      if (context?.previousUser) {
        queryClient.setQueryData(userKeys.detail(newUser.id), context.previousUser);
      }
    },
    onSettled: (data, error, variables) => {
      // Always refetch after mutation
      queryClient.invalidateQueries({ queryKey: userKeys.detail(variables.id) });
    },
  });
}
```

### Pattern 3: Offline-First Data Sync

```typescript
// hooks/useOfflineSync.ts
import { useEffect } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { storage } from '@/lib/storage';
import NetInfo from '@react-native-community/netinfo';

interface PendingMutation {
  id: string;
  type: 'create' | 'update' | 'delete';
  endpoint: string;
  data: any;
  timestamp: number;
}

const PENDING_MUTATIONS_KEY = 'pending_mutations';

export function usePendingMutations() {
  const getPending = (): PendingMutation[] => {
    const stored = storage.getString(PENDING_MUTATIONS_KEY);
    return stored ? JSON.parse(stored) : [];
  };

  const addPending = (mutation: Omit<PendingMutation, 'id' | 'timestamp'>) => {
    const pending = getPending();
    pending.push({
      ...mutation,
      id: Date.now().toString(),
      timestamp: Date.now(),
    });
    storage.set(PENDING_MUTATIONS_KEY, JSON.stringify(pending));
  };

  const removePending = (id: string) => {
    const pending = getPending().filter((m) => m.id !== id);
    storage.set(PENDING_MUTATIONS_KEY, JSON.stringify(pending));
  };

  const clearPending = () => {
    storage.delete(PENDING_MUTATIONS_KEY);
  };

  return { getPending, addPending, removePending, clearPending };
}

export function useOfflineSync() {
  const queryClient = useQueryClient();
  const { getPending, removePending } = usePendingMutations();

  const syncMutation = useMutation({
    mutationFn: async (mutation: PendingMutation) => {
      const response = await fetch(mutation.endpoint, {
        method: mutation.type === 'delete' ? 'DELETE' :
                mutation.type === 'create' ? 'POST' : 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(mutation.data),
      });

      if (!response.ok) throw new Error('Sync failed');
      return response.json();
    },
    onSuccess: (_, mutation) => {
      removePending(mutation.id);
    },
  });

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state) => {
      if (state.isConnected) {
        // Sync pending mutations when back online
        const pending = getPending();
        pending
          .sort((a, b) => a.timestamp - b.timestamp)
          .forEach((mutation) => {
            syncMutation.mutate(mutation);
          });
      }
    });

    return unsubscribe;
  }, []);

  return { pendingCount: getPending().length };
}

// Usage in a component
function TodoList() {
  const { pendingCount } = useOfflineSync();
  const { addPending } = usePendingMutations();
  const queryClient = useQueryClient();

  const createTodo = async (todo: Partial<Todo>) => {
    // Optimistically add to local state
    const tempId = `temp_${Date.now()}`;
    const newTodo = { ...todo, id: tempId };

    queryClient.setQueryData(['todos'], (old: Todo[]) => [...(old || []), newTodo]);

    // Queue for sync
    addPending({
      type: 'create',
      endpoint: '/api/todos',
      data: todo,
    });
  };

  return (
    <View>
      {pendingCount > 0 && (
        <Text className="text-warning">
          {pendingCount} changes pending sync
        </Text>
      )}
      {/* ... */}
    </View>
  );
}
```

### Pattern 4: Secure Storage for Sensitive Data

```typescript
// lib/secureStorage.ts
import * as SecureStore from 'expo-secure-store';

export const secureStorage = {
  async getItem(key: string): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(key);
    } catch (error) {
      console.error('SecureStore get error:', error);
      return null;
    }
  },

  async setItem(key: string, value: string): Promise<void> {
    try {
      await SecureStore.setItemAsync(key, value);
    } catch (error) {
      console.error('SecureStore set error:', error);
    }
  },

  async removeItem(key: string): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error('SecureStore delete error:', error);
    }
  },
};

// stores/useAuthStore.ts - Separate store for auth
import { create } from 'zustand';
import { secureStorage } from '@/lib/secureStorage';

interface AuthState {
  token: string | null;
  refreshToken: string | null;
  isHydrated: boolean;

  setTokens: (token: string, refreshToken: string) => Promise<void>;
  clearTokens: () => Promise<void>;
  hydrate: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  refreshToken: null,
  isHydrated: false,

  setTokens: async (token, refreshToken) => {
    await Promise.all([
      secureStorage.setItem('auth_token', token),
      secureStorage.setItem('refresh_token', refreshToken),
    ]);
    set({ token, refreshToken });
  },

  clearTokens: async () => {
    await Promise.all([
      secureStorage.removeItem('auth_token'),
      secureStorage.removeItem('refresh_token'),
    ]);
    set({ token: null, refreshToken: null });
  },

  hydrate: async () => {
    const [token, refreshToken] = await Promise.all([
      secureStorage.getItem('auth_token'),
      secureStorage.getItem('refresh_token'),
    ]);
    set({ token, refreshToken, isHydrated: true });
  },
}));

// Use in app initialization
function App() {
  const hydrate = useAuthStore((state) => state.hydrate);
  const isHydrated = useAuthStore((state) => state.isHydrated);

  useEffect(() => {
    hydrate();
  }, []);

  if (!isHydrated) {
    return <SplashScreen />;
  }

  return <Navigation />;
}
```

### Pattern 5: Form State with React Hook Form

```typescript
// components/ProfileForm.tsx
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { View, TextInput, Text, Pressable, Alert } from 'react-native';

const profileSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number').optional(),
  bio: z.string().max(160, 'Bio must be 160 characters or less').optional(),
});

type ProfileFormData = z.infer<typeof profileSchema>;

export function ProfileForm({ defaultValues }: { defaultValues?: Partial<ProfileFormData> }) {
  const {
    control,
    handleSubmit,
    formState: { errors, isSubmitting, isDirty },
    reset,
  } = useForm<ProfileFormData>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      name: '',
      email: '',
      phone: '',
      bio: '',
      ...defaultValues,
    },
  });

  const onSubmit = async (data: ProfileFormData) => {
    try {
      await updateProfile(data);
      Alert.alert('Success', 'Profile updated!');
      reset(data); // Reset form state after successful save
    } catch (error) {
      Alert.alert('Error', 'Failed to update profile');
    }
  };

  return (
    <View className="p-4">
      <Controller
        control={control}
        name="name"
        render={({ field: { onChange, onBlur, value } }) => (
          <View className="mb-4">
            <Text className="text-foreground mb-1 font-medium">Name</Text>
            <TextInput
              className="bg-muted px-4 py-3 rounded-xl text-foreground"
              onBlur={onBlur}
              onChangeText={onChange}
              value={value}
              placeholder="Your name"
            />
            {errors.name && (
              <Text className="text-destructive mt-1 text-sm">
                {errors.name.message}
              </Text>
            )}
          </View>
        )}
      />

      <Controller
        control={control}
        name="email"
        render={({ field: { onChange, onBlur, value } }) => (
          <View className="mb-4">
            <Text className="text-foreground mb-1 font-medium">Email</Text>
            <TextInput
              className="bg-muted px-4 py-3 rounded-xl text-foreground"
              onBlur={onBlur}
              onChangeText={onChange}
              value={value}
              placeholder="your@email.com"
              keyboardType="email-address"
              autoCapitalize="none"
            />
            {errors.email && (
              <Text className="text-destructive mt-1 text-sm">
                {errors.email.message}
              </Text>
            )}
          </View>
        )}
      />

      <Controller
        control={control}
        name="bio"
        render={({ field: { onChange, onBlur, value } }) => (
          <View className="mb-4">
            <Text className="text-foreground mb-1 font-medium">Bio</Text>
            <TextInput
              className="bg-muted px-4 py-3 rounded-xl text-foreground min-h-[100]"
              onBlur={onBlur}
              onChangeText={onChange}
              value={value}
              placeholder="Tell us about yourself"
              multiline
              textAlignVertical="top"
            />
            {errors.bio && (
              <Text className="text-destructive mt-1 text-sm">
                {errors.bio.message}
              </Text>
            )}
          </View>
        )}
      />

      <Pressable
        onPress={handleSubmit(onSubmit)}
        disabled={isSubmitting || !isDirty}
        className={`py-4 rounded-xl items-center ${
          isSubmitting || !isDirty ? 'bg-primary/50' : 'bg-primary'
        }`}
      >
        <Text className="text-primary-foreground font-semibold">
          {isSubmitting ? 'Saving...' : 'Save Changes'}
        </Text>
      </Pressable>
    </View>
  );
}
```

### Pattern 6: Jotai for Atomic State

```typescript
// atoms/index.ts
import { atom } from 'jotai';
import { atomWithStorage, createJSONStorage } from 'jotai/utils';
import { mmkvStorage } from '@/lib/storage';

// Simple atoms
export const counterAtom = atom(0);

// Derived atom
export const doubleCounterAtom = atom((get) => get(counterAtom) * 2);

// Writable derived atom
export const incrementAtom = atom(
  null, // no read value
  (get, set) => set(counterAtom, get(counterAtom) + 1)
);

// Persistent atom with MMKV
const jotaiStorage = createJSONStorage(() => ({
  getItem: (key) => mmkvStorage.getItem(key),
  setItem: (key, value) => mmkvStorage.setItem(key, value),
  removeItem: (key) => mmkvStorage.removeItem(key),
}));

export const themeAtom = atomWithStorage<'light' | 'dark' | 'system'>(
  'theme',
  'system',
  jotaiStorage
);

export const onboardingCompletedAtom = atomWithStorage(
  'onboarding_completed',
  false,
  jotaiStorage
);

// Async atom
export const userProfileAtom = atom(async (get) => {
  const response = await fetch('/api/profile');
  return response.json();
});

// Usage
import { useAtom, useAtomValue, useSetAtom } from 'jotai';

function Counter() {
  const [count, setCount] = useAtom(counterAtom);
  const doubleCount = useAtomValue(doubleCounterAtom);
  const increment = useSetAtom(incrementAtom);

  return (
    <View>
      <Text>Count: {count}</Text>
      <Text>Double: {doubleCount}</Text>
      <Pressable onPress={increment}>
        <Text>Increment</Text>
      </Pressable>
    </View>
  );
}
```

## Best Practices

### Do's

- **Use MMKV over AsyncStorage** - 10x faster
- **Separate auth tokens** - Use SecureStore for sensitive data
- **Implement offline support** - Users expect apps to work offline
- **Use selectors** - Prevent unnecessary re-renders
- **Persist strategically** - Not everything needs to be persisted

### Don'ts

- **Don't store large data in MMKV** - Use SQLite for large datasets
- **Don't ignore sync conflicts** - Handle offline-to-online transitions
- **Don't persist derived state** - Compute it instead
- **Don't store sensitive data insecurely** - Use SecureStore
- **Don't over-fetch** - Use proper stale times

## Resources

- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [TanStack Query](https://tanstack.com/query)
- [MMKV](https://github.com/mrousavy/react-native-mmkv)
- [Expo SecureStore](https://docs.expo.dev/versions/latest/sdk/securestore/)
- [Jotai](https://jotai.org/)
