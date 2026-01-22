# Jotai Atomic State

Atomic state management with MMKV persistence.

## Basic Atoms

```typescript
// atoms/index.ts
import { atom } from 'jotai';
import { atomWithStorage, createJSONStorage } from 'jotai/utils';
import { mmkvStorage } from '@/lib/storage';

// Simple atoms
export const counterAtom = atom(0);

// Derived atom
export const doubleCounterAtom = atom((get) => get(counterAtom) * 2);

// Writable derived atom (action)
export const incrementAtom = atom(
  null,
  (get, set) => set(counterAtom, get(counterAtom) + 1)
);
```

## Persistent Atoms with MMKV

```typescript
// Jotai storage adapter
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
```

## Async Atoms

```typescript
// Async atom - automatically suspends
export const userProfileAtom = atom(async (get) => {
  const response = await fetch('/api/profile');
  return response.json();
});

// Async write atom
export const loginAtom = atom(null, async (get, set, credentials: Credentials) => {
  const response = await fetch('/api/login', {
    method: 'POST',
    body: JSON.stringify(credentials),
  });
  const user = await response.json();
  set(userAtom, user);
});
```

## Usage

```typescript
import { useAtom, useAtomValue, useSetAtom } from 'jotai';
import { Suspense } from 'react';

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

// With async atom
function Profile() {
  return (
    <Suspense fallback={<Skeleton />}>
      <ProfileContent />
    </Suspense>
  );
}

function ProfileContent() {
  const profile = useAtomValue(userProfileAtom);
  return <Text>{profile.name}</Text>;
}
```
