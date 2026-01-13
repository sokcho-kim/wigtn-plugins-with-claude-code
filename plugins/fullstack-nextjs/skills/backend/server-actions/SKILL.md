---
name: server-actions
description: Next.js Server Actions for form handling, mutations, and server-side logic.
---

# Server Actions

## When to Use

- Form submissions and mutations
- Data modifications (create, update, delete)
- Actions triggered by user interaction
- When you want progressive enhancement

## When NOT to Use

- Read-only data fetching → Use Server Components
- Third-party API access needed from client → Use API routes
- WebSocket/real-time features → Use dedicated solutions
- Complex request/response handling → Use API routes

## Decision Criteria

| Need | Solution |
|------|----------|
| Form submission | Server Action |
| Progressive enhancement | Server Action with `<form action>` |
| Loading state | `useActionState` or `useTransition` |
| Optimistic UI | `useOptimistic` + Server Action |
| Complex API | API route instead |

## Best Practices

1. **Always validate input** - Use Zod on the server
2. **Return typed results** - Define success/error states
3. **Revalidate after mutation** - `revalidatePath` or `revalidateTag`
4. **Handle errors gracefully** - Never expose internal errors
5. **Keep actions focused** - One action, one responsibility

## Common Pitfalls

- ❌ Not validating input (security risk)
- ❌ Returning sensitive error details
- ❌ Forgetting to revalidate cache
- ❌ Making actions too complex
- ❌ Not handling loading states

---

## Patterns

### Pattern 1: Basic Form Action

**Use when**: Simple form submission without client state

```typescript
// app/actions/posts.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const schema = z.object({
  title: z.string().min(1, 'Title required'),
  content: z.string().min(1, 'Content required'),
});

export async function createPost(formData: FormData) {
  const parsed = schema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  if (!parsed.success) {
    throw new Error('Invalid input');
  }

  await db.post.create({ data: parsed.data });

  revalidatePath('/posts');
  redirect('/posts');
}
```

```typescript
// app/posts/new/page.tsx
import { createPost } from '@/app/actions/posts';

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create</button>
    </form>
  );
}
```

### Pattern 2: Action with useActionState

**Use when**: Need loading state and error handling in UI

```typescript
// app/actions/posts.ts
'use server';

type ActionState = {
  success?: boolean;
  error?: string;
  fieldErrors?: Record<string, string[]>;
};

export async function createPost(
  prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const parsed = schema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  if (!parsed.success) {
    return {
      error: 'Validation failed',
      fieldErrors: parsed.error.flatten().fieldErrors,
    };
  }

  try {
    await db.post.create({ data: parsed.data });
    revalidatePath('/posts');
    return { success: true };
  } catch {
    return { error: 'Failed to create post' };
  }
}
```

```typescript
// components/PostForm.tsx
'use client';

import { useActionState } from 'react';
import { createPost } from '@/app/actions/posts';

export function PostForm() {
  const [state, formAction, pending] = useActionState(createPost, {});

  return (
    <form action={formAction}>
      <input name="title" disabled={pending} />
      {state.fieldErrors?.title && (
        <p className="text-red-500">{state.fieldErrors.title[0]}</p>
      )}

      <textarea name="content" disabled={pending} />
      {state.fieldErrors?.content && (
        <p className="text-red-500">{state.fieldErrors.content[0]}</p>
      )}

      {state.error && <p className="text-red-500">{state.error}</p>}
      {state.success && <p className="text-green-500">Created!</p>}

      <button disabled={pending}>
        {pending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
}
```

### Pattern 3: Optimistic Updates

**Use when**: Instant UI feedback before server confirms

```typescript
'use client';

import { useOptimistic, useTransition } from 'react';
import { toggleLike } from '@/app/actions/likes';

interface Props {
  postId: string;
  initialLiked: boolean;
  initialCount: number;
}

export function LikeButton({ postId, initialLiked, initialCount }: Props) {
  const [isPending, startTransition] = useTransition();
  const [optimistic, setOptimistic] = useOptimistic(
    { liked: initialLiked, count: initialCount },
    (state, newLiked: boolean) => ({
      liked: newLiked,
      count: state.count + (newLiked ? 1 : -1),
    })
  );

  const handleClick = () => {
    startTransition(async () => {
      setOptimistic(!optimistic.liked);
      await toggleLike(postId);
    });
  };

  return (
    <button onClick={handleClick} disabled={isPending}>
      {optimistic.liked ? '❤️' : '🤍'} {optimistic.count}
    </button>
  );
}
```

### Pattern 4: Action with Confirmation

**Use when**: Destructive actions that need confirmation

```typescript
// app/actions/posts.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function deletePost(id: string) {
  await db.post.delete({ where: { id } });
  revalidatePath('/posts');
}
```

```typescript
// components/DeleteButton.tsx
'use client';

import { useTransition } from 'react';
import { deletePost } from '@/app/actions/posts';

export function DeleteButton({ postId }: { postId: string }) {
  const [isPending, startTransition] = useTransition();

  const handleDelete = () => {
    if (!confirm('Are you sure?')) return;

    startTransition(async () => {
      await deletePost(postId);
    });
  };

  return (
    <button
      onClick={handleDelete}
      disabled={isPending}
      className="text-red-500"
    >
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  );
}
```

### Pattern 5: Revalidation Strategies

**Use when**: Different caching needs after mutation

```typescript
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';

export async function updatePost(id: string, data: UpdateData) {
  await db.post.update({ where: { id }, data });

  // Option 1: Revalidate specific path
  revalidatePath(`/posts/${id}`);

  // Option 2: Revalidate by tag (if fetches use tags)
  revalidateTag('posts');

  // Option 3: Revalidate layout (includes all nested pages)
  revalidatePath('/posts', 'layout');

  // Option 4: Revalidate everything (use sparingly)
  revalidatePath('/', 'layout');
}
```

### Pattern 6: Protected Action

**Use when**: Action requires authentication

```typescript
'use server';

import { auth } from '@/auth';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const session = await auth();

  if (!session) {
    redirect('/login');
  }

  const data = {
    title: formData.get('title') as string,
    content: formData.get('content') as string,
    authorId: session.user.id,
  };

  await db.post.create({ data });
  revalidatePath('/posts');
}
```
