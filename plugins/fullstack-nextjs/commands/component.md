# /component - React Component Generator

Generate production-ready React/Next.js components with TypeScript and accessibility.

## Usage

```
/component <ComponentName> [options]
```

## Options

- `--client`: Client Component (default: Server)
- `--form`: Form with validation
- `--list`: List/table component
- `--modal`: Modal/dialog
- `--with-test`: Include test file

## Examples

```
/component Button --client
/component UserProfile
/component LoginForm --form --with-test
/component DataTable --list
```

## Output

```
components/<Name>/
├── <Name>.tsx
├── <Name>.test.tsx  # --with-test
└── index.ts
```

## Templates

### Server Component
```typescript
interface Props {}

export async function Name({ }: Props) {
  return <div></div>;
}
```

### Client Component
```typescript
'use client';
import { useState } from 'react';

interface Props {}

export function Name({ }: Props) {
  return <div></div>;
}
```

## $ARGUMENTS
