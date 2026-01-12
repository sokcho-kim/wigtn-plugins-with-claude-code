---
name: server-actions
description: Next.js Server Actions patterns, form handling, mutations. Use when implementing server-side data mutations.
---

# Server Actions

Next.js Server Actions 패턴입니다.

## Basic Server Action

```typescript
// app/actions/users.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { prisma } from '@/lib/prisma';
import { createUserSchema } from '@/lib/validations/user';

export async function createUser(formData: FormData) {
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
  };

  // Validate
  const validatedData = createUserSchema.parse(rawData);

  // Create user
  await prisma.user.create({
    data: validatedData,
  });

  // Revalidate and redirect
  revalidatePath('/users');
  redirect('/users');
}
```

## With Return Value

```typescript
// app/actions/users.ts
'use server';

import { z } from 'zod';

const schema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
});

type ActionResult = {
  success: boolean;
  message: string;
  errors?: Record<string, string[]>;
};

export async function createUser(
  prevState: ActionResult | null,
  formData: FormData,
): Promise<ActionResult> {
  const rawData = Object.fromEntries(formData);

  const validatedFields = schema.safeParse(rawData);

  if (!validatedFields.success) {
    return {
      success: false,
      message: 'Validation failed',
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  try {
    await prisma.user.create({
      data: validatedFields.data,
    });

    revalidatePath('/users');

    return {
      success: true,
      message: 'User created successfully',
    };
  } catch (error) {
    return {
      success: false,
      message: 'Failed to create user',
    };
  }
}
```

## Using with useActionState

```typescript
// components/users/create-user-form.tsx
'use client';

import { useActionState } from 'react';
import { createUser } from '@/app/actions/users';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const initialState = {
  success: false,
  message: '',
  errors: undefined,
};

export function CreateUserForm() {
  const [state, formAction, isPending] = useActionState(
    createUser,
    initialState,
  );

  return (
    <form action={formAction} className="space-y-4">
      <div>
        <Input name="name" placeholder="Name" />
        {state.errors?.name && (
          <p className="text-sm text-red-500">{state.errors.name[0]}</p>
        )}
      </div>

      <div>
        <Input name="email" type="email" placeholder="Email" />
        {state.errors?.email && (
          <p className="text-sm text-red-500">{state.errors.email[0]}</p>
        )}
      </div>

      <Button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create User'}
      </Button>

      {state.message && (
        <p className={state.success ? 'text-green-500' : 'text-red-500'}>
          {state.message}
        </p>
      )}
    </form>
  );
}
```

## Programmatic Invocation

```typescript
// Using with useTransition
'use client';

import { useTransition } from 'react';
import { deleteUser } from '@/app/actions/users';

export function DeleteButton({ userId }: { userId: string }) {
  const [isPending, startTransition] = useTransition();

  const handleDelete = () => {
    if (confirm('Are you sure?')) {
      startTransition(async () => {
        await deleteUser(userId);
      });
    }
  };

  return (
    <Button onClick={handleDelete} disabled={isPending} variant="danger">
      {isPending ? 'Deleting...' : 'Delete'}
    </Button>
  );
}
```

## CRUD Actions Pattern

```typescript
// app/actions/posts.ts
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';
import { redirect } from 'next/navigation';
import { auth } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import {
  createPostSchema,
  updatePostSchema,
} from '@/lib/validations/post';

// Create
export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  const data = createPostSchema.parse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  const post = await prisma.post.create({
    data: {
      ...data,
      authorId: session.user.id,
    },
  });

  revalidatePath('/posts');
  redirect(`/posts/${post.id}`);
}

// Update
export async function updatePost(id: string, formData: FormData) {
  const session = await auth();
  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  // Check ownership
  const post = await prisma.post.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (post?.authorId !== session.user.id) {
    throw new Error('Forbidden');
  }

  const data = updatePostSchema.parse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  await prisma.post.update({
    where: { id },
    data,
  });

  revalidatePath(`/posts/${id}`);
  revalidatePath('/posts');
}

// Delete
export async function deletePost(id: string) {
  const session = await auth();
  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  const post = await prisma.post.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (post?.authorId !== session.user.id) {
    throw new Error('Forbidden');
  }

  await prisma.post.delete({ where: { id } });

  revalidatePath('/posts');
  redirect('/posts');
}

// Toggle action
export async function togglePostPublished(id: string) {
  const post = await prisma.post.findUnique({
    where: { id },
    select: { published: true },
  });

  await prisma.post.update({
    where: { id },
    data: { published: !post?.published },
  });

  revalidatePath(`/posts/${id}`);
  revalidatePath('/posts');
}
```

## File Upload Action

```typescript
// app/actions/upload.ts
'use server';

import { writeFile } from 'fs/promises';
import { join } from 'path';
import { v4 as uuid } from 'uuid';

export async function uploadFile(formData: FormData) {
  const file = formData.get('file') as File;

  if (!file || file.size === 0) {
    return { success: false, error: 'No file provided' };
  }

  // Validate file type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
  if (!allowedTypes.includes(file.type)) {
    return { success: false, error: 'Invalid file type' };
  }

  // Validate file size (5MB)
  if (file.size > 5 * 1024 * 1024) {
    return { success: false, error: 'File too large' };
  }

  const bytes = await file.arrayBuffer();
  const buffer = Buffer.from(bytes);

  const ext = file.name.split('.').pop();
  const filename = `${uuid()}.${ext}`;
  const path = join(process.cwd(), 'public/uploads', filename);

  await writeFile(path, buffer);

  return {
    success: true,
    url: `/uploads/${filename}`,
  };
}
```

## Optimistic Updates

```typescript
// components/posts/like-button.tsx
'use client';

import { useOptimistic } from 'react';
import { toggleLike } from '@/app/actions/posts';

interface LikeButtonProps {
  postId: string;
  initialLikes: number;
  initialIsLiked: boolean;
}

export function LikeButton({
  postId,
  initialLikes,
  initialIsLiked,
}: LikeButtonProps) {
  const [optimisticState, addOptimistic] = useOptimistic(
    { likes: initialLikes, isLiked: initialIsLiked },
    (state, _) => ({
      likes: state.isLiked ? state.likes - 1 : state.likes + 1,
      isLiked: !state.isLiked,
    }),
  );

  const handleLike = async () => {
    addOptimistic(null);
    await toggleLike(postId);
  };

  return (
    <form action={handleLike}>
      <button type="submit">
        {optimisticState.isLiked ? '❤️' : '🤍'} {optimisticState.likes}
      </button>
    </form>
  );
}
```

## Error Handling Pattern

```typescript
// lib/action-utils.ts
type ActionResponse<T = void> =
  | { success: true; data: T }
  | { success: false; error: string };

export async function safeAction<T>(
  fn: () => Promise<T>,
): Promise<ActionResponse<T>> {
  try {
    const data = await fn();
    return { success: true, data };
  } catch (error) {
    console.error('Action error:', error);

    if (error instanceof z.ZodError) {
      return { success: false, error: 'Validation failed' };
    }

    if (error instanceof Error) {
      return { success: false, error: error.message };
    }

    return { success: false, error: 'An unexpected error occurred' };
  }
}

// Usage in action
export async function createPost(formData: FormData) {
  return safeAction(async () => {
    const session = await auth();
    if (!session) throw new Error('Unauthorized');

    const data = createPostSchema.parse(Object.fromEntries(formData));

    const post = await prisma.post.create({ data });
    revalidatePath('/posts');

    return post;
  });
}
```

## Best Practices

```yaml
action_guidelines:
  - Always add 'use server' directive
  - Validate all inputs with Zod
  - Check authentication/authorization
  - Return structured responses
  - Handle errors gracefully

revalidation:
  - Use revalidatePath for page updates
  - Use revalidateTag for tagged fetches
  - Call revalidate before redirect

security:
  - Never trust client data
  - Always validate on server
  - Check user permissions
  - Sanitize file uploads
  - Rate limit sensitive actions

patterns:
  - useActionState for form submissions
  - useTransition for programmatic calls
  - useOptimistic for instant feedback
  - Return errors instead of throwing
```
