---
name: form-validation
description: Form handling with React Hook Form and Zod validation in Next.js applications.
---

# Form Validation

## When to Use

- Client-side forms with complex validation
- Forms with real-time field validation
- Multi-step forms or wizards
- Forms with dynamic/array fields
- Reusable form components

## When NOT to Use

- Simple forms with no validation → Native HTML forms
- Server-only validation → Server Actions with Zod directly
- Single field inputs → Local state is sufficient

## Decision Criteria

| Need | Solution |
|------|----------|
| Client-side validation | React Hook Form + Zod |
| Server Action forms | `useActionState` + Zod on server |
| Real-time validation | React Hook Form `mode: 'onChange'` |
| Array/dynamic fields | `useFieldArray` |
| Multi-step forms | React Hook Form with step state |
| File uploads | `FormData` + custom validation |

## Best Practices

1. **Zod for schema** - Single source of truth for types and validation
2. **Server-side revalidation** - Never trust client validation alone
3. **Accessible errors** - Associate errors with fields using `aria-describedby`
4. **Debounce async validation** - Avoid excessive API calls
5. **Progressive enhancement** - Forms should work without JS

## Common Pitfalls

- ❌ Validating only on client side
- ❌ Blocking submit without showing errors
- ❌ Not resetting form after successful submit
- ❌ Using `onChange` mode for large forms (performance)
- ❌ Not handling server errors in form state

---

## Setup

### Dependencies

```bash
npm install react-hook-form @hookform/resolvers zod
```

---

## Patterns

### Pattern 1: Basic Form with Validation

**Use when**: Standard form with client-side validation

```typescript
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Min 8 characters'),
});

type FormData = z.infer<typeof schema>;

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    await login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input {...register('email')} type="email" />
        {errors.email && <p className="text-destructive">{errors.email.message}</p>}
      </div>

      <div>
        <input {...register('password')} type="password" />
        {errors.password && <p className="text-destructive">{errors.password.message}</p>}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Loading...' : 'Submit'}
      </button>
    </form>
  );
}
```

### Pattern 2: Common Zod Schemas

**Use when**: Reusable validation patterns

```typescript
// lib/schemas.ts
import { z } from 'zod';

// User schema
export const userSchema = z.object({
  name: z.string().min(1, 'Required').max(100),
  email: z.string().email('Invalid email'),
  age: z.coerce.number().int().positive().optional(),
  role: z.enum(['user', 'admin']).default('user'),
});

// Password with confirmation
export const passwordSchema = z
  .object({
    password: z
      .string()
      .min(8, 'Min 8 characters')
      .regex(/[A-Z]/, 'Need uppercase')
      .regex(/[0-9]/, 'Need number'),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords must match',
    path: ['confirmPassword'],
  });

// Optional/nullable fields
export const profileSchema = z.object({
  required: z.string().min(1),
  optional: z.string().optional(),
  nullable: z.string().nullable(),
  withDefault: z.string().default('default'),
});
```

### Pattern 3: Server Action Integration

**Use when**: Forms that submit to Server Actions

```typescript
// app/actions/user.ts
'use server';

import { z } from 'zod';

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

type State = {
  success?: boolean;
  error?: string;
  fieldErrors?: Record<string, string[]>;
};

export async function createUser(prevState: State, formData: FormData): Promise<State> {
  const parsed = schema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
  });

  if (!parsed.success) {
    return { fieldErrors: parsed.error.flatten().fieldErrors };
  }

  try {
    await db.user.create({ data: parsed.data });
    return { success: true };
  } catch {
    return { error: 'Failed to create user' };
  }
}
```

```typescript
// components/UserForm.tsx
'use client';

import { useActionState } from 'react';
import { createUser } from '@/app/actions/user';

export function UserForm() {
  const [state, formAction, pending] = useActionState(createUser, {});

  return (
    <form action={formAction}>
      <div>
        <input name="name" />
        {state.fieldErrors?.name && (
          <p className="text-destructive">{state.fieldErrors.name[0]}</p>
        )}
      </div>

      <div>
        <input name="email" type="email" />
        {state.fieldErrors?.email && (
          <p className="text-destructive">{state.fieldErrors.email[0]}</p>
        )}
      </div>

      {state.error && <p className="text-destructive">{state.error}</p>}
      {state.success && <p className="text-green-600">Created!</p>}

      <button disabled={pending}>
        {pending ? 'Creating...' : 'Create'}
      </button>
    </form>
  );
}
```

### Pattern 4: Reusable Form Field

**Use when**: Consistent form field styling

```typescript
import { UseFormRegister, FieldErrors } from 'react-hook-form';
import { cn } from '@/lib/utils';

interface FieldProps {
  name: string;
  label: string;
  register: UseFormRegister<any>;
  errors: FieldErrors;
  type?: string;
}

export function Field({ name, label, register, errors, type = 'text' }: FieldProps) {
  const error = errors[name];

  return (
    <div className="space-y-1">
      <label htmlFor={name} className="text-sm font-medium">
        {label}
      </label>
      <input
        id={name}
        type={type}
        {...register(name)}
        aria-describedby={error ? `${name}-error` : undefined}
        className={cn(
          'w-full rounded border px-3 py-2',
          error && 'border-destructive'
        )}
      />
      {error && (
        <p id={`${name}-error`} className="text-sm text-destructive">
          {error.message as string}
        </p>
      )}
    </div>
  );
}
```

### Pattern 5: Form Wrapper Component

**Use when**: Abstracting form boilerplate

```typescript
'use client';

import { FormProvider, useForm, UseFormProps } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

interface FormProps<T extends z.ZodType> {
  schema: T;
  onSubmit: (data: z.infer<T>) => Promise<void>;
  children: React.ReactNode;
  defaultValues?: UseFormProps<z.infer<T>>['defaultValues'];
}

export function Form<T extends z.ZodType>({
  schema,
  onSubmit,
  children,
  defaultValues,
}: FormProps<T>) {
  const methods = useForm<z.infer<T>>({
    resolver: zodResolver(schema),
    defaultValues,
  });

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>{children}</form>
    </FormProvider>
  );
}

// Usage
<Form schema={userSchema} onSubmit={handleSubmit} defaultValues={{ name: '' }}>
  <Field name="email" label="Email" />
  <Field name="name" label="Name" />
  <SubmitButton>Save</SubmitButton>
</Form>
```

### Pattern 6: Array/Dynamic Fields

**Use when**: Lists of repeatable form sections

```typescript
import { useFieldArray, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  items: z.array(
    z.object({
      name: z.string().min(1, 'Required'),
      quantity: z.coerce.number().positive('Must be positive'),
    })
  ).min(1, 'Add at least one item'),
});

export function ItemsForm() {
  const { control, register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
    defaultValues: { items: [{ name: '', quantity: 1 }] },
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: 'items',
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {fields.map((field, index) => (
        <div key={field.id} className="flex gap-2">
          <input {...register(`items.${index}.name`)} placeholder="Name" />
          <input {...register(`items.${index}.quantity`)} type="number" />
          <button type="button" onClick={() => remove(index)}>Remove</button>
        </div>
      ))}

      {errors.items?.message && (
        <p className="text-destructive">{errors.items.message}</p>
      )}

      <button type="button" onClick={() => append({ name: '', quantity: 1 })}>
        Add Item
      </button>
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Pattern 7: File Upload Validation

**Use when**: Validating file inputs

```typescript
const schema = z.object({
  file: z
    .instanceof(FileList)
    .refine((files) => files.length > 0, 'File required')
    .refine((files) => files[0]?.size < 5_000_000, 'Max 5MB')
    .refine(
      (files) => ['image/jpeg', 'image/png'].includes(files[0]?.type),
      'Only JPEG or PNG'
    ),
});

export function UploadForm() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: { file: FileList }) => {
    const formData = new FormData();
    formData.append('file', data.file[0]);
    await uploadFile(formData);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input type="file" {...register('file')} accept="image/*" />
      {errors.file && (
        <p className="text-destructive">{errors.file.message}</p>
      )}
      <button type="submit">Upload</button>
    </form>
  );
}
```
