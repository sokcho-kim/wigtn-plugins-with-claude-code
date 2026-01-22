# Client-Side Session Hook

Custom hook for managing session state in client components.

## Custom Session Hook

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
```

## Usage in Components

```typescript
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

## Session Provider Setup

```typescript
// app/providers.tsx
"use client";

import { SessionProvider } from "next-auth/react";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      {children}
    </SessionProvider>
  );
}

// app/layout.tsx
import { Providers } from "./providers";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```
