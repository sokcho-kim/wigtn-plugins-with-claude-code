---
name: mobile-testing
description: Master mobile testing with Jest, React Native Testing Library, Detox for E2E, and Maestro for UI automation. Covers unit tests, integration tests, and end-to-end testing patterns.
---

# Mobile App Testing

Comprehensive testing guide for React Native applications covering unit tests, integration tests, and end-to-end testing.

## When to Use This Skill

- Setting up testing infrastructure
- Writing unit tests for components and hooks
- Integration testing with mocked APIs
- E2E testing with Detox or Maestro
- Snapshot testing for UI consistency

## Core Concepts

### 1. Testing Pyramid (Mobile)

```
        /\
       /E2E\         Detox, Maestro (few, slow)
      /------\
     /Integration\   RNTL + MSW (some, medium)
    /--------------\
   /    Unit Tests   \  Jest (many, fast)
  /____________________\
```

### 2. Testing Tools

| Tool | Type | Best For |
|------|------|----------|
| **Jest** | Unit | Functions, hooks, pure logic |
| **RNTL** | Integration | Component testing |
| **Detox** | E2E | Full app flows (local) |
| **Maestro** | E2E | UI automation (CI/CD) |

## Quick Start

### Jest + RNTL Setup

```bash
npm install --save-dev @testing-library/react-native @testing-library/jest-native jest-expo
```

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  collectCoverageFrom: [
    '**/*.{ts,tsx}',
    '!**/node_modules/**',
    '!**/coverage/**',
    '!**/*.d.ts',
  ],
};
```

```typescript
// jest.setup.js
import '@testing-library/jest-native/extend-expect';

// Mock expo modules
jest.mock('expo-font');
jest.mock('expo-asset');
jest.mock('expo-constants', () => ({
  expoConfig: { extra: {} },
}));

// Mock react-native-reanimated
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');
  Reanimated.default.call = () => {};
  return Reanimated;
});

// Mock expo-router
jest.mock('expo-router', () => ({
  router: {
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  },
  useLocalSearchParams: () => ({}),
  useSegments: () => [],
  Link: 'Link',
}));

// Silence the warning: Animated: `useNativeDriver` is not supported
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

// Mock MMKV
jest.mock('react-native-mmkv', () => ({
  MMKV: jest.fn(() => ({
    getString: jest.fn(),
    set: jest.fn(),
    delete: jest.fn(),
    contains: jest.fn(),
  })),
}));
```

## Patterns

### Pattern 1: Component Testing

```typescript
// components/__tests__/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { Button } from '../Button';

describe('Button', () => {
  it('renders correctly with text', () => {
    render(<Button>Press me</Button>);

    expect(screen.getByText('Press me')).toBeOnTheScreen();
  });

  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    render(<Button onPress={onPress}>Press me</Button>);

    fireEvent.press(screen.getByText('Press me'));

    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('shows loading state', () => {
    render(<Button loading>Press me</Button>);

    expect(screen.getByTestId('activity-indicator')).toBeOnTheScreen();
    expect(screen.queryByText('Press me')).not.toBeOnTheScreen();
  });

  it('is disabled when loading', () => {
    const onPress = jest.fn();
    render(
      <Button loading onPress={onPress}>
        Press me
      </Button>
    );

    fireEvent.press(screen.getByRole('button'));

    expect(onPress).not.toHaveBeenCalled();
  });

  it('applies variant styles correctly', () => {
    render(<Button variant="destructive">Delete</Button>);

    const button = screen.getByRole('button');
    expect(button).toHaveStyle({ backgroundColor: '#EF4444' });
  });
});

// Test with context providers
import { render } from '@testing-library/react-native';
import { ThemeProvider } from '@/providers/ThemeProvider';
import { AuthProvider } from '@/providers/AuthProvider';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

function renderWithProviders(ui: React.ReactElement, options = {}) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return render(
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <ThemeProvider>{ui}</ThemeProvider>
      </AuthProvider>
    </QueryClientProvider>,
    options
  );
}

// Usage
describe('ProfileScreen', () => {
  it('shows user information', () => {
    renderWithProviders(<ProfileScreen />);

    expect(screen.getByText('John Doe')).toBeOnTheScreen();
  });
});
```

### Pattern 2: Hook Testing

```typescript
// hooks/__tests__/useCounter.test.ts
import { renderHook, act } from '@testing-library/react-native';
import { useCounter } from '../useCounter';

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { result } = renderHook(() => useCounter());

    expect(result.current.count).toBe(0);
  });

  it('initializes with custom value', () => {
    const { result } = renderHook(() => useCounter(10));

    expect(result.current.count).toBe(10);
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrements count', () => {
    const { result } = renderHook(() => useCounter(5));

    act(() => {
      result.current.decrement();
    });

    expect(result.current.count).toBe(4);
  });
});

// Testing async hooks
import { renderHook, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useUser } from '../useUser';

const wrapper = ({ children }: { children: React.ReactNode }) => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('useUser', () => {
  beforeEach(() => {
    global.fetch = jest.fn();
  });

  it('fetches user data', async () => {
    const mockUser = { id: '1', name: 'John Doe' };
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockUser),
    });

    const { result } = renderHook(() => useUser('1'), { wrapper });

    expect(result.current.isLoading).toBe(true);

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.data).toEqual(mockUser);
  });

  it('handles error', async () => {
    (global.fetch as jest.Mock).mockRejectedValueOnce(new Error('Failed'));

    const { result } = renderHook(() => useUser('1'), { wrapper });

    await waitFor(() => {
      expect(result.current.isError).toBe(true);
    });
  });
});
```

### Pattern 3: Mocking APIs with MSW

```bash
npm install --save-dev msw
```

```typescript
// mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    });
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({
      id: '123',
      ...body,
    }, { status: 201 });
  }),

  http.get('/api/posts', () => {
    return HttpResponse.json([
      { id: '1', title: 'First Post' },
      { id: '2', title: 'Second Post' },
    ]);
  }),
];

// mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// jest.setup.js
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// In tests, override handlers as needed
import { server } from '@/mocks/server';
import { http, HttpResponse } from 'msw';

describe('UserProfile', () => {
  it('shows error state', async () => {
    server.use(
      http.get('/api/users/:id', () => {
        return new HttpResponse(null, { status: 500 });
      })
    );

    renderWithProviders(<UserProfile userId="1" />);

    await waitFor(() => {
      expect(screen.getByText('Failed to load user')).toBeOnTheScreen();
    });
  });
});
```

### Pattern 4: Snapshot Testing

```typescript
// components/__tests__/Card.test.tsx
import { render } from '@testing-library/react-native';
import { Card, CardHeader, CardTitle, CardContent } from '../Card';

describe('Card', () => {
  it('matches snapshot', () => {
    const tree = render(
      <Card>
        <CardHeader>
          <CardTitle>Test Card</CardTitle>
        </CardHeader>
        <CardContent>
          <Text>Card content here</Text>
        </CardContent>
      </Card>
    );

    expect(tree.toJSON()).toMatchSnapshot();
  });

  it('matches snapshot with different variant', () => {
    const tree = render(
      <Card variant="outlined">
        <CardTitle>Outlined Card</CardTitle>
      </Card>
    );

    expect(tree.toJSON()).toMatchSnapshot();
  });
});

// Update snapshots: npm test -- -u
```

### Pattern 5: E2E Testing with Detox

```bash
npm install --save-dev detox jest-circus
npx detox init
```

```javascript
// .detoxrc.js
module.exports = {
  testRunner: {
    args: {
      $0: 'jest',
      config: 'e2e/jest.config.js',
    },
    jest: {
      setupTimeout: 120000,
    },
  },
  apps: {
    'ios.debug': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/MyApp.app',
      build: 'xcodebuild -workspace ios/MyApp.xcworkspace -scheme MyApp -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build',
    },
    'android.debug': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/debug/app-debug.apk',
      build: 'cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug && cd ..',
    },
  },
  devices: {
    simulator: {
      type: 'ios.simulator',
      device: { type: 'iPhone 15' },
    },
    emulator: {
      type: 'android.emulator',
      device: { avdName: 'Pixel_5_API_34' },
    },
  },
  configurations: {
    'ios.sim.debug': {
      device: 'simulator',
      app: 'ios.debug',
    },
    'android.emu.debug': {
      device: 'emulator',
      app: 'android.debug',
    },
  },
};

// e2e/login.test.ts
describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show login screen', async () => {
    await expect(element(by.text('Sign In'))).toBeVisible();
    await expect(element(by.id('email-input'))).toBeVisible();
    await expect(element(by.id('password-input'))).toBeVisible();
  });

  it('should login successfully', async () => {
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();

    await waitFor(element(by.text('Welcome')))
      .toBeVisible()
      .withTimeout(5000);
  });

  it('should show error for invalid credentials', async () => {
    await element(by.id('email-input')).typeText('wrong@example.com');
    await element(by.id('password-input')).typeText('wrongpassword');
    await element(by.id('login-button')).tap();

    await waitFor(element(by.text('Invalid credentials')))
      .toBeVisible()
      .withTimeout(3000);
  });
});

// Run: npx detox test --configuration ios.sim.debug
```

### Pattern 6: E2E Testing with Maestro

```yaml
# .maestro/login.yaml
appId: com.myapp.app
---
- launchApp

- assertVisible: "Sign In"

# Test successful login
- tapOn: "Email"
- inputText: "test@example.com"

- tapOn: "Password"
- inputText: "password123"

- tapOn: "Sign In Button"

- assertVisible: "Welcome"

# .maestro/navigation.yaml
appId: com.myapp.app
---
- launchApp:
    clearState: true

# Login first
- runFlow: login.yaml

# Test tab navigation
- tapOn:
    id: "tab-explore"

- assertVisible: "Explore"

- tapOn:
    id: "tab-profile"

- assertVisible: "Profile"

# Test back navigation
- back

- assertVisible: "Explore"

# .maestro/form-validation.yaml
appId: com.myapp.app
---
- launchApp

- tapOn: "Email"
- inputText: "invalid-email"

- tapOn: "Password"
- inputText: "123"

- tapOn: "Sign In Button"

# Should show validation errors
- assertVisible: "Invalid email address"
- assertVisible: "Password must be at least 8 characters"

# Run: maestro test .maestro/
```

### Pattern 7: Testing Navigation

```typescript
// __tests__/navigation.test.tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { HomeScreen } from '../screens/HomeScreen';
import { DetailsScreen } from '../screens/DetailsScreen';

const Stack = createNativeStackNavigator();

function MockedNavigator({ initialRouteName = 'Home' }) {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName={initialRouteName}>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Details" component={DetailsScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

describe('Navigation', () => {
  it('navigates from Home to Details', async () => {
    render(<MockedNavigator />);

    // Start on Home
    expect(screen.getByText('Home Screen')).toBeOnTheScreen();

    // Navigate to Details
    fireEvent.press(screen.getByText('Go to Details'));

    // Should be on Details
    await waitFor(() => {
      expect(screen.getByText('Details Screen')).toBeOnTheScreen();
    });
  });

  it('passes params correctly', async () => {
    render(<MockedNavigator />);

    fireEvent.press(screen.getByText('View Item 123'));

    await waitFor(() => {
      expect(screen.getByText('Item ID: 123')).toBeOnTheScreen();
    });
  });
});

// For Expo Router
jest.mock('expo-router', () => ({
  router: {
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  },
  useLocalSearchParams: jest.fn(() => ({ id: '123' })),
  Link: ({ children }: { children: React.ReactNode }) => children,
}));

import { router } from 'expo-router';

describe('Home Screen Navigation', () => {
  it('navigates to details on item press', () => {
    render(<HomeScreen />);

    fireEvent.press(screen.getByText('View Details'));

    expect(router.push).toHaveBeenCalledWith('/details/123');
  });
});
```

## Best Practices

### Do's

- **Test user behavior** - Not implementation details
- **Use testID** - For reliable element selection
- **Mock external dependencies** - APIs, native modules
- **Write isolated tests** - Each test independent
- **Test error states** - Not just happy paths

### Don'ts

- **Don't test implementation details** - Test outcomes
- **Don't over-mock** - Test real integrations when possible
- **Don't ignore flaky tests** - Fix or remove them
- **Don't skip E2E** - Critical paths need E2E coverage
- **Don't test library code** - Trust your dependencies

## Test Coverage Targets

| Type | Coverage Target |
|------|----------------|
| Unit | 80%+ |
| Integration | 60%+ |
| E2E | Critical paths |

## Resources

- [React Native Testing Library](https://callstack.github.io/react-native-testing-library/)
- [Detox Documentation](https://wix.github.io/Detox/)
- [Maestro Documentation](https://maestro.mobile.dev/)
- [MSW Documentation](https://mswjs.io/)
