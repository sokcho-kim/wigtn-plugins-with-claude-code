# /feature - Full Feature Scaffolding

Generate complete full-stack features with all layers.

## Usage

```
/feature <feature-name> [options]
```

## Options

- `--crud`: Full CRUD feature
- `--auth`: Auth-protected feature
- `--realtime`: With real-time updates

## Examples

```
/feature posts --crud
/feature dashboard --auth
/feature chat --realtime
```

## Output (--crud)

```
# Database
prisma/schema.prisma  (model added)

# API Layer
app/api/<feature>/route.ts
app/api/<feature>/[id]/route.ts

# Server Actions
app/actions/<feature>.ts

# Pages
app/<feature>/page.tsx           # List
app/<feature>/[id]/page.tsx      # Detail
app/<feature>/new/page.tsx       # Create
app/<feature>/[id]/edit/page.tsx # Edit

# Components
components/<feature>/
├── <Feature>List.tsx
├── <Feature>Card.tsx
├── <Feature>Form.tsx
└── <Feature>Detail.tsx

# Hooks
hooks/use<Feature>.ts

# Types
types/<feature>.ts
```

## Generated Code Includes

1. **Prisma Model** - Database schema
2. **API Routes** - RESTful endpoints
3. **Server Actions** - Form mutations
4. **Pages** - UI with loading/error states
5. **Components** - Reusable UI pieces
6. **Hooks** - Data fetching with React Query
7. **Types** - TypeScript definitions

## $ARGUMENTS
