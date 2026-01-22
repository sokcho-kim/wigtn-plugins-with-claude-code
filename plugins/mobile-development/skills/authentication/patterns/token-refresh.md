# Token Refresh & Session Management

Auto token refresh and session management for mobile apps.

## API Client with Token Refresh

```typescript
// lib/api.ts
import { useAuthStore } from '@/stores/useAuthStore';
import * as SecureStore from 'expo-secure-store';

const BASE_URL = process.env.EXPO_PUBLIC_API_URL;

async function refreshToken(): Promise<string | null> {
  const refreshToken = await SecureStore.getItemAsync('refresh_token');
  if (!refreshToken) return null;

  try {
    const response = await fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    if (!response.ok) {
      // Refresh token expired - logout
      useAuthStore.getState().logout();
      return null;
    }

    const data = await response.json();

    // Store new tokens
    await SecureStore.setItemAsync('access_token', data.accessToken);
    await SecureStore.setItemAsync('refresh_token', data.refreshToken);

    return data.accessToken;
  } catch (error) {
    useAuthStore.getState().logout();
    return null;
  }
}

export async function apiClient(
  endpoint: string,
  options: RequestInit = {}
): Promise<any> {
  let accessToken = await SecureStore.getItemAsync('access_token');

  const makeRequest = async (token: string | null) => {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    return fetch(`${BASE_URL}${endpoint}`, {
      ...options,
      headers,
    });
  };

  let response = await makeRequest(accessToken);

  // Handle 401 - try refresh
  if (response.status === 401) {
    accessToken = await refreshToken();
    if (accessToken) {
      response = await makeRequest(accessToken);
    }
  }

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'API request failed');
  }

  return response.json();
}
```

## useApiClient Hook

```typescript
// hooks/useApiClient.ts
import { useCallback } from 'react';
import { apiClient } from '@/lib/api';

export function useApiClient() {
  const get = useCallback((endpoint: string) => {
    return apiClient(endpoint, { method: 'GET' });
  }, []);

  const post = useCallback((endpoint: string, data: any) => {
    return apiClient(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }, []);

  const put = useCallback((endpoint: string, data: any) => {
    return apiClient(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }, []);

  const del = useCallback((endpoint: string) => {
    return apiClient(endpoint, { method: 'DELETE' });
  }, []);

  return { get, post, put, del };
}
```

## Session Timeout

```typescript
// hooks/useSessionTimeout.ts
import { useEffect, useRef } from 'react';
import { AppState, AppStateStatus } from 'react-native';
import { useAuthStore } from '@/stores/useAuthStore';

const SESSION_TIMEOUT = 30 * 60 * 1000; // 30 minutes

export function useSessionTimeout() {
  const { logout } = useAuthStore();
  const backgroundTime = useRef<number | null>(null);

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (state: AppStateStatus) => {
      if (state === 'background') {
        backgroundTime.current = Date.now();
      } else if (state === 'active' && backgroundTime.current) {
        const elapsed = Date.now() - backgroundTime.current;
        if (elapsed > SESSION_TIMEOUT) {
          logout();
        }
        backgroundTime.current = null;
      }
    });

    return () => subscription.remove();
  }, [logout]);
}
```
