---
name: prisma-schema-design
description: Prisma schema design patterns, model definitions, and naming conventions. Use when creating or modifying database models.
---

# Prisma Schema Design

Prisma 스키마 설계를 위한 패턴, 규칙, 보일러플레이트입니다.

## Naming Conventions

```yaml
models:
  name: PascalCase, singular      # User, Product, OrderItem
  table: snake_case, plural       # @@map("users"), @@map("order_items")

fields:
  name: camelCase                 # firstName, createdAt, userId
  foreign_key: <relation>Id       # userId, productId, categoryId

enums:
  name: PascalCase                # UserRole, OrderStatus
  values: SCREAMING_SNAKE_CASE    # PENDING, IN_PROGRESS, COMPLETED
```

## Required Fields Pattern

모든 모델에 필수로 포함되어야 하는 필드:

```prisma
model BaseEntity {
  id        String   @id @default(uuid())
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## Model Boilerplate

### Basic Entity

```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  role      UserRole @default(USER)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  posts     Post[]
  profile   Profile?

  @@map("users")
}

enum UserRole {
  USER
  ADMIN
  MODERATOR
}
```

### Soft Delete Pattern

```prisma
model Post {
  id        String    @id @default(uuid())
  title     String
  content   String?
  published Boolean   @default(false)

  // Soft delete
  deletedAt DateTime?

  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  // Relations
  authorId  String
  author    User      @relation(fields: [authorId], references: [id])

  @@index([deletedAt])
  @@map("posts")
}
```

### Audit Trail Pattern

```prisma
model AuditLog {
  id         String   @id @default(uuid())
  entityType String
  entityId   String
  action     String   // CREATE, UPDATE, DELETE
  oldValue   Json?
  newValue   Json?

  userId     String
  user       User     @relation(fields: [userId], references: [id])

  createdAt  DateTime @default(now())

  @@index([entityType, entityId])
  @@index([userId])
  @@index([createdAt])
  @@map("audit_logs")
}
```

### Multi-tenant Pattern

```prisma
model Tenant {
  id        String   @id @default(uuid())
  name      String
  slug      String   @unique

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  users     User[]
  projects  Project[]

  @@map("tenants")
}

model User {
  id        String   @id @default(uuid())
  email     String

  tenantId  String
  tenant    Tenant   @relation(fields: [tenantId], references: [id])

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@unique([tenantId, email])  // Email unique per tenant
  @@index([tenantId])
  @@map("users")
}
```

### Localization Pattern

```prisma
model Product {
  id           String               @id @default(uuid())
  sku          String               @unique
  price        Decimal              @db.Decimal(10, 2)

  translations ProductTranslation[]

  createdAt    DateTime             @default(now())
  updatedAt    DateTime             @updatedAt

  @@map("products")
}

model ProductTranslation {
  id          String  @id @default(uuid())
  locale      String  // ko, en, ja
  name        String
  description String?

  productId   String
  product     Product @relation(fields: [productId], references: [id], onDelete: Cascade)

  @@unique([productId, locale])
  @@map("product_translations")
}
```

## Field Type Patterns

```prisma
// Strings
name          String              // VARCHAR(191) - default
bio           String?             // Nullable
description   String   @db.Text   // TEXT for long content
shortCode     String   @db.VarChar(10)

// Numbers
age           Int
price         Decimal  @db.Decimal(10, 2)
rating        Float
quantity      Int      @default(0)

// Boolean
isActive      Boolean  @default(true)
isVerified    Boolean  @default(false)

// Dates
createdAt     DateTime @default(now())
updatedAt     DateTime @updatedAt
publishedAt   DateTime?
expiresAt     DateTime?

// JSON
metadata      Json?
settings      Json     @default("{}")
tags          String[] // Array (PostgreSQL only)

// Enums
status        OrderStatus @default(PENDING)
role          UserRole    @default(USER)
```

## Validation Notes

```yaml
constraints_to_consider:
  - String length limits (@db.VarChar)
  - Decimal precision for money
  - Required vs optional fields
  - Default values
  - Unique constraints
  - Check constraints (via database)

common_mistakes:
  - Using Int for money (use Decimal)
  - Missing indexes on foreign keys
  - Not using @updatedAt
  - Forgetting @@map for table names
```

## Output Example

```prisma
// schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String
  password  String
  role      UserRole @default(USER)

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  posts     Post[]
  comments  Comment[]

  @@map("users")
}
```
