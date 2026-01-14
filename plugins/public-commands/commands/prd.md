---
description: |
  Generate structured PRD documents from vague feature requests.

  Trigger keywords:
  - Commands: "/prd", "PRD 작성해줘", "기능 정의서", "요구사항 문서"

  - Natural language (바이브 코더 친화):
    - "~하는거 만들고 싶어", "~하는 기능 필요해"
    - "~할 수 있게 해줘", "~하는 앱 만들어줘"
    - "~하는 서비스 기획해줘", "이런 거 가능해?"
    - "아이디어가 있는데", "기능 추가하고 싶어"
    - "~하는 사이트 만들어줘", "~하는 시스템 구축해줘"
---

# PRD Generation

모호한 기능 요청을 구조화된 PRD 문서로 변환합니다.

## Pipeline Position

```
┌─────────────────────────────────────────────────────────────┐
│  [/prd] → [digging] → [/implement] → [/auto-commit]        │
│   ^^^^^                                                     │
│   현재 단계                                                  │
└─────────────────────────────────────────────────────────────┘
```

| 이전 단계 | 현재 | 다음 단계 |
|----------|------|----------|
| 프로젝트 시작 | `/prd` - PRD 문서 생성 | `digging` - PRD 분석 & 개선 |

## Trigger Recognition

### 자연어 패턴 인식

사용자가 다음과 같은 패턴으로 말하면 PRD 생성을 시작합니다:

| 패턴 | 예시 |
|------|------|
| "~하는거 만들고 싶어" | "로그인하는거 만들고 싶어" |
| "~하는 기능 필요해" | "결제하는 기능 필요해" |
| "~할 수 있게 해줘" | "사진 업로드할 수 있게 해줘" |
| "~하는 앱/사이트 만들어줘" | "쇼핑몰 사이트 만들어줘" |
| "아이디어가 있는데" | "아이디어가 있는데 들어볼래?" |
| "이런 거 가능해?" | "실시간 채팅 이런 거 가능해?" |

### 복잡도 판단

```
사용자 입력 분석
       ↓
┌──────────────────────────────────────────┐
│ 복잡도 판단                               │
├──────────────────────────────────────────┤
│ 간단한 기능 (단일 CRUD, 버튼 추가 등)     │
│ → "바로 구현할까요, PRD 먼저 작성할까요?" │
│                                          │
│ 복잡한 기능 (인증, 결제, 다중 도메인 등)  │
│ → PRD 작성 권장 안내                      │
└──────────────────────────────────────────┘
```

## Usage

```bash
/prd user-authentication
/prd plugin-marketplace --detail=full
```

## Parameters

- `feature-name`: 기능명 (required)
- `--detail`: 상세 수준 (basic | full, default: full)

## Protocol

### Phase 1: Context Gathering

1. **프로젝트 구조 분석**
   - Glob으로 프로젝트 구조 탐색
   - 기존 PRD 파일 검색 (`prd/`, `docs/prd/`, `requirements/`)
   - package.json, requirements.txt 등에서 기술 스택 확인

2. **기존 코드 분석** (해당 시)
   - API 엔드포인트 패턴 (`src/api/`, `app/api/`)
   - 프론트엔드 구조 (`src/app/`, `src/components/`)
   - 데이터베이스 스키마 (`prisma/schema.prisma`, `models/`)

### Phase 2: PRD Generation

다음 템플릿을 사용하여 PRD를 작성합니다:

```markdown
# [Feature Name] PRD

> **Version**: 1.0
> **Created**: YYYY-MM-DD
> **Status**: Draft

## 1. Overview

### 1.1 Problem Statement
[해결하려는 문제가 무엇인가?]

### 1.2 Goals
- [목표 1]
- [목표 2]

### 1.3 Non-Goals (Out of Scope)
- [명시적으로 하지 않을 것]

### 1.4 Scope
| 포함 | 제외 |
|------|------|
| ... | ... |

## 2. User Stories

### 2.1 Primary User
As a [사용자 유형], I want to [행동] so that [이유/이점].

### 2.2 Acceptance Criteria (Gherkin)
Scenario: [시나리오명]
  Given [전제 조건]
  When [행동]
  Then [결과]

## 3. Functional Requirements

| ID | Requirement | Priority | Dependencies |
|----|------------|----------|--------------|
| FR-001 | [요구사항 설명] | P0 (Must) | - |
| FR-002 | [요구사항 설명] | P1 (Should) | FR-001 |

## 4. Non-Functional Requirements

### 4.1 Performance
- Response time: < 200ms (p95)
- Concurrent users: 1000+

### 4.2 Security
- Authentication: Required/Optional
- Data encryption: At rest / In transit

## 5. Technical Design

### 5.1 API Specification
[상세 API 명세 - 아래 API Specification Detail 섹션 참고]

### 5.2 Database Schema
[스키마 변경 사항]

### 5.3 Architecture Diagram
[필요 시 아키텍처 다이어그램]

## 6. Implementation Phases

### Phase 1: MVP
- [ ] Task 1
- [ ] Task 2
**Deliverable**: [산출물]

### Phase 2: Enhancement
- [ ] Task 3
**Deliverable**: [산출물]

## 7. Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| [지표] | [목표값] | [측정 방법] |
```

### Phase 3: API Specification Detail

PRD 내 API 명세는 다음 형식으로 **상세하게** 작성합니다:

#### API 명세 템플릿

```markdown
### API: [Endpoint Name]

#### `[METHOD] /api/v1/[resource]`

**Description**: [엔드포인트 설명]

**Authentication**: Required / Optional / None

**Headers**:
| Header | Required | Description |
|--------|----------|-------------|
| Authorization | Yes | Bearer {accessToken} |
| Content-Type | Yes | application/json |

**Request Body**:
```json
{
  "field1": "string (required) - 필드 설명",
  "field2": "number (optional) - 필드 설명",
  "field3": {
    "nested": "string (required) - 중첩 필드 설명"
  }
}
```

**Request Example**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "rememberMe": true
}
```

**Response 200 OK**:
```json
{
  "success": true,
  "data": {
    "id": "string - 리소스 ID",
    "createdAt": "string (ISO 8601) - 생성 시간"
  },
  "meta": {
    "timestamp": "string (ISO 8601)"
  }
}
```

**Response Example**:
```json
{
  "success": true,
  "data": {
    "id": "usr_123456",
    "email": "user@example.com",
    "createdAt": "2024-01-15T09:30:00Z"
  },
  "meta": {
    "timestamp": "2024-01-15T09:30:00Z"
  }
}
```

**Error Responses**:
| Status | Code | Message | Description |
|--------|------|---------|-------------|
| 400 | INVALID_INPUT | Invalid request body | 요청 본문 유효성 검사 실패 |
| 401 | UNAUTHORIZED | Authentication required | 인증 토큰 누락 또는 만료 |
| 403 | FORBIDDEN | Access denied | 권한 없음 |
| 404 | NOT_FOUND | Resource not found | 리소스 없음 |
| 409 | CONFLICT | Resource already exists | 중복 리소스 |
| 422 | VALIDATION_ERROR | Validation failed | 비즈니스 규칙 위반 |
| 500 | INTERNAL_ERROR | Internal server error | 서버 오류 |

**Error Response Format**:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "Invalid request body",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-15T09:30:00Z"
  }
}
```

**Rate Limiting**:
- Limit: 100 requests per minute
- Headers: X-RateLimit-Limit, X-RateLimit-Remaining
```

#### API 명세 예시 (로그인)

```markdown
### API: User Authentication

#### `POST /api/v1/auth/login`

**Description**: 사용자 로그인 및 JWT 토큰 발급

**Authentication**: None

**Headers**:
| Header | Required | Description |
|--------|----------|-------------|
| Content-Type | Yes | application/json |

**Request Body**:
```json
{
  "email": "string (required) - 사용자 이메일, 유효한 이메일 형식",
  "password": "string (required) - 비밀번호, 최소 8자",
  "rememberMe": "boolean (optional) - 로그인 유지 여부, default: false"
}
```

**Request Example**:
```json
{
  "email": "user@example.com",
  "password": "MySecurePass123!",
  "rememberMe": true
}
```

**Response 200 OK**:
```json
{
  "success": true,
  "data": {
    "accessToken": "string - JWT 액세스 토큰 (15분)",
    "refreshToken": "string - 리프레시 토큰 (7일, rememberMe시 30일)",
    "expiresIn": "number - 액세스 토큰 만료 시간 (초)",
    "user": {
      "id": "string - 사용자 ID",
      "email": "string - 이메일",
      "name": "string - 이름",
      "role": "string - 역할 (USER | ADMIN)"
    }
  }
}
```

**Response Example**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJl...",
    "expiresIn": 900,
    "user": {
      "id": "usr_abc123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "USER"
    }
  }
}
```

**Error Responses**:
| Status | Code | Message | When |
|--------|------|---------|------|
| 400 | INVALID_INPUT | Invalid email format | 이메일 형식 오류 |
| 401 | INVALID_CREDENTIALS | Invalid email or password | 이메일/비밀번호 불일치 |
| 403 | ACCOUNT_LOCKED | Account is locked | 5회 이상 로그인 실패 |
| 403 | ACCOUNT_DISABLED | Account is disabled | 비활성화된 계정 |
```

### Phase 4: Output Location

PRD 파일 저장 위치 확인 (AskUserQuestion 사용):

```
question: "PRD 파일을 어디에 저장할까요?"
options:
  - label: "prd/"
    description: "prd 폴더에 저장"
  - label: "docs/prd/"
    description: "docs/prd 폴더에 저장"
  - label: "루트"
    description: "[feature-name]-prd.md로 저장"
```

### Phase 5: 다음 단계 안내

PRD 작성 완료 후 자동으로 다음 단계를 안내합니다:

```
✅ PRD 문서가 생성되었습니다: docs/prd/user-authentication.md

┌─────────────────────────────────────────────────────────────┐
│  📋 다음 단계                                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  구현 전에 PRD를 검토하시겠습니까?                            │
│                                                             │
│  → `digging` 스킬로 PRD의 취약점과 누락점을 분석합니다.       │
│  → "PRD 검토해줘" 또는 "digging"이라고 말씀해주세요.          │
│                                                             │
│  바로 구현을 시작하려면:                                      │
│  → `/implement user-authentication`                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Priority Levels (MoSCoW)

| Priority | Label | Description |
|----------|-------|-------------|
| **P0** | Must Have | 없으면 출시 불가 |
| **P1** | Should Have | 가능하면 포함 |
| **P2** | Could Have | 있으면 좋음 |
| **P3** | Won't Have | 이번 릴리스에서 제외 |

## INVEST Criteria for User Stories

| Principle | Description |
|-----------|-------------|
| **I**ndependent | 독립적으로 개발 가능 |
| **N**egotiable | 범위 협상 가능 |
| **V**aluable | 사용자 가치 제공 |
| **E**stimable | 공수 추정 가능 |
| **S**mall | 스프린트에 맞는 크기 |
| **T**estable | 명확한 테스트 기준 |

## Quality Checklist

PRD 작성 후 확인:
- [ ] 목적이 명확하게 정의되었는가?
- [ ] 모든 사용자 스토리에 수용 기준이 있는가?
- [ ] 비기능 요구사항이 측정 가능한가?
- [ ] API 명세가 Request/Response/Error 모두 포함하는가?
- [ ] 우선순위가 명확한가?
- [ ] 의존성이 식별되었는가?

## Integration Points

### 다음 단계로 전달하는 출력

```
digging 스킬에 전달:
- PRD 마크다운 파일 경로
- 기능 요구사항 목록 (FR-XXX)
- 비기능 요구사항 목록 (NFR-XXX)
- API 명세 (상세)
- 기술 설계 초안
```

## Auto-Trigger

PRD 작성 완료 시 자동으로 digging 사용을 제안:

```
💡 PRD 작성이 완료되었습니다.

   권장: 구현 전 `digging` 스킬로 계획을 검토하세요.
   - 누락된 요구사항 발견
   - 보안 취약점 식별
   - 기술적 리스크 평가

   "PRD 검토해줘" 또는 바로 "/implement [기능명]"
```

## Rules

1. **Specific**: "카테고리별 필터링 가능" (O) / "검색 가능" (X)
2. **Measurable**: "응답시간 < 200ms" (O) / "빠른 응답" (X)
3. **Testable**: 명확한 수용 기준
4. **Independent**: 요구사항 간 의존성 최소화
5. **API 명세 완전성**: Request, Response, Error 모두 정의

## Examples

### 새 프로젝트 PRD 생성

```
입력: /prd 사용자 인증

분석:
- 프로젝트 구조 탐색
- 기술 스택 확인 (Next.js, Prisma)

생성:
- docs/prd/user-authentication.md 작성
- FR-001 ~ FR-010 정의
- API 엔드포인트 상세 설계 (Request/Response/Error)
- 데이터베이스 스키마 설계

다음 단계 안내:
→ "PRD 검토해줘" (digging 스킬)
→ "/implement 사용자 인증"
```

### 자연어 입력 처리

```
입력: "로그인하는거 만들고 싶어"

인식:
- 패턴 매칭: "~하는거 만들고 싶어"
- 기능 추출: "로그인"

응답:
"로그인 기능을 만들어 드릴게요!

 어떻게 진행할까요?

 1. 📋 PRD 먼저 작성 (권장)
    - 요구사항 정리
    - API 명세 설계
    - 구현 계획 수립

 2. ⚡ 바로 구현
    - 기본 JWT 인증으로 빠르게 구현

 → PRD 작성: 'PRD 작성해줘'
 → 바로 구현: '바로 만들어줘'"
```
