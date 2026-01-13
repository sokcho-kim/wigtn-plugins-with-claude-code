---
name: frontend-test
description: Master frontend testing with Jest and React Testing Library. Comprehensive testing patterns for components, hooks, and integration tests. Use when setting up testing infrastructure or writing component tests.
---

# Frontend Testing

Comprehensive testing patterns for React applications using Jest, React Testing Library, and modern testing best practices.

## When to Use This Skill

- Setting up Jest and React Testing Library in a new project
- Writing component tests with accessibility-focused queries
- Testing custom hooks and context providers
- Implementing integration tests for user flows
- Configuring test coverage thresholds
- Mocking Next.js features (router, Image, etc.)

## 1. Installation

```bash
npm install -D jest @testing-library/react @testing-library/jest-dom @testing-library/user-event jest-environment-jsdom @types/jest
```

## 2. Jest Configuration

### jest.config.js

```javascript
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/__tests__/**',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};

module.exports = createJestConfig(customJestConfig);
```

### jest.setup.js

```javascript
import '@testing-library/jest-dom';

// Mock Next.js router
jest.mock('next/navigation', () => ({
  useRouter() {
    return {
      push: jest.fn(),
      replace: jest.fn(),
      prefetch: jest.fn(),
      back: jest.fn(),
      pathname: '/',
      query: {},
      asPath: '/',
    };
  },
  useSearchParams() {
    return new URLSearchParams();
  },
  usePathname() {
    return '/';
  },
}));

// Mock Next.js Image
jest.mock('next/image', () => ({
  __esModule: true,
  default: (props) => {
    return <img {...props} />;
  },
}));
```

## 3. Component Testing Patterns

### Basic Component Test

```typescript
// src/components/ui/__tests__/button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from '../button';

describe('Button', () => {
  it('renders children correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('handles click events', async () => {
    const handleClick = jest.fn();
    const user = userEvent.setup();
    
    render(<Button onClick={handleClick}>Click me</Button>);
    
    await user.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('shows loading state', () => {
    render(<Button isLoading>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

## 4. Hook Testing

```typescript
// src/features/products/hooks/__tests__/use-products.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useProducts } from '../use-products';
import { productsApi } from '../../api/products-api';

jest.mock('../../api/products-api');

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });
  
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
};

describe('useProducts', () => {
  it('fetches products successfully', async () => {
    const mockProducts = [
      { id: '1', name: 'Product 1', price: 100 },
    ];
    
    (productsApi.getAll as jest.Mock).mockResolvedValue(mockProducts);
    
    const { result } = renderHook(() => useProducts(), {
      wrapper: createWrapper(),
    });
    
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    
    expect(result.current.data).toEqual(mockProducts);
  });
});
```

## Testing Checklist

- [ ] Jest configured
- [ ] Testing Library configured
- [ ] Test utilities created
- [ ] Mock factories created
- [ ] Component tests written
- [ ] Hook tests written
- [ ] API tests written
- [ ] Coverage threshold set

## Best Practices

```typescript
// ✅ Good: Descriptive test names
it('shows error message when email is invalid', () => {});

// ❌ Bad: Vague test names
it('works', () => {});

// ✅ Good: Test user behavior
await user.click(screen.getByRole('button', { name: /submit/i }));

// ❌ Bad: Test implementation
fireEvent.click(container.querySelector('.submit-button'));
```

## Commands

```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage
```

## Related Skills
- component-generator-agent.md
- data-flow-agent.md
- error-boundary-skill.md