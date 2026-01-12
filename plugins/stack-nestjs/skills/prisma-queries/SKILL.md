---
name: prisma-queries
description: Prisma query patterns, filtering, relations loading, raw queries. Use when writing database queries.
---

# Prisma Queries

Prisma를 사용한 쿼리 패턴입니다.

## Basic CRUD Operations

### Create

```typescript
// Single create
const user = await prisma.user.create({
  data: {
    email: 'alice@example.com',
    name: 'Alice',
  },
});

// Create with relations
const post = await prisma.post.create({
  data: {
    title: 'Hello World',
    author: {
      connect: { id: userId },  // Connect to existing
    },
    tags: {
      create: [                   // Create new
        { name: 'typescript' },
        { name: 'prisma' },
      ],
    },
  },
});

// Create many
const users = await prisma.user.createMany({
  data: [
    { email: 'a@example.com', name: 'A' },
    { email: 'b@example.com', name: 'B' },
  ],
  skipDuplicates: true,  // Skip on unique constraint
});
```

### Read

```typescript
// Find unique
const user = await prisma.user.findUnique({
  where: { id: userId },
});

// Find unique or throw
const user = await prisma.user.findUniqueOrThrow({
  where: { id: userId },
});

// Find first
const user = await prisma.user.findFirst({
  where: { status: 'ACTIVE' },
  orderBy: { createdAt: 'desc' },
});

// Find many
const users = await prisma.user.findMany({
  where: { status: 'ACTIVE' },
  take: 10,
  skip: 0,
  orderBy: { name: 'asc' },
});
```

### Update

```typescript
// Update single
const user = await prisma.user.update({
  where: { id: userId },
  data: { name: 'New Name' },
});

// Update many
const result = await prisma.user.updateMany({
  where: { status: 'INACTIVE' },
  data: { deletedAt: new Date() },
});

// Upsert
const user = await prisma.user.upsert({
  where: { email: 'alice@example.com' },
  update: { name: 'Alice Updated' },
  create: { email: 'alice@example.com', name: 'Alice' },
});
```

### Delete

```typescript
// Delete single
const user = await prisma.user.delete({
  where: { id: userId },
});

// Delete many
const result = await prisma.user.deleteMany({
  where: { status: 'DELETED' },
});

// Soft delete pattern
const user = await prisma.user.update({
  where: { id: userId },
  data: { deletedAt: new Date() },
});
```

## Filtering

### Basic Filters

```typescript
// Equals
where: { status: 'ACTIVE' }
where: { status: { equals: 'ACTIVE' } }

// Not equals
where: { status: { not: 'DELETED' } }

// In list
where: { status: { in: ['ACTIVE', 'PENDING'] } }
where: { status: { notIn: ['DELETED'] } }

// Null checks
where: { deletedAt: null }
where: { deletedAt: { not: null } }
```

### String Filters

```typescript
// Contains (case-insensitive)
where: {
  name: {
    contains: 'alice',
    mode: 'insensitive',
  },
}

// Starts/Ends with
where: { email: { startsWith: 'admin' } }
where: { email: { endsWith: '@company.com' } }
```

### Logical Operators

```typescript
// AND (implicit)
where: {
  status: 'ACTIVE',
  role: 'ADMIN',
}

// OR
where: {
  OR: [
    { email: { contains: 'admin' } },
    { role: 'ADMIN' },
  ],
}

// Complex combination
where: {
  AND: [
    { status: 'ACTIVE' },
    {
      OR: [
        { role: 'ADMIN' },
        { permissions: { has: 'manage_users' } },
      ],
    },
  ],
}
```

## Relations

### Include Relations

```typescript
// Include single relation
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    profile: true,
    posts: true,
  },
});

// Nested include
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    posts: {
      include: {
        comments: {
          include: { author: true },
        },
      },
    },
  },
});
```

### Filter Relations

```typescript
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  },
});
```

## Pagination

```typescript
// Offset pagination
async function getUsers(page: number, limit: number) {
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.user.count(),
  ]);

  return {
    data: users,
    meta: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}

// Cursor pagination
async function getUsersCursor(cursor?: string, limit: number = 10) {
  const users = await prisma.user.findMany({
    take: limit + 1,
    cursor: cursor ? { id: cursor } : undefined,
    skip: cursor ? 1 : 0,
    orderBy: { id: 'asc' },
  });

  const hasMore = users.length > limit;
  const data = hasMore ? users.slice(0, -1) : users;

  return {
    data,
    nextCursor: hasMore ? data[data.length - 1].id : null,
  };
}
```

## Transactions

```typescript
// Sequential operations
const [user, post] = await prisma.$transaction([
  prisma.user.create({ data: userData }),
  prisma.post.create({ data: postData }),
]);

// Interactive transaction
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });

  if (!user) throw new Error('User not found');

  const order = await tx.order.create({
    data: { userId: user.id, ...orderData },
  });

  await tx.user.update({
    where: { id },
    data: { orderCount: { increment: 1 } },
  });

  return order;
});
```

## Performance Tips

```yaml
query_optimization:
  - Use select to fetch only needed fields
  - Use include sparingly (N+1 problem)
  - Add indexes for filtered/sorted fields
  - Use cursor pagination for large datasets
  - Batch operations with createMany/updateMany

avoid:
  - Nested includes more than 3 levels deep
  - findMany without pagination
  - Multiple queries when one would suffice
  - Selecting all fields when few are needed

patterns:
  - Count and findMany in parallel for pagination
  - Use transactions for related operations
  - Cache frequently accessed data
  - Use raw queries for complex operations
```
