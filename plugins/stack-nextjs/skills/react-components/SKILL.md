---
name: react-components
description: React component patterns, composition, props typing, client/server components. Use when building UI components.
---

# React Components

React 컴포넌트 패턴과 구성 방법입니다.

## Component Types

### Server Component (Default)

```typescript
// components/users/user-list.tsx
import { getUsers } from '@/lib/api/users';

export async function UserList() {
  const users = await getUsers();

  return (
    <ul className="space-y-2">
      {users.map((user) => (
        <li key={user.id} className="p-4 border rounded">
          {user.name}
        </li>
      ))}
    </ul>
  );
}
```

### Client Component

```typescript
// components/users/user-search.tsx
'use client';

import { useState } from 'react';
import { Input } from '@/components/ui/input';

export function UserSearch() {
  const [query, setQuery] = useState('');

  return (
    <Input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      placeholder="Search users..."
    />
  );
}
```

## Props Typing

### Basic Props

```typescript
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
}

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  onClick,
}: ButtonProps) {
  return (
    <button
      className={cn(variants[variant], sizes[size])}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

### Extending HTML Props

```typescript
import { ComponentPropsWithoutRef, forwardRef } from 'react';

interface InputProps extends ComponentPropsWithoutRef<'input'> {
  label?: string;
  error?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, className, ...props }, ref) => {
    return (
      <div className="space-y-1">
        {label && <label className="text-sm font-medium">{label}</label>}
        <input
          ref={ref}
          className={cn('w-full px-3 py-2 border rounded', className)}
          {...props}
        />
        {error && <p className="text-sm text-red-500">{error}</p>}
      </div>
    );
  },
);

Input.displayName = 'Input';
```

### Polymorphic Components

```typescript
import { ComponentPropsWithoutRef, ElementType } from 'react';

type BoxProps<T extends ElementType> = {
  as?: T;
  children: React.ReactNode;
} & ComponentPropsWithoutRef<T>;

export function Box<T extends ElementType = 'div'>({
  as,
  children,
  ...props
}: BoxProps<T>) {
  const Component = as || 'div';
  return <Component {...props}>{children}</Component>;
}

// Usage
<Box as="section" className="p-4">Content</Box>
<Box as="article">Article content</Box>
```

## Component Patterns

### Compound Components

```typescript
// components/ui/card.tsx
import { createContext, useContext, ReactNode } from 'react';

const CardContext = createContext<{ variant: string } | null>(null);

interface CardProps {
  children: ReactNode;
  variant?: 'default' | 'bordered';
}

function Card({ children, variant = 'default' }: CardProps) {
  return (
    <CardContext.Provider value={{ variant }}>
      <div className={cn('rounded-lg', variants[variant])}>
        {children}
      </div>
    </CardContext.Provider>
  );
}

function CardHeader({ children }: { children: ReactNode }) {
  return <div className="p-4 border-b">{children}</div>;
}

function CardContent({ children }: { children: ReactNode }) {
  return <div className="p-4">{children}</div>;
}

function CardFooter({ children }: { children: ReactNode }) {
  return <div className="p-4 border-t">{children}</div>;
}

Card.Header = CardHeader;
Card.Content = CardContent;
Card.Footer = CardFooter;

export { Card };

// Usage
<Card variant="bordered">
  <Card.Header>Title</Card.Header>
  <Card.Content>Content</Card.Content>
  <Card.Footer>Actions</Card.Footer>
</Card>
```

### Render Props

```typescript
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => ReactNode;
  keyExtractor: (item: T) => string;
  emptyComponent?: ReactNode;
}

export function List<T>({
  items,
  renderItem,
  keyExtractor,
  emptyComponent,
}: ListProps<T>) {
  if (items.length === 0) {
    return emptyComponent || <p>No items</p>;
  }

  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item)}>{renderItem(item, index)}</li>
      ))}
    </ul>
  );
}

// Usage
<List
  items={users}
  keyExtractor={(user) => user.id}
  renderItem={(user) => <UserCard user={user} />}
  emptyComponent={<EmptyState />}
/>
```

### Controlled vs Uncontrolled

```typescript
interface ToggleProps {
  // Controlled
  checked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  // Uncontrolled
  defaultChecked?: boolean;
}

export function Toggle({
  checked: controlledChecked,
  onCheckedChange,
  defaultChecked = false,
}: ToggleProps) {
  const [uncontrolledChecked, setUncontrolledChecked] = useState(defaultChecked);

  const isControlled = controlledChecked !== undefined;
  const checked = isControlled ? controlledChecked : uncontrolledChecked;

  const handleChange = () => {
    const newValue = !checked;
    if (!isControlled) {
      setUncontrolledChecked(newValue);
    }
    onCheckedChange?.(newValue);
  };

  return (
    <button
      role="switch"
      aria-checked={checked}
      onClick={handleChange}
    >
      {checked ? 'On' : 'Off'}
    </button>
  );
}
```

## Component Composition

### Slot Pattern

```typescript
interface DialogProps {
  trigger: ReactNode;
  title: ReactNode;
  description?: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
}

export function Dialog({
  trigger,
  title,
  description,
  children,
  footer,
}: DialogProps) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <div onClick={() => setOpen(true)}>{trigger}</div>
      {open && (
        <div className="dialog-overlay">
          <div className="dialog-content">
            <div className="dialog-header">
              <h2>{title}</h2>
              {description && <p>{description}</p>}
            </div>
            <div className="dialog-body">{children}</div>
            {footer && <div className="dialog-footer">{footer}</div>}
          </div>
        </div>
      )}
    </>
  );
}

// Usage
<Dialog
  trigger={<Button>Open</Button>}
  title="Confirm Action"
  description="Are you sure?"
  footer={<Button>Confirm</Button>}
>
  <p>Dialog content here</p>
</Dialog>
```

### Provider Pattern

```typescript
// components/providers/index.tsx
'use client';

import { QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'next-themes';
import { Toaster } from '@/components/ui/toaster';
import { queryClient } from '@/lib/query-client';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="system">
        {children}
        <Toaster />
      </ThemeProvider>
    </QueryClientProvider>
  );
}
```

## Skeleton Components

```typescript
// components/skeletons/user-card-skeleton.tsx
export function UserCardSkeleton() {
  return (
    <div className="p-4 border rounded animate-pulse">
      <div className="flex items-center gap-4">
        <div className="w-12 h-12 bg-gray-200 rounded-full" />
        <div className="flex-1 space-y-2">
          <div className="h-4 w-32 bg-gray-200 rounded" />
          <div className="h-3 w-24 bg-gray-200 rounded" />
        </div>
      </div>
    </div>
  );
}

// Usage with Suspense
<Suspense fallback={<UserCardSkeleton />}>
  <UserCard userId={id} />
</Suspense>
```

## Best Practices

```yaml
component_guidelines:
  - Use server components by default
  - Add 'use client' only when needed
  - Keep components focused and small
  - Use composition over inheritance
  - Type all props explicitly

file_structure:
  components/
  ├── ui/               # Reusable primitives
  │   ├── button.tsx
  │   ├── input.tsx
  │   └── card.tsx
  ├── [feature]/        # Feature-specific
  │   ├── user-card.tsx
  │   └── user-list.tsx
  ├── layout/           # Layout components
  │   ├── header.tsx
  │   └── sidebar.tsx
  └── providers/        # Context providers

naming:
  - PascalCase for components
  - kebab-case for files
  - Props suffix for prop types
  - Skeleton suffix for loading states

when_to_use_client:
  - useState, useEffect, useRef
  - Event handlers (onClick, onChange)
  - Browser APIs (localStorage, window)
  - Third-party client libraries
```
