# Zustand with Slices Pattern

Scalable Zustand setup using the slices pattern for large applications.

## Slice Definition

```typescript
// store/slices/createUserSlice.ts
import { StateCreator } from "zustand";

export interface UserSlice {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

export const createUserSlice: StateCreator<
  UserSlice & CartSlice, // Combined store type
  [],
  [],
  UserSlice
> = (set, get) => ({
  user: null,
  isAuthenticated: false,
  login: async (credentials) => {
    const user = await authApi.login(credentials);
    set({ user, isAuthenticated: true });
  },
  logout: () => {
    set({ user: null, isAuthenticated: false });
    // Can access other slices
    // get().clearCart()
  },
});
```

## Combined Store

```typescript
// store/index.ts
import { create } from "zustand";
import { devtools, persist } from "zustand/middleware";
import { createUserSlice, UserSlice } from "./slices/createUserSlice";
import { createCartSlice, CartSlice } from "./slices/createCartSlice";

type StoreState = UserSlice & CartSlice;

export const useStore = create<StoreState>()(
  devtools(
    persist(
      (...args) => ({
        ...createUserSlice(...args),
        ...createCartSlice(...args),
      }),
      { name: "app-storage" }
    )
  )
);

// Selective subscriptions (prevents unnecessary re-renders)
export const useUser = () => useStore((state) => state.user);
export const useCart = () => useStore((state) => state.cart);
export const useIsAuthenticated = () => useStore((state) => state.isAuthenticated);
```

## Usage with Selectors

```typescript
// components/UserProfile.tsx
import { useUser, useStore } from "@/store";
import { shallow } from "zustand/shallow";

function UserProfile() {
  // Single value - no shallow needed
  const user = useUser();

  // Multiple values - use shallow comparison
  const { login, logout } = useStore(
    (state) => ({ login: state.login, logout: state.logout }),
    shallow
  );

  return (
    <div>
      {user ? (
        <>
          <p>{user.name}</p>
          <button onClick={logout}>Logout</button>
        </>
      ) : (
        <button onClick={() => login({ email: "", password: "" })}>
          Login
        </button>
      )}
    </div>
  );
}
```
