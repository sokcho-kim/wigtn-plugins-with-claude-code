# Secure Storage for Sensitive Data

Use SecureStore for auth tokens and sensitive user data.

## SecureStore Wrapper

```typescript
// lib/secureStorage.ts
import * as SecureStore from 'expo-secure-store';

export const secureStorage = {
  async getItem(key: string): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(key);
    } catch (error) {
      console.error('SecureStore get error:', error);
      return null;
    }
  },

  async setItem(key: string, value: string): Promise<void> {
    try {
      await SecureStore.setItemAsync(key, value);
    } catch (error) {
      console.error('SecureStore set error:', error);
    }
  },

  async removeItem(key: string): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error('SecureStore delete error:', error);
    }
  },
};
```

## Auth Store with SecureStore

```typescript
// stores/useAuthStore.ts
import { create } from 'zustand';
import { secureStorage } from '@/lib/secureStorage';

interface AuthState {
  token: string | null;
  refreshToken: string | null;
  isHydrated: boolean;

  setTokens: (token: string, refreshToken: string) => Promise<void>;
  clearTokens: () => Promise<void>;
  hydrate: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  refreshToken: null,
  isHydrated: false,

  setTokens: async (token, refreshToken) => {
    await Promise.all([
      secureStorage.setItem('auth_token', token),
      secureStorage.setItem('refresh_token', refreshToken),
    ]);
    set({ token, refreshToken });
  },

  clearTokens: async () => {
    await Promise.all([
      secureStorage.removeItem('auth_token'),
      secureStorage.removeItem('refresh_token'),
    ]);
    set({ token: null, refreshToken: null });
  },

  hydrate: async () => {
    const [token, refreshToken] = await Promise.all([
      secureStorage.getItem('auth_token'),
      secureStorage.getItem('refresh_token'),
    ]);
    set({ token, refreshToken, isHydrated: true });
  },
}));
```

## App Initialization

```typescript
// App.tsx
function App() {
  const hydrate = useAuthStore((state) => state.hydrate);
  const isHydrated = useAuthStore((state) => state.isHydrated);

  useEffect(() => {
    hydrate();
  }, []);

  if (!isHydrated) {
    return <SplashScreen />;
  }

  return <Navigation />;
}
```

## Storage Comparison

| Data Type | Storage | Reason |
|-----------|---------|--------|
| Auth tokens | SecureStore | Encrypted in Keychain/Keystore |
| User preferences | MMKV | Fast, not sensitive |
| API cache | MMKV | Fast read/write |
| Session flags | MMKV | Fast access needed |
