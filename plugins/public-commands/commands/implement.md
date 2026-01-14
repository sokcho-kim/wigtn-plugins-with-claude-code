---
description: |
  Implement features based on PRD specifications.

  Trigger keywords:
  - Commands: "/implement", "구현해줘", "만들어줘", "바로 구현"

  - Natural language (바이브 코더 친화):
    - "코드 작성해줘", "개발해줘", "빌드해줘"
    - "이제 만들어", "시작해줘", "진행해줘"
    - "코딩해줘", "개발 시작", "구현 시작"
    - "바로 만들어줘", "빨리 만들어줘"
    - "작업해줘", "개발 진행해줘"

  Best used AFTER /prd and digging.
---

# Implement

PRD에 정의된 기능을 구현합니다.

**핵심 원칙**: 설계와 구현을 분리하여, 설계 확인 후 구현을 진행합니다.

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

## Two-Phase Approach

```
┌─────────────────────────────────────────────────────────────┐
│                    /implement 워크플로우                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐                  ┌─────────────┐           │
│  │   DESIGN    │  ──  확인  ──▶  │   BUILD     │           │
│  │   (설계)    │     (Y/n)       │   (구현)    │           │
│  └─────────────┘                  └─────────────┘           │
│                                                             │
│  • PRD 분석          사용자 승인    • 코드 작성             │
│  • 아키텍처 결정     필요!         • 파일 생성             │
│    (subagent)                     • 테스트 실행           │
│  • 구현 계획                       • 빌드 검증             │
│  • 파일 구조                                               │
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

---

## DESIGN Phase (설계 단계)

### Step 1: PRD 검색

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

### Step 2: 아키텍처 결정 (Subagent)

PRD 분석을 바탕으로 최적의 아키텍처를 결정합니다.

**`architecture-decision` agent 호출:**

```yaml
Input:
  prd_path: "docs/prd/user-authentication.md"
  project_path: "./"
  existing_stack: ["typescript", "prisma"]

Output:
  architecture:
    type: "modular-monolith"  # monolithic | modular-monolith | msa
    confidence: 85
  recommendations:
    tech_stack: ["NestJS", "Prisma", "PostgreSQL"]
    folder_structure: "src/modules/..."
    key_patterns: ["Repository pattern", "Event-driven"]
  warnings: ["향후 MSA 전환 고려"]
```

**아키텍처 결정 기준:**

| 평가 항목 | 모놀리식 | 모듈러 모놀리식 | MSA |
|----------|---------|---------------|-----|
| 도메인 수 | 1-2개 | 3-4개 | 5개+ |
| 팀 규모 | 1-3명 | 3-10명 | 10명+ |
| 프로젝트 단계 | MVP | 성장기 | 엔터프라이즈 |
| 독립 배포 필요 | X | △ | O |

**결정 결과 표시:**

```
┌─────────────────────────────────────────────────────────────┐
│  🏗️ 아키텍처 결정                                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  추천 아키텍처: Modular Monolith (신뢰도: 85%)              │
│                                                             │
│  📊 분석 결과:                                              │
│  • 식별된 도메인: 인증, 사용자, 상품, 주문 (4개)            │
│  • 도메인 복잡도: Medium                                    │
│  • 확장성 요구: Medium                                      │
│                                                             │
│  📁 추천 구조:                                              │
│  src/modules/{auth,users,products,orders}/                  │
│                                                             │
│  ⚠️ 주의사항:                                               │
│  • 4개 도메인으로 향후 MSA 전환 고려                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Step 3: 프로젝트 상태 분석

**프로젝트 구조 자동 탐지:**

| 프로젝트 유형 | 소스 경로 | API 경로 | 컴포넌트 경로 |
|--------------|---------|---------|-------------|
| 일반 | `src/`, `lib/` | `src/api/` | `src/components/` |
| Next.js | `app/`, `src/app/` | `app/api/` | `components/` |
| Monorepo | `apps/*/src/` | `apps/api/` | `apps/web/src/` |
| NestJS | `src/` | `src/modules/` | - |
| Python | `src/`, `app/` | `app/api/` | - |

**확인 사항:**
- 기존 구현 여부
- 관련 파일 위치
- 사용 중인 패턴/컨벤션

### Step 4: Gap Analysis

| Status | Description | Action |
|--------|-------------|--------|
| ✅ Complete | 이미 구현됨 | 스킵 또는 업데이트 확인 |
| ⚠️ Partial | 부분 구현 | 남은 부분만 구현 |
| ❌ Not done | 미구현 | 전체 구현 |

### Step 5: 구현 계획 수립

PRD와 프로젝트 분석을 바탕으로 구현 계획을 수립합니다:

```markdown
## 구현 계획

### 생성할 파일
| 경로 | 설명 | 타입 |
|------|------|------|
| src/api/auth/login.ts | 로그인 API | Backend |
| src/api/auth/register.ts | 회원가입 API | Backend |
| src/services/AuthService.ts | 인증 서비스 | Backend |
| src/components/LoginForm.tsx | 로그인 폼 | Frontend |
| tests/auth.test.ts | 인증 테스트 | Test |

### 수정할 파일
| 경로 | 변경 내용 |
|------|----------|
| prisma/schema.prisma | User 모델 추가 |
| src/app/layout.tsx | AuthProvider 추가 |

### 구현 순서
1. Database/Schema 변경
2. Backend API 구현
3. Frontend 컴포넌트 구현
4. 테스트 작성
```

### Step 6: 사용자 확인 (CHECKPOINT)

**설계 완료 후 반드시 사용자 확인을 받습니다:**

```
┌─────────────────────────────────────────────────────────────┐
│  📋 구현 계획이 준비되었습니다                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  기능: 사용자 인증                                          │
│  PRD: docs/prd/user-authentication.md                       │
│                                                             │
│  📁 생성할 파일 (5개)                                       │
│  • src/api/auth/login.ts                                    │
│  • src/api/auth/register.ts                                 │
│  • src/services/AuthService.ts                              │
│  • src/components/LoginForm.tsx                             │
│  • tests/auth.test.ts                                       │
│                                                             │
│  ✏️ 수정할 파일 (2개)                                       │
│  • prisma/schema.prisma                                     │
│  • src/app/layout.tsx                                       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  이 계획대로 구현을 진행할까요?                              │
│                                                             │
│  → "진행" : 바로 구현 시작                                  │
│  → "상세 검토" : digging으로 파일별 분석 후 진행            │
│  → "수정 필요" : 계획 수정                                  │
│  → "취소" : 구현 취소                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**AskUserQuestion 사용:**
```yaml
question: "이 계획대로 구현을 진행할까요?"
options:
  - label: "진행 (Recommended)"
    description: "바로 구현 시작"
  - label: "상세 검토"
    description: "digging 스킬로 파일별 상세 분석 후 진행"
  - label: "수정 필요"
    description: "계획 수정 후 재확인"
  - label: "취소"
    description: "구현 취소"
```

### "상세 검토" 선택 시 (Optional Deep Dive)

사용자가 "상세 검토"를 선택하면 `digging` 스킬을 호출하여 파일별 상세 분석을 진행합니다:

```
┌─────────────────────────────────────────────────────────────┐
│  🔍 상세 검토 진행 중...                                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [1/5] src/api/auth/login.ts                                │
│  ├── 예상 구현: POST /api/auth/login                        │
│  ├── 의존성: AuthService, JWT                               │
│  └── ⚠️ 질문: Rate limiting 필요 여부?                      │
│                                                             │
│  [2/5] src/api/auth/register.ts                             │
│  ├── 예상 구현: POST /api/auth/register                     │
│  ├── 의존성: AuthService, Email validation                  │
│  └── ⚠️ 질문: 이메일 인증 프로세스 포함?                    │
│                                                             │
│  [3/5] src/services/AuthService.ts                          │
│  ├── 예상 구현: 인증 로직, 토큰 관리                         │
│  └── ✅ 이슈 없음                                           │
│                                                             │
│  ...                                                        │
└─────────────────────────────────────────────────────────────┘
```

**digging 스킬 호출:**
```yaml
input:
  context: "implementation_review"
  files:
    - path: "src/api/auth/login.ts"
      purpose: "로그인 API"
      type: "Backend"
    - path: "src/api/auth/register.ts"
      purpose: "회원가입 API"
      type: "Backend"
  prd_path: "docs/prd/user-authentication.md"

output:
  - file: "src/api/auth/login.ts"
    questions:
      - "Rate limiting 적용 필요?"
      - "로그인 실패 횟수 제한?"
    risks: []
  - file: "src/api/auth/register.ts"
    questions:
      - "이메일 인증 필수?"
    risks:
      - "이메일 중복 체크 로직 필요"
```

**상세 검토 완료 후:**
- 식별된 질문에 대한 답변 수집
- 답변 기반으로 구현 계획 보완
- 다시 사용자 확인 → BUILD Phase 진행

---

## BUILD Phase (구현 단계)

사용자 확인 후 실제 코드 작성을 진행합니다.

### Step 1: 코드 작성

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

4. **Tests** (해당 시)
   - 유닛 테스트
   - 통합 테스트

### Step 2: 구현 진행 상황 표시

```
⏳ 구현 진행 중...

[1/5] ✅ prisma/schema.prisma - User 모델 추가 완료
[2/5] ✅ src/api/auth/login.ts - 로그인 API 완료
[3/5] ⏳ src/api/auth/register.ts - 회원가입 API 작성 중...
[4/5] ⏸️ src/services/AuthService.ts - 대기 중
[5/5] ⏸️ src/components/LoginForm.tsx - 대기 중
```

### Step 3: 검증

```bash
# TypeScript 타입 체크 (해당 시)
npm run typecheck

# 테스트 실행 (해당 시)
npm test

# 빌드 확인
npm run build
```

### Step 4: 구현 완료 보고

```
✅ 구현이 완료되었습니다!

┌─────────────────────────────────────────────────────────────┐
│  📋 구현 결과                                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  생성된 파일:                                                │
│  ✅ src/api/auth/login.ts                                   │
│  ✅ src/api/auth/register.ts                                │
│  ✅ src/services/AuthService.ts                             │
│  ✅ src/components/LoginForm.tsx                            │
│  ✅ tests/auth.test.ts                                      │
│                                                             │
│  수정된 파일:                                                │
│  ✅ prisma/schema.prisma                                    │
│  ✅ src/app/layout.tsx                                      │
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

---

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

---

## Validation Checklist

구현 완료 후 확인:
- [ ] 타입 에러 없음
- [ ] 빌드 성공
- [ ] 기존 테스트 통과
- [ ] 기존 기능에 영향 없음
- [ ] PRD 요구사항 충족

---

## Integration Points

### 이전 단계에서 받는 입력

```
/prd + digging 결과물:
- 검증된 PRD 문서
- 기능 요구사항 (FR-XXX)
- 비기능 요구사항 (NFR-XXX)
- API 명세 (상세)
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

---

## Auto-Trigger

구현 완료 시 자동으로 auto-commit 사용을 제안:

```
💡 구현이 완료되었습니다.

   다음 단계:
   → `/auto-commit`으로 품질 검사 후 커밋
   → 코드 리뷰를 통해 품질 게이트 통과 확인

   또는 추가 작업:
   → 다른 기능 구현: `/implement [기능명]`
   → 테스트 추가 작성
```

---

## Rules

1. **설계-구현 분리**
   - 설계 완료 후 반드시 사용자 확인
   - 확인 없이 구현 진행 금지

2. **기존 코드 수정 시**
   - 먼저 Read로 현재 구현 확인
   - 기존 패턴/컨벤션 준수
   - 불필요한 변경 최소화

3. **새 파일 생성 시**
   - 기존 파일 구조 참고
   - 적절한 경로에 생성
   - 네이밍 컨벤션 준수

4. **에러 발생 시**
   - 즉시 수정
   - 롤백이 필요하면 사용자에게 알림

---

## Examples

### PRD 기반 구현

```
입력: /implement 사용자 인증

=== DESIGN Phase ===

PRD 확인:
- docs/prd/user-authentication.md 발견
- digging 분석 완료 확인 ✅
- Critical 이슈 없음 ✅

구현 계획 수립:
- 생성 파일 5개
- 수정 파일 2개
- 구현 순서 정의

사용자 확인 요청:
"이 계획대로 구현을 진행할까요?"

=== BUILD Phase (사용자 승인 후) ===

구현:
- src/api/auth/login.ts 생성
- src/api/auth/register.ts 생성
- src/services/AuthService.ts 생성
- src/components/LoginForm.tsx 생성
- tests/auth.test.ts 생성

검증:
- TypeScript ✅
- 테스트 ✅
- 빌드 ✅

다음 단계 안내:
→ `/auto-commit`
```

### 자연어 입력 처리

```
입력: "이제 만들어줘"

인식:
- 패턴 매칭: "이제 만들어줘"
- 이전 대화에서 기능 확인: "사용자 인증"

진행:
- /implement 사용자 인증 실행
- DESIGN → 사용자 확인 → BUILD
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
