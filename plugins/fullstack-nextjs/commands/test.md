# /test - Test Generator

Generate tests for components, hooks, and API routes.

## Usage

```
/test <target> [options]
```

## Options

- `--unit`: Unit test (Vitest + RTL)
- `--e2e`: E2E test (Playwright)
- `--integration`: Integration test
- `--coverage`: Include coverage setup

## Examples

```
/test Button --unit
/test useAuth --unit
/test auth --e2e
/test LoginForm --integration
```

## Output

```
# Unit test
<target>.test.tsx

# E2E test
e2e/<target>.spec.ts
```

## Templates

### Component Test
```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Component } from './Component';

describe('Component', () => {
  it('renders correctly', () => {
    render(<Component />);
    expect(screen.getByRole('...')).toBeInTheDocument();
  });

  it('handles interaction', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();

    render(<Component onClick={onClick} />);
    await user.click(screen.getByRole('button'));

    expect(onClick).toHaveBeenCalled();
  });
});
```

### Hook Test
```typescript
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useHook } from './useHook';

describe('useHook', () => {
  it('returns initial value', () => {
    const { result } = renderHook(() => useHook());
    expect(result.current.value).toBeDefined();
  });

  it('updates correctly', () => {
    const { result } = renderHook(() => useHook());
    act(() => { result.current.update(); });
    expect(result.current.value).toBe(expected);
  });
});
```

### E2E Test
```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature', () => {
  test('user flow works', async ({ page }) => {
    await page.goto('/path');
    await page.fill('input[name="field"]', 'value');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/success');
  });
});
```

## $ARGUMENTS
