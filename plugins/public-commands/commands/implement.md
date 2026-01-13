---
description: Implement features based on PRD specifications immediately. Trigger on "/implement", "구현해줘", "만들어줘", "바로 구현", or when user wants to implement a feature from PRD. Best used AFTER /prd and digging.
---

# Implement

PRD에 정의된 기능을 즉시 구현합니다. 계획 확인 없이 바로 코드 작성을 시작합니다.

## Pipeline Position

```
┌─────────────────────────────────────────────────────────────┐
│  [/prd] → [digging] → [/implement] → [/auto-commit]        │
│                        ^^^^^^^^^^^                          │
│                        현재 단계                             │
└─────────────────────────────────────────────────────────────┘
```

| 이전 단계 | 현재 | 다음 단계 |
|----------|------|----------|
| `digging` - PRD 분석 완료 | `/implement` - 구현 | `/auto-commit` - 품질 검사 & 커밋 |

## Prerequisites Check

구현 시작 전 확인:

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️ 구현 전 체크리스트                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ PRD 문서가 존재하는가?                                   │
│     → 없으면 `/prd [기능명]`으로 먼저 작성                   │
│                                                             │
│  ✅ PRD 검토가 완료되었는가? (권장)                          │
│     → `digging` 스킬로 취약점 분석 권장                      │
│                                                             │
│  ✅ Critical 이슈가 해결되었는가?                            │
│     → digging 결과 Critical 항목은 구현 전 수정 필수        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Usage

```bash
/implement 사용자 인증
/implement 플러그인 등록
/implement FR-006          # PRD 기능 ID로 직접 지정
```

## Parameters

- `feature-name or FR-ID`: 기능명 또는 기능 ID (required)

## Protocol

### Phase 1: PRD 검색

인자로 전달된 기능명 또는 기능 ID로 PRD 검색:

**검색 경로 (자동 탐지):**
```
prd/
docs/prd/
requirements/
specs/
*.prd.md
*-requirements.md
*-spec.md
```

**검색 패턴:**
- 기능명이 포함된 PRD 파일
- FR-XXX 형식의 기능 ID
- 관련 키워드가 포함된 섹션

**PRD를 찾지 못한 경우:**
```
❌ PRD 문서를 찾을 수 없습니다.

다음 중 하나를 선택해주세요:
1. `/prd [기능명]`으로 PRD 먼저 작성
2. PRD 파일 경로 직접 지정
3. PRD 없이 바로 구현 (권장하지 않음)
```

### Phase 2: 현재 구현 상태 확인

**프로젝트 구조 자동 탐지:**

| 프로젝트 유형 | 소스 경로 | API 경로 | 컴포넌트 경로 |
|--------------|---------|---------|-------------|
| 일반 | `src/`, `lib/` | `src/api/` | `src/components/` |
| Next.js | `app/`, `src/app/` | `app/api/` | `components/` |
| Monorepo | `apps/*/src/` | `apps/api/` | `apps/web/src/` |
| Python | `src/`, `app/` | `app/api/` | - |

**확인 사항:**
- 기존 구현 여부
- 관련 파일 위치
- 사용 중인 패턴/컨벤션

### Phase 3: Gap Analysis

| Status | Description | Action |
|--------|-------------|--------|
| ✅ Complete | 이미 구현됨 | 스킵 또는 업데이트 확인 |
| ⚠️ Partial | 부분 구현 | 남은 부분 구현 |
| ❌ Not done | 미구현 | 전체 구현 |

### Phase 4: 즉시 구현 시작

계획 확인 없이 바로 코드 작성:

**구현 순서:**
1. **Database/Schema** (필요 시)
   - 스키마 변경/추가
   - 마이그레이션 생성

2. **Backend/API**
   - 엔드포인트 구현
   - 서비스 로직
   - DTO/Validation

3. **Frontend/UI**
   - 페이지/컴포넌트
   - 상태 관리
   - API 연동

### Phase 5: 구현 완료 후 검증

```bash
# TypeScript 타입 체크 (해당 시)
npm run typecheck

# 테스트 실행 (해당 시)
npm test

# 빌드 확인
npm run build
```

### Phase 6: 다음 단계 안내

구현 완료 후 자동으로 커밋 안내:

```
✅ 구현이 완료되었습니다!

┌─────────────────────────────────────────────────────────────┐
│  📋 구현 결과                                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  생성된 파일:                                                │
│  - src/api/auth/login.ts                                    │
│  - src/api/auth/register.ts                                 │
│  - src/services/AuthService.ts                              │
│  - tests/auth.test.ts                                       │
│                                                             │
│  검증 결과:                                                  │
│  ✅ TypeScript 타입 체크 통과                                │
│  ✅ 테스트 통과 (4/4)                                        │
│  ✅ 빌드 성공                                                │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  📋 다음 단계                                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  변경사항을 커밋하시겠습니까?                                 │
│                                                             │
│  → `/auto-commit`으로 품질 검사 후 자동 커밋                 │
│  → 품질 미달 시 자동 개선 또는 수정 안내                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Code Pattern Discovery

### API 엔드포인트 발견
```bash
# 기존 API 패턴 찾기
Glob: "**/api/**/*.{ts,js,py}"
Grep: "@router|@Controller|router\."
```

### 컴포넌트 패턴 발견
```bash
# 기존 컴포넌트 패턴 찾기
Glob: "**/components/**/*.{tsx,jsx}"
Grep: "export (default )?function|export const"
```

### 데이터베이스 스키마 발견
```bash
# Prisma
Glob: "**/prisma/schema.prisma"

# SQLAlchemy
Glob: "**/models/*.py"

# TypeORM
Glob: "**/entities/*.ts"
```

## Validation Checklist

구현 완료 후 확인:
- [ ] 타입 에러 없음
- [ ] 빌드 성공
- [ ] 기존 테스트 통과
- [ ] 기존 기능에 영향 없음
- [ ] PRD 요구사항 충족

## Integration Points

### 이전 단계에서 받는 입력

```
/prd + digging 결과물:
- 검증된 PRD 문서
- 기능 요구사항 (FR-XXX)
- 비기능 요구사항 (NFR-XXX)
- 식별된 리스크 및 대응 방안
```

### 다음 단계로 전달하는 출력

```
/auto-commit에 전달:
- 새로 생성된 파일 목록
- 수정된 파일 목록
- 구현된 기능 목록
- 검증 결과 (타입체크, 테스트, 빌드)
```

## Auto-Trigger

구현 완료 시 자동으로 auto-commit 사용을 제안:

```
💡 구현이 완료되었습니다.

   다음 단계:
   → `/auto-commit`으로 품질 검사 후 커밋

   또는 추가 작업:
   → 다른 기능 구현: `/implement [기능명]`
   → 테스트 추가 작성
```

## Rules

1. **기존 코드 수정 시**
   - 먼저 Read로 현재 구현 확인
   - 기존 패턴/컨벤션 준수
   - 불필요한 변경 최소화

2. **새 파일 생성 시**
   - 기존 파일 구조 참고
   - 적절한 경로에 생성
   - 네이밍 컨벤션 준수

3. **에러 발생 시**
   - 즉시 수정
   - 롤백이 필요하면 사용자에게 알림

## Examples

### PRD 기반 구현

```
입력: /implement 사용자 인증

PRD 확인:
- docs/prd/user-authentication.md 발견
- digging 분석 완료 확인 ✅
- Critical 이슈 없음 ✅

구현:
- src/api/auth/login.ts 생성
- src/api/auth/register.ts 생성
- src/services/AuthService.ts 생성
- tests/auth.test.ts 생성

검증:
- TypeScript ✅
- 테스트 ✅
- 빌드 ✅

다음 단계 안내:
→ `/auto-commit`
```

### 기능 ID로 구현

```
입력: /implement FR-006

PRD 확인:
- FR-006: "플러그인 등록" 기능 발견

구현:
- API 엔드포인트 추가
- 프론트엔드 폼 페이지 생성

다음 단계 안내:
→ `/auto-commit`
```

### PRD 없이 구현 시도

```
입력: /implement 알림 기능

PRD 확인:
- ❌ PRD 문서 없음

안내:
⚠️ PRD 없이 구현하면 요구사항 누락 위험이 있습니다.

권장: `/prd 알림 기능`으로 먼저 PRD를 작성하세요.
계속하려면: "PRD 없이 진행"이라고 말씀해주세요.
```
