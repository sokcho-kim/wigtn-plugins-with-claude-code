---
name: error-handling
description: Error handling patterns for Next.js applications including API errors, boundaries, and logging.
---

# Error Handling

## When to Use

- API routes returning errors to clients
- Server Actions with validation failures
- React Error Boundaries for UI errors
- Logging and monitoring production errors
- Custom error pages (404, 500)

## When NOT to Use

- Simple console.log debugging → Use browser devtools
- Expected business logic cases → Use regular return values
- Validation only → Use Zod directly

## Decision Criteria

| Need | Solution |
|------|----------|
| API error responses | Custom error classes + handler wrapper |
| Server Action errors | ActionResult type pattern |
| Component crashes | Error Boundary (`error.tsx`) |
| Page not found | `notFound()` + `not-found.tsx` |
| Global error page | `app/error.tsx` |
| Production logging | Logger utility + service integration |

## Best Practices

1. **Never expose internal errors** - Return generic messages in production
2. **Use custom error classes** - Typed errors with status codes
3. **Wrap handlers consistently** - Single error handling pattern
4. **Log with context** - Include relevant data for debugging
5. **Graceful degradation** - Show fallback UI, not blank screens

## Common Pitfalls

- ❌ Exposing stack traces to clients
- ❌ Catching errors without logging
- ❌ Missing error boundaries in critical sections
- ❌ Not handling async errors in components
- ❌ Inconsistent error response formats

---

## Setup

### Custom Error Classes

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(
    message: string,
    public fieldErrors?: Record<string, string[]>
  ) {
    super(message, 400, 'VALIDATION_ERROR');
    this.name = 'ValidationError';
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
    this.name = 'NotFoundError';
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 403, 'FORBIDDEN');
    this.name = 'ForbiddenError';
  }
}
```

---

## Patterns

### Pattern 1: API Route Error Handler

**Use when**: Consistent error handling across API routes

```typescript
// lib/api-handler.ts
import { NextRequest, NextResponse } from 'next/server';
import { AppError } from './errors';
import { ZodError } from 'zod';

type Handler = (request: NextRequest, context?: any) => Promise<NextResponse>;

export function withErrorHandler(handler: Handler): Handler {
  return async (request, context) => {
    try {
      return await handler(request, context);
    } catch (error) {
      console.error('API Error:', error);

      if (error instanceof AppError) {
        return NextResponse.json(
          { error: error.message, code: error.code },
          { status: error.statusCode }
        );
      }

      if (error instanceof ZodError) {
        return NextResponse.json(
          { error: 'Validation failed', fieldErrors: error.flatten().fieldErrors },
          { status: 400 }
        );
      }

      return NextResponse.json(
        { error: 'Internal server error' },
        { status: 500 }
      );
    }
  };
}

// Usage
export const GET = withErrorHandler(async (request, { params }) => {
  const { id } = await params;
  const user = await db.user.findUnique({ where: { id } });

  if (!user) {
    throw new NotFoundError('User');
  }

  return NextResponse.json(user);
});
```

### Pattern 2: Server Action Error Handling

**Use when**: Actions that return structured results

```typescript
// lib/action-utils.ts
type ActionResult<T = void> =
  | { success: true; data: T }
  | { success: false; error: string; fieldErrors?: Record<string, string[]> };

export async function safeAction<T>(
  fn: () => Promise<T>
): Promise<ActionResult<T>> {
  try {
    const data = await fn();
    return { success: true, data };
  } catch (error) {
    console.error('Action error:', error);

    if (error instanceof AppError) {
      return { success: false, error: error.message };
    }

    if (error instanceof ZodError) {
      return {
        success: false,
        error: 'Validation failed',
        fieldErrors: error.flatten().fieldErrors,
      };
    }

    return { success: false, error: 'Something went wrong' };
  }
}

// Usage
'use server';

export async function createPost(formData: FormData) {
  return safeAction(async () => {
    const data = schema.parse({
      title: formData.get('title'),
      content: formData.get('content'),
    });

    const post = await db.post.create({ data });
    revalidatePath('/posts');
    return post;
  });
}
```

### Pattern 3: Global Error Boundary

**Use when**: Catching unhandled errors in the app

```typescript
// app/error.tsx
'use client';

import { useEffect } from 'react';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error(error);
  }, [error]);

  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h2 className="text-2xl font-bold">Something went wrong!</h2>
        <p className="mt-2 text-muted-foreground">
          {process.env.NODE_ENV === 'development' ? error.message : 'An error occurred'}
        </p>
        <button
          onClick={reset}
          className="mt-4 rounded bg-primary px-4 py-2 text-primary-foreground"
        >
          Try again
        </button>
      </div>
    </div>
  );
}
```

### Pattern 4: Route-Level Error Boundary

**Use when**: Custom error UI for specific routes

```typescript
// app/dashboard/error.tsx
'use client';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div className="p-4 bg-destructive/10 rounded">
      <h3 className="font-bold text-destructive">Dashboard Error</h3>
      <p className="text-destructive/80">{error.message}</p>
      <button onClick={reset} className="mt-2 text-primary underline">
        Retry
      </button>
    </div>
  );
}
```

### Pattern 5: Not Found Handling

**Use when**: Custom 404 pages

```typescript
// app/not-found.tsx
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h1 className="text-6xl font-bold">404</h1>
        <p className="mt-2 text-xl text-muted-foreground">Page not found</p>
        <Link href="/" className="mt-4 inline-block text-primary underline">
          Go home
        </Link>
      </div>
    </div>
  );
}

// Trigger programmatically
import { notFound } from 'next/navigation';

export default async function Page({ params }: { params: { id: string } }) {
  const post = await getPost(params.id);

  if (!post) {
    notFound();
  }

  return <div>{post.title}</div>;
}
```

### Pattern 6: Component Error Boundary

**Use when**: Isolating errors to specific components

```typescript
'use client';

import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div role="alert" className="p-4 bg-destructive/10 rounded">
      <p className="font-bold">Error:</p>
      <pre className="text-sm">{error.message}</pre>
      <button onClick={resetErrorBoundary}>Retry</button>
    </div>
  );
}

export function SafeComponent({ children }: { children: React.ReactNode }) {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onError={(error) => console.error('Caught error:', error)}
    >
      {children}
    </ErrorBoundary>
  );
}
```

### Pattern 7: Logger Utility

**Use when**: Structured logging for production

```typescript
// lib/logger.ts
type LogLevel = 'info' | 'warn' | 'error';

interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  context?: Record<string, unknown>;
}

export const logger = {
  info: (message: string, context?: Record<string, unknown>) =>
    log('info', message, context),
  warn: (message: string, context?: Record<string, unknown>) =>
    log('warn', message, context),
  error: (message: string, context?: Record<string, unknown>) =>
    log('error', message, context),
};

function log(level: LogLevel, message: string, context?: Record<string, unknown>) {
  const entry: LogEntry = {
    level,
    message,
    timestamp: new Date().toISOString(),
    context,
  };

  if (process.env.NODE_ENV === 'production') {
    // Send to logging service (e.g., Sentry, LogRocket)
    console[level](JSON.stringify(entry));
  } else {
    console[level](message, context);
  }
}

// Usage
try {
  await processPayment(order);
  logger.info('Payment processed', { orderId: order.id });
} catch (error) {
  logger.error('Payment failed', { orderId: order.id, error: String(error) });
  throw error;
}
```
