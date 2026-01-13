---
name: api-response-types
description: Standardized API response type patterns for TypeScript. Use when defining API response structures.
---

# API Response Types

표준화된 API 응답 타입 패턴입니다.

## Standard Response Wrapper

### Success Response

```typescript
export interface ApiResponse<T> {
  success: true;
  data: T;
  message?: string;
  timestamp: string;
}

// 사용
type UserResponse = ApiResponse<UserResponseDto>;
```

### Error Response

```typescript
export interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
  timestamp: string;
}

// 통합 타입
export type ApiResult<T> = ApiResponse<T> | ApiError;
```

### Response Factory

```typescript
export const ApiResponseFactory = {
  success<T>(data: T, message?: string): ApiResponse<T> {
    return {
      success: true,
      data,
      message,
      timestamp: new Date().toISOString(),
    };
  },

  error(code: string, message: string, details?: Record<string, any>): ApiError {
    return {
      success: false,
      error: { code, message, details },
      timestamp: new Date().toISOString(),
    };
  },
};
```

## HTTP Status Specific Types

```typescript
// 201 Created
export interface CreatedResponse<T> extends ApiResponse<T> {
  location?: string;
}

// 204 No Content
export interface NoContentResponse {
  success: true;
}

// 400 Bad Request
export interface ValidationError extends ApiError {
  error: {
    code: 'VALIDATION_ERROR';
    message: string;
    details: {
      field: string;
      message: string;
    }[];
  };
}

// 401 Unauthorized
export interface UnauthorizedError extends ApiError {
  error: {
    code: 'UNAUTHORIZED';
    message: string;
  };
}

// 404 Not Found
export interface NotFoundError extends ApiError {
  error: {
    code: 'NOT_FOUND';
    message: string;
    resource?: string;
  };
}
```

## Paginated Response

```typescript
export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

// 사용
type UsersListResponse = PaginatedResponse<UserResponseDto>;
```

## Cursor-based Pagination

```typescript
export interface CursorPaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    cursor: string | null;
    nextCursor: string | null;
    hasMore: boolean;
    limit: number;
  };
}
```

## Async Operation Response

```typescript
// 202 Accepted
export interface AsyncOperationResponse {
  success: true;
  data: {
    operationId: string;
    status: 'pending' | 'processing';
    estimatedCompletion?: string;
    statusUrl: string;
  };
}

// Operation Status
export interface OperationStatusResponse {
  success: true;
  data: {
    operationId: string;
    status: 'pending' | 'processing' | 'completed' | 'failed';
    progress?: number;
    result?: unknown;
    error?: string;
  };
}
```

## Type Guards

```typescript
export function isApiSuccess<T>(response: ApiResult<T>): response is ApiResponse<T> {
  return response.success === true;
}

export function isApiError(response: ApiResult<unknown>): response is ApiError {
  return response.success === false;
}

// 사용
const result = await fetchUser(id);
if (isApiSuccess(result)) {
  console.log(result.data); // T 타입으로 추론
} else {
  console.error(result.error.message);
}
```

## Best Practices

1. **일관성**: 모든 API에 동일한 응답 구조 사용
2. **타입 가드**: 런타임 타입 체크 함수 제공
3. **에러 코드**: 문자열 상수로 에러 코드 관리
4. **타임스탬프**: 모든 응답에 ISO 형식 타임스탬프 포함
5. **제네릭**: 데이터 타입은 제네릭으로 유연하게
