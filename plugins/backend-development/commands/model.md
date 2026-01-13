---
description: Prisma 스키마에 모델을 추가하고 관련 코드를 생성합니다. Trigger on "/model", "모델 만들어줘", "스키마 추가해줘", "엔티티 만들어줘", or when user needs to create database models.
---

# Model

Prisma 데이터 모델을 생성하고 관련 코드를 생성합니다.

## Usage

```bash
/model <ModelName> [options]
```

## Parameters

- `ModelName`: 모델 이름 (PascalCase, required)
- `--fields <fields>`: 필드 정의 (쉼표 구분)
- `--relations <relations>`: 관계 정의
- `--with-crud`: CRUD 서비스 함께 생성
- `--soft-delete`: 소프트 삭제 필드 추가

## Field Syntax

```
fieldName:Type:modifier
```

| 타입     | 예시                   |
| -------- | ---------------------- |
| String   | `name:String`          |
| Int      | `price:Int`            |
| Boolean  | `isActive:Boolean`     |
| DateTime | `publishedAt:DateTime` |
| Json     | `metadata:Json`        |

| 수정자           | 의미              |
| ---------------- | ----------------- |
| `?`              | Optional          |
| `unique`         | Unique constraint |
| `default(value)` | 기본값            |

## Protocol

### Step 1: 기존 스키마 확인

```bash
# Prisma 스키마 존재 확인
Read: prisma/schema.prisma

# 모델 중복 확인
Grep: "model <ModelName>"
```

**이미 존재하는 경우:**

```
⚠️ Product 모델이 이미 존재합니다.

선택해주세요:
1. 필드 추가/수정
2. 기존 모델 확인
3. 취소
```

### Step 2: 스키마 추가

prisma/schema.prisma에 모델 추가

### Step 3: 마이그레이션 안내

```
✅ 모델 추가 완료

다음 명령어로 마이그레이션을 실행하세요:
npx prisma migrate dev --name add_<model>
```

### Step 4: CRUD 생성 (--with-crud)

```
src/<model>/
├── <model>.module.ts
├── <model>.service.ts
├── <model>.repository.ts
└── dto/
    ├── create-<model>.dto.ts
    └── update-<model>.dto.ts
```

## Templates

### Basic Model

```prisma
model Product {
  id          String   @id @default(uuid())
  title       String
  price       Int
  description String?

  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}
```

### With Relations

```prisma
model Product {
  id          String   @id @default(uuid())
  title       String
  price       Int

  seller      User     @relation(fields: [sellerId], references: [id])
  sellerId    String

  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@index([sellerId])
}
```

### With Soft Delete (--soft-delete)

```prisma
model Order {
  id        String    @id @default(uuid())
  status    String    @default("PENDING")
  total     Int

  deletedAt DateTime?  // Soft delete

  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
}
```

## Relation Types

| 표현     | 관계               |
| -------- | ------------------ |
| `User`   | Many-to-One (N:1)  |
| `Post[]` | One-to-Many (1:N)  |
| `Tag[]`  | Many-to-Many (N:N) |

## Examples

### 기본 모델

```
입력: /model User --fields "email:String:unique,name:String?,role:String:default(USER)"

결과:
model User {
  id    String  @id @default(uuid())
  email String  @unique
  name  String?
  role  String  @default("USER")
  ...
}
```

### 관계 포함

```
입력: /model Product --fields "title:String,price:Int" --relations "seller:User"

결과:
model Product {
  id       String @id @default(uuid())
  title    String
  price    Int
  seller   User   @relation(fields: [sellerId], references: [id])
  sellerId String
  ...
}
```

### CRUD 포함

```
입력: /model Order --with-crud

결과:
- prisma/schema.prisma에 Order 모델 추가
- src/order/ 디렉토리에 CRUD 파일 생성
```

## Skill Reference

> 📚 이 Command는 `backend-architect` 스킬의 Phase 3 (데이터 모델링)을 실행합니다.
> 전체 설계가 필요하면 `/backend` 명령어를 먼저 사용하세요.

## Integration Points

| 연결 대상                | 역할                             |
| ------------------------ | -------------------------------- |
| `backend-architect` 스킬 | 데이터 모델링 패턴 참조          |
| `/api` 명령어            | 모델 생성 후 API 엔드포인트 생성 |
| `/backend` 명령어        | 전체 백엔드 설계가 필요한 경우   |

## Next Step

모델 생성 완료 후:

```
💡 Prisma 모델이 추가되었습니다!

다음 단계:
  1. npx prisma migrate dev --name add_<model>
  2. `/api <model> --crud`로 API 생성
  3. `/auto-commit`으로 커밋
```

## Rules

1. **중복 방지**: 기존 모델 존재 시 확인
2. **관계 검증**: 참조하는 모델 존재 여부 확인
3. **인덱스 자동 추가**: 외래 키에 @@index 추가
4. **타임스탬프**: createdAt, updatedAt 자동 포함

## $ARGUMENTS
