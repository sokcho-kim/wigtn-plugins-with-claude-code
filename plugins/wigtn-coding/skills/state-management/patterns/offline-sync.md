# Offline-First Data Sync

Queue mutations offline and sync when back online.

## Pending Mutations Store

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
```

## Auto Sync Hook

```typescript
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
```

## Usage Example

```typescript
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
    </View>
  );
}
```
