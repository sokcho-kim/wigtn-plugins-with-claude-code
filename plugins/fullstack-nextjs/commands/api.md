# /api - API Route Generator

Generate Next.js API route handlers.

## Usage

```
/api <route-path> [options]
```

## Options

- `--crud`: Full CRUD operations
- `--auth`: Protected route
- `--dynamic`: Dynamic route [id]

## Examples

```
/api posts --crud
/api users/[id] --dynamic
/api admin/stats --auth
```

## Output

```
app/api/<route>/
├── route.ts           # GET, POST
└── [id]/route.ts      # GET, PATCH, DELETE (--dynamic)
```

## Templates

### Basic Route
```typescript
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const data = await getData();
  return NextResponse.json(data);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const created = await createData(body);
  return NextResponse.json(created, { status: 201 });
}
```

### Dynamic Route
```typescript
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const data = await getById(id);

  if (!data) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 });
  }

  return NextResponse.json(data);
}
```

### Protected Route
```typescript
import { auth } from '@/auth';

export async function GET() {
  const session = await auth();

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  return NextResponse.json({ data: 'protected' });
}
```

## $ARGUMENTS
