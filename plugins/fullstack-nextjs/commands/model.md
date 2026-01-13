# /model - Prisma Model Generator

Generate Prisma schema models and related code.

## Usage

```
/model <ModelName> [options]
```

## Options

- `--fields`: Specify fields (comma-separated)
- `--relations`: Add relation fields
- `--with-crud`: Generate CRUD operations

## Examples

```
/model User --fields "email:String:unique,name:String?"
/model Post --relations "author:User,tags:Tag[]"
/model Comment --with-crud
```

## Output

### Schema Addition
```prisma
model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
}
```

### With CRUD (--with-crud)
```
lib/
└── <model>/
    ├── queries.ts    # findMany, findById, etc.
    ├── mutations.ts  # create, update, delete
    └── types.ts      # TypeScript types
```

## Field Types

| Prisma | TypeScript |
|--------|------------|
| String | string |
| Int | number |
| Boolean | boolean |
| DateTime | Date |
| Json | JsonValue |

## Modifiers

- `?` - Optional
- `[]` - Array
- `@unique` - Unique constraint
- `@default()` - Default value

## $ARGUMENTS
