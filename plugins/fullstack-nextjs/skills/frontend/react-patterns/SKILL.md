---
name: react-patterns
description: React 19+ patterns including Server Components, hooks, state management, and component architecture.
---

# React Patterns

## When to Use

- Building UI components in Next.js
- Managing client-side state
- Creating reusable hooks
- Implementing interactive features

## When NOT to Use

- Static content without interactivity → Use Server Components without hooks
- Data fetching only → Use Server Components with async/await
- Form submissions → Consider Server Actions first

## Decision Criteria

| Need | Solution |
|------|----------|
| Display data | Server Component (default) |
| User interaction | Client Component (`'use client'`) |
| Shared state | Zustand or Context |
| Server data | React Query or Server Components |
| Form state | React Hook Form |
| URL state | `useSearchParams` / `nuqs` |

## Best Practices

1. **Server Components by default** - Only add `'use client'` when needed
2. **Colocation** - Keep components close to where they're used
3. **Composition over props** - Use children and slots
4. **Single responsibility** - One component, one job
5. **Explicit dependencies** - List all deps in useEffect/useMemo

## Common Pitfalls

- ❌ Adding `'use client'` to every component
- ❌ Fetching data in Client Components (use Server Components)
- ❌ Prop drilling instead of composition
- ❌ Missing dependency arrays in hooks
- ❌ Overusing useEffect for derived state

---

## Patterns

### Pattern 1: Server Component (Default)

**Use when**: Displaying data, no interactivity needed

```typescript
// No 'use client' - this is a Server Component
interface Props {
  id: string;
}

export async function UserProfile({ id }: Props) {
  const user = await getUser(id); // Direct DB/API call

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

### Pattern 2: Client Component

**Use when**: Need hooks, event handlers, or browser APIs

```typescript
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}
```

### Pattern 3: Hybrid Pattern

**Use when**: Server data + client interactivity

```typescript
// Server Component (parent)
export async function ProductPage({ id }: { id: string }) {
  const product = await getProduct(id); // Server fetch

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <AddToCartButton productId={id} /> {/* Client child */}
    </div>
  );
}

// Client Component (child)
'use client';

export function AddToCartButton({ productId }: { productId: string }) {
  const [isPending, startTransition] = useTransition();

  return (
    <button
      onClick={() => startTransition(() => addToCart(productId))}
      disabled={isPending}
    >
      {isPending ? 'Adding...' : 'Add to Cart'}
    </button>
  );
}
```

### Pattern 4: Custom Hook

**Use when**: Reusing stateful logic across components

```typescript
'use client';

import { useState, useCallback } from 'react';

export function useToggle(initial = false) {
  const [value, setValue] = useState(initial);

  const toggle = useCallback(() => setValue(v => !v), []);
  const setTrue = useCallback(() => setValue(true), []);
  const setFalse = useCallback(() => setValue(false), []);

  return { value, toggle, setTrue, setFalse } as const;
}

// Usage
function Modal() {
  const { value: isOpen, toggle, setFalse } = useToggle();
  // ...
}
```

### Pattern 5: Zustand Store

**Use when**: Global client state shared across components

```typescript
// store/useStore.ts
import { create } from 'zustand';

interface CartStore {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  clear: () => void;
}

export const useCartStore = create<CartStore>((set) => ({
  items: [],
  addItem: (item) => set((s) => ({ items: [...s.items, item] })),
  removeItem: (id) => set((s) => ({ items: s.items.filter(i => i.id !== id) })),
  clear: () => set({ items: [] }),
}));

// Usage - selective subscription prevents unnecessary re-renders
function CartCount() {
  const count = useCartStore((s) => s.items.length);
  return <span>{count}</span>;
}
```

### Pattern 6: Compound Components

**Use when**: Building flexible, composable UI components

```typescript
// Card compound component
const Card = ({ children }: { children: React.ReactNode }) => (
  <div className="rounded-lg border shadow-sm">{children}</div>
);

Card.Header = ({ children }: { children: React.ReactNode }) => (
  <div className="border-b p-4 font-semibold">{children}</div>
);

Card.Body = ({ children }: { children: React.ReactNode }) => (
  <div className="p-4">{children}</div>
);

Card.Footer = ({ children }: { children: React.ReactNode }) => (
  <div className="border-t p-4">{children}</div>
);

// Usage
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content here</Card.Body>
  <Card.Footer>
    <Button>Action</Button>
  </Card.Footer>
</Card>
```

### Pattern 7: Error Boundary

**Use when**: Gracefully handling component errors

```typescript
'use client';

import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div role="alert" className="p-4 bg-red-50 rounded">
      <p className="font-bold">Something went wrong</p>
      <pre className="text-sm text-red-600">{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

// Usage
<ErrorBoundary FallbackComponent={ErrorFallback}>
  <RiskyComponent />
</ErrorBoundary>
```
