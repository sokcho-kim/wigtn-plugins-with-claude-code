---
name: api-integration
description: Master API integration with fetch, Axios, TanStack Query, error handling, retry logic, and request/response interceptors. Use when building API clients, handling external APIs, or implementing data fetching.
---

# API Integration

Comprehensive patterns for integrating external APIs with modern error handling, retry logic, caching, and type safety using fetch, Axios, and TanStack Query.

## When to Use This Skill

- Setting up API clients with proper error handling
- Implementing retry logic and exponential backoff
- Creating type-safe API interfaces with TypeScript
- Handling authentication tokens and refresh flows
- Building request/response interceptors
- Implementing caching strategies
- Setting up optimistic updates and mutations

## Core Concepts

### 1. API Client Options

| Library | Bundle Size | Features | When to Use |
|---------|-------------|----------|-------------|
| **fetch** | 0kb (native) | Basic, flexible | Simple requests, modern browsers |
| **Axios** | 13kb | Interceptors, auto-transform | Complex apps, older browser support |
| **TanStack Query** | 13kb | Caching, background sync | Data-heavy apps, real-time updates |

### 2. Error Handling Strategies

```
Network Errors → Retry with exponential backoff
4xx Errors → Show user error, don't retry
5xx Errors → Retry up to N times
Timeout → Retry with longer timeout
```

## Quick Start

### Basic Fetch API Client

```typescript
// lib/api/client.ts
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "https://api.example.com";

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: unknown
  ) {
    super(message);
    this.name = "ApiError";
  }
}

async function request<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;

  const config: RequestInit = {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options?.headers,
    },
  };

  try {
    const response = await fetch(url, config);

    // Handle non-2xx responses
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new ApiError(
        errorData.message || `HTTP ${response.status}: ${response.statusText}`,
        response.status,
        errorData
      );
    }

    // Handle 204 No Content
    if (response.status === 204) {
      return null as T;
    }

    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) {
      throw error;
    }
    // Network error or other unexpected error
    throw new ApiError("Network error occurred", 0, error);
  }
}

export const api = {
  get: <T>(endpoint: string, options?: RequestInit) =>
    request<T>(endpoint, { ...options, method: "GET" }),

  post: <T>(endpoint: string, data?: unknown, options?: RequestInit) =>
    request<T>(endpoint, {
      ...options,
      method: "POST",
      body: JSON.stringify(data),
    }),

  put: <T>(endpoint: string, data?: unknown, options?: RequestInit) =>
    request<T>(endpoint, {
      ...options,
      method: "PUT",
      body: JSON.stringify(data),
    }),

  patch: <T>(endpoint: string, data?: unknown, options?: RequestInit) =>
    request<T>(endpoint, {
      ...options,
      method: "PATCH",
      body: JSON.stringify(data),
    }),

  delete: <T>(endpoint: string, options?: RequestInit) =>
    request<T>(endpoint, { ...options, method: "DELETE" }),
};

// Usage
interface User {
  id: string;
  name: string;
  email: string;
}

const user = await api.get<User>("/users/123");
const newUser = await api.post<User>("/users", { name: "John", email: "john@example.com" });
```

## Patterns

### Pattern 1: Advanced Fetch Client with Interceptors

```typescript
// lib/api/advanced-client.ts
type RequestInterceptor = (config: RequestInit & { url: string }) => Promise<RequestInit & { url: string }>;
type ResponseInterceptor = (response: Response) => Promise<Response>;

class ApiClient {
  private baseURL: string;
  private requestInterceptors: RequestInterceptor[] = [];
  private responseInterceptors: ResponseInterceptor[] = [];

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  addRequestInterceptor(interceptor: RequestInterceptor) {
    this.requestInterceptors.push(interceptor);
  }

  addResponseInterceptor(interceptor: ResponseInterceptor) {
    this.responseInterceptors.push(interceptor);
  }

  private async applyRequestInterceptors(
    config: RequestInit & { url: string }
  ): Promise<RequestInit & { url: string }> {
    let result = config;
    for (const interceptor of this.requestInterceptors) {
      result = await interceptor(result);
    }
    return result;
  }

  private async applyResponseInterceptors(response: Response): Promise<Response> {
    let result = response;
    for (const interceptor of this.responseInterceptors) {
      result = await interceptor(result);
    }
    return result;
  }

  async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    let config = {
      url: `${this.baseURL}${endpoint}`,
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
    };

    // Apply request interceptors
    config = await this.applyRequestInterceptors(config);

    // Make request
    let response = await fetch(config.url, config);

    // Apply response interceptors
    response = await this.applyResponseInterceptors(response);

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new ApiError(
        errorData.message || `HTTP ${response.status}`,
        response.status,
        errorData
      );
    }

    if (response.status === 204) return null as T;
    return await response.json();
  }

  get<T>(endpoint: string, options?: RequestInit) {
    return this.request<T>(endpoint, { ...options, method: "GET" });
  }

  post<T>(endpoint: string, data?: unknown, options?: RequestInit) {
    return this.request<T>(endpoint, {
      ...options,
      method: "POST",
      body: JSON.stringify(data),
    });
  }

  put<T>(endpoint: string, data?: unknown, options?: RequestInit) {
    return this.request<T>(endpoint, {
      ...options,
      method: "PUT",
      body: JSON.stringify(data),
    });
  }

  delete<T>(endpoint: string, options?: RequestInit) {
    return this.request<T>(endpoint, { ...options, method: "DELETE" });
  }
}

// Create client
export const apiClient = new ApiClient(
  process.env.NEXT_PUBLIC_API_URL || "https://api.example.com"
);

// Add auth token interceptor
apiClient.addRequestInterceptor(async (config) => {
  const token = await getAuthToken(); // Your token retrieval logic
  if (token) {
    config.headers = {
      ...config.headers,
      Authorization: `Bearer ${token}`,
    };
  }
  return config;
});

// Add retry interceptor for 5xx errors
apiClient.addResponseInterceptor(async (response) => {
  if (response.status >= 500 && response.status < 600) {
    // Retry logic here
    console.warn(`Server error ${response.status}, retrying...`);
  }
  return response;
});
```

### Pattern 2: Retry Logic with Exponential Backoff

```typescript
// lib/api/retry.ts
interface RetryOptions {
  maxRetries?: number;
  baseDelay?: number;
  maxDelay?: number;
  retryableStatuses?: number[];
}

const DEFAULT_RETRY_OPTIONS: RetryOptions = {
  maxRetries: 3,
  baseDelay: 1000, // 1 second
  maxDelay: 10000, // 10 seconds
  retryableStatuses: [408, 429, 500, 502, 503, 504],
};

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function calculateBackoff(attempt: number, baseDelay: number, maxDelay: number): number {
  const exponentialDelay = baseDelay * Math.pow(2, attempt);
  const jitter = Math.random() * 0.1 * exponentialDelay; // Add 10% jitter
  return Math.min(exponentialDelay + jitter, maxDelay);
}

export async function fetchWithRetry<T>(
  url: string,
  options: RequestInit = {},
  retryOptions: RetryOptions = {}
): Promise<T> {
  const config = { ...DEFAULT_RETRY_OPTIONS, ...retryOptions };
  let lastError: Error;

  for (let attempt = 0; attempt <= config.maxRetries!; attempt++) {
    try {
      const response = await fetch(url, options);

      // If response is ok, return it
      if (response.ok) {
        if (response.status === 204) return null as T;
        return await response.json();
      }

      // Check if status is retryable
      if (!config.retryableStatuses!.includes(response.status)) {
        const errorData = await response.json().catch(() => ({}));
        throw new ApiError(
          errorData.message || `HTTP ${response.status}`,
          response.status,
          errorData
        );
      }

      // If this is the last attempt, throw error
      if (attempt === config.maxRetries) {
        const errorData = await response.json().catch(() => ({}));
        throw new ApiError(
          `Failed after ${config.maxRetries} retries`,
          response.status,
          errorData
        );
      }

      // Wait before retrying
      const backoffDelay = calculateBackoff(
        attempt,
        config.baseDelay!,
        config.maxDelay!
      );
      console.log(`Retry attempt ${attempt + 1} after ${backoffDelay}ms`);
      await delay(backoffDelay);
    } catch (error) {
      lastError = error as Error;

      // Don't retry on ApiError unless it's a retryable status
      if (
        error instanceof ApiError &&
        !config.retryableStatuses!.includes(error.status)
      ) {
        throw error;
      }

      // If this is the last attempt, throw error
      if (attempt === config.maxRetries) {
        throw lastError;
      }

      // Wait before retrying
      const backoffDelay = calculateBackoff(
        attempt,
        config.baseDelay!,
        config.maxDelay!
      );
      console.log(`Network error, retry attempt ${attempt + 1} after ${backoffDelay}ms`);
      await delay(backoffDelay);
    }
  }

  throw lastError!;
}

// Usage
const data = await fetchWithRetry<User>(
  "https://api.example.com/users/123",
  {
    method: "GET",
    headers: { "Content-Type": "application/json" },
  },
  {
    maxRetries: 5,
    baseDelay: 500,
    retryableStatuses: [408, 429, 500, 502, 503, 504],
  }
);
```

### Pattern 3: Axios Client with Interceptors

```typescript
// lib/api/axios-client.ts
import axios, { AxiosError, AxiosRequestConfig, AxiosResponse } from "axios";

const axiosClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "https://api.example.com",
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
  },
});

// Request interceptor - add auth token
axiosClient.interceptors.request.use(
  async (config) => {
    const token = await getAuthToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor - handle errors and refresh token
axiosClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as AxiosRequestConfig & {
      _retry?: boolean;
    };

    // Handle 401 Unauthorized - refresh token
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const newToken = await refreshAuthToken();
        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
        }
        return axiosClient(originalRequest);
      } catch (refreshError) {
        // Redirect to login
        window.location.href = "/login";
        return Promise.reject(refreshError);
      }
    }

    // Transform error
    const apiError = new ApiError(
      error.response?.data?.message || error.message,
      error.response?.status || 0,
      error.response?.data
    );

    return Promise.reject(apiError);
  }
);

export default axiosClient;

// API service layer
export const userApi = {
  getUser: (id: string) => axiosClient.get<User>(`/users/${id}`),
  createUser: (data: CreateUserData) => axiosClient.post<User>("/users", data),
  updateUser: (id: string, data: Partial<User>) =>
    axiosClient.put<User>(`/users/${id}`, data),
  deleteUser: (id: string) => axiosClient.delete(`/users/${id}`),
};
```

### Pattern 4: TanStack Query Integration

```typescript
// lib/api/query-client.ts
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
    },
  },
});

// app/providers.tsx
"use client";

import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "@/lib/api/query-client";

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}

// hooks/use-users.ts
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "@/lib/api/client";

interface User {
  id: string;
  name: string;
  email: string;
}

// Query keys factory
export const userKeys = {
  all: ["users"] as const,
  lists: () => [...userKeys.all, "list"] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, "detail"] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// Queries
export function useUsers(filters: UserFilters = {}) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => api.get<User[]>(`/users?${new URLSearchParams(filters)}`),
    staleTime: 5 * 60 * 1000,
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => api.get<User>(`/users/${id}`),
    enabled: !!id,
  });
}

// Mutations
export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserData) => api.post<User>("/users", data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<User> }) =>
      api.put<User>(`/users/${id}`, data),
    onMutate: async ({ id, data }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: userKeys.detail(id) });

      // Snapshot previous value
      const previousUser = queryClient.getQueryData(userKeys.detail(id));

      // Optimistically update
      queryClient.setQueryData(userKeys.detail(id), (old: User | undefined) => ({
        ...old!,
        ...data,
      }));

      return { previousUser };
    },
    onError: (err, { id }, context) => {
      // Rollback on error
      if (context?.previousUser) {
        queryClient.setQueryData(userKeys.detail(id), context.previousUser);
      }
    },
    onSettled: (data, error, { id }) => {
      queryClient.invalidateQueries({ queryKey: userKeys.detail(id) });
    },
  });
}

// Usage in component
"use client";

export function UserList() {
  const { data: users, isLoading, error } = useUsers({ active: true });
  const createUser = useCreateUser();

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  const handleCreate = async () => {
    await createUser.mutateAsync({
      name: "New User",
      email: "new@example.com",
    });
  };

  return (
    <div>
      <button onClick={handleCreate}>Create User</button>
      <ul>
        {users?.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Pattern 5: Type-Safe API with Zod Validation

```typescript
// lib/api/type-safe-client.ts
import { z } from "zod";

// Define schemas
const userSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["user", "admin"]),
  createdAt: z.string().datetime(),
});

const userListResponseSchema = z.object({
  data: z.array(userSchema),
  total: z.number(),
  page: z.number(),
  perPage: z.number(),
});

type User = z.infer<typeof userSchema>;
type UserListResponse = z.infer<typeof userListResponseSchema>;

// Type-safe fetch with validation
async function fetchWithValidation<T>(
  url: string,
  schema: z.ZodSchema<T>,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(url, options);

  if (!response.ok) {
    throw new ApiError(`HTTP ${response.status}`, response.status);
  }

  const data = await response.json();

  // Validate response
  const result = schema.safeParse(data);

  if (!result.success) {
    console.error("Validation error:", result.error);
    throw new Error(`Invalid API response: ${result.error.message}`);
  }

  return result.data;
}

// Type-safe API functions
export const typeSafeApi = {
  getUsers: async (page: number = 1): Promise<UserListResponse> => {
    return fetchWithValidation(
      `https://api.example.com/users?page=${page}`,
      userListResponseSchema
    );
  },

  getUser: async (id: string): Promise<User> => {
    return fetchWithValidation(
      `https://api.example.com/users/${id}`,
      userSchema
    );
  },

  createUser: async (data: Omit<User, "id" | "createdAt">): Promise<User> => {
    return fetchWithValidation(
      "https://api.example.com/users",
      userSchema,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      }
    );
  },
};
```

### Pattern 6: Request Cancellation

```typescript
// hooks/use-cancellable-fetch.ts
import { useEffect, useRef } from "react";

export function useCancellableFetch() {
  const abortControllerRef = useRef<AbortController | null>(null);

  useEffect(() => {
    return () => {
      // Cleanup on unmount
      abortControllerRef.current?.abort();
    };
  }, []);

  const fetchWithCancel = async <T,>(
    url: string,
    options: RequestInit = {}
  ): Promise<T> => {
    // Cancel previous request if exists
    abortControllerRef.current?.abort();

    // Create new abort controller
    const abortController = new AbortController();
    abortControllerRef.current = abortController;

    try {
      const response = await fetch(url, {
        ...options,
        signal: abortController.signal,
      });

      if (!response.ok) {
        throw new ApiError(`HTTP ${response.status}`, response.status);
      }

      return await response.json();
    } catch (error) {
      if (error instanceof Error && error.name === "AbortError") {
        console.log("Request was cancelled");
        throw new Error("Request cancelled");
      }
      throw error;
    }
  };

  const cancel = () => {
    abortControllerRef.current?.abort();
  };

  return { fetchWithCancel, cancel };
}

// Usage
function SearchComponent() {
  const { fetchWithCancel } = useCancellableFetch();
  const [results, setResults] = useState([]);

  const handleSearch = async (query: string) => {
    try {
      const data = await fetchWithCancel<SearchResults>(
        `/api/search?q=${query}`
      );
      setResults(data.results);
    } catch (error) {
      if (error.message !== "Request cancelled") {
        console.error("Search failed:", error);
      }
    }
  };

  return <input onChange={(e) => handleSearch(e.target.value)} />;
}
```

## Error Handling Best Practices

### Comprehensive Error Handler

```typescript
// lib/api/error-handler.ts
export function handleApiError(error: unknown): string {
  if (error instanceof ApiError) {
    switch (error.status) {
      case 400:
        return "Invalid request. Please check your input.";
      case 401:
        return "You are not authenticated. Please log in.";
      case 403:
        return "You don't have permission to access this resource.";
      case 404:
        return "The requested resource was not found.";
      case 429:
        return "Too many requests. Please try again later.";
      case 500:
        return "Server error. Please try again later.";
      default:
        return error.message || "An unexpected error occurred.";
    }
  }

  if (error instanceof Error) {
    if (error.message.includes("NetworkError")) {
      return "Network error. Please check your connection.";
    }
    return error.message;
  }

  return "An unexpected error occurred.";
}

// Usage in component
try {
  await api.post("/users", userData);
} catch (error) {
  const errorMessage = handleApiError(error);
  toast.error(errorMessage);
}
```

## Best Practices

### Do's

- **Use TypeScript** - Type-safe requests and responses
- **Validate responses** - Use Zod or similar for runtime validation
- **Implement retry logic** - For transient failures
- **Handle errors gracefully** - Show user-friendly messages
- **Use interceptors** - For auth tokens, logging, error handling
- **Cancel requests** - When component unmounts or new request starts
- **Cache responses** - Use TanStack Query or SWR for caching

### Don'ts

- **Don't expose API keys** - Use environment variables
- **Don't ignore errors** - Always handle errors properly
- **Don't retry 4xx errors** - These are client errors, won't succeed on retry
- **Don't fetch in loops** - Use batch endpoints or parallel requests
- **Don't forget timeout** - Set reasonable timeouts for all requests
- **Don't mutate cached data** - Use immutable updates
- **Don't skip loading states** - Always show loading indicators

## Security Checklist

- [ ] API keys stored in environment variables
- [ ] HTTPS used for all requests
- [ ] Authentication tokens stored securely
- [ ] CORS configured properly
- [ ] Rate limiting implemented
- [ ] Input validation on client and server
- [ ] Sensitive data not logged
- [ ] Request timeout configured

## Resources

- [Fetch API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
- [Axios Documentation](https://axios-http.com/)
- [TanStack Query Documentation](https://tanstack.com/query)
- [Zod Documentation](https://zod.dev/)
