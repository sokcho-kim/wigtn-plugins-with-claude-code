# Jotai Atomic State

Atomic state management with Jotai for granular updates.

## Basic Atoms

```typescript
// atoms/userAtoms.ts
import { atom } from "jotai";
import { atomWithStorage } from "jotai/utils";

// Basic atom
export const userAtom = atom<User | null>(null);

// Derived atom (computed)
export const isAuthenticatedAtom = atom((get) => get(userAtom) !== null);

// Atom with localStorage persistence
export const themeAtom = atomWithStorage<"light" | "dark">("theme", "light");
```

## Async Atoms

```typescript
// atoms/profileAtom.ts
import { atom } from "jotai";
import { userAtom } from "./userAtoms";

// Async atom - automatically suspends
export const userProfileAtom = atom(async (get) => {
  const user = get(userAtom);
  if (!user) return null;

  const response = await fetch(`/api/users/${user.id}/profile`);
  return response.json();
});
```

## Write-Only Atoms (Actions)

```typescript
// atoms/actions.ts
import { atom } from "jotai";
import { userAtom } from "./userAtoms";
import { cartAtom } from "./cartAtoms";

// Write-only atom (action)
export const logoutAtom = atom(null, (get, set) => {
  set(userAtom, null);
  set(cartAtom, []);
  localStorage.removeItem("token");
});

// Async write atom
export const loginAtom = atom(null, async (get, set, credentials: Credentials) => {
  const response = await fetch("/api/login", {
    method: "POST",
    body: JSON.stringify(credentials),
  });
  const user = await response.json();
  set(userAtom, user);
});
```

## Usage with Suspense

```typescript
import { useAtom } from "jotai";
import { Suspense } from "react";
import { userAtom, userProfileAtom, logoutAtom } from "@/atoms";

function ProfileContent() {
  const [user] = useAtom(userAtom);
  const [profile] = useAtom(userProfileAtom); // Suspends while loading
  const [, logout] = useAtom(logoutAtom);

  return (
    <div>
      <h1>{profile?.name}</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}

function Profile() {
  return (
    <Suspense fallback={<Skeleton />}>
      <ProfileContent />
    </Suspense>
  );
}
```
