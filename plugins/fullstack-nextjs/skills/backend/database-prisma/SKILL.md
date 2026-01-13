---
name: database-prisma
description: Prisma ORM patterns for database modeling, queries, and migrations.
---

# Database with Prisma

## When to Use

- Any Next.js app needing database access
- Type-safe database queries
- Database migrations and schema management
- Relations between entities

## When NOT to Use

- Simple key-value storage → Consider Redis
- Document-heavy apps → Consider MongoDB directly
- Real-time sync → Consider Firebase/Supabase
- Already using another ORM

## Decision Criteria

| Need | Solution |
|------|----------|
| Type-safe queries | Prisma Client |
| Database migrations | Prisma Migrate |
| Quick prototyping | `db push` |
| Production deployment | `migrate deploy` |
| Seed data | Prisma seed scripts |
| Complex queries | Raw SQL with `$queryRaw` |

## Best Practices

1. **Single client instance** - Use global singleton in dev
2. **Use transactions** - For related mutations
3. **Index foreign keys** - Add `@@index` for relations
4. **Soft deletes** - Add `deletedAt` instead of hard delete
5. **Select only needed fields** - Use `select` to reduce payload

## Common Pitfalls

- ❌ Creating new client per request (connection exhaustion)
- ❌ N+1 queries (use `include` or batch)
- ❌ Missing indexes on foreign keys
- ❌ Not handling unique constraint errors
- ❌ Using `findFirst` when `findUnique` works

---

## Setup

### Client Singleton

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
```

---

## Patterns

### Pattern 1: Basic Schema

**Use when**: Starting a new project

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  String
  tags      Tag[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}

enum Role {
  USER
  ADMIN
}
```

### Pattern 2: CRUD Operations

**Use when**: Standard data operations

```typescript
// Create
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    name: 'John',
  },
});

// Read one
const user = await prisma.user.findUnique({
  where: { id: userId },
});

// Read many with filter
const posts = await prisma.post.findMany({
  where: {
    published: true,
    author: { email: { contains: '@company.com' } },
  },
  orderBy: { createdAt: 'desc' },
  take: 10,
});

// Update
const updated = await prisma.user.update({
  where: { id: userId },
  data: { name: 'Jane' },
});

// Delete
await prisma.user.delete({
  where: { id: userId },
});

// Upsert
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { name: 'Updated' },
  create: { email: 'user@example.com', name: 'New' },
});
```

### Pattern 3: Relations

**Use when**: Fetching related data

```typescript
// Include relations
const post = await prisma.post.findUnique({
  where: { id: postId },
  include: {
    author: true,
    tags: true,
  },
});

// Select specific fields (more efficient)
const post = await prisma.post.findUnique({
  where: { id: postId },
  select: {
    title: true,
    content: true,
    author: {
      select: { name: true, email: true },
    },
  },
});

// Create with relations
const post = await prisma.post.create({
  data: {
    title: 'New Post',
    author: { connect: { id: userId } },
    tags: {
      connectOrCreate: [
        { where: { name: 'tech' }, create: { name: 'tech' } },
        { where: { name: 'news' }, create: { name: 'news' } },
      ],
    },
  },
});

// Nested create
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    posts: {
      create: [
        { title: 'First post' },
        { title: 'Second post' },
      ],
    },
  },
});
```

### Pattern 4: Transactions

**Use when**: Multiple operations must succeed together

```typescript
// Sequential transaction
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: userData }),
  prisma.post.create({ data: postData }),
]);

// Interactive transaction
const result = await prisma.$transaction(async (tx) => {
  // Decrement sender balance
  const sender = await tx.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } },
  });

  if (sender.balance < 0) {
    throw new Error('Insufficient balance');
  }

  // Increment receiver balance
  await tx.account.update({
    where: { id: receiverId },
    data: { balance: { increment: amount } },
  });

  return { success: true };
});
```

### Pattern 5: Pagination

**Use when**: Large datasets need paging

```typescript
// Offset pagination
async function getPosts(page: number, limit: number) {
  const [posts, total] = await Promise.all([
    prisma.post.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.post.count(),
  ]);

  return {
    data: posts,
    meta: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}

// Cursor pagination (better for large datasets)
async function getPostsCursor(cursor?: string, limit = 10) {
  const posts = await prisma.post.findMany({
    take: limit + 1,
    cursor: cursor ? { id: cursor } : undefined,
    orderBy: { createdAt: 'desc' },
  });

  const hasMore = posts.length > limit;
  const data = hasMore ? posts.slice(0, -1) : posts;
  const nextCursor = hasMore ? data[data.length - 1].id : null;

  return { data, nextCursor, hasMore };
}
```

### Pattern 6: Soft Delete

**Use when**: Need to preserve deleted records

```prisma
model Post {
  // ... other fields
  deletedAt DateTime?
}
```

```typescript
// "Delete" (soft)
await prisma.post.update({
  where: { id: postId },
  data: { deletedAt: new Date() },
});

// Query active only
const posts = await prisma.post.findMany({
  where: { deletedAt: null },
});

// Restore
await prisma.post.update({
  where: { id: postId },
  data: { deletedAt: null },
});

// Middleware for automatic filtering
prisma.$use(async (params, next) => {
  if (params.model === 'Post' && params.action === 'findMany') {
    params.args.where = { ...params.args.where, deletedAt: null };
  }
  return next(params);
});
```

### Pattern 7: Error Handling

**Use when**: Handling database errors gracefully

```typescript
import { Prisma } from '@prisma/client';

async function createUser(data: CreateUserData) {
  try {
    return await prisma.user.create({ data });
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      // Unique constraint violation
      if (error.code === 'P2002') {
        throw new Error('Email already exists');
      }
      // Foreign key constraint
      if (error.code === 'P2003') {
        throw new Error('Related record not found');
      }
      // Record not found
      if (error.code === 'P2025') {
        throw new Error('Record not found');
      }
    }
    throw error;
  }
}
```
