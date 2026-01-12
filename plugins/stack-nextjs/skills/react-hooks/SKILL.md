---
name: react-hooks
description: React hooks patterns, custom hooks, state management. Use when implementing component logic.
---

# React Hooks

React 훅 패턴과 커스텀 훅입니다.

## Basic Hooks

### useState

```typescript
'use client';

import { useState } from 'react';

// Simple state
const [count, setCount] = useState(0);
const [name, setName] = useState('');

// Object state
const [form, setForm] = useState({
  email: '',
  password: '',
});

// Update object state
setForm((prev) => ({ ...prev, email: 'new@email.com' }));

// Lazy initialization (expensive computation)
const [data, setData] = useState(() => {
  return computeExpensiveValue();
});
```

### useEffect

```typescript
import { useEffect } from 'react';

// Run on mount only
useEffect(() => {
  console.log('Component mounted');

  return () => {
    console.log('Component unmounted');
  };
}, []);

// Run when dependencies change
useEffect(() => {
  fetchData(userId);
}, [userId]);

// Cleanup pattern
useEffect(() => {
  const controller = new AbortController();

  fetch('/api/data', { signal: controller.signal })
    .then((res) => res.json())
    .then(setData);

  return () => controller.abort();
}, []);
```

### useRef

```typescript
import { useRef, useEffect } from 'react';

// DOM reference
function InputFocus() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  return <input ref={inputRef} />;
}

// Mutable value (no re-render)
function Timer() {
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const start = () => {
    intervalRef.current = setInterval(() => {
      console.log('tick');
    }, 1000);
  };

  const stop = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
  };

  return (
    <>
      <button onClick={start}>Start</button>
      <button onClick={stop}>Stop</button>
    </>
  );
}
```

### useMemo & useCallback

```typescript
import { useMemo, useCallback } from 'react';

// Memoize expensive computation
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name));
}, [items]);

// Memoize function reference
const handleClick = useCallback(() => {
  console.log('Clicked', id);
}, [id]);

// Memoize object/array props
const options = useMemo(
  () => ({
    enabled: true,
    limit: 10,
  }),
  [],
);
```

## Custom Hooks

### useToggle

```typescript
// hooks/use-toggle.ts
import { useState, useCallback } from 'react';

export function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => setValue((v) => !v), []);
  const setTrue = useCallback(() => setValue(true), []);
  const setFalse = useCallback(() => setValue(false), []);

  return { value, toggle, setTrue, setFalse };
}

// Usage
const { value: isOpen, toggle, setFalse: close } = useToggle();
```

### useLocalStorage

```typescript
// hooks/use-local-storage.ts
import { useState, useEffect } from 'react';

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') {
      return initialValue;
    }
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      if (typeof window !== 'undefined') {
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      }
    } catch (error) {
      console.error(error);
    }
  };

  return [storedValue, setValue] as const;
}

// Usage
const [theme, setTheme] = useLocalStorage('theme', 'light');
```

### useDebounce

```typescript
// hooks/use-debounce.ts
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// Usage
const [search, setSearch] = useState('');
const debouncedSearch = useDebounce(search, 300);

useEffect(() => {
  if (debouncedSearch) {
    fetchResults(debouncedSearch);
  }
}, [debouncedSearch]);
```

### useMediaQuery

```typescript
// hooks/use-media-query.ts
import { useState, useEffect } from 'react';

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false);

  useEffect(() => {
    const media = window.matchMedia(query);
    setMatches(media.matches);

    const listener = (e: MediaQueryListEvent) => setMatches(e.matches);
    media.addEventListener('change', listener);

    return () => media.removeEventListener('change', listener);
  }, [query]);

  return matches;
}

// Usage
const isMobile = useMediaQuery('(max-width: 768px)');
const prefersDark = useMediaQuery('(prefers-color-scheme: dark)');
```

### useClickOutside

```typescript
// hooks/use-click-outside.ts
import { useEffect, RefObject } from 'react';

export function useClickOutside(
  ref: RefObject<HTMLElement>,
  handler: () => void,
) {
  useEffect(() => {
    const listener = (event: MouseEvent | TouchEvent) => {
      if (!ref.current || ref.current.contains(event.target as Node)) {
        return;
      }
      handler();
    };

    document.addEventListener('mousedown', listener);
    document.addEventListener('touchstart', listener);

    return () => {
      document.removeEventListener('mousedown', listener);
      document.removeEventListener('touchstart', listener);
    };
  }, [ref, handler]);
}

// Usage
const dropdownRef = useRef<HTMLDivElement>(null);
useClickOutside(dropdownRef, () => setIsOpen(false));
```

### useAsync

```typescript
// hooks/use-async.ts
import { useState, useCallback } from 'react';

interface UseAsyncState<T> {
  data: T | null;
  error: Error | null;
  isLoading: boolean;
}

export function useAsync<T, Args extends unknown[]>(
  asyncFunction: (...args: Args) => Promise<T>,
) {
  const [state, setState] = useState<UseAsyncState<T>>({
    data: null,
    error: null,
    isLoading: false,
  });

  const execute = useCallback(
    async (...args: Args) => {
      setState({ data: null, error: null, isLoading: true });
      try {
        const data = await asyncFunction(...args);
        setState({ data, error: null, isLoading: false });
        return data;
      } catch (error) {
        setState({ data: null, error: error as Error, isLoading: false });
        throw error;
      }
    },
    [asyncFunction],
  );

  return { ...state, execute };
}

// Usage
const { data, error, isLoading, execute } = useAsync(createUser);
const handleSubmit = () => execute(formData);
```

### useForm

```typescript
// hooks/use-form.ts
import { useState, useCallback, ChangeEvent } from 'react';

interface UseFormOptions<T> {
  initialValues: T;
  onSubmit: (values: T) => void | Promise<void>;
  validate?: (values: T) => Partial<Record<keyof T, string>>;
}

export function useForm<T extends Record<string, any>>({
  initialValues,
  onSubmit,
  validate,
}: UseFormOptions<T>) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = useCallback(
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const { name, value } = e.target;
      setValues((prev) => ({ ...prev, [name]: value }));
      setErrors((prev) => ({ ...prev, [name]: undefined }));
    },
    [],
  );

  const handleSubmit = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();

      if (validate) {
        const validationErrors = validate(values);
        if (Object.keys(validationErrors).length > 0) {
          setErrors(validationErrors);
          return;
        }
      }

      setIsSubmitting(true);
      try {
        await onSubmit(values);
      } finally {
        setIsSubmitting(false);
      }
    },
    [values, validate, onSubmit],
  );

  const reset = useCallback(() => {
    setValues(initialValues);
    setErrors({});
  }, [initialValues]);

  return {
    values,
    errors,
    isSubmitting,
    handleChange,
    handleSubmit,
    reset,
    setValues,
    setErrors,
  };
}
```

## Data Fetching Hooks (TanStack Query)

```typescript
// hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getUsers, createUser, updateUser, deleteUser } from '@/lib/api/users';

export function useUsers(params?: { page?: number; search?: string }) {
  return useQuery({
    queryKey: ['users', params],
    queryFn: () => getUsers(params),
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => getUserById(id),
    enabled: !!id,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserDto }) =>
      updateUser(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['users', id] });
    },
  });
}
```

## Best Practices

```yaml
hook_rules:
  - Only call hooks at top level
  - Only call hooks from React functions
  - Use 'use' prefix for custom hooks
  - Keep hooks focused and reusable

dependencies:
  - Include all values used inside effect
  - Use useCallback for function dependencies
  - Use useMemo for object/array dependencies
  - Use refs for values that shouldn't trigger re-render

performance:
  - Use useMemo for expensive computations
  - Use useCallback for callbacks passed to children
  - Avoid creating objects in render
  - Split state by update frequency

organization:
  hooks/
  ├── use-toggle.ts
  ├── use-debounce.ts
  ├── use-local-storage.ts
  └── use-users.ts      # Feature-specific hooks
```
