---
name: utility-types
description: TypeScript utility types patterns for advanced type manipulation. Use when creating generic types, mapped types, or conditional types.
---

# TypeScript Utility Types

고급 타입 조작을 위한 TypeScript 유틸리티 타입 패턴입니다.

## Built-in Utility Types

### Partial & Required

```typescript
// 모든 속성을 선택적으로
type PartialUser = Partial<User>;

// 모든 속성을 필수로
type RequiredUser = Required<User>;

// 특정 속성만 선택적으로
type PartialPick<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
```

### Pick & Omit

```typescript
// 특정 속성만 선택
type UserPreview = Pick<User, 'id' | 'name'>;

// 특정 속성 제외
type UserWithoutPassword = Omit<User, 'password'>;
```

### Record & Extract & Exclude

```typescript
// 키-값 타입 생성
type UserRoles = Record<string, Role>;

// 유니온에서 특정 타입 추출
type StringOrNumber = Extract<string | number | boolean, string | number>;

// 유니온에서 특정 타입 제외
type OnlyString = Exclude<string | number, number>;
```

## Custom Utility Types

### DeepPartial

```typescript
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// 사용
interface Config {
  database: {
    host: string;
    port: number;
  };
}

type PartialConfig = DeepPartial<Config>;
```

### NonNullable Deep

```typescript
type DeepNonNullable<T> = {
  [P in keyof T]: T[P] extends object
    ? DeepNonNullable<NonNullable<T[P]>>
    : NonNullable<T[P]>;
};
```

### Readonly Deep

```typescript
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};
```

### Optional Keys

```typescript
type OptionalKeys<T> = {
  [K in keyof T]-?: undefined extends T[K] ? K : never;
}[keyof T];

type RequiredKeys<T> = {
  [K in keyof T]-?: undefined extends T[K] ? never : K;
}[keyof T];
```

## Conditional Types

### If Type

```typescript
type If<C extends boolean, T, F> = C extends true ? T : F;

// 사용
type Result = If<true, string, number>; // string
```

### Flatten

```typescript
type Flatten<T> = T extends Array<infer U> ? U : T;

// 사용
type Item = Flatten<string[]>; // string
```

### UnwrapPromise

```typescript
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;

// 사용
type Data = UnwrapPromise<Promise<User>>; // User
```

## Function Types

### Parameters & ReturnType

```typescript
type Params = Parameters<typeof myFunction>;
type Return = ReturnType<typeof myFunction>;
```

### Async Function Return

```typescript
type AsyncReturnType<T extends (...args: any) => Promise<any>> =
  T extends (...args: any) => Promise<infer R> ? R : never;
```

## Best Practices

1. **타입 추론 활용**: 가능하면 명시적 타입 대신 추론 활용
2. **제네릭 제약**: `extends`로 타입 범위 제한
3. **조건부 타입**: 복잡한 타입 로직에 활용
4. **맵드 타입**: 기존 타입 변환에 활용
