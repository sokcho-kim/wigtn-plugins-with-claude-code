---
name: forms-validation
description: Master form handling with React Hook Form and Zod validation. Build type-safe forms with automatic validation, error handling, and accessibility. Use when building forms, implementing validation, or handling user input.
---

# Forms & Validation

Comprehensive patterns for building production-ready forms with React Hook Form and Zod schema validation, including accessibility, error handling, and complex form scenarios.

## When to Use This Skill

- Building forms with React Hook Form
- Implementing type-safe validation with Zod
- Creating dynamic forms with field arrays
- Handling multi-step forms and wizards
- Implementing form accessibility (WCAG compliance)
- Integrating forms with Server Actions in Next.js
- Building complex forms with conditional fields

## Core Concepts

### 1. Form Libraries Comparison

| Feature | React Hook Form | Formik | Uncontrolled Forms |
|---------|----------------|--------|-------------------|
| **Re-renders** | Minimal | High | None |
| **Bundle Size** | Small (9kb) | Medium (13kb) | None |
| **Validation** | Built-in + schema | Built-in + Yup | Manual |
| **TypeScript** | Excellent | Good | Manual |
| **Performance** | Best | Good | Best |

### 2. Why React Hook Form + Zod?

```
React Hook Form: Performance-focused, minimal re-renders
Zod: Type-safe schemas, automatic TypeScript inference
Together: Best DX, runtime safety, compile-time safety
```

## Quick Start

### Installation

```bash
npm install react-hook-form zod @hookform/resolvers
# Optional but recommended
npm install @radix-ui/react-label @radix-ui/react-slot
```

### Basic Form

```typescript
// app/contact/page.tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";

const contactSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  message: z.string().min(10, "Message must be at least 10 characters"),
});

type ContactFormData = z.infer<typeof contactSchema>;

export default function ContactPage() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<ContactFormData>({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      name: "",
      email: "",
      message: "",
    },
  });

  const onSubmit = async (data: ContactFormData) => {
    try {
      const response = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      if (!response.ok) throw new Error("Failed to submit");

      reset();
      alert("Message sent successfully!");
    } catch (error) {
      alert("Failed to send message");
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Name
        </label>
        <input
          id="name"
          {...register("name")}
          className="mt-1 block w-full rounded-md border p-2"
          aria-invalid={errors.name ? "true" : "false"}
        />
        {errors.name && (
          <p className="mt-1 text-sm text-red-600" role="alert">
            {errors.name.message}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <input
          id="email"
          type="email"
          {...register("email")}
          className="mt-1 block w-full rounded-md border p-2"
          aria-invalid={errors.email ? "true" : "false"}
        />
        {errors.email && (
          <p className="mt-1 text-sm text-red-600" role="alert">
            {errors.email.message}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="message" className="block text-sm font-medium">
          Message
        </label>
        <textarea
          id="message"
          {...register("message")}
          rows={4}
          className="mt-1 block w-full rounded-md border p-2"
          aria-invalid={errors.message ? "true" : "false"}
        />
        {errors.message && (
          <p className="mt-1 text-sm text-red-600" role="alert">
            {errors.message.message}
          </p>
        )}
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="rounded-md bg-blue-600 px-4 py-2 text-white disabled:opacity-50"
      >
        {isSubmitting ? "Sending..." : "Send Message"}
      </button>
    </form>
  );
}
```

## Patterns

### Pattern 1: Reusable Form Components

```typescript
// components/ui/form.tsx
"use client";

import * as React from "react";
import { useFormContext, Controller } from "react-hook-form";
import { cn } from "@/lib/utils";

const FormField = Controller;

interface FormItemContextValue {
  id: string;
}

const FormItemContext = React.createContext<FormItemContextValue>(
  {} as FormItemContextValue
);

const FormItem = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  const id = React.useId();

  return (
    <FormItemContext.Provider value={{ id }}>
      <div ref={ref} className={cn("space-y-2", className)} {...props} />
    </FormItemContext.Provider>
  );
});
FormItem.displayName = "FormItem";

const FormLabel = React.forwardRef<
  HTMLLabelElement,
  React.LabelHTMLAttributes<HTMLLabelElement>
>(({ className, ...props }, ref) => {
  const { id } = React.useContext(FormItemContext);

  return (
    <label
      ref={ref}
      className={cn("text-sm font-medium leading-none", className)}
      htmlFor={id}
      {...props}
    />
  );
});
FormLabel.displayName = "FormLabel";

const FormControl = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ ...props }, ref) => {
  const { id } = React.useContext(FormItemContext);
  const { error } = useFormField();

  return (
    <div
      ref={ref}
      id={id}
      aria-describedby={error ? `${id}-error` : undefined}
      aria-invalid={!!error}
      {...props}
    />
  );
});
FormControl.displayName = "FormControl";

const FormMessage = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, children, ...props }, ref) => {
  const { error } = useFormField();
  const { id } = React.useContext(FormItemContext);
  const body = error ? String(error?.message) : children;

  if (!body) return null;

  return (
    <p
      ref={ref}
      id={`${id}-error`}
      className={cn("text-sm font-medium text-destructive", className)}
      role="alert"
      {...props}
    >
      {body}
    </p>
  );
});
FormMessage.displayName = "FormMessage";

const useFormField = () => {
  const fieldContext = React.useContext(FormItemContext);
  const { getFieldState, formState } = useFormContext();
  const fieldState = getFieldState(fieldContext.id, formState);

  return {
    id: fieldContext.id,
    ...fieldState,
  };
};

export { FormField, FormItem, FormLabel, FormControl, FormMessage };

// Usage
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form";

function ContactForm() {
  const form = useForm<ContactFormData>({
    resolver: zodResolver(contactSchema),
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </form>
    </Form>
  );
}
```

### Pattern 2: Complex Zod Schemas

```typescript
// lib/validations/user.ts
import * as z from "zod";

// Reusable schemas
const passwordSchema = z
  .string()
  .min(8, "Password must be at least 8 characters")
  .regex(/[A-Z]/, "Password must contain an uppercase letter")
  .regex(/[a-z]/, "Password must contain a lowercase letter")
  .regex(/[0-9]/, "Password must contain a number")
  .regex(/[^A-Za-z0-9]/, "Password must contain a special character");

const phoneSchema = z
  .string()
  .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone number");

// User registration schema
export const registerSchema = z
  .object({
    username: z
      .string()
      .min(3, "Username must be at least 3 characters")
      .max(20, "Username must be at most 20 characters")
      .regex(/^[a-zA-Z0-9_]+$/, "Username can only contain letters, numbers, and underscores"),
    email: z.string().email("Invalid email address"),
    password: passwordSchema,
    confirmPassword: z.string(),
    phone: phoneSchema.optional(),
    dateOfBirth: z
      .string()
      .refine((date) => {
        const age = new Date().getFullYear() - new Date(date).getFullYear();
        return age >= 18;
      }, "You must be at least 18 years old"),
    terms: z.boolean().refine((val) => val === true, {
      message: "You must accept the terms and conditions",
    }),
    role: z.enum(["user", "admin", "moderator"]).default("user"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"],
  });

export type RegisterFormData = z.infer<typeof registerSchema>;

// Profile update schema (partial)
export const updateProfileSchema = registerSchema
  .pick({ username: true, email: true, phone: true })
  .partial();
```

### Pattern 3: Field Arrays (Dynamic Forms)

```typescript
// app/products/new/page.tsx
"use client";

import { useForm, useFieldArray } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";

const variantSchema = z.object({
  name: z.string().min(1, "Variant name is required"),
  price: z.number().min(0, "Price must be positive"),
  stock: z.number().int().min(0, "Stock must be a positive integer"),
  sku: z.string().min(1, "SKU is required"),
});

const productSchema = z.object({
  name: z.string().min(1, "Product name is required"),
  description: z.string().min(10, "Description must be at least 10 characters"),
  category: z.string().min(1, "Category is required"),
  variants: z.array(variantSchema).min(1, "At least one variant is required"),
  tags: z.array(z.string()).default([]),
});

type ProductFormData = z.infer<typeof productSchema>;

export default function NewProductPage() {
  const {
    register,
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: {
      variants: [{ name: "", price: 0, stock: 0, sku: "" }],
      tags: [],
    },
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: "variants",
  });

  const onSubmit = async (data: ProductFormData) => {
    console.log(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div>
        <label htmlFor="name">Product Name</label>
        <input id="name" {...register("name")} />
        {errors.name && <p className="text-red-600">{errors.name.message}</p>}
      </div>

      <div>
        <h3 className="text-lg font-semibold">Variants</h3>
        {fields.map((field, index) => (
          <div key={field.id} className="space-y-4 rounded border p-4">
            <div>
              <label htmlFor={`variants.${index}.name`}>Variant Name</label>
              <input {...register(`variants.${index}.name`)} />
              {errors.variants?.[index]?.name && (
                <p className="text-red-600">
                  {errors.variants[index]?.name?.message}
                </p>
              )}
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div>
                <label htmlFor={`variants.${index}.price`}>Price</label>
                <input
                  type="number"
                  step="0.01"
                  {...register(`variants.${index}.price`, {
                    valueAsNumber: true,
                  })}
                />
                {errors.variants?.[index]?.price && (
                  <p className="text-red-600">
                    {errors.variants[index]?.price?.message}
                  </p>
                )}
              </div>

              <div>
                <label htmlFor={`variants.${index}.stock`}>Stock</label>
                <input
                  type="number"
                  {...register(`variants.${index}.stock`, {
                    valueAsNumber: true,
                  })}
                />
                {errors.variants?.[index]?.stock && (
                  <p className="text-red-600">
                    {errors.variants[index]?.stock?.message}
                  </p>
                )}
              </div>

              <div>
                <label htmlFor={`variants.${index}.sku`}>SKU</label>
                <input {...register(`variants.${index}.sku`)} />
                {errors.variants?.[index]?.sku && (
                  <p className="text-red-600">
                    {errors.variants[index]?.sku?.message}
                  </p>
                )}
              </div>
            </div>

            <button
              type="button"
              onClick={() => remove(index)}
              className="text-red-600"
            >
              Remove Variant
            </button>
          </div>
        ))}

        <button
          type="button"
          onClick={() => append({ name: "", price: 0, stock: 0, sku: "" })}
          className="mt-4"
        >
          Add Variant
        </button>
      </div>

      <button type="submit" className="rounded bg-blue-600 px-4 py-2 text-white">
        Create Product
      </button>
    </form>
  );
}
```

### Pattern 4: Multi-Step Forms

```typescript
// components/multi-step-form.tsx
"use client";

import { useState } from "react";
import { useForm, UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";

// Step schemas
const personalInfoSchema = z.object({
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().min(1, "Last name is required"),
  email: z.string().email("Invalid email"),
});

const addressSchema = z.object({
  street: z.string().min(1, "Street is required"),
  city: z.string().min(1, "City is required"),
  state: z.string().min(1, "State is required"),
  zipCode: z.string().regex(/^\d{5}$/, "Invalid zip code"),
});

const paymentSchema = z.object({
  cardNumber: z.string().regex(/^\d{16}$/, "Invalid card number"),
  expiryDate: z.string().regex(/^\d{2}\/\d{2}$/, "Invalid expiry date (MM/YY)"),
  cvv: z.string().regex(/^\d{3}$/, "Invalid CVV"),
});

// Combined schema
const checkoutSchema = personalInfoSchema
  .merge(addressSchema)
  .merge(paymentSchema);

type CheckoutFormData = z.infer<typeof checkoutSchema>;

const STEPS = [
  { title: "Personal Info", schema: personalInfoSchema },
  { title: "Address", schema: addressSchema },
  { title: "Payment", schema: paymentSchema },
];

export function MultiStepCheckoutForm() {
  const [currentStep, setCurrentStep] = useState(0);

  const form = useForm<CheckoutFormData>({
    resolver: zodResolver(STEPS[currentStep].schema),
    mode: "onChange",
  });

  const onNext = async () => {
    const isValid = await form.trigger();
    if (isValid) {
      if (currentStep < STEPS.length - 1) {
        setCurrentStep(currentStep + 1);
      }
    }
  };

  const onSubmit = async (data: CheckoutFormData) => {
    console.log("Final submission:", data);
    // Process checkout
  };

  return (
    <div className="mx-auto max-w-2xl">
      {/* Progress indicator */}
      <div className="mb-8 flex justify-between">
        {STEPS.map((step, index) => (
          <div
            key={step.title}
            className={`flex-1 ${
              index <= currentStep ? "text-blue-600" : "text-gray-400"
            }`}
          >
            <div className="flex items-center">
              <div
                className={`flex h-8 w-8 items-center justify-center rounded-full border-2 ${
                  index <= currentStep
                    ? "border-blue-600 bg-blue-600 text-white"
                    : "border-gray-400"
                }`}
              >
                {index + 1}
              </div>
              <span className="ml-2 text-sm font-medium">{step.title}</span>
            </div>
          </div>
        ))}
      </div>

      <form onSubmit={form.handleSubmit(onSubmit)}>
        {/* Step 1: Personal Info */}
        {currentStep === 0 && (
          <PersonalInfoStep form={form} />
        )}

        {/* Step 2: Address */}
        {currentStep === 1 && (
          <AddressStep form={form} />
        )}

        {/* Step 3: Payment */}
        {currentStep === 2 && (
          <PaymentStep form={form} />
        )}

        {/* Navigation buttons */}
        <div className="mt-8 flex justify-between">
          <button
            type="button"
            onClick={() => setCurrentStep(currentStep - 1)}
            disabled={currentStep === 0}
            className="rounded bg-gray-200 px-4 py-2 disabled:opacity-50"
          >
            Previous
          </button>

          {currentStep < STEPS.length - 1 ? (
            <button
              type="button"
              onClick={onNext}
              className="rounded bg-blue-600 px-4 py-2 text-white"
            >
              Next
            </button>
          ) : (
            <button
              type="submit"
              className="rounded bg-green-600 px-4 py-2 text-white"
            >
              Complete Purchase
            </button>
          )}
        </div>
      </form>
    </div>
  );
}

function PersonalInfoStep({ form }: { form: UseFormReturn<CheckoutFormData> }) {
  return (
    <div className="space-y-4">
      <div>
        <label htmlFor="firstName">First Name</label>
        <input {...form.register("firstName")} />
        {form.formState.errors.firstName && (
          <p className="text-red-600">{form.formState.errors.firstName.message}</p>
        )}
      </div>
      <div>
        <label htmlFor="lastName">Last Name</label>
        <input {...form.register("lastName")} />
        {form.formState.errors.lastName && (
          <p className="text-red-600">{form.formState.errors.lastName.message}</p>
        )}
      </div>
      <div>
        <label htmlFor="email">Email</label>
        <input type="email" {...form.register("email")} />
        {form.formState.errors.email && (
          <p className="text-red-600">{form.formState.errors.email.message}</p>
        )}
      </div>
    </div>
  );
}

function AddressStep({ form }: { form: UseFormReturn<CheckoutFormData> }) {
  return (
    <div className="space-y-4">
      <div>
        <label htmlFor="street">Street Address</label>
        <input {...form.register("street")} />
        {form.formState.errors.street && (
          <p className="text-red-600">{form.formState.errors.street.message}</p>
        )}
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="city">City</label>
          <input {...form.register("city")} />
          {form.formState.errors.city && (
            <p className="text-red-600">{form.formState.errors.city.message}</p>
          )}
        </div>
        <div>
          <label htmlFor="state">State</label>
          <input {...form.register("state")} />
          {form.formState.errors.state && (
            <p className="text-red-600">{form.formState.errors.state.message}</p>
          )}
        </div>
      </div>
      <div>
        <label htmlFor="zipCode">Zip Code</label>
        <input {...form.register("zipCode")} />
        {form.formState.errors.zipCode && (
          <p className="text-red-600">{form.formState.errors.zipCode.message}</p>
        )}
      </div>
    </div>
  );
}

function PaymentStep({ form }: { form: UseFormReturn<CheckoutFormData> }) {
  return (
    <div className="space-y-4">
      <div>
        <label htmlFor="cardNumber">Card Number</label>
        <input {...form.register("cardNumber")} placeholder="1234567812345678" />
        {form.formState.errors.cardNumber && (
          <p className="text-red-600">{form.formState.errors.cardNumber.message}</p>
        )}
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="expiryDate">Expiry Date</label>
          <input {...form.register("expiryDate")} placeholder="MM/YY" />
          {form.formState.errors.expiryDate && (
            <p className="text-red-600">{form.formState.errors.expiryDate.message}</p>
          )}
        </div>
        <div>
          <label htmlFor="cvv">CVV</label>
          <input {...form.register("cvv")} placeholder="123" />
          {form.formState.errors.cvv && (
            <p className="text-red-600">{form.formState.errors.cvv.message}</p>
          )}
        </div>
      </div>
    </div>
  );
}
```

### Pattern 5: Server Actions Integration (Next.js)

```typescript
// app/actions/auth.ts
"use server";

import { z } from "zod";
import { revalidatePath } from "next/cache";

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export async function loginAction(formData: FormData) {
  const validatedFields = loginSchema.safeParse({
    email: formData.get("email"),
    password: formData.get("password"),
  });

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  // Process login
  const { email, password } = validatedFields.data;

  try {
    // Your auth logic here
    await authenticate(email, password);

    revalidatePath("/dashboard");
    return { success: true };
  } catch (error) {
    return {
      errors: { _form: ["Invalid credentials"] },
    };
  }
}

// app/login/page.tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { loginAction } from "../actions/auth";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const router = useRouter();
  const form = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    const formData = new FormData();
    formData.append("email", data.email);
    formData.append("password", data.password);

    const result = await loginAction(formData);

    if (result.errors) {
      // Handle errors
      Object.entries(result.errors).forEach(([key, value]) => {
        if (key === "_form") {
          form.setError("root", { message: value[0] });
        } else {
          form.setError(key as any, { message: value[0] });
        }
      });
    } else {
      router.push("/dashboard");
    }
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      {/* Form fields */}
    </form>
  );
}
```

## Advanced Patterns

### Conditional Fields

```typescript
const schema = z.discriminatedUnion("accountType", [
  z.object({
    accountType: z.literal("personal"),
    name: z.string(),
    email: z.string().email(),
  }),
  z.object({
    accountType: z.literal("business"),
    companyName: z.string(),
    taxId: z.string(),
    email: z.string().email(),
  }),
]);

function DynamicForm() {
  const { watch, register } = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
  });

  const accountType = watch("accountType");

  return (
    <form>
      <select {...register("accountType")}>
        <option value="personal">Personal</option>
        <option value="business">Business</option>
      </select>

      {accountType === "personal" && (
        <input {...register("name")} placeholder="Full Name" />
      )}

      {accountType === "business" && (
        <>
          <input {...register("companyName")} placeholder="Company Name" />
          <input {...register("taxId")} placeholder="Tax ID" />
        </>
      )}
    </form>
  );
}
```

### Async Validation

```typescript
const schema = z.object({
  username: z.string().min(3).refine(
    async (username) => {
      const response = await fetch(`/api/check-username?username=${username}`);
      const data = await response.json();
      return data.available;
    },
    { message: "Username is already taken" }
  ),
});
```

## Best Practices

### Do's

- **Use Zod for validation** - Type safety + runtime validation
- **Validate on blur** - Better UX than onChange for every field
- **Provide immediate feedback** - Show errors as soon as field loses focus
- **Use proper ARIA attributes** - `aria-invalid`, `aria-describedby`
- **Disable submit during submission** - Prevent duplicate submissions
- **Reset form after success** - Clear fields after successful submission

### Don'ts

- **Don't validate on every keystroke** - Causes poor UX
- **Don't forget loading states** - Always show when submitting
- **Don't skip accessibility** - Forms must be keyboard navigable
- **Don't nest forms** - Not valid HTML
- **Don't forget error boundaries** - Catch validation errors gracefully

## Accessibility Checklist

- [ ] All inputs have associated labels
- [ ] Error messages use `role="alert"`
- [ ] Invalid fields have `aria-invalid="true"`
- [ ] Error messages linked with `aria-describedby`
- [ ] Form is keyboard navigable
- [ ] Submit button has loading state
- [ ] Required fields are marked
- [ ] Focus management implemented

## Resources

- [React Hook Form Documentation](https://react-hook-form.com/)
- [Zod Documentation](https://zod.dev/)
- [WCAG Form Guidelines](https://www.w3.org/WAI/tutorials/forms/)
