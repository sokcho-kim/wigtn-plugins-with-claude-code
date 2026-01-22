# Custom Auth with JWT

Build your own authentication system using JWT tokens.

## JWT Utilities

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
```

## Login Action

```typescript
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

## Middleware Protection

```typescript
// middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { verifyToken } from "@/lib/auth/jwt";

export async function middleware(request: NextRequest) {
  const token = request.cookies.get("auth-token")?.value;

  if (request.nextUrl.pathname.startsWith("/dashboard")) {
    if (!token) {
      return NextResponse.redirect(new URL("/login", request.url));
    }

    const session = await verifyToken(token);
    if (!session) {
      return NextResponse.redirect(new URL("/login", request.url));
    }
  }

  return NextResponse.next();
}
```
