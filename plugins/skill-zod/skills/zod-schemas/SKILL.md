---
name: zod-schemas
description: Zod schema validation patterns for type-safe runtime validation. Use when defining validation schemas.
---

# Zod Schema Patterns

타입 안전한 런타임 검증을 위한 Zod 스키마 패턴입니다.

## Basic Schemas

### Primitive Types

```typescript
import { z } from 'zod';

// 기본 타입
const stringSchema = z.string();
const numberSchema = z.number();
const booleanSchema = z.boolean();
const dateSchema = z.date();

// 리터럴
const roleSchema = z.literal('admin');

// Enum
const statusSchema = z.enum(['active', 'inactive', 'pending']);
```

### String Validations

```typescript
const emailSchema = z.string().email();
const urlSchema = z.string().url();
const uuidSchema = z.string().uuid();
const minMaxSchema = z.string().min(2).max(100);
const regexSchema = z.string().regex(/^[a-z]+$/);
const trimSchema = z.string().trim();
```

### Number Validations

```typescript
const positiveSchema = z.number().positive();
const intSchema = z.number().int();
const rangeSchema = z.number().min(0).max(100);
const multipleOfSchema = z.number().multipleOf(5);
```

## Object Schemas

### Basic Object

```typescript
const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(2),
  age: z.number().int().positive().optional(),
  role: z.enum(['user', 'admin']).default('user'),
});

// 타입 추출
type User = z.infer<typeof userSchema>;
```

### Nested Objects

```typescript
const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
  country: z.string(),
  zipCode: z.string(),
});

const userWithAddressSchema = z.object({
  name: z.string(),
  address: addressSchema,
});
```

### Partial & Required

```typescript
// 모든 필드 선택적
const partialUserSchema = userSchema.partial();

// 특정 필드만 선택적
const createUserSchema = userSchema.partial({
  id: true,
  role: true,
});

// 모든 필드 필수
const strictUserSchema = userSchema.required();
```

### Pick & Omit

```typescript
// 특정 필드만 선택
const userPreviewSchema = userSchema.pick({
  id: true,
  name: true,
});

// 특정 필드 제외
const userWithoutIdSchema = userSchema.omit({
  id: true,
});
```

## Array Schemas

```typescript
const stringArraySchema = z.array(z.string());
const userArraySchema = z.array(userSchema);

// 길이 제한
const limitedArraySchema = z.array(z.string()).min(1).max(10);

// 비어있지 않은 배열
const nonEmptyArraySchema = z.array(z.string()).nonempty();
```

## Union & Intersection

```typescript
// Union (OR)
const stringOrNumberSchema = z.union([z.string(), z.number()]);
// 또는
const stringOrNumber = z.string().or(z.number());

// Discriminated Union
const resultSchema = z.discriminatedUnion('status', [
  z.object({ status: z.literal('success'), data: z.any() }),
  z.object({ status: z.literal('error'), message: z.string() }),
]);

// Intersection (AND)
const combinedSchema = z.intersection(
  z.object({ name: z.string() }),
  z.object({ age: z.number() })
);
```

## Transform & Refine

### Transform

```typescript
const dateStringSchema = z.string().transform((val) => new Date(val));

const trimmedEmailSchema = z.string()
  .trim()
  .toLowerCase()
  .email();
```

### Refine (Custom Validation)

```typescript
const passwordSchema = z.string()
  .min(8)
  .refine(
    (val) => /[A-Z]/.test(val),
    { message: '대문자가 포함되어야 합니다' }
  )
  .refine(
    (val) => /[0-9]/.test(val),
    { message: '숫자가 포함되어야 합니다' }
  );

// Super Refine (여러 필드 검증)
const registerSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).superRefine((data, ctx) => {
  if (data.password !== data.confirmPassword) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: '비밀번호가 일치하지 않습니다',
      path: ['confirmPassword'],
    });
  }
});
```

## API Request/Response Schemas

```typescript
// Request Schema
const createUserRequestSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(8),
    name: z.string().min(2),
  }),
  params: z.object({}).optional(),
  query: z.object({}).optional(),
});

// Response Schema
const apiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.literal(true),
    data: dataSchema,
    timestamp: z.string(),
  });

const userResponseSchema = apiResponseSchema(userSchema);
```

## Error Handling

```typescript
const result = userSchema.safeParse(data);

if (result.success) {
  // result.data는 User 타입
  console.log(result.data);
} else {
  // 에러 처리
  const errors = result.error.flatten();
  console.log(errors.fieldErrors);
}
```

## Best Practices

1. **스키마 재사용**: 공통 스키마는 별도 파일로 분리
2. **타입 추출**: `z.infer<typeof schema>`로 타입 생성
3. **에러 메시지**: 사용자 친화적 에러 메시지 제공
4. **Transform**: 입력 정규화에 활용
5. **safeParse**: 예외 대신 Result 패턴 사용
