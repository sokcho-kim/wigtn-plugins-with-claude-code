---
name: frontend-authentication
description: Master authentication with NextAuth.js, Clerk, and custom solutions. Implement protected routes, session management, OAuth providers, and role-based access control. Use when building auth systems or securing applications.
---

# Authentication

Comprehensive authentication patterns for Next.js applications using NextAuth.js, Clerk, and custom solutions.

## When to Use This Skill

- Implementing authentication in Next.js App Router
- Setting up OAuth providers (Google, GitHub, etc.)
- Building protected routes and middleware
- Managing user sessions and tokens
- Implementing role-based access control (RBAC)

## Core Concepts

### Authentication Options

| Solution | Complexity | Customization | When to Use |
|----------|------------|---------------|-------------|
| **NextAuth.js** | Low | High | Full control, self-hosted |
| **Clerk** | Very Low | Medium | Fast setup, managed service |
| **Custom** | High | Very High | Specific requirements |

### Authentication Flow

```
1. User Login → 2. Server Validation → 3. Token Generation →
4. Client Storage → 5. Protected Routes → 6. Token Refresh
```

## Quick Start

```bash
npm install next-auth@beta
```

```typescript
// auth.ts (root level)
import NextAuth from "next-auth";
import GitHub from "next-auth/providers/github";

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    }),
  ],
});

// app/api/auth/[...nextauth]/route.ts
import { handlers } from "@/auth";
export const { GET, POST } = handlers;
```

## Available Patterns

Load detailed patterns as needed:

| Pattern | File | Description |
|---------|------|-------------|
| NextAuth.js v5 | `patterns/nextauth.md` | Full setup with OAuth, credentials, callbacks |
| Protected Routes | `patterns/protected-routes.md` | Middleware and route protection |
| RBAC | `patterns/rbac.md` | Role-based access control |
| Session Hook | `patterns/session-hook.md` | Client-side session management |
| Server Actions | `patterns/server-actions.md` | Auth in server actions |
| Clerk | `patterns/clerk.md` | Managed auth service integration |
| Custom JWT | `patterns/custom-jwt.md` | Build your own auth with JWT |
| OAuth Flow | `patterns/oauth-flow.md` | Manual OAuth implementation |
| Magic Link | `patterns/magic-link.md` | Passwordless authentication |

## References

- `common/security.md` - Security best practices and checklist
- [NextAuth.js Documentation](https://next-auth.js.org/)
- [Clerk Documentation](https://clerk.com/docs)
