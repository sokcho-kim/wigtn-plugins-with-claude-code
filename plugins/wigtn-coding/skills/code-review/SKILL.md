---
name: code-review
description: Multi-level code review system with quality scoring. Supports 4 review levels from quick lint checks to deep architecture analysis. Level 1-2 for standard reviews, Level 3 for senior-level deep analysis, Level 4 for architecture decisions.
disable-model-invocation: true
context: fork
context-agent-type: general-purpose
---

# Code Review

멀티 레벨 코드 리뷰 시스템입니다. 상황에 맞는 깊이의 리뷰를 제공합니다.

## Review Levels

| Level | Name | 용도 | 깊이 | 적용 상황 |
|-------|------|------|------|----------|
| **1** | Quick | 린터 수준 체크 | 낮음 | 빠른 PR 승인, 자동 포맷팅 |
| **2** | Standard | 기본 품질 리뷰 | 중간 | 일반 코드 리뷰, `/auto-commit` |
| **3** | Deep | 시니어급 심층 분석 | 높음 | 핵심 로직, 보안 민감 코드 |
| **4** | Architecture | 설계 수준 검토 | 매우 높음 | 새 모듈, 아키텍처 변경 |

```
Review Depth Pyramid

         ┌─────────────┐
         │   Level 4   │  Architecture Review
         │ (설계 수준)  │  - SOLID 원칙
         ├─────────────┤  - 계층 위반 탐지
         │   Level 3   │  - 확장성/운영성
         │ (시니어급)   │
         │             │  Deep Review
         ├─────────────┤  - 호출 체인 분석
         │   Level 2   │  - 동시성/보안 심층
         │  (Standard) │  - 기술 부채 예측
         │             │
         ├─────────────┤  Standard Review ← 기본값
         │   Level 1   │  - 5 카테고리 점수
         │   (Quick)   │  - 체크리스트 평가
         │             │
         └─────────────┘  Quick Review
                          - 린트 체크
                          - 포맷팅 검사
```

### Level 선택 가이드

| 상황 | 권장 Level |
|------|-----------|
| "빠르게 봐줘", "린트만" | Level 1 (Quick) |
| "코드 리뷰해줘", `/auto-commit` | Level 2 (Standard) |
| "자세히 봐줘", "시니어 관점으로" | Level 3 (Deep) |
| "아키텍처 검토", "설계 리뷰" | Level 4 (Architecture) |

### Level 3-4 상세 가이드

- **Level 3 (Deep Review)**: [levels/deep-review.md](levels/deep-review.md)
  - 호출 체인 분석, 에지 케이스 발굴, 동시성/보안 심층 분석

- **Level 4 (Architecture Review)**: [levels/architecture-review.md](levels/architecture-review.md)
  - SOLID 원칙, 의존성 분석, 계층 위반 탐지, 확장성/운영성 평가

---

## Parallel Review Mode

> **Agent Teams 병렬 리뷰**: 3개 카테고리 전문 에이전트가 동시에 리뷰하여 **3x 속도 향상**을 달성합니다.

### 병렬 모드 활성화 조건

| 조건 | 모드 | 이유 |
|------|------|------|
| 변경 파일 3개 이상 | **병렬** (자동) | 충분한 리뷰 대상 |
| 변경 파일 2개 이하 | 순차 | 병렬화 오버헤드 > 이득 |
| `--no-parallel-review` 플래그 | 순차 | 사용자 명시 |

### 에이전트별 담당 카테고리

```
┌─────────────────────────────────────────────────────────────┐
│  Parallel Review Agents                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Agent A: Readability(20) + Maintainability(20)             │
│  ├── 명명 규칙, 주석, 코드 구조                             │
│  └── 모듈성, 결합도, 확장성                                 │
│                                                             │
│  Agent B: Performance(20) + Testability(20)                 │
│  ├── 알고리즘 효율성, 리소스 사용                           │
│  └── 순수 함수, 의존성 주입, 테스트 용이성                  │
│                                                             │
│  Agent C: Best Practices(20) + Security Flag                │
│  ├── 언어 관례, 디자인 패턴, 에러 처리                      │
│  └── OWASP Top 10 검사 (Critical → 강제 FAIL)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Score Merge Contract

**`parallel-review-coordinator`가 병합 시 사용하는 YAML 출력 형식:**

```yaml
# 각 에이전트 출력 형식
agent_result:
  agent_id: "A" | "B" | "C"
  categories:
    - name: string          # 카테고리명
      score: number         # /20
      issues:
        - severity: "critical" | "major" | "minor" | "info"
          file: string
          line: number
          message: string
          suggestion: string
  security_flag: boolean    # Agent C만 사용
  duration: string
```

### 병합 규칙

| 규칙 | 설명 |
|------|------|
| 점수 합산 | Agent A(40) + Agent B(40) + Agent C(20) = 100 |
| Security Override | `security_flag: true` → 총점 59점 이하 강제 |
| Issues 통합 | 3개 에이전트 이슈 합산, 중복 제거, severity 정렬 |
| 타임아웃 대체 | 60초 초과 시 보수적 기본값(15/20) 적용 |
| 결과 일관성 | 병렬/순차 모드 동일 기준 (점수 +-5점 이내) |

---

## Level 1-2: Standard Review

파일/함수 단위 코드 리뷰와 품질 점수 시스템을 제공합니다. 가독성, 유지보수성, 성능, 테스트 가능성 등을 분석하여 구체적인 점수와 개선 제안을 제공합니다.

## Pipeline Position

```
┌─────────────────────────────────────────────────────────────┐
│  [/prd] → [digging] → [/implement] → [/auto-commit]        │
│                                           │                 │
│                                      ┌────┴────┐            │
│                                      │code-    │            │
│                                      │review   │ ← 현재     │
│                                      └────┬────┘            │
│                                           │                 │
│                                      code-formatter         │
└─────────────────────────────────────────────────────────────┘
```

| 호출자 | 현재 | 연동 |
|--------|------|------|
| `/auto-commit` - 품질 게이트 | `code-review` - 품질 평가 | `code-formatter` - 자동 개선 |

## When to Use This Skill

- `/auto-commit` 명령의 품질 게이트로 자동 호출됨
- 특정 파일이나 함수에 대한 집중 리뷰가 필요할 때
- 코드 품질을 수치화하여 측정하고 싶을 때
- PR 머지 전 코드 품질 검증이 필요할 때
- 리팩토링 전후 품질 비교가 필요할 때
- 팀 코드 리뷰 기준을 표준화하고 싶을 때

## Quality Score System

### Overall Score (100점 만점)

| Grade | Score | Description | Auto-Commit Action |
|-------|-------|-------------|-------------------|
| **A+** | 95-100 | 모범적인 코드, 즉시 머지 가능 | ✅ 바로 커밋 |
| **A** | 90-94 | 우수한 코드, 사소한 개선점만 존재 | ✅ 바로 커밋 |
| **B+** | 85-89 | 좋은 코드, 몇 가지 개선 권장 | ✅ 바로 커밋 |
| **B** | 80-84 | 괜찮은 코드, 개선 필요 | ✅ 바로 커밋 |
| **C+** | 75-79 | 보통, 리팩토링 권장 | ⚠️ code-formatter 시도 |
| **C** | 70-74 | 개선 필요, 기술 부채 발생 가능 | ⚠️ code-formatter 시도 |
| **D** | 60-69 | 문제 있음, 수정 필수 | ⚠️ code-formatter 시도 |
| **F** | < 60 | 심각한 문제, 재작성 권장 | ❌ 커밋 중단 |

### Category Scores (각 20점)

| Category | Weight | 평가 기준 |
|----------|--------|----------|
| **Readability** | 20% | 명명 규칙, 주석, 코드 구조 |
| **Maintainability** | 20% | 모듈성, 결합도, 확장성 |
| **Performance** | 20% | 알고리즘 효율성, 리소스 사용 |
| **Testability** | 20% | 테스트 용이성, 의존성 주입 |
| **Best Practices** | 20% | 언어 관례, 디자인 패턴, 보안 |

## Review Protocol

### Phase 1: Context Analysis

```bash
# 파일 컨텍스트 파악
Read: <target-file>

# 관련 파일 확인
Glob: "**/tests/**/*<filename>*"
Glob: "**/*<related-pattern>*"

# 프로젝트 컨벤션 확인
Read: .eslintrc* | .prettierrc* | pyproject.toml
```

### Phase 2: Code Analysis

**Readability (가독성) 체크리스트:**
- [ ] 변수/함수명이 의도를 명확히 표현하는가?
- [ ] 함수 길이가 적절한가? (20줄 이하 권장)
- [ ] 중첩 깊이가 적절한가? (3단계 이하 권장)
- [ ] 주석이 "왜"를 설명하는가?
- [ ] 일관된 포맷팅이 적용되었는가?

**Maintainability (유지보수성) 체크리스트:**
- [ ] 단일 책임 원칙을 준수하는가?
- [ ] 의존성이 명확히 주입되는가?
- [ ] 하드코딩된 값이 없는가?
- [ ] 모듈 간 결합도가 낮은가?
- [ ] 변경 시 영향 범위가 제한적인가?

**Performance (성능) 체크리스트:**
- [ ] 불필요한 루프/연산이 없는가?
- [ ] 메모리 누수 가능성이 없는가?
- [ ] 적절한 캐싱이 적용되었는가?
- [ ] N+1 쿼리 문제가 없는가?
- [ ] 비동기 처리가 적절한가?

**Testability (테스트 가능성) 체크리스트:**
- [ ] 순수 함수로 작성되었는가?
- [ ] 외부 의존성이 모킹 가능한가?
- [ ] 테스트 케이스 작성이 용이한가?
- [ ] 경계 조건이 명확한가?
- [ ] 에러 케이스가 분리되어 있는가?

**Best Practices (모범 사례) 체크리스트:**
- [ ] 언어 표준 관례를 따르는가?
- [ ] 에러 처리가 적절한가?
- [ ] 타입 안전성이 보장되는가?
- [ ] 보안 취약점이 없는가?
- [ ] 로깅이 적절히 적용되었는가?

### Phase 3: Score Calculation

```
총점 = (가독성 × 0.2) + (유지보수성 × 0.2) + (성능 × 0.2) +
       (테스트가능성 × 0.2) + (모범사례 × 0.2)
```

**점수 산정 기준:**

| 항목별 | 점수 | 기준 |
|--------|------|------|
| 우수 | 18-20 | 모든 체크리스트 충족 |
| 양호 | 15-17 | 대부분 충족, 사소한 이슈 |
| 보통 | 12-14 | 절반 충족, 개선 필요 |
| 미흡 | 9-11 | 많은 이슈, 수정 필수 |
| 불량 | 0-8 | 심각한 문제 |

## Output Format

### For Auto-Commit (품질 게이트용)

```markdown
## Quality Gate Result

| 항목 | 점수 | 상태 |
|------|------|------|
| Readability | 18/20 | ✅ |
| Maintainability | 16/20 | ✅ |
| Performance | 15/20 | ⚠️ |
| Best Practices | 17/20 | ✅ |
| **Total** | **82/100** | **✅ PASS** |

### Gate Decision
- **Status**: PASS
- **Action**: 커밋 진행 가능

### Issues Found (if any)
- [Minor] src/utils/helper.ts:45 - 변수명 개선 권장
```

### For Detailed Review (상세 리뷰용)

```markdown
# Code Review Report

## Target
- **File**: `src/services/UserService.ts`
- **Function**: `authenticateUser`
- **Lines**: 45-89

## Quality Score

| Category | Score | Grade |
|----------|-------|-------|
| Readability | 17/20 | B+ |
| Maintainability | 15/20 | B |
| Performance | 18/20 | A |
| Testability | 14/20 | C+ |
| Best Practices | 16/20 | B |
| **Total** | **80/100** | **B** |

## Summary

전반적으로 양호한 코드입니다. 성능 면에서는 우수하나,
테스트 가능성과 유지보수성에서 개선이 필요합니다.

## Findings

### Critical (즉시 수정 필요)
1. **[Line 52]** SQL 인젝션 취약점
   - 현재: `query = f"SELECT * FROM users WHERE id = {user_id}"`
   - 권장: 파라미터화된 쿼리 사용

### Major (수정 권장)
1. **[Line 67-78]** 함수 길이 초과
   - 현재: 35줄
   - 권장: 헬퍼 함수로 분리

### Minor (개선 제안)
1. **[Line 45]** 변수명 개선
   - 현재: `d`
   - 권장: `userData` 또는 `userDetails`

## Recommendations

1. **Testability 개선**:
   - 데이터베이스 접근을 Repository 패턴으로 분리
   - 의존성 주입으로 모킹 가능하게 변경

2. **Maintainability 개선**:
   - 검증 로직을 별도 함수로 추출
   - 매직 넘버를 상수로 정의

## Before/After Example

**Before:**
```typescript
if (user.status === 1 && user.age >= 18) {
  // complex logic...
}
```

**After:**
```typescript
const isActiveAdult = user.status === UserStatus.ACTIVE &&
                      user.age >= MINIMUM_AGE;
if (isActiveAdult) {
  // complex logic...
}
```
```

## Integration Points

### 호출되는 컨텍스트

| 호출자 | 용도 | 출력 형식 |
|--------|------|----------|
| `/auto-commit` | 품질 게이트 | 간략 (점수 + 통과/실패) |
| 사용자 직접 요청 | 상세 리뷰 | 상세 (전체 리포트) |

### code-formatter 연동

품질 점수 60-79점일 때 자동으로 code-formatter 호출:

```
code-review 결과: 72/100 ⚠️
   ↓
code-formatter 자동 호출
   - ESLint/Prettier 수정
   - import 정리
   ↓
code-review 재평가
   ↓
결과에 따라 커밋/중단 결정
```

## Severity Levels

| Level | Description | Action | Auto-Commit Impact |
|-------|-------------|--------|-------------------|
| **Critical** | 보안 취약점, 버그, 데이터 손실 가능 | 즉시 수정 | ❌ 즉시 실패 |
| **Major** | 성능 문제, 유지보수 어려움 | 머지 전 수정 권장 | ⚠️ 점수 감점 |
| **Minor** | 코드 스타일, 네이밍, 가독성 | 가능하면 수정 | 💡 점수 소폭 감점 |
| **Info** | 제안, 대안 | 참고용 | - 점수 영향 없음 |

## Language-Specific Guidelines

### TypeScript/JavaScript
- 타입 any 사용 지양
- null/undefined 적절히 처리
- async/await 일관성
- ESLint 규칙 준수

### Python
- PEP 8 스타일 가이드
- Type hints 사용
- Docstring 작성
- f-string 활용

### Go
- 에러 처리 패턴
- goroutine 안전성
- 인터페이스 활용
- 간결한 네이밍

## Common Patterns

### Function-Level Review

```bash
입력: 이 함수를 리뷰해줘

단계:
1. 함수 전체 읽기
2. 호출부 및 사용처 확인
3. 관련 테스트 확인
4. 5개 카테고리 평가
5. 점수 및 피드백 제공
```

### File-Level Review

```bash
입력: UserService.ts 파일 리뷰해줘

단계:
1. 파일 전체 읽기
2. 클래스/모듈 구조 분석
3. 각 함수별 간단 평가
4. 전체 점수 산정
5. 우선순위별 개선점 정리
```

### Comparative Review

```bash
입력: 리팩토링 전후 비교해줘

단계:
1. 두 버전 모두 읽기
2. 동일 기준으로 평가
3. 점수 변화 비교
4. 개선/퇴보 항목 정리
```

## Best Practices

### Do's
- **구체적인 라인 번호 제시** - 개선점 위치 명확히
- **실제 예시 코드 제공** - Before/After 비교
- **우선순위 명시** - Critical > Major > Minor
- **긍정적인 점도 언급** - 잘된 부분 칭찬
- **근거 제시** - 왜 문제인지 설명

### Don'ts
- **개인 스타일 강요** - 프로젝트 컨벤션 우선
- **과도한 지적** - 핵심 이슈에 집중
- **모호한 피드백** - "좋지 않음" 대신 구체적으로
- **컨텍스트 무시** - 프로젝트 상황 고려
- **자동 수정 가능한 것 지적** - 린터로 해결 가능한 건 스킵

## Auto-Trigger

다음 상황에서 code-review가 자동 호출됨:

1. `/auto-commit` 실행 시 (품질 게이트)
2. 사용자가 "코드 리뷰해줘", "리뷰" 요청 시
3. PR 리뷰 요청 시
