---
name: prisma-relations
description: Prisma relation patterns - one-to-one, one-to-many, many-to-many, and self-relations. Use when designing model relationships.
---

# Prisma Relations

관계 설정 패턴과 베스트 프랙티스입니다.

## One-to-One Relations

### Required One-to-One

```prisma
model User {
  id      String   @id @default(uuid())
  email   String   @unique
  profile Profile?  // Optional side
}

model Profile {
  id     String @id @default(uuid())
  bio    String?
  avatar String?

  userId String @unique  // Required + unique = 1:1
  user   User   @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

### Optional One-to-One

```prisma
model User {
  id       String    @id @default(uuid())
  settings Settings?
}

model Settings {
  id       String  @id @default(uuid())
  theme    String  @default("light")
  language String  @default("ko")

  userId   String? @unique  // Optional
  user     User?   @relation(fields: [userId], references: [id])
}
```

## One-to-Many Relations

### Basic One-to-Many

```prisma
model User {
  id    String @id @default(uuid())
  email String @unique
  posts Post[]  // One user has many posts
}

model Post {
  id       String @id @default(uuid())
  title    String
  content  String?

  authorId String
  author   User   @relation(fields: [authorId], references: [id])

  @@index([authorId])  // Always index foreign keys
}
```

### One-to-Many with Cascade Delete

```prisma
model Category {
  id       String    @id @default(uuid())
  name     String
  products Product[]
}

model Product {
  id         String   @id @default(uuid())
  name       String

  categoryId String
  category   Category @relation(fields: [categoryId], references: [id], onDelete: Cascade)

  @@index([categoryId])
}
```

### Multiple Relations to Same Model

```prisma
model User {
  id            String    @id @default(uuid())
  name          String

  writtenPosts  Post[]    @relation("author")
  editedPosts   Post[]    @relation("editor")
}

model Post {
  id       String  @id @default(uuid())
  title    String

  authorId String
  author   User    @relation("author", fields: [authorId], references: [id])

  editorId String?
  editor   User?   @relation("editor", fields: [editorId], references: [id])

  @@index([authorId])
  @@index([editorId])
}
```

## Many-to-Many Relations

### Implicit Many-to-Many (Simple)

```prisma
model Post {
  id    String @id @default(uuid())
  title String
  tags  Tag[]  // Prisma creates junction table automatically
}

model Tag {
  id    String @id @default(uuid())
  name  String @unique
  posts Post[]
}

// Prisma auto-creates: _PostToTag(A, B)
```

### Explicit Many-to-Many (With Extra Fields)

```prisma
model User {
  id          String       @id @default(uuid())
  email       String       @unique
  memberships Membership[]
}

model Team {
  id      String       @id @default(uuid())
  name    String
  members Membership[]
}

model Membership {
  id       String   @id @default(uuid())
  role     String   @default("member")  // Extra field
  joinedAt DateTime @default(now())     // Extra field

  userId   String
  user     User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  teamId   String
  team     Team     @relation(fields: [teamId], references: [id], onDelete: Cascade)

  @@unique([userId, teamId])  // One membership per user per team
  @@index([userId])
  @@index([teamId])
}
```

### Ordered Many-to-Many

```prisma
model Playlist {
  id     String         @id @default(uuid())
  name   String
  tracks PlaylistTrack[]
}

model Track {
  id        String         @id @default(uuid())
  title     String
  playlists PlaylistTrack[]
}

model PlaylistTrack {
  id         String   @id @default(uuid())
  position   Int      // Order in playlist
  addedAt    DateTime @default(now())

  playlistId String
  playlist   Playlist @relation(fields: [playlistId], references: [id], onDelete: Cascade)

  trackId    String
  track      Track    @relation(fields: [trackId], references: [id], onDelete: Cascade)

  @@unique([playlistId, trackId])
  @@index([playlistId, position])  // For ordered queries
}
```

## Self-Relations

### Simple Self-Relation (Parent-Child)

```prisma
model Category {
  id       String     @id @default(uuid())
  name     String

  parentId String?
  parent   Category?  @relation("CategoryHierarchy", fields: [parentId], references: [id])
  children Category[] @relation("CategoryHierarchy")

  @@index([parentId])
}
```

### Adjacency List (Tree Structure)

```prisma
model Comment {
  id       String    @id @default(uuid())
  content  String

  // Self-relation for replies
  parentId String?
  parent   Comment?  @relation("CommentReplies", fields: [parentId], references: [id])
  replies  Comment[] @relation("CommentReplies")

  // Post relation
  postId   String
  post     Post      @relation(fields: [postId], references: [id])

  @@index([parentId])
  @@index([postId])
}
```

### Many-to-Many Self-Relation (Followers)

```prisma
model User {
  id        String   @id @default(uuid())
  name      String

  followers Follow[] @relation("following")
  following Follow[] @relation("follower")
}

model Follow {
  id          String   @id @default(uuid())
  createdAt   DateTime @default(now())

  followerId  String
  follower    User     @relation("follower", fields: [followerId], references: [id], onDelete: Cascade)

  followingId String
  following   User     @relation("following", fields: [followingId], references: [id], onDelete: Cascade)

  @@unique([followerId, followingId])
  @@index([followerId])
  @@index([followingId])
}
```

## Referential Actions

```prisma
// onDelete options
onDelete: Cascade     // Delete related records
onDelete: Restrict    // Prevent deletion if related exist
onDelete: NoAction    // Similar to Restrict
onDelete: SetNull     // Set FK to null (field must be optional)
onDelete: SetDefault  // Set FK to default value

// onUpdate options
onUpdate: Cascade     // Update FK when PK changes
onUpdate: Restrict    // Prevent PK change if related exist
onUpdate: NoAction    // Similar to Restrict
onUpdate: SetNull     // Set FK to null
onUpdate: SetDefault  // Set FK to default

// Common patterns
model Post {
  authorId String
  author   User   @relation(fields: [authorId], references: [id], onDelete: Cascade)
  // When user deleted, delete their posts
}

model Comment {
  userId String?
  user   User?  @relation(fields: [userId], references: [id], onDelete: SetNull)
  // When user deleted, keep comment but set userId to null
}
```

## Query Patterns

```typescript
// Include relations
const user = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: true,
    profile: true,
  },
});

// Nested includes
const user = await prisma.user.findUnique({
  where: { id },
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

// Select specific relation fields
const user = await prisma.user.findUnique({
  where: { id },
  include: {
    posts: {
      select: { id: true, title: true },
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  },
});

// Create with relations
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    profile: {
      create: { bio: 'Hello' },
    },
    posts: {
      create: [
        { title: 'First Post' },
        { title: 'Second Post' },
      ],
    },
  },
});
```
