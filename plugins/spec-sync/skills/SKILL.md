---
name: spec-sync
description: 모노레포/멀티레포 환경에서 프론트엔드, 백엔드, AI 등 프로젝트 간 스펙 불일치를 감지하고 동기화합니다. Trigger on "/sync", "/스펙동기화", "스펙 맞춰줘", "API 불일치 확인", "타입 동기화", or when user mentions frontend-backend sync.
model: opus
allowed-tools: ["Read", "Edit", "Write", "Grep", "Glob"]
---

# Spec Sync

모노레포/멀티레포 환경에서 여러 프로젝트 간 스펙 불일치를 감지하고 자동으로 동기화합니다.

## When to Use

- 프론트엔드 ↔ 백엔드 API 스펙 불일치 의심
- 백엔드 ↔ AI 서비스 데이터 구조 확인
- 스키마 변경 후 전체 프로젝트 동기화
- 새 팀원 합류 시 스펙 일관성 검증
- PR 전 크로스 프로젝트 영향도 확인

## When NOT to Use

- 단일 프로젝트 작업
- 독립적인 마이크로서비스 (API 계약이 명확한 경우)

## Sync Targets

| 대상               | 추출 위치                 | 예시                              |
| ------------------ | ------------------------- | --------------------------------- |
| **API 엔드포인트** | 라우트 정의, fetch 호출   | `/api/users`, `GET /products/:id` |
| **요청/응답 타입** | DTO, interface, type      | `CreateUserDto`, `UserResponse`   |
| **데이터 스키마**  | Prisma, TypeORM, Mongoose | `User`, `Product`, `Order`        |
| **환경 변수**      | .env, config              | `API_URL`, `DATABASE_URL`         |
| **API 버전**       | 헤더, URL prefix          | `v1`, `v2`                        |

## Protocol

### Step 1: 프로젝트 경로 수집

```
프로젝트 경로를 입력해주세요:

1. 프론트엔드: [경로 또는 URL]
2. 백엔드: [경로 또는 URL]
3. AI 서비스: [경로 또는 URL] (선택)
4. 공유 스키마: [경로] (선택)

예시:
• ./apps/web
• ./apps/api
• ./packages/shared
```

### Step 2: 스펙 추출

각 프로젝트에서 다음을 분석합니다:

**프론트엔드 분석:**

- `fetch`, `axios`, `ky` 등 API 호출 패턴
- API 클라이언트 타입 정의
- 환경 변수 (`NEXT_PUBLIC_API_URL` 등)
- Zod/Yup 스키마

**백엔드 분석:**

- 라우트 핸들러 (`app/api/`, `src/routes/`)
- DTO/Entity 정의
- OpenAPI/Swagger 스펙
- Prisma/TypeORM 스키마

**AI 서비스 분석:**

- 입력/출력 스키마
- 모델 요청/응답 타입
- 스트리밍 이벤트 구조

### Step 3: 불일치 감지

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Spec Analysis Result                                         │
├─────────────────────────────────────────────────────────────────┤
│ 분석 대상:                                                       │
│   • Frontend: ./apps/web                                        │
│   • Backend: ./apps/api                                         │
│   • Shared: ./packages/shared                                   │
├─────────────────────────────────────────────────────────────────┤
│ ✅ 일치 (12개)                                                   │
│   • GET /api/users                                              │
│   • POST /api/auth/login                                        │
│   • ...                                                         │
├─────────────────────────────────────────────────────────────────┤
│ ⚠️ 불일치 (3개)                                                  │
│                                                                 │
│ 1. [API] POST /api/users                                        │
│    ┌─────────────┬──────────────────┬──────────────────┐        │
│    │    항목     │    Frontend      │     Backend      │        │
│    ├─────────────┼──────────────────┼──────────────────┤        │
│    │ 필드        │ { name, email }  │ { name, email,   │        │
│    │             │                  │   password }     │        │
│    ├─────────────┼──────────────────┼──────────────────┤        │
│    │ 응답        │ User             │ UserWithToken    │        │
│    └─────────────┴──────────────────┴──────────────────┘        │
│    💡 권장: Backend 기준으로 Frontend 수정                       │
│                                                                 │
│ 2. [TYPE] User.role                                             │
│    ┌─────────────┬──────────────────┬──────────────────┐        │
│    │    항목     │    Frontend      │     Backend      │        │
│    ├─────────────┼──────────────────┼──────────────────┤        │
│    │ 타입        │ string           │ "admin"|"user"   │        │
│    └─────────────┴──────────────────┴──────────────────┘        │
│    💡 권장: Backend enum을 Frontend에 적용                       │
│                                                                 │
│ 3. [SCHEMA] Product.price                                       │
│    ┌─────────────┬──────────────────┬──────────────────┐        │
│    │    항목     │    Frontend      │     Backend      │        │
│    ├─────────────┼──────────────────┼──────────────────┤        │
│    │ 타입        │ number           │ Decimal          │        │
│    ├─────────────┼──────────────────┼──────────────────┤        │
│    │ 처리        │ 없음             │ toNumber()       │        │
│    └─────────────┴──────────────────┴──────────────────┘        │
│    💡 권장: Frontend에서 Decimal 처리 로직 추가                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4: Source of Truth 판단

| 불일치 유형    | 기본 Source of Truth | 이유                |
| -------------- | -------------------- | ------------------- |
| API 엔드포인트 | **Backend**          | 실제 서버 구현 기준 |
| 데이터 스키마  | **Database/Prisma**  | 단일 진실의 원천    |
| 비즈니스 타입  | **Shared Package**   | 공유 타입 우선      |
| 환경 변수      | **Backend**          | 서버 설정 기준      |
| UI 전용 타입   | **Frontend**         | 클라이언트 전용     |

### Step 5: 동기화 대상 선택

```
어떤 항목을 동기화할까요?

[1] POST /api/users - Backend → Frontend
[2] User.role - Backend → Frontend
[3] Product.price - Backend → Frontend
[A] 전체 동기화 (권장 방향)
[M] 수동 선택 (각 항목별 방향 지정)
[S] 건너뛰기

선택:
```

**수동 선택 시:**

```
1. POST /api/users
   [F] Frontend 기준으로 Backend 수정
   [B] Backend 기준으로 Frontend 수정 ⭐ 권장
   [S] 건너뛰기

2. User.role
   [F] Frontend 기준 (string)
   [B] Backend 기준 (union type) ⭐ 권장
   [S] 건너뛰기
```

### Step 6: 자동 동기화 실행

선택된 항목에 대해 코드 수정을 수행합니다.

**동기화 작업:**

```typescript
// Frontend: types/user.ts
// Before
interface CreateUserRequest {
  name: string;
  email: string;
}

// After (Backend 기준 동기화)
interface CreateUserRequest {
  name: string;
  email: string;
  password: string; // 추가됨
}
```

### Step 7: 동기화 리포트

```
┌─────────────────────────────────────────────────────────────────┐
│ ✅ Sync Complete                                                │
├─────────────────────────────────────────────────────────────────┤
│ 동기화 완료: 3개                                                 │
│                                                                 │
│ 📝 수정된 파일:                                                  │
│   • apps/web/types/user.ts                                      │
│     - CreateUserRequest에 password 필드 추가                    │
│     - User.role 타입을 union type으로 변경                      │
│   • apps/web/lib/api/users.ts                                   │
│     - createUser 함수 파라미터 업데이트                         │
│   • apps/web/components/UserForm.tsx                            │
│     - password 입력 필드 추가 필요 (TODO 주석 추가)              │
│                                                                 │
│ ⚠️ 수동 확인 필요:                                               │
│   • apps/web/components/UserForm.tsx                            │
│     - UI에 password 필드 추가 필요                              │
│                                                                 │
│ 💡 다음 단계:                                                    │
│   1. 타입 체크: npx tsc --noEmit                                │
│   2. 테스트 실행: npm test                                      │
│   3. UI 업데이트 확인                                           │
└─────────────────────────────────────────────────────────────────┘
```

## Detection Patterns

### API 호출 패턴 감지

```typescript
// Frontend fetch 패턴
fetch('/api/users', { method: 'POST', body: JSON.stringify(data) })
axios.post('/api/users', data)
api.users.create(data)

// Backend 라우트 패턴
// Next.js App Router
export async function POST(request: Request) { }
// NestJS
@Post('users') create(@Body() dto: CreateUserDto) { }
// Express
app.post('/api/users', handler)
```

### 타입 정의 패턴 감지

```typescript
// Interface/Type
interface User { id: string; name: string; }
type User = { id: string; name: string; }

// Zod Schema
const UserSchema = z.object({ id: z.string(), name: z.string() })

// Prisma Model
model User { id String @id; name String }

// DTO
class CreateUserDto { @IsString() name: string; }
```

## Examples

### 예시 1: 기본 사용

```
User: /sync apps/web apps/api

Claude:
1. 두 프로젝트 분석
2. API 엔드포인트 14개, 타입 8개 비교
3. 불일치 2개 발견 리포트
4. 동기화 방향 선택 요청
5. 선택 후 자동 코드 수정
```

### 예시 2: 특정 API만 동기화

```
User: /sync apps/web apps/api --endpoint /api/users

Claude:
1. /api/users 관련 코드만 분석
2. 요청/응답 타입 비교
3. 불일치 리포트
4. 선택적 동기화
```

### 예시 3: 공유 패키지 포함

```
User: /sync apps/web apps/api packages/shared

Claude:
1. shared 패키지를 Source of Truth로 인식
2. web, api 모두 shared 기준으로 비교
3. shared와 다른 부분 리포트
4. shared 기준으로 동기화
```

## Rules

1. **비파괴적 동기화**: 기존 코드 구조 최대한 유지
2. **타입 안전성**: 동기화 후 타입 에러 없어야 함
3. **단계적 적용**: 한 번에 전체가 아닌 선택적 동기화
4. **롤백 가능**: 변경 전 백업 또는 git diff 제공
5. **수동 확인 표시**: 자동화 불가능한 부분 명확히 표시

## Limitations

- 동적으로 생성되는 API 경로는 감지 어려움
- GraphQL은 별도 분석 로직 필요
- 런타임 타입 변환은 감지 불가
- 외부 API (third-party)는 분석 범위 외

## Advanced Options

```
/sync [paths...] [options]

Options:
  --endpoint <path>    특정 엔드포인트만 분석
  --type <name>        특정 타입만 분석
  --dry-run            실제 수정 없이 리포트만
  --force              확인 없이 권장 방향으로 동기화
  --output <file>      불일치 리포트 JSON 저장
```
