# Role-Based Access Control (RBAC)

Implement role-based permissions in Next.js applications.

## Role Definition

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
```

## RequireRole Component

```typescript
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
```

## Usage in Pages

```typescript
// app/admin/page.tsx
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

## Client-Side Role Check

```typescript
"use client";

import { useSession } from "next-auth/react";
import { UserRole, hasPermission } from "@/lib/auth/roles";

export function AdminButton() {
  const { data: session } = useSession();
  const userRole = session?.user?.role as UserRole;

  if (!hasPermission(userRole, UserRole.ADMIN)) {
    return null;
  }

  return <button>Admin Action</button>;
}
```
