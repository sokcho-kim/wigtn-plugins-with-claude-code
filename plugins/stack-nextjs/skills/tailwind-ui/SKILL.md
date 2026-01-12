---
name: tailwind-ui
description: Tailwind CSS patterns, responsive design, component styling. Use when styling UI components.
---

# Tailwind UI

Tailwind CSS 스타일링 패턴입니다.

## Class Utilities

### cn Helper (Class Merge)

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage
cn('px-4 py-2', condition && 'bg-blue-500', className);
cn('text-sm', 'text-lg'); // Result: 'text-lg' (merged)
```

## Component Styling Patterns

### Button Variants

```typescript
// components/ui/button.tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline: 'border border-input bg-background hover:bg-accent',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  },
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

export function Button({
  className,
  variant,
  size,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}
```

### Input Styling

```typescript
// components/ui/input.tsx
export function Input({ className, ...props }: InputProps) {
  return (
    <input
      className={cn(
        'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm',
        'ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium',
        'placeholder:text-muted-foreground',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
        'disabled:cursor-not-allowed disabled:opacity-50',
        className,
      )}
      {...props}
    />
  );
}
```

### Card Component

```typescript
// components/ui/card.tsx
export function Card({ className, ...props }: CardProps) {
  return (
    <div
      className={cn(
        'rounded-lg border bg-card text-card-foreground shadow-sm',
        className,
      )}
      {...props}
    />
  );
}

export function CardHeader({ className, ...props }: CardProps) {
  return (
    <div className={cn('flex flex-col space-y-1.5 p-6', className)} {...props} />
  );
}

export function CardTitle({ className, ...props }: CardProps) {
  return (
    <h3
      className={cn('text-2xl font-semibold leading-none tracking-tight', className)}
      {...props}
    />
  );
}

export function CardContent({ className, ...props }: CardProps) {
  return <div className={cn('p-6 pt-0', className)} {...props} />;
}
```

## Layout Patterns

### Flex Layouts

```html
<!-- Center content -->
<div class="flex items-center justify-center h-screen">
  <div>Centered</div>
</div>

<!-- Space between -->
<div class="flex items-center justify-between">
  <span>Left</span>
  <span>Right</span>
</div>

<!-- Stack with gap -->
<div class="flex flex-col gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
</div>

<!-- Inline items -->
<div class="flex items-center gap-2">
  <Icon />
  <span>Text</span>
</div>
```

### Grid Layouts

```html
<!-- Responsive grid -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <div>Card 1</div>
  <div>Card 2</div>
  <div>Card 3</div>
</div>

<!-- Auto-fit grid -->
<div class="grid grid-cols-[repeat(auto-fit,minmax(250px,1fr))] gap-4">
  <!-- Cards auto-adjust -->
</div>

<!-- Dashboard layout -->
<div class="grid grid-cols-12 gap-4">
  <div class="col-span-12 lg:col-span-8">Main content</div>
  <div class="col-span-12 lg:col-span-4">Sidebar</div>
</div>
```

### Container

```html
<!-- Standard container -->
<div class="container mx-auto px-4">
  Content
</div>

<!-- Max-width variants -->
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  Content
</div>
```

## Responsive Design

```html
<!-- Mobile-first approach -->
<div class="
  w-full          /* Mobile: full width */
  sm:w-1/2        /* Small: half width */
  md:w-1/3        /* Medium: third width */
  lg:w-1/4        /* Large: quarter width */
">
  Responsive element
</div>

<!-- Hide/show based on screen size -->
<div class="hidden md:block">Desktop only</div>
<div class="block md:hidden">Mobile only</div>

<!-- Responsive padding -->
<div class="p-4 sm:p-6 lg:p-8">
  Content with responsive padding
</div>

<!-- Responsive text -->
<h1 class="text-2xl sm:text-3xl lg:text-4xl font-bold">
  Responsive Heading
</h1>
```

## Common Patterns

### Form Layout

```html
<form class="space-y-6">
  <div class="space-y-2">
    <label class="text-sm font-medium">Email</label>
    <input class="w-full px-3 py-2 border rounded-md" />
    <p class="text-sm text-red-500">Error message</p>
  </div>

  <div class="flex gap-4">
    <button type="submit" class="flex-1 bg-primary text-white py-2 rounded-md">
      Submit
    </button>
    <button type="button" class="flex-1 border py-2 rounded-md">
      Cancel
    </button>
  </div>
</form>
```

### Table Styling

```html
<div class="overflow-x-auto">
  <table class="w-full text-sm">
    <thead class="bg-gray-50 border-b">
      <tr>
        <th class="px-4 py-3 text-left font-medium">Name</th>
        <th class="px-4 py-3 text-left font-medium">Email</th>
        <th class="px-4 py-3 text-right font-medium">Actions</th>
      </tr>
    </thead>
    <tbody class="divide-y">
      <tr class="hover:bg-gray-50">
        <td class="px-4 py-3">John Doe</td>
        <td class="px-4 py-3 text-gray-500">john@example.com</td>
        <td class="px-4 py-3 text-right">
          <button class="text-blue-600 hover:underline">Edit</button>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

### Badge/Tag

```html
<!-- Status badges -->
<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
  Active
</span>

<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
  Pending
</span>

<span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
  Error
</span>
```

### Loading States

```html
<!-- Spinner -->
<div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>

<!-- Skeleton -->
<div class="animate-pulse space-y-4">
  <div class="h-4 bg-gray-200 rounded w-3/4"></div>
  <div class="h-4 bg-gray-200 rounded w-1/2"></div>
</div>

<!-- Disabled state -->
<button disabled class="opacity-50 cursor-not-allowed bg-gray-300 px-4 py-2 rounded">
  Loading...
</button>
```

## Dark Mode

```typescript
// tailwind.config.ts
export default {
  darkMode: 'class',
  // ...
}

// Usage
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  Dark mode ready
</div>

// Toggle with next-themes
<ThemeProvider attribute="class" defaultTheme="system">
  {children}
</ThemeProvider>
```

## Animation

```html
<!-- Hover effects -->
<button class="transition-colors duration-200 hover:bg-blue-600">
  Hover me
</button>

<!-- Scale on hover -->
<div class="transition-transform hover:scale-105">
  Card content
</div>

<!-- Fade in -->
<div class="animate-fadeIn">
  Fading content
</div>

<!-- Custom animation in config -->
animation: {
  'fadeIn': 'fadeIn 0.3s ease-in-out',
},
keyframes: {
  fadeIn: {
    '0%': { opacity: '0' },
    '100%': { opacity: '1' },
  },
}
```

## Best Practices

```yaml
styling_guidelines:
  - Use cn() for conditional classes
  - Extract repeated patterns to components
  - Use CVA for variant-based styling
  - Follow mobile-first approach
  - Use semantic color names

organization:
  - Keep base styles in globals.css
  - Component-specific styles in component files
  - Avoid inline arbitrary values when possible
  - Use design tokens (CSS variables)

performance:
  - Purge unused styles in production
  - Avoid deeply nested selectors
  - Use built-in utilities over custom CSS
  - Group responsive variants logically

accessibility:
  - Ensure sufficient color contrast
  - Add focus-visible styles
  - Use proper text sizes (min 16px for body)
  - Include hover AND focus states
```
