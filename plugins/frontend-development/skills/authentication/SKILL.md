---
name: authentication
description: Master authentication with NextAuth.js, Clerk, and custom solutions. Implement protected routes, session management, OAuth providers, and role-based access control. Use when building auth systems or securing applications.
---

# Authentication

Comprehensive authentication patterns for Next.js applications using NextAuth.js, Clerk, and custom solutions, including OAuth, session management, protected routes, and role-based access control.

## When to Use This Skill

- Implementing authentication in Next.js App Router
- Setting up OAuth providers (Google, GitHub, etc.)
- Building protected routes and middleware
- Managing user sessions and tokens
- Implementing role-based access control (RBAC)
- Handling authentication state in React
- Building custom authentication flows

## Core Concepts

### 1. Authentication Options

| Solution | Complexity | Customization | When to Use |
|----------|------------|---------------|-------------|
| **NextAuth.js** | Low | High | Full control, self-hosted |
| **Clerk** | Very Low | Medium | Fast setup, managed service |
| **Custom** | High | Very High | Specific requirements |

### 2. Authentication Flow

```
1. User Login → 2. Server Validation → 3. Token Generation →
4. Client Storage → 5. Protected Routes → 6. Token Refresh
```

## Quick Start

### NextAuth.js v5 Setup

```bash
npm install next-auth@beta
```

```typescript
// auth.ts (root level)
import NextAuth from "next-auth";
import GitHub from "next-auth/providers/github";
import Google from "next-auth/providers/google";
import Credentials from "next-auth/providers/credentials";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { db } from "@/lib/db";
import bcrypt from "bcryptjs";

export const { handlers, signIn, signOut, auth } = NextAuth({
  adapter: PrismaAdapter(db),
  session: { strategy: "jwt" },
  pages: {
    signIn: "/login",
    error: "/error",
  },
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    }),
    Credentials({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          throw new Error("Invalid credentials");
        }

        const user = await db.user.findUnique({
          where: { email: credentials.email as string },
        });

        if (!user || !user.hashedPassword) {
          throw new Error("Invalid credentials");
        }

        const isPasswordValid = await bcrypt.compare(
          credentials.password as string,
          user.hashedPassword
        );

        if (!isPasswordValid) {
          throw new Error("Invalid credentials");
        }

        return {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.role = user.role;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub!;
        session.user.role = token.role as string;
      }
      return session;
    },
  },
});

// app/api/auth/[...nextauth]/route.ts
import { handlers } from "@/auth";

export const { GET, POST } = handlers;
```

## Patterns

### Pattern 1: Protected Routes with Middleware

```typescript
// middleware.ts
import { auth } from "@/auth";
import { NextResponse } from "next/server";

export default auth((req) => {
  const { nextUrl } = req;
  const isLoggedIn = !!req.auth;

  const isAuthRoute = nextUrl.pathname.startsWith("/login") ||
                      nextUrl.pathname.startsWith("/register");
  const isProtectedRoute = nextUrl.pathname.startsWith("/dashboard") ||
                          nextUrl.pathname.startsWith("/profile");

  // Redirect logged-in users away from auth pages
  if (isAuthRoute && isLoggedIn) {
    return NextResponse.redirect(new URL("/dashboard", nextUrl));
  }

  // Redirect non-logged-in users to login
  if (isProtectedRoute && !isLoggedIn) {
    return NextResponse.redirect(new URL("/login", nextUrl));
  }

  return NextResponse.next();
});

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
};
```

### Pattern 2: Role-Based Access Control

```typescript
// lib/auth/roles.ts
export enum UserRole {
  USER = "USER",
  ADMIN = "ADMIN",
  MODERATOR = "MODERATOR",
}

export const roleHierarchy: Record<UserRole, number> = {
  [UserRole.USER]: 1,
  [UserRole.MODERATOR]: 2,
  [UserRole.ADMIN]: 3,
};

export function hasPermission(userRole: UserRole, requiredRole: UserRole): boolean {
  return roleHierarchy[userRole] >= roleHierarchy[requiredRole];
}

// components/rbac/RequireRole.tsx
import { auth } from "@/auth";
import { redirect } from "next/navigation";
import { UserRole, hasPermission } from "@/lib/auth/roles";

interface RequireRoleProps {
  children: React.ReactNode;
  role: UserRole;
  fallback?: React.ReactNode;
}

export async function RequireRole({ children, role, fallback }: RequireRoleProps) {
  const session = await auth();

  if (!session?.user) {
    redirect("/login");
  }

  const userRole = session.user.role as UserRole;

  if (!hasPermission(userRole, role)) {
    if (fallback) return <>{fallback}</>;
    redirect("/unauthorized");
  }

  return <>{children}</>;
}

// Usage in page
import { RequireRole } from "@/components/rbac/RequireRole";
import { UserRole } from "@/lib/auth/roles";

export default function AdminPage() {
  return (
    <RequireRole role={UserRole.ADMIN}>
      <h1>Admin Dashboard</h1>
      {/* Admin-only content */}
    </RequireRole>
  );
}
```

### Pattern 3: Client-Side Session Hook

```typescript
// hooks/use-session.ts
"use client";

import { useSession as useNextAuthSession } from "next-auth/react";

export function useSession() {
  const { data: session, status, update } = useNextAuthSession();

  return {
    user: session?.user,
    isAuthenticated: !!session?.user,
    isLoading: status === "loading",
    update,
  };
}

// Usage in component
"use client";

import { useSession } from "@/hooks/use-session";

export function UserProfile() {
  const { user, isAuthenticated, isLoading } = useSession();

  if (isLoading) return <div>Loading...</div>;
  if (!isAuthenticated) return <div>Please sign in</div>;

  return (
    <div>
      <h2>Welcome, {user?.name}</h2>
      <p>{user?.email}</p>
    </div>
  );
}
```

### Pattern 4: Server Actions with Auth

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

### Pattern 5: Clerk Integration

```bash
npm install @clerk/nextjs
```

```typescript
// app/layout.tsx
import { ClerkProvider } from "@clerk/nextjs";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  );
}

// middleware.ts
import { authMiddleware } from "@clerk/nextjs";

export default authMiddleware({
  publicRoutes: ["/", "/api/webhook"],
  ignoredRoutes: ["/api/public"],
});

export const config = {
  matcher: ["/((?!.+\\.[\\w]+$|_next).*)", "/", "/(api|trpc)(.*)"],
};

// app/dashboard/page.tsx
import { auth, currentUser } from "@clerk/nextjs";
import { redirect } from "next/navigation";

export default async function DashboardPage() {
  const { userId } = auth();

  if (!userId) {
    redirect("/sign-in");
  }

  const user = await currentUser();

  return (
    <div>
      <h1>Welcome, {user?.firstName}</h1>
      <p>{user?.emailAddresses[0]?.emailAddress}</p>
    </div>
  );
}

// components/SignInButton.tsx
"use client";

import { SignInButton, SignOutButton, useUser } from "@clerk/nextjs";

export function AuthButtons() {
  const { isSignedIn, user } = useUser();

  if (isSignedIn) {
    return (
      <div>
        <span>Hello, {user.firstName}</span>
        <SignOutButton />
      </div>
    );
  }

  return <SignInButton mode="modal" />;
}
```

### Pattern 6: Custom Auth with JWT

```typescript
// lib/auth/jwt.ts
import { SignJWT, jwtVerify } from "jose";
import { cookies } from "next/headers";

const secret = new TextEncoder().encode(process.env.JWT_SECRET!);

export async function createToken(payload: { userId: string; role: string }) {
  return await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("7d")
    .sign(secret);
}

export async function verifyToken(token: string) {
  try {
    const { payload } = await jwtVerify(token, secret);
    return payload as { userId: string; role: string };
  } catch (error) {
    return null;
  }
}

export async function getSession() {
  const cookieStore = await cookies();
  const token = cookieStore.get("auth-token")?.value;

  if (!token) return null;

  return await verifyToken(token);
}

// app/actions/auth.ts
"use server";

import { cookies } from "next/headers";
import { createToken } from "@/lib/auth/jwt";
import { db } from "@/lib/db";
import bcrypt from "bcryptjs";

export async function login(email: string, password: string) {
  const user = await db.user.findUnique({
    where: { email },
  });

  if (!user || !user.hashedPassword) {
    return { error: "Invalid credentials" };
  }

  const isValid = await bcrypt.compare(password, user.hashedPassword);

  if (!isValid) {
    return { error: "Invalid credentials" };
  }

  const token = await createToken({
    userId: user.id,
    role: user.role,
  });

  const cookieStore = await cookies();
  cookieStore.set("auth-token", token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 7, // 7 days
    path: "/",
  });

  return { success: true };
}

export async function logout() {
  const cookieStore = await cookies();
  cookieStore.delete("auth-token");
}
```

### Pattern 7: OAuth Flow (Manual Implementation)

```typescript
// app/api/auth/google/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const code = searchParams.get("code");

  if (!code) {
    // Redirect to Google OAuth
    const googleAuthUrl = new URL("https://accounts.google.com/o/oauth2/v2/auth");
    googleAuthUrl.searchParams.set("client_id", process.env.GOOGLE_CLIENT_ID!);
    googleAuthUrl.searchParams.set(
      "redirect_uri",
      `${process.env.NEXT_PUBLIC_URL}/api/auth/google`
    );
    googleAuthUrl.searchParams.set("response_type", "code");
    googleAuthUrl.searchParams.set(
      "scope",
      "openid email profile"
    );

    return NextResponse.redirect(googleAuthUrl);
  }

  try {
    // Exchange code for tokens
    const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        code,
        client_id: process.env.GOOGLE_CLIENT_ID,
        client_secret: process.env.GOOGLE_CLIENT_SECRET,
        redirect_uri: `${process.env.NEXT_PUBLIC_URL}/api/auth/google`,
        grant_type: "authorization_code",
      }),
    });

    const tokens = await tokenResponse.json();

    // Get user info
    const userInfoResponse = await fetch(
      "https://www.googleapis.com/oauth2/v2/userinfo",
      {
        headers: { Authorization: `Bearer ${tokens.access_token}` },
      }
    );

    const userInfo = await userInfoResponse.json();

    // Create or update user in database
    const user = await db.user.upsert({
      where: { email: userInfo.email },
      update: {
        name: userInfo.name,
        image: userInfo.picture,
      },
      create: {
        email: userInfo.email,
        name: userInfo.name,
        image: userInfo.picture,
      },
    });

    // Create session token
    const sessionToken = await createToken({
      userId: user.id,
      role: user.role,
    });

    // Set cookie and redirect
    const response = NextResponse.redirect(
      new URL("/dashboard", process.env.NEXT_PUBLIC_URL!)
    );

    response.cookies.set("auth-token", sessionToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 60 * 60 * 24 * 7,
    });

    return response;
  } catch (error) {
    return NextResponse.redirect(
      new URL("/login?error=oauth_failed", process.env.NEXT_PUBLIC_URL!)
    );
  }
}
```

### Pattern 8: Magic Link Authentication

```typescript
// app/actions/magic-link.ts
"use server";

import { db } from "@/lib/db";
import { sendEmail } from "@/lib/email";
import crypto from "crypto";

export async function sendMagicLink(email: string) {
  const token = crypto.randomBytes(32).toString("hex");
  const expires = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

  await db.magicLink.create({
    data: {
      email,
      token,
      expires,
    },
  });

  const magicLink = `${process.env.NEXT_PUBLIC_URL}/auth/verify?token=${token}`;

  await sendEmail({
    to: email,
    subject: "Your Magic Link",
    html: `
      <p>Click the link below to sign in:</p>
      <a href="${magicLink}">${magicLink}</a>
      <p>This link expires in 15 minutes.</p>
    `,
  });

  return { success: true };
}

// app/auth/verify/route.ts
import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/db";
import { createToken } from "@/lib/auth/jwt";

export async function GET(request: NextRequest) {
  const token = request.nextUrl.searchParams.get("token");

  if (!token) {
    return NextResponse.redirect(new URL("/login?error=invalid_token", request.url));
  }

  const magicLink = await db.magicLink.findUnique({
    where: { token },
    include: { user: true },
  });

  if (!magicLink || magicLink.expires < new Date()) {
    return NextResponse.redirect(new URL("/login?error=expired_token", request.url));
  }

  // Delete used token
  await db.magicLink.delete({ where: { id: magicLink.id } });

  // Create session
  const sessionToken = await createToken({
    userId: magicLink.user.id,
    role: magicLink.user.role,
  });

  const response = NextResponse.redirect(new URL("/dashboard", request.url));
  response.cookies.set("auth-token", sessionToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 7,
  });

  return response;
}
```

## Best Practices

### Do's

- **Use HTTPS in production** - Always encrypt authentication data
- **Hash passwords** - Use bcrypt or argon2
- **Implement CSRF protection** - Prevent cross-site request forgery
- **Use HTTP-only cookies** - For storing tokens securely
- **Implement rate limiting** - Prevent brute-force attacks
- **Validate sessions server-side** - Don't trust client data
- **Implement token refresh** - For long-lived sessions

### Don'ts

- **Don't store passwords in plain text** - Always hash
- **Don't expose tokens in URLs** - Use HTTP-only cookies
- **Don't skip session validation** - Always check server-side
- **Don't use weak secrets** - Use strong, random JWT secrets
- **Don't trust client-side auth checks** - Always validate server-side
- **Don't forget to expire sessions** - Implement proper timeout
- **Don't log sensitive data** - Passwords, tokens should never be logged

## Security Checklist

- [ ] Passwords hashed with bcrypt/argon2
- [ ] HTTPS enabled in production
- [ ] HTTP-only cookies for tokens
- [ ] CSRF protection implemented
- [ ] Rate limiting on auth endpoints
- [ ] Account lockout after failed attempts
- [ ] Email verification implemented
- [ ] Password reset flow secure
- [ ] Session timeout configured
- [ ] Two-factor authentication (optional)

## Environment Variables

```bash
# .env.local

# NextAuth.js
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here

# OAuth Providers
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret

# Clerk (alternative)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxx
CLERK_SECRET_KEY=sk_test_xxx

# Custom JWT
JWT_SECRET=your-jwt-secret-256-bit-minimum

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```

## Resources

- [NextAuth.js Documentation](https://next-auth.js.org/)
- [Clerk Documentation](https://clerk.com/docs)
- [OAuth 2.0 Specification](https://oauth.net/2/)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
