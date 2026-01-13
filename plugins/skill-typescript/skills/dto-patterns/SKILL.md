---
name: dto-patterns
description: Data Transfer Object patterns for TypeScript. Use when creating request/response types for APIs.
---

# DTO Patterns

API 요청/응답을 위한 Data Transfer Object 패턴입니다.

## Basic DTO Structure

### Request DTOs

```typescript
// Create DTO - 생성에 필요한 필드만
export interface CreateUserDto {
  email: string;
  password: string;
  name: string;
}

// Update DTO - 모든 필드 선택적
export interface UpdateUserDto {
  email?: string;
  password?: string;
  name?: string;
}

// Partial Update - 명시적 Partial
export type PatchUserDto = Partial<CreateUserDto>;
```

### Response DTOs

```typescript
// 민감한 정보 제외
export interface UserResponseDto {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
  // password 제외
}

// 관계 포함
export interface UserWithPostsDto extends UserResponseDto {
  posts: PostResponseDto[];
}
```

## DTO Transformation

### Entity to DTO

```typescript
// 변환 함수
export function toUserResponseDto(user: User): UserResponseDto {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    createdAt: user.createdAt,
  };
}

// 배열 변환
export function toUserResponseDtos(users: User[]): UserResponseDto[] {
  return users.map(toUserResponseDto);
}
```

### Class Transformer (NestJS)

```typescript
import { Exclude, Expose, Transform } from 'class-transformer';

export class UserResponseDto {
  @Expose()
  id: string;

  @Expose()
  email: string;

  @Expose()
  name: string;

  @Exclude()
  password: string;

  @Transform(({ value }) => value.toISOString())
  @Expose()
  createdAt: string;
}
```

## Validation DTOs

### Class Validator (NestJS)

```typescript
import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  @MinLength(2)
  name: string;
}

export class UpdateUserDto {
  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @MinLength(8)
  @IsOptional()
  password?: string;

  @IsString()
  @MinLength(2)
  @IsOptional()
  name?: string;
}
```

## Pagination DTOs

```typescript
// 요청
export interface PaginationQueryDto {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

// 응답
export interface PaginatedResponseDto<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

// 사용
export type PaginatedUsersDto = PaginatedResponseDto<UserResponseDto>;
```

## Filter DTOs

```typescript
export interface UserFilterDto {
  search?: string;
  role?: UserRole;
  isActive?: boolean;
  createdAfter?: Date;
  createdBefore?: Date;
}
```

## Best Practices

1. **단일 책임**: 하나의 DTO는 하나의 목적
2. **불변성**: DTO는 가능하면 readonly
3. **검증 분리**: 입력 검증은 DTO 레벨에서
4. **변환 함수**: Entity <-> DTO 변환 명확히
5. **네이밍**: `Create*Dto`, `Update*Dto`, `*ResponseDto` 패턴 사용
