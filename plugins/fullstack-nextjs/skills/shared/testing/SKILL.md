---
name: testing
description: Testing patterns with Vitest, React Testing Library, and Playwright for Next.js applications.
---

# Testing Patterns

## When to Use

- Unit testing components and hooks
- Integration testing forms and user flows
- E2E testing critical user journeys
- Testing Server Components and Actions
- Regression testing after changes

## When NOT to Use

- Prototypes/MVPs → Focus on core features first
- Static content pages → Visual testing may suffice
- Third-party library internals → Trust library tests

## Decision Criteria

| Need | Solution |
|------|----------|
| Component logic | Vitest + React Testing Library |
| Hook behavior | `renderHook` from RTL |
| User interactions | `userEvent` from RTL |
| Full user flows | Playwright E2E |
| API route testing | Vitest with mocked request |
| Visual regression | Playwright screenshots |

## Best Practices

1. **Test behavior, not implementation** - Test what users see and do
2. **Use `getByRole` first** - Most accessible queries
3. **Avoid test IDs** - Use semantic queries instead
4. **Mock at boundaries** - API calls, not internal functions
5. **Keep tests focused** - One assertion per behavior

## Common Pitfalls

- ❌ Testing implementation details (internal state)
- ❌ Using `getByTestId` when semantic queries work
- ❌ Not waiting for async operations
- ❌ Mocking too much (losing confidence)
- ❌ Flaky tests from timing issues

---

## Setup

### Vitest Config

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    globals: true,
    css: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

### Setup File

```typescript
// vitest.setup.ts
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => {
  cleanup();
});
```

---

## Patterns

### Pattern 1: Component Unit Test

**Use when**: Testing component rendering and props

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();

    render(<Button onClick={handleClick}>Click</Button>);
    await user.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Disabled</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### Pattern 2: Hook Test

**Use when**: Testing custom hooks in isolation

```typescript
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useToggle } from './useToggle';

describe('useToggle', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useToggle());
    expect(result.current.value).toBe(false);
  });

  it('toggles value', () => {
    const { result } = renderHook(() => useToggle(false));

    act(() => {
      result.current.toggle();
    });

    expect(result.current.value).toBe(true);
  });

  it('accepts initial value', () => {
    const { result } = renderHook(() => useToggle(true));
    expect(result.current.value).toBe(true);
  });
});
```

### Pattern 3: Async Component Test

**Use when**: Components that fetch data

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { UserProfile } from './UserProfile';

vi.mock('@/lib/api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: '1', name: 'John' }),
}));

describe('UserProfile', () => {
  it('shows loading then user data', async () => {
    render(<UserProfile userId="1" />);

    // Loading state
    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    // Loaded state
    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument();
    });
  });
});
```

### Pattern 4: Form Integration Test

**Use when**: Testing form submission and validation

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  it('submits with valid data', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });

  it('shows validation errors on empty submit', async () => {
    const user = userEvent.setup();

    render(<LoginForm onSubmit={vi.fn()} />);

    await user.click(screen.getByRole('button', { name: /sign in/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
  });
});
```

### Pattern 5: Playwright E2E Config

**Use when**: End-to-end testing setup

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Pattern 6: E2E Test

**Use when**: Testing complete user journeys

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login');

    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('text=Welcome')).toBeVisible();
  });

  test('shows error for invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('input[name="email"]', 'wrong@example.com');
    await page.fill('input[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.locator('text=Invalid credentials')).toBeVisible();
  });
});
```

### Pattern 7: Page Object Pattern

**Use when**: Reusable page interactions in E2E

```typescript
// e2e/pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.locator('input[name="email"]');
    this.passwordInput = page.locator('input[name="password"]');
    this.submitButton = page.locator('button[type="submit"]');
    this.errorMessage = page.locator('[role="alert"]');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}

// Usage in tests
test('login with page object', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('test@example.com', 'password123');
  await expect(page).toHaveURL('/dashboard');
});
```

### Pattern 8: Mocking Patterns

**Use when**: Isolating tests from external dependencies

```typescript
import { vi } from 'vitest';

// Mock entire module
vi.mock('@/lib/api', () => ({
  fetchUsers: vi.fn(),
  createUser: vi.fn(),
}));

// Set mock implementation
import { fetchUsers } from '@/lib/api';
vi.mocked(fetchUsers).mockResolvedValue([{ id: '1', name: 'John' }]);

// Mock once for specific test
vi.mocked(fetchUsers).mockResolvedValueOnce([]);

// Mock Server Action
vi.mock('@/app/actions/user', () => ({
  createUser: vi.fn().mockResolvedValue({ success: true }),
}));

// Reset mocks between tests
beforeEach(() => {
  vi.clearAllMocks();
});
```
