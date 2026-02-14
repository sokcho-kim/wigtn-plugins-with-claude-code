# Server Actions with Auth

Secure server actions with authentication validation.

## Protected Server Action

```typescript
// app/actions/profile.ts
"use server";

import { auth } from "@/auth";
import { db } from "@/lib/db";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const updateProfileSchema = z.object({
  name: z.string().min(1, "Name is required"),
  bio: z.string().max(500).optional(),
});

export async function updateProfile(formData: FormData) {
  const session = await auth();

  if (!session?.user) {
    return { error: "Unauthorized" };
  }

  const data = {
    name: formData.get("name"),
    bio: formData.get("bio"),
  };

  const validatedFields = updateProfileSchema.safeParse(data);

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  try {
    await db.user.update({
      where: { id: session.user.id },
      data: validatedFields.data,
    });

    revalidatePath("/profile");
    return { success: true };
  } catch (error) {
    return { error: "Failed to update profile" };
  }
}
```

## Form Component

```typescript
// app/profile/edit/page.tsx
"use client";

import { updateProfile } from "@/app/actions/profile";
import { useFormState } from "react-dom";

export default function EditProfilePage() {
  const [state, formAction] = useFormState(updateProfile, null);

  return (
    <form action={formAction}>
      <input name="name" placeholder="Name" required />
      {state?.errors?.name && <p className="text-red-600">{state.errors.name[0]}</p>}

      <textarea name="bio" placeholder="Bio" />
      {state?.errors?.bio && <p className="text-red-600">{state.errors.bio[0]}</p>}

      <button type="submit">Save</button>
      {state?.error && <p className="text-red-600">{state.error}</p>}
      {state?.success && <p className="text-green-600">Profile updated!</p>}
    </form>
  );
}
```

## Auth Helper for Actions

```typescript
// lib/auth/action-auth.ts
import { auth } from "@/auth";

export async function requireAuth() {
  const session = await auth();

  if (!session?.user) {
    throw new Error("Unauthorized");
  }

  return session.user;
}

// Usage
export async function deletePost(postId: string) {
  const user = await requireAuth();

  await db.post.delete({
    where: { id: postId, authorId: user.id },
  });
}
```
