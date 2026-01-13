# /page - Next.js Page Generator

Generate Next.js App Router pages with metadata and data fetching.

## Usage

```
/page <route-path> [options]
```

## Options

- `--dynamic`: Dynamic route [id]
- `--parallel`: Parallel routes
- `--with-loading`: Include loading.tsx
- `--with-error`: Include error.tsx

## Examples

```
/page dashboard
/page products/[id] --dynamic --with-loading
/page settings --with-error
```

## Output

```
app/<route>/
├── page.tsx
├── loading.tsx  # --with-loading
└── error.tsx    # --with-error
```

## Template

```typescript
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Page',
};

interface Props {
  params: Promise<{ id: string }>;
}

export default async function Page({ params }: Props) {
  const { id } = await params;
  return <main></main>;
}
```

## $ARGUMENTS
