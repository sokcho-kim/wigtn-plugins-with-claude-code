---
name: nextjs-routing
description: Next.js App Router patterns, layouts, route groups, middleware. Use when setting up page routing.
---

# Next.js Routing

Next.js App Router 라우팅 패턴입니다.

## Directory Structure

```
app/
├── layout.tsx              # Root layout
├── page.tsx                # Home page (/)
├── globals.css
├── (auth)/                 # Route group (no URL segment)
│   ├── layout.tsx          # Auth layout
│   ├── login/
│   │   └── page.tsx        # /login
│   └── register/
│       └── page.tsx        # /register
├── (main)/                 # Main app group
│   ├── layout.tsx          # Main layout with sidebar
│   ├── dashboard/
│   │   └── page.tsx        # /dashboard
│   └── settings/
│       └── page.tsx        # /settings
├── users/
│   ├── page.tsx            # /users (list)
│   ├── [id]/
│   │   ├── page.tsx        # /users/:id (detail)
│   │   └── edit/
│   │       └── page.tsx    # /users/:id/edit
│   └── new/
│       └── page.tsx        # /users/new
├── api/
│   └── [...]/              # API routes
└── not-found.tsx           # 404 page
```

## Page Components

### Basic Page

```typescript
// app/users/page.tsx
import { Suspense } from 'react';
import { UserList } from '@/components/users/user-list';
import { UserListSkeleton } from '@/components/users/user-list-skeleton';

export const metadata = {
  title: 'Users',
  description: 'User management page',
};

export default function UsersPage() {
  return (
    <div className="container py-8">
      <h1 className="text-2xl font-bold mb-6">Users</h1>
      <Suspense fallback={<UserListSkeleton />}>
        <UserList />
      </Suspense>
    </div>
  );
}
```

### Dynamic Route Page

```typescript
// app/users/[id]/page.tsx
import { notFound } from 'next/navigation';
import { getUser } from '@/lib/api/users';

interface Props {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: Props) {
  const { id } = await params;
  const user = await getUser(id);

  return {
    title: user?.name || 'User Not Found',
  };
}

export default async function UserDetailPage({ params }: Props) {
  const { id } = await params;
  const user = await getUser(id);

  if (!user) {
    notFound();
  }

  return (
    <div className="container py-8">
      <h1 className="text-2xl font-bold">{user.name}</h1>
      {/* User details */}
    </div>
  );
}
```

### Search Params

```typescript
// app/users/page.tsx
interface Props {
  searchParams: Promise<{
    page?: string;
    search?: string;
    status?: string;
  }>;
}

export default async function UsersPage({ searchParams }: Props) {
  const { page = '1', search, status } = await searchParams;

  const users = await getUsers({
    page: parseInt(page),
    search,
    status,
  });

  return (
    <div>
      <UserFilters />
      <UserTable users={users.data} />
      <Pagination meta={users.meta} />
    </div>
  );
}
```

## Layouts

### Root Layout

```typescript
// app/layout.tsx
import { Inter } from 'next/font/google';
import { Providers } from '@/components/providers';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: {
    template: '%s | MyApp',
    default: 'MyApp',
  },
  description: 'My awesome application',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

### Nested Layout

```typescript
// app/(main)/layout.tsx
import { Sidebar } from '@/components/layout/sidebar';
import { Header } from '@/components/layout/header';

export default function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  );
}
```

### Auth Layout

```typescript
// app/(auth)/layout.tsx
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="w-full max-w-md p-8 bg-white rounded-lg shadow">
        {children}
      </div>
    </div>
  );
}
```

## Route Groups

```typescript
// Route groups for organization (no URL impact)
app/
├── (marketing)/            # Marketing pages
│   ├── page.tsx            # / (home)
│   ├── about/
│   └── pricing/
├── (shop)/                 # E-commerce
│   ├── layout.tsx          # Shop layout
│   ├── products/
│   └── cart/
└── (dashboard)/            # Admin area
    ├── layout.tsx          # Dashboard layout
    ├── overview/
    └── analytics/
```

## Loading & Error States

### Loading UI

```typescript
// app/users/loading.tsx
export default function Loading() {
  return (
    <div className="container py-8">
      <div className="animate-pulse space-y-4">
        <div className="h-8 w-48 bg-gray-200 rounded" />
        <div className="h-64 bg-gray-200 rounded" />
      </div>
    </div>
  );
}
```

### Error Boundary

```typescript
// app/users/error.tsx
'use client';

import { useEffect } from 'react';
import { Button } from '@/components/ui/button';

interface Props {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function Error({ error, reset }: Props) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="container py-8 text-center">
      <h2 className="text-xl font-semibold mb-4">Something went wrong!</h2>
      <Button onClick={reset}>Try again</Button>
    </div>
  );
}
```

### Not Found

```typescript
// app/users/[id]/not-found.tsx
import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="container py-8 text-center">
      <h2 className="text-xl font-semibold mb-4">User Not Found</h2>
      <p className="text-gray-600 mb-4">
        The user you're looking for doesn't exist.
      </p>
      <Link href="/users" className="text-blue-600 hover:underline">
        Back to Users
      </Link>
    </div>
  );
}
```

## Middleware

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value;
  const { pathname } = request.nextUrl;

  // Redirect to login if not authenticated
  if (!token && pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  // Redirect to dashboard if already authenticated
  if (token && (pathname === '/login' || pathname === '/register')) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // Add custom headers
  const response = NextResponse.next();
  response.headers.set('x-pathname', pathname);

  return response;
}

export const config = {
  matcher: [
    /*
     * Match all paths except:
     * - api routes
     * - static files
     * - _next
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
};
```

## Parallel Routes

```typescript
// app/@modal/(.)users/[id]/page.tsx (intercepted route)
import { Modal } from '@/components/ui/modal';
import { UserDetail } from '@/components/users/user-detail';

export default function UserModal({ params }: { params: { id: string } }) {
  return (
    <Modal>
      <UserDetail id={params.id} />
    </Modal>
  );
}

// app/layout.tsx
export default function Layout({
  children,
  modal,
}: {
  children: React.ReactNode;
  modal: React.ReactNode;
}) {
  return (
    <>
      {children}
      {modal}
    </>
  );
}
```

## Navigation

```typescript
// Client navigation
'use client';

import Link from 'next/link';
import { useRouter, usePathname, useSearchParams } from 'next/navigation';

function Navigation() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  // Programmatic navigation
  const handleClick = () => {
    router.push('/users');
    router.replace('/login');
    router.back();
    router.refresh();  // Refetch server components
  };

  // Update search params
  const updateSearch = (key: string, value: string) => {
    const params = new URLSearchParams(searchParams.toString());
    params.set(key, value);
    router.push(`${pathname}?${params.toString()}`);
  };

  return (
    <nav>
      <Link
        href="/users"
        className={pathname === '/users' ? 'active' : ''}
      >
        Users
      </Link>
    </nav>
  );
}
```

## Best Practices

```yaml
routing_guidelines:
  - Use route groups for organization
  - Co-locate related files (page, loading, error)
  - Use layout for shared UI
  - Prefer server components for data fetching
  - Use Suspense for streaming

file_conventions:
  - page.tsx: Route segment UI
  - layout.tsx: Shared layout
  - loading.tsx: Loading state
  - error.tsx: Error boundary
  - not-found.tsx: 404 page
  - template.tsx: Re-rendered layout

naming:
  - Use kebab-case for directories
  - Dynamic routes: [param]
  - Catch-all: [...param]
  - Optional catch-all: [[...param]]
  - Route groups: (groupName)
```
