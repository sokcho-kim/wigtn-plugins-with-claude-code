---
name: auth-patterns
description: Authentication patterns with NextAuth.js v5, sessions, and middleware protection.
---

# Authentication Patterns

## When to Use

- User login/registration
- Protected routes and pages
- Role-based access control
- OAuth (Google, GitHub, etc.)
- Session management

## When NOT to Use

- Public-only sites
- API-key only authentication → Use middleware directly
- Machine-to-machine auth → Use API keys or JWT

## Decision Criteria

| Need | Solution |
|------|----------|
| OAuth providers | NextAuth.js |
| Email/password | NextAuth.js Credentials |
| Session storage | Database adapter (recommended) or JWT |
| Protected pages | Middleware |
| Protected Server Components | `auth()` check |
| Protected API routes | `auth()` check |

## Best Practices

1. **Use database sessions** - More secure than JWT for web apps
2. **Protect in middleware** - Faster than checking in each page
3. **Never expose user IDs** - Use session, not raw IDs in URLs
4. **Hash passwords** - Use bcrypt or Argon2
5. **Implement CSRF protection** - NextAuth handles this

## Common Pitfalls

- ❌ Storing passwords in plain text
- ❌ Not checking auth in Server Components
- ❌ Trusting client-side auth state only
- ❌ Not protecting API routes
- ❌ Exposing sensitive user data

---

## Setup

### NextAuth v5 Configuration

```typescript
// auth.ts
import NextAuth from 'next-auth';
import GitHub from 'next-auth/providers/github';
import Google from 'next-auth/providers/google';
import Credentials from 'next-auth/providers/credentials';
import { PrismaAdapter } from '@auth/prisma-adapter';
import { prisma } from '@/lib/prisma';
import bcrypt from 'bcryptjs';

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    GitHub({
      clientId: process.env.GITHUB_ID!,
      clientSecret: process.env.GITHUB_SECRET!,
    }),
    Google({
      clientId: process.env.GOOGLE_ID!,
      clientSecret: process.env.GOOGLE_SECRET!,
    }),
    Credentials({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null;
        }

        const user = await prisma.user.findUnique({
          where: { email: credentials.email as string },
        });

        if (!user?.password) return null;

        const valid = await bcrypt.compare(
          credentials.password as string,
          user.password
        );

        if (!valid) return null;

        return {
          id: user.id,
          email: user.email,
          name: user.name,
        };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      if (token && session.user) {
        session.user.id = token.id as string;
      }
      return session;
    },
  },
  pages: {
    signIn: '/login',
    error: '/auth/error',
  },
});
```

### Route Handler

```typescript
// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/auth';

export const { GET, POST } = handlers;
```

---

## Patterns

### Pattern 1: Middleware Protection

**Use when**: Protecting routes at the edge

```typescript
// middleware.ts
import { auth } from '@/auth';
import { NextResponse } from 'next/server';

export default auth((req) => {
  const isLoggedIn = !!req.auth;
  const { pathname } = req.nextUrl;

  // Public routes
  const publicRoutes = ['/', '/login', '/register', '/about'];
  const isPublicRoute = publicRoutes.includes(pathname);

  // Auth routes (redirect if logged in)
  const authRoutes = ['/login', '/register'];
  const isAuthRoute = authRoutes.includes(pathname);

  if (isAuthRoute && isLoggedIn) {
    return NextResponse.redirect(new URL('/dashboard', req.url));
  }

  if (!isPublicRoute && !isLoggedIn) {
    const loginUrl = new URL('/login', req.url);
    loginUrl.searchParams.set('callbackUrl', pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
});

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

### Pattern 2: Server Component Protection

**Use when**: Checking auth in Server Components

```typescript
// app/dashboard/page.tsx
import { auth } from '@/auth';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const session = await auth();

  if (!session) {
    redirect('/login');
  }

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
      {/* Dashboard content */}
    </div>
  );
}
```

### Pattern 3: Role-Based Access

**Use when**: Different permissions for different users

```typescript
// Extend types
// types/next-auth.d.ts
import { DefaultSession } from 'next-auth';

declare module 'next-auth' {
  interface User {
    role: 'USER' | 'ADMIN';
  }

  interface Session extends DefaultSession {
    user: User & DefaultSession['user'];
  }
}

// Update auth config
callbacks: {
  async jwt({ token, user }) {
    if (user) {
      token.role = user.role;
    }
    return token;
  },
  async session({ session, token }) {
    if (session.user) {
      session.user.role = token.role as 'USER' | 'ADMIN';
    }
    return session;
  },
}

// Check in component
async function AdminPage() {
  const session = await auth();

  if (session?.user.role !== 'ADMIN') {
    redirect('/unauthorized');
  }

  return <div>Admin content</div>;
}

// Check in middleware
export default auth((req) => {
  const isAdmin = req.auth?.user.role === 'ADMIN';
  const isAdminRoute = req.nextUrl.pathname.startsWith('/admin');

  if (isAdminRoute && !isAdmin) {
    return NextResponse.redirect(new URL('/unauthorized', req.url));
  }
});
```

### Pattern 4: Sign In/Out Actions

**Use when**: Server-side auth actions

```typescript
// app/actions/auth.ts
'use server';

import { signIn, signOut } from '@/auth';
import { AuthError } from 'next-auth';

export async function login(formData: FormData) {
  try {
    await signIn('credentials', {
      email: formData.get('email'),
      password: formData.get('password'),
      redirectTo: '/dashboard',
    });
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'CredentialsSignin':
          return { error: 'Invalid credentials' };
        default:
          return { error: 'Something went wrong' };
      }
    }
    throw error;
  }
}

export async function logout() {
  await signOut({ redirectTo: '/' });
}

export async function loginWithGitHub() {
  await signIn('github', { redirectTo: '/dashboard' });
}
```

### Pattern 5: Login Form

**Use when**: Email/password authentication

```typescript
// app/login/page.tsx
import { login, loginWithGitHub } from '@/app/actions/auth';

export default function LoginPage() {
  return (
    <div className="max-w-md mx-auto">
      <form action={login} className="space-y-4">
        <div>
          <label htmlFor="email">Email</label>
          <input
            id="email"
            name="email"
            type="email"
            required
            className="w-full border rounded p-2"
          />
        </div>

        <div>
          <label htmlFor="password">Password</label>
          <input
            id="password"
            name="password"
            type="password"
            required
            className="w-full border rounded p-2"
          />
        </div>

        <button
          type="submit"
          className="w-full bg-primary text-white rounded p-2"
        >
          Sign In
        </button>
      </form>

      <div className="mt-4">
        <form action={loginWithGitHub}>
          <button
            type="submit"
            className="w-full border rounded p-2"
          >
            Continue with GitHub
          </button>
        </form>
      </div>
    </div>
  );
}
```

### Pattern 6: Session Provider (Client)

**Use when**: Need session in Client Components

```typescript
// app/providers.tsx
'use client';

import { SessionProvider } from 'next-auth/react';

export function Providers({ children }: { children: React.ReactNode }) {
  return <SessionProvider>{children}</SessionProvider>;
}

// app/layout.tsx
import { Providers } from './providers';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}

// Client component usage
'use client';

import { useSession, signOut } from 'next-auth/react';

export function UserMenu() {
  const { data: session, status } = useSession();

  if (status === 'loading') return <div>Loading...</div>;
  if (!session) return <a href="/login">Sign In</a>;

  return (
    <div>
      <span>{session.user.name}</span>
      <button onClick={() => signOut()}>Sign Out</button>
    </div>
  );
}
```
