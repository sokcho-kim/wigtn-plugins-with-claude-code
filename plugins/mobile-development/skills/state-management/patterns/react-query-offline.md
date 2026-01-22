# React Query with Offline Support

Offline-first data fetching with persistent cache.

## Setup

```bash
npx expo install @tanstack/react-query @tanstack/query-async-storage-persister @react-native-community/netinfo
```

## Query Client Configuration

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
      refetchOnWindowFocus: false,
      networkMode: 'offlineFirst',
    },
    mutations: {
      networkMode: 'offlineFirst',
    },
  },
});

// MMKV persister
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
        queryClient.resumePausedMutations();
      }}
    >
      {children}
    </PersistQueryClientProvider>
  );
}
```

## Query Hooks

```typescript
// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

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
```

## Optimistic Update Mutation

```typescript
export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.updateUser,
    onMutate: async (newUser) => {
      await queryClient.cancelQueries({ queryKey: userKeys.detail(newUser.id) });
      const previousUser = queryClient.getQueryData(userKeys.detail(newUser.id));
      queryClient.setQueryData(userKeys.detail(newUser.id), newUser);
      return { previousUser };
    },
    onError: (err, newUser, context) => {
      if (context?.previousUser) {
        queryClient.setQueryData(userKeys.detail(newUser.id), context.previousUser);
      }
    },
    onSettled: (data, error, variables) => {
      queryClient.invalidateQueries({ queryKey: userKeys.detail(variables.id) });
    },
  });
}
```
