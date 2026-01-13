---
name: typescript
description: TypeScript patterns for type safety, utility types, and best practices in Next.js applications.
---

# TypeScript Patterns

## When to Use

- All Next.js application code
- Defining API contracts and data shapes
- Component props and event handlers
- Form validation with Zod integration
- Generic reusable utilities

## When NOT to Use

- Quick scripts/prototypes → Use `any` sparingly
- Third-party types exist → Don't recreate
- Configuration files → May need `.js` extension

## Decision Criteria

| Need | Solution |
|------|----------|
| API response types | Generic `ApiResponse<T>` |
| Form state | `ActionState` with field errors |
| Component props | Interface extending HTML attrs |
| Partial updates | `Partial<T>` or `Pick<T, K>` |
| Runtime validation | Zod schema + `z.infer` |
| Type narrowing | Discriminated unions |

## Best Practices

1. **Infer from Zod** - Single source of truth for types
2. **Prefer interfaces** - Better error messages, extendable
3. **Use strict mode** - Catch more errors at compile time
4. **Avoid `any`** - Use `unknown` + type guards instead
5. **Export types** - Keep types near related code

## Common Pitfalls

- ❌ Using `any` to silence errors
- ❌ Duplicating types instead of inferring
- ❌ Overly complex generic signatures
- ❌ Not using discriminated unions for state
- ❌ Missing return types on async functions

---

## Setup

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

---

## Patterns

### Pattern 1: API Response Types

**Use when**: Consistent API response shapes

```typescript
// lib/types.ts
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string };

type PaginatedResponse<T> = {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
};

// Usage
async function fetchUsers(): Promise<ApiResponse<User[]>> {
  // ...
}

async function fetchUsersPaginated(
  page: number
): Promise<PaginatedResponse<User>> {
  // ...
}
```

### Pattern 2: Server Action State

**Use when**: Forms with Server Actions

```typescript
type ActionState<T = void> = {
  success?: boolean;
  error?: string;
  fieldErrors?: Record<string, string[]>;
  data?: T;
};

// Usage in action
export async function createUser(
  prevState: ActionState<User>,
  formData: FormData
): Promise<ActionState<User>> {
  // ...
  return { success: true, data: user };
}
```

### Pattern 3: Entity Types

**Use when**: Defining data models

```typescript
// Matches Prisma schema
type User = {
  id: string;
  email: string;
  name: string | null;
  createdAt: Date;
  updatedAt: Date;
};

type Post = {
  id: string;
  title: string;
  content: string | null;
  published: boolean;
  authorId: string;
  author?: User;
  createdAt: Date;
  updatedAt: Date;
};

// Create/Update variants
type CreateUser = Omit<User, 'id' | 'createdAt' | 'updatedAt'>;
type UpdateUser = Partial<CreateUser>;
```

### Pattern 4: Utility Types

**Use when**: Transforming existing types

```typescript
// Built-in utilities
type PartialUser = Partial<User>;           // All optional
type RequiredUser = Required<User>;          // All required
type UserPreview = Pick<User, 'id' | 'name'>; // Select fields
type CreateUser = Omit<User, 'id'>;          // Exclude fields
type UserMap = Record<string, User>;         // Object type

// Custom utilities
type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
type RequiredBy<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

type Nullable<T> = T | null;

// Usage
type UserWithOptionalEmail = PartialBy<User, 'email'>;
type UserWithRequiredName = RequiredBy<User, 'name'>;
```

### Pattern 5: Component Props

**Use when**: Typing React components

```typescript
// Basic props
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'destructive';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: () => void;
}

// Extending HTML attributes
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

// Event handlers
type ChangeHandler = React.ChangeEventHandler<HTMLInputElement>;
type SubmitHandler = React.FormEventHandler<HTMLFormElement>;
type ClickHandler = React.MouseEventHandler<HTMLButtonElement>;

// Polymorphic component (as prop)
type PolymorphicProps<E extends React.ElementType, P = {}> = P &
  Omit<React.ComponentPropsWithoutRef<E>, keyof P> & {
    as?: E;
  };
```

### Pattern 6: Zod Integration

**Use when**: Runtime validation with type inference

```typescript
import { z } from 'zod';

// Schema definition
const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().positive().optional(),
});

// Infer type from schema
type UserInput = z.infer<typeof userSchema>;

// Validation functions
function validateUser(data: unknown): UserInput {
  return userSchema.parse(data); // Throws on invalid
}

function safeValidateUser(data: unknown) {
  const result = userSchema.safeParse(data);
  if (!result.success) {
    return { error: result.error.flatten() };
  }
  return { data: result.data };
}
```

### Pattern 7: Type Guards

**Use when**: Runtime type checking

```typescript
// Type predicate
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value
  );
}

// Discriminated union
type Result<T> =
  | { type: 'success'; data: T }
  | { type: 'error'; error: Error };

function handleResult<T>(result: Result<T>): T {
  if (result.type === 'success') {
    return result.data; // TypeScript knows this is T
  } else {
    throw result.error; // TypeScript knows this is Error
  }
}

// Usage
const result: Result<User> = await fetchUser(id);
if (result.type === 'success') {
  console.log(result.data.name); // Autocomplete works
}
```

### Pattern 8: Generic Patterns

**Use when**: Reusable typed utilities

```typescript
// Generic function
async function fetchData<T>(url: string): Promise<T> {
  const res = await fetch(url);
  return res.json();
}

// Generic component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Generic hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue;
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

// Usage
const users = await fetchData<User[]>('/api/users');
<List items={users} renderItem={(u) => u.name} keyExtractor={(u) => u.id} />
const [theme, setTheme] = useLocalStorage('theme', 'light');
```
