# Magic Link Authentication

Implement passwordless authentication with magic links.

## Send Magic Link

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
```

## Verify Magic Link

```typescript
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

  // Create or get user
  let user = await db.user.findUnique({ where: { email: magicLink.email } });

  if (!user) {
    user = await db.user.create({
      data: { email: magicLink.email },
    });
  }

  // Create session
  const sessionToken = await createToken({
    userId: user.id,
    role: user.role,
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

## Login Form

```typescript
"use client";

import { useState } from "react";
import { sendMagicLink } from "@/app/actions/magic-link";

export function MagicLinkForm() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    await sendMagicLink(email);
    setSent(true);
    setLoading(false);
  };

  if (sent) {
    return <p>Check your email for the magic link!</p>;
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="your@email.com"
        required
      />
      <button type="submit" disabled={loading}>
        {loading ? "Sending..." : "Send Magic Link"}
      </button>
    </form>
  );
}
```
