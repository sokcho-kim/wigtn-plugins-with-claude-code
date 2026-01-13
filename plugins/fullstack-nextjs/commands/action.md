# /action - Server Action Generator

Generate Next.js Server Actions for form handling and mutations.

## Usage

```
/action <actionName> [options]
```

## Options

- `--form`: Form action with validation
- `--mutation`: Data mutation action
- `--with-revalidate`: Include revalidation

## Examples

```
/action createPost --form --with-revalidate
/action updateUser --mutation
/action deleteComment --with-revalidate
```

## Output

```
app/actions/<name>.ts
```

## Templates

### Form Action
```typescript
'use server';

import { z } from 'zod';
import { revalidatePath } from 'next/cache';

const schema = z.object({
  title: z.string().min(1),
  content: z.string(),
});

interface ActionState {
  error?: string;
  success?: boolean;
}

export async function createPost(
  prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const parsed = schema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
  });

  if (!parsed.success) {
    return { error: 'Validation failed' };
  }

  await db.post.create({ data: parsed.data });
  revalidatePath('/posts');

  return { success: true };
}
```

### Mutation Action
```typescript
'use server';

import { revalidatePath } from 'next/cache';

export async function updatePost(id: string, data: UpdatePostInput) {
  await db.post.update({
    where: { id },
    data,
  });

  revalidatePath(`/posts/${id}`);
}
```

### Delete Action
```typescript
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function deletePost(id: string) {
  await db.post.delete({ where: { id } });
  revalidatePath('/posts');
  redirect('/posts');
}
```

## $ARGUMENTS
