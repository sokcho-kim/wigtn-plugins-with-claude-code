---
name: prisma-indexes
description: Prisma index optimization patterns, composite indexes, and query performance. Use when optimizing database queries.
---

# Prisma Indexes

인덱스 설계와 쿼리 최적화 패턴입니다.

## Index Types

### Single Column Index

```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique  // Unique index
  name      String
  status    String
  createdAt DateTime @default(now())

  @@index([status])      // Single index
  @@index([createdAt])   // For date range queries
}
```

### Composite Index

```prisma
model Post {
  id          String   @id @default(uuid())
  authorId    String
  status      String
  publishedAt DateTime?
  createdAt   DateTime @default(now())

  // Composite index - order matters!
  @@index([authorId, status])       // For: WHERE authorId = ? AND status = ?
  @@index([status, publishedAt])    // For: WHERE status = ? ORDER BY publishedAt
}
```

### Unique Constraints

```prisma
model User {
  id       String @id @default(uuid())
  email    String @unique                    // Single unique
  tenantId String
  username String

  @@unique([tenantId, username])             // Composite unique
  @@unique([tenantId, email])                // Email unique per tenant
}
```

## Index Patterns by Query Type

### Equality Queries

```prisma
// Query: WHERE status = 'ACTIVE'
@@index([status])

// Query: WHERE authorId = ? AND categoryId = ?
@@index([authorId, categoryId])
```

### Range Queries

```prisma
// Query: WHERE createdAt > ? AND createdAt < ?
@@index([createdAt])

// Query: WHERE status = ? AND createdAt > ?
@@index([status, createdAt])  // Equality first, then range
```

### Sorting Queries

```prisma
// Query: ORDER BY createdAt DESC
@@index([createdAt])

// Query: WHERE status = ? ORDER BY createdAt DESC
@@index([status, createdAt])  // Filter field first
```

### Covering Index

```prisma
model Post {
  id        String   @id
  title     String
  status    String
  authorId  String
  createdAt DateTime

  // Query: SELECT title FROM posts WHERE status = ? AND authorId = ?
  // Include title in index for "covering index"
  @@index([status, authorId, title])
}
```

## Common Index Patterns

### Foreign Key Indexes

```prisma
model Post {
  id       String @id @default(uuid())

  authorId String
  author   User   @relation(fields: [authorId], references: [id])

  @@index([authorId])  // ALWAYS index foreign keys
}
```

### Soft Delete Index

```prisma
model Post {
  id        String    @id @default(uuid())
  deletedAt DateTime?

  // For: WHERE deletedAt IS NULL
  @@index([deletedAt])
}
```

### Multi-tenant Index

```prisma
model Document {
  id        String @id @default(uuid())
  tenantId  String
  status    String
  createdAt DateTime

  // Tenant-first for row-level security
  @@index([tenantId])
  @@index([tenantId, status])
  @@index([tenantId, createdAt])
}
```

### Search Index

```prisma
model Product {
  id          String @id @default(uuid())
  name        String
  description String
  categoryId  String
  price       Decimal

  // For category + price filtering
  @@index([categoryId, price])

  // For full-text search (PostgreSQL)
  // Use raw SQL: CREATE INDEX ... USING gin(to_tsvector('english', name || ' ' || description))
}
```

## Index Selection Guidelines

```yaml
when_to_add_index:
  - Foreign key columns (ALWAYS)
  - Columns in WHERE clauses
  - Columns in ORDER BY
  - Columns in JOIN conditions
  - Columns with high selectivity

when_NOT_to_add_index:
  - Low cardinality columns (boolean, status with few values)
  - Small tables (< 1000 rows)
  - Frequently updated columns
  - Columns rarely used in queries

composite_index_order:
  1. Equality conditions first
  2. Range conditions second
  3. Sort columns last

  example: |
    Query: WHERE tenant = ? AND status = ? AND created > ? ORDER BY created
    Index: @@index([tenant, status, created])
```

## Index Analysis

### Query Analysis

```sql
-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM posts WHERE author_id = 'xxx' AND status = 'published';

-- Check if index is used
-- Look for "Index Scan" vs "Seq Scan"
```

### Index Size Check

```sql
-- PostgreSQL
SELECT
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_indexes
WHERE tablename = 'posts'
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Unused Index Detection

```sql
-- PostgreSQL
SELECT
  indexrelname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexrelname NOT LIKE '%_pkey';
```

## Performance Tips

```yaml
tips:
  - Index foreign keys automatically
  - Use composite indexes for multi-column queries
  - Order composite index columns by selectivity
  - Don't over-index (slows writes)
  - Monitor index usage and remove unused
  - Consider partial indexes for filtered queries

partial_index_example: |
  -- Only index non-deleted records
  CREATE INDEX idx_active_users ON users (email) WHERE deleted_at IS NULL;

expression_index_example: |
  -- Index on lowercase email for case-insensitive search
  CREATE INDEX idx_users_email_lower ON users (LOWER(email));
```

## Prisma Limitations

```yaml
not_supported_in_schema:
  - Partial indexes
  - Expression indexes
  - GIN/GiST indexes
  - Concurrent index creation

workaround: |
  Use raw SQL migrations:

  -- migration.sql
  CREATE INDEX CONCURRENTLY idx_posts_search
    ON posts USING gin(to_tsvector('english', title || ' ' || content));

  CREATE INDEX idx_active_posts ON posts (created_at)
    WHERE deleted_at IS NULL;
```
