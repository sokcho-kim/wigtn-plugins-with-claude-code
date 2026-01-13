---
name: nextjs-app-router
description: Next.js 15+ App Router patterns including routing, data fetching, caching, and rendering strategies.
---

# Next.js App Router

## When to Use

- Building any Next.js 13+ application
- Need SSR, SSG, or ISR
- Building full-stack features with Server Actions
- SEO-critical pages

## When NOT to Use

- Simple static sites → Consider Astro
- Pure SPA without SEO needs → Consider Vite + React
- Real-time heavy apps → Consider dedicated WebSocket solutions

## Decision Criteria

| Need | Solution |
|------|----------|
| SEO + Dynamic data | Server Component + ISR |
| User dashboard | Server Component + `no-store` |
| Static content | Static generation (default) |
| Personalized content | Dynamic rendering |
| Slow data source | Streaming with Suspense |
| Modal over page | Intercepting routes |
| Multiple independent sections | Parallel routes |

## Best Practices

1. **Fetch in Server Components** - Not in Client Components
2. **Use Suspense boundaries** - For streaming and loading states
3. **Colocate loading.tsx** - Next to page.tsx for automatic loading UI
4. **Prefer Server Actions** - Over API routes for mutations
5. **Use route groups** - For organizing without affecting URL

## Common Pitfalls

- ❌ Fetching in Client Components (move to Server Component)
- ❌ Not using Suspense (blocks entire page)
- ❌ Over-caching dynamic data
- ❌ Ignoring loading/error states
- ❌ Deep nesting layouts (performance impact)

---

## File Conventions

```
app/
├── layout.tsx       # Shared UI, persists across navigation
├── page.tsx         # Unique UI for route
├── loading.tsx      # Loading UI (Suspense boundary)
├── error.tsx        # Error UI (Error boundary)
├── not-found.tsx    # 404 UI
├── route.ts         # API endpoint
├── template.tsx     # Re-renders on navigation (unlike layout)
└── default.tsx      # Fallback for parallel routes
```

---

## Patterns

### Pattern 1: Basic Page with Metadata

**Use when**: Any page that needs SEO

```typescript
// app/products/page.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Products',
  description: 'Browse our products',
};

export default async function ProductsPage() {
  const products = await getProducts();

  return (
    <main>
      <h1>Products</h1>
      <ProductGrid products={products} />
    </main>
  );
}
```

### Pattern 2: Dynamic Route with Generated Metadata

**Use when**: Detail pages (product, blog post, user profile)

```typescript
// app/products/[slug]/page.tsx
import { Metadata } from 'next';
import { notFound } from 'next/navigation';

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const product = await getProduct(slug);

  if (!product) return {};

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      images: [product.image],
    },
  };
}

export async function generateStaticParams() {
  const products = await getProducts();
  return products.map((p) => ({ slug: p.slug }));
}

export default async function ProductPage({ params }: Props) {
  const { slug } = await params;
  const product = await getProduct(slug);

  if (!product) notFound();

  return <ProductDetail product={product} />;
}
```

### Pattern 3: Streaming with Suspense

**Use when**: Page has slow data sources, want fast initial load

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Fast - renders immediately */}
      <WelcomeMessage />

      {/* Slow - streams in */}
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>

      {/* Very slow - streams in later */}
      <Suspense fallback={<ChartSkeleton />}>
        <AnalyticsChart />
      </Suspense>
    </div>
  );
}

// Each async component fetches its own data
async function Stats() {
  const stats = await getStats(); // 500ms
  return <StatsCards data={stats} />;
}

async function AnalyticsChart() {
  const data = await getAnalytics(); // 2000ms
  return <Chart data={data} />;
}
```

### Pattern 4: Parallel Routes

**Use when**: Independent sections that load separately

```
app/dashboard/
├── layout.tsx
├── page.tsx
├── @stats/
│   ├── page.tsx
│   └── loading.tsx
├── @activity/
│   ├── page.tsx
│   └── loading.tsx
└── @notifications/
    ├── page.tsx
    └── loading.tsx
```

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  stats,
  activity,
  notifications,
}: {
  children: React.ReactNode;
  stats: React.ReactNode;
  activity: React.ReactNode;
  notifications: React.ReactNode;
}) {
  return (
    <div className="grid grid-cols-3 gap-4">
      <main className="col-span-2">{children}</main>
      <aside className="space-y-4">
        {stats}
        {activity}
        {notifications}
      </aside>
    </div>
  );
}
```

### Pattern 5: Intercepting Routes (Modal)

**Use when**: Show modal on soft navigation, full page on hard navigation

```
app/
├── @modal/
│   ├── (.)photos/[id]/page.tsx  # Intercepted (modal)
│   └── default.tsx
├── photos/
│   └── [id]/page.tsx            # Full page
└── layout.tsx
```

```typescript
// app/@modal/(.)photos/[id]/page.tsx
import { Modal } from '@/components/Modal';

export default async function PhotoModal({
  params
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params;
  const photo = await getPhoto(id);

  return (
    <Modal>
      <img src={photo.url} alt={photo.title} />
    </Modal>
  );
}

// app/photos/[id]/page.tsx - Full page version
export default async function PhotoPage({ params }) {
  const { id } = await params;
  const photo = await getPhoto(id);

  return (
    <div className="photo-page">
      <img src={photo.url} alt={photo.title} />
      <PhotoDetails photo={photo} />
    </div>
  );
}
```

### Pattern 6: Route Groups

**Use when**: Organizing routes without affecting URL, different layouts

```
app/
├── (marketing)/          # No /marketing in URL
│   ├── layout.tsx        # Marketing layout
│   ├── page.tsx          # / (home)
│   ├── about/page.tsx    # /about
│   └── pricing/page.tsx  # /pricing
├── (app)/                # No /app in URL
│   ├── layout.tsx        # App layout (with sidebar)
│   ├── dashboard/page.tsx    # /dashboard
│   └── settings/page.tsx     # /settings
└── (auth)/
    ├── layout.tsx        # Centered auth layout
    ├── login/page.tsx    # /login
    └── register/page.tsx # /register
```

### Pattern 7: Data Caching Strategies

**Use when**: Optimizing data fetching performance

```typescript
// Static - cached forever (default)
const data = await fetch(url);

// Revalidate every hour (ISR)
const data = await fetch(url, {
  next: { revalidate: 3600 }
});

// No cache - always fresh
const data = await fetch(url, {
  cache: 'no-store'
});

// Tag-based revalidation
const data = await fetch(url, {
  next: { tags: ['products'] }
});

// Revalidate in Server Action
'use server';
import { revalidateTag, revalidatePath } from 'next/cache';

export async function updateProduct(id: string, data: ProductData) {
  await db.product.update({ where: { id }, data });

  revalidateTag('products');      // Revalidate by tag
  revalidatePath(`/products/${id}`); // Revalidate specific path
}
```
