# /hook - Custom Hook Generator

Generate reusable React hooks with TypeScript.

## Usage

```
/hook <hookName> [options]
```

## Options

- `--state`: State management hook
- `--fetch`: Data fetching hook (React Query)
- `--effect`: Side effect hook
- `--with-test`: Include test file

## Examples

```
/hook useToggle --state
/hook useUser --fetch
/hook useDebounce --effect --with-test
```

## Output

```
hooks/
├── <hookName>.ts
├── <hookName>.test.ts  # --with-test
└── index.ts
```

## Templates

### State Hook
```typescript
import { useState, useCallback } from 'react';

export function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return { value, toggle };
}
```

### Fetch Hook
```typescript
import { useQuery } from '@tanstack/react-query';

export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => fetchUser(id),
  });
}
```

## $ARGUMENTS
