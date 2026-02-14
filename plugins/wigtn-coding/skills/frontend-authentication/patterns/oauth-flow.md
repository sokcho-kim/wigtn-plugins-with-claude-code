# Manual OAuth Implementation

Implement OAuth flow manually without NextAuth.js.

## Google OAuth Route

```typescript
// app/api/auth/google/route.ts
import { NextRequest, NextResponse } from "next/server";
import { db } from "@/lib/db";
import { createToken } from "@/lib/auth/jwt";

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
    googleAuthUrl.searchParams.set("scope", "openid email profile");

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

    // Create or update user
    const user = await db.user.upsert({
      where: { email: userInfo.email },
      update: { name: userInfo.name, image: userInfo.picture },
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

## OAuth Button Component

```typescript
"use client";

export function GoogleLoginButton() {
  const handleGoogleLogin = () => {
    window.location.href = "/api/auth/google";
  };

  return (
    <button onClick={handleGoogleLogin} className="flex items-center gap-2">
      <GoogleIcon />
      Continue with Google
    </button>
  );
}
```
