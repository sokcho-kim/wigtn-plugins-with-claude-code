---
name: api-routes
description: Next.js API Route Handlers for RESTful endpoints and request handling.
---

# API Routes

## When to Use

- External API access (webhooks, third-party integrations)
- Public REST API for other clients
- Complex request/response handling
- File uploads with custom processing
- WebSocket upgrade points

## When NOT to Use

- Form submissions from Next.js app → Use Server Actions
- Internal data fetching → Use Server Components
- Simple mutations → Use Server Actions

## Decision Criteria

| Need | Solution |
|------|----------|
| Form submission | Server Action (preferred) |
| External webhook | API Route |
| Public REST API | API Route |
| File upload | API Route |
| GraphQL endpoint | API Route |
| Internal mutation | Server Action |

## Best Practices

1. **Validate all input** - Never trust client data
2. **Use proper HTTP methods** - GET, POST, PATCH, DELETE
3. **Return proper status codes** - 200, 201, 400, 401, 404, 500
4. **Handle errors consistently** - Use error handler wrapper
5. **Document your API** - OpenAPI/Swagger for public APIs

## Common Pitfalls

- ❌ Not validating request body
- ❌ Exposing internal errors to clients
- ❌ Wrong HTTP status codes
- ❌ Not handling all HTTP methods
- ❌ Missing authentication checks

---

## Patterns

### Pattern 1: Basic CRUD Route

**Use when**: Standard RESTful endpoints

```typescript
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const createSchema = z.object({
  title: z.string().min(1),
  content: z.string(),
});

// GET /api/posts
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const page = parseInt(searchParams.get('page') || '1');
  const limit = parseInt(searchParams.get('limit') || '10');

  const posts = await prisma.post.findMany({
    skip: (page - 1) * limit,
    take: limit,
    orderBy: { createdAt: 'desc' },
  });

  return NextResponse.json(posts);
}

// POST /api/posts
export async function POST(request: NextRequest) {
  const body = await request.json();
  const parsed = createSchema.safeParse(body);

  if (!parsed.success) {
    return NextResponse.json(
      { error: 'Invalid input', details: parsed.error.flatten() },
      { status: 400 }
    );
  }

  const post = await prisma.post.create({
    data: parsed.data,
  });

  return NextResponse.json(post, { status: 201 });
}
```

### Pattern 2: Dynamic Route

**Use when**: Operating on specific resources

```typescript
// app/api/posts/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';

interface Params {
  params: Promise<{ id: string }>;
}

// GET /api/posts/:id
export async function GET(request: NextRequest, { params }: Params) {
  const { id } = await params;

  const post = await prisma.post.findUnique({
    where: { id },
  });

  if (!post) {
    return NextResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    );
  }

  return NextResponse.json(post);
}

// PATCH /api/posts/:id
export async function PATCH(request: NextRequest, { params }: Params) {
  const { id } = await params;
  const body = await request.json();

  try {
    const post = await prisma.post.update({
      where: { id },
      data: body,
    });
    return NextResponse.json(post);
  } catch {
    return NextResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    );
  }
}

// DELETE /api/posts/:id
export async function DELETE(request: NextRequest, { params }: Params) {
  const { id } = await params;

  try {
    await prisma.post.delete({ where: { id } });
    return new NextResponse(null, { status: 204 });
  } catch {
    return NextResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    );
  }
}
```

### Pattern 3: Protected Route

**Use when**: Route requires authentication

```typescript
// app/api/user/route.ts
import { auth } from '@/auth';
import { NextResponse } from 'next/server';

export async function GET() {
  const session = await auth();

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
    select: { id: true, email: true, name: true },
  });

  return NextResponse.json(user);
}
```

### Pattern 4: Error Handler Wrapper

**Use when**: Consistent error handling across routes

```typescript
// lib/api-handler.ts
import { NextRequest, NextResponse } from 'next/server';
import { ZodError } from 'zod';

type Handler = (
  request: NextRequest,
  context?: any
) => Promise<NextResponse>;

export function withErrorHandler(handler: Handler): Handler {
  return async (request, context) => {
    try {
      return await handler(request, context);
    } catch (error) {
      console.error('API Error:', error);

      if (error instanceof ZodError) {
        return NextResponse.json(
          { error: 'Validation failed', details: error.flatten() },
          { status: 400 }
        );
      }

      if (error instanceof Error) {
        // Don't expose internal error messages in production
        const message =
          process.env.NODE_ENV === 'development'
            ? error.message
            : 'Internal server error';

        return NextResponse.json(
          { error: message },
          { status: 500 }
        );
      }

      return NextResponse.json(
        { error: 'Internal server error' },
        { status: 500 }
      );
    }
  };
}

// Usage
export const GET = withErrorHandler(async (request) => {
  const data = await fetchData();
  return NextResponse.json(data);
});
```

### Pattern 5: File Upload

**Use when**: Handling file uploads

```typescript
// app/api/upload/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { writeFile } from 'fs/promises';
import { join } from 'path';

export async function POST(request: NextRequest) {
  const formData = await request.formData();
  const file = formData.get('file') as File | null;

  if (!file) {
    return NextResponse.json(
      { error: 'No file provided' },
      { status: 400 }
    );
  }

  // Validate file type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
  if (!allowedTypes.includes(file.type)) {
    return NextResponse.json(
      { error: 'Invalid file type' },
      { status: 400 }
    );
  }

  // Validate file size (5MB)
  if (file.size > 5 * 1024 * 1024) {
    return NextResponse.json(
      { error: 'File too large' },
      { status: 400 }
    );
  }

  const bytes = await file.arrayBuffer();
  const buffer = Buffer.from(bytes);

  const filename = `${Date.now()}-${file.name}`;
  const path = join(process.cwd(), 'public/uploads', filename);

  await writeFile(path, buffer);

  return NextResponse.json({
    url: `/uploads/${filename}`,
  });
}
```

### Pattern 6: Webhook Handler

**Use when**: Receiving external webhooks

```typescript
// app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = request.headers.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    console.error('Webhook signature verification failed');
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    );
  }

  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(event.data.object);
      break;
    case 'invoice.paid':
      await handleInvoicePaid(event.data.object);
      break;
    default:
      console.log(`Unhandled event type: ${event.type}`);
  }

  return NextResponse.json({ received: true });
}
```

### Pattern 7: Route Segment Config

**Use when**: Customizing route behavior

```typescript
// app/api/data/route.ts

// Force dynamic (no caching)
export const dynamic = 'force-dynamic';

// Or set revalidation
export const revalidate = 60; // seconds

// Edge runtime
export const runtime = 'edge';

// Max duration (seconds)
export const maxDuration = 30;

export async function GET() {
  // ...
}
```
