# public-commands

> **Core Development Workflow Plugin**

아이디어에서 배포까지, 마찰 없는 개발 워크플로우를 제공하는 핵심 플러그인입니다.

---

## Overview

`public-commands`는 PRD 생성부터 구현, 품질 검사, 자동 커밋까지 전체 개발 라이프사이클을 지원합니다. 바이브 코딩(Vibe Coding) 철학에 맞춰 최소한의 입력으로 최대의 결과를 얻을 수 있도록 설계되었습니다.

### Workflow Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   /prd  ──▶  digging  ──▶  /implement  ──▶  /auto-commit   │
│     │          │              │                │            │
│     ▼          ▼              ▼                ▼            │
│   PRD       취약점          코드            품질 검사       │
│   생성       분석           구현            + 커밋          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Installation

### Option 1: Marketplace

```bash
/plugin install public-commands@wigtn-plugins
```

### Option 2: Manual (Symlink)

```bash
ln -s /path/to/wigtn-plugins/plugins/public-commands ~/.claude/plugins/
```

---

## Components

| Type | Name | Description |
|------|------|-------------|
| Command | `/prd` | PRD 문서 자동 생성 |
| Command | `/implement` | PRD 기반 기능 구현 |
| Command | `/auto-commit` | 품질 게이트 + 자동 커밋 |
| Skill | `code-review` | 코드 품질 점수 평가 (0-100) |
| Skill | `digging` | PRD 취약점 분석 |
| Agent | `architecture-decision` | MSA vs 모놀리식 아키텍처 결정 |
| Agent | `code-formatter` | 다중 언어 포맷팅 자동화 |

---

## Commands

### /prd

모호한 기능 요청을 구조화된 PRD(Product Requirement Document)로 변환합니다.

```bash
/prd 사용자 인증 기능
/prd 결제 시스템
```

**바이브 코더 친화 트리거:**
- "~하는거 만들고 싶어"
- "~만들어줘"
- "기획서 작성해줘"

**출력물:**
- 기능 요구사항 (FR-XXX)
- 비기능 요구사항 (NFR-XXX)
- API 명세서 (상세)
- 데이터 모델
- 우선순위 정의

---

### /implement

PRD에 정의된 기능을 구현합니다. **설계(DESIGN)**와 **구현(BUILD)** 두 단계로 분리됩니다.

```bash
/implement 사용자 인증
/implement FR-006
```

**바이브 코더 친화 트리거:**
- "코드 작성해줘", "개발해줘"
- "이제 만들어", "시작해줘"
- "바로 만들어줘"

#### Two-Phase Approach

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
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### DESIGN Phase

| Step | 내용 |
|------|------|
| 1 | PRD 검색 |
| 2 | 아키텍처 결정 (`architecture-decision` agent) |
| 3 | 프로젝트 상태 분석 |
| 4 | Gap Analysis |
| 5 | 구현 계획 수립 |
| 6 | 사용자 확인 (CHECKPOINT) |

#### 사용자 확인 옵션

```
이 계획대로 구현을 진행할까요?

→ "진행 (Recommended)" : 바로 구현 시작
→ "상세 검토" : digging 스킬로 파일별 상세 분석 후 진행
→ "수정 필요" : 계획 수정
→ "취소" : 구현 취소
```

---

### /auto-commit

변경사항을 분석하고, 품질 검사를 거쳐 자동으로 커밋합니다.

```bash
/auto-commit                      # 품질 검사 + 자동 메시지 + 푸시
/auto-commit --no-push            # 커밋만, 푸시 안함
/auto-commit --no-review          # 품질 검사 스킵 (긴급 핫픽스용)
```

**바이브 코더 친화 트리거:**
- "커밋해줘", "자동 커밋"
- "git push", "git 푸시"

#### Quality Gate System

```
                    ┌─────────────────┐
                    │  변경사항 수집   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  code-review    │
                    │  품질 점수 평가  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌─────────┐    ┌─────────┐    ┌─────────┐
        │ ≥80점   │    │ 60-79점 │    │ <60점   │
        │  PASS   │    │  WARN   │    │  FAIL   │
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
             │              ▼              │
             │    ┌─────────────────┐      │
             │    │ code-formatter  │      │
             │    │   자동 개선     │      │
             │    └────────┬────────┘      │
             │              │              │
             ▼              ▼              ▼
        ┌─────────────┐       ┌─────────────┐
        │   COMMIT    │       │    STOP     │
        │   & PUSH    │       │  수동 수정   │
        └─────────────┘       └─────────────┘
```

| Score | Grade | Action |
|-------|-------|--------|
| 80+ | A/B | ✅ 바로 커밋 |
| 60-79 | C/D | ⚠️ 자동 개선 후 재시도 |
| < 60 | F | ❌ 커밋 중단, 수동 수정 필요 |

---

## Skills

### code-review

파일/함수 단위 코드 리뷰와 품질 점수 시스템을 제공합니다.

**평가 카테고리 (각 20점):**

| Category | 평가 기준 |
|----------|----------|
| Readability | 명명 규칙, 주석, 코드 구조 |
| Maintainability | 모듈성, 결합도, 확장성 |
| Performance | 알고리즘 효율성, 리소스 사용 |
| Testability | 테스트 용이성, 의존성 주입 |
| Best Practices | 언어 관례, 디자인 패턴, 보안 |

**등급 체계:**

| Grade | Score | Description |
|-------|-------|-------------|
| A+ | 95-100 | 모범적인 코드 |
| A | 90-94 | 우수한 코드 |
| B+ | 85-89 | 좋은 코드 |
| B | 80-84 | 괜찮은 코드 |
| C | 70-79 | 개선 필요 |
| D | 60-69 | 문제 있음 |
| F | < 60 | 재작성 권장 |

---

### digging

PRD 문서의 취약점, 누락점, 리스크를 분석합니다.

**분석 카테고리:**

| Category | 체크 항목 |
|----------|----------|
| 완전성 | 기능/비기능 요구사항 누락, 엣지 케이스 |
| 실현가능성 | 기술 스택 적합성, 구현 복잡도 |
| 보안 | 인증/인가, 데이터 보호, 입력 검증 |
| 일관성 | 용어 통일, 요구사항 충돌, 우선순위 |

**심각도 레벨:**

| Level | 기준 | 액션 |
|-------|------|------|
| 🔴 Critical | 보안 취약점, 핵심 기능 누락 | 즉시 수정 필수 |
| 🟡 Major | 품질 저하, 재작업 유발 | 구현 전 수정 권장 |
| 🟢 Minor | 개선하면 좋은 사항 | 선택적 수정 |

---

## Agents

### architecture-decision

PRD 분석을 바탕으로 최적의 아키텍처를 결정합니다.

**결정 기준:**

| 평가 항목 | 모놀리식 | 모듈러 모놀리식 | MSA |
|----------|---------|---------------|-----|
| 도메인 수 | 1-2개 | 3-4개 | 5개+ |
| 팀 규모 | 1-3명 | 3-10명 | 10명+ |
| 프로젝트 단계 | MVP | 성장기 | 엔터프라이즈 |
| 독립 배포 필요 | X | △ | O |

**출력:**
- 아키텍처 타입 + 신뢰도 점수
- 추천 기술 스택
- 폴더 구조
- 주의사항/경고

---

### code-formatter

다중 언어 포맷팅 및 린팅 자동화를 수행합니다.

**지원 언어/도구:**

| Language | Formatter |
|----------|-----------|
| TypeScript/JavaScript | Prettier, ESLint |
| Python | Black, isort, Ruff |
| Go | gofmt, goimports |
| Rust | rustfmt |

**자동 수정:**
- Import 정리
- 포맷팅 통일
- 린트 에러 수정

---

## Quick Start

### 1. PRD 생성

```bash
/prd 사용자 인증 기능
```

또는 자연어로:
```
"로그인 기능 만들고 싶어"
```

### 2. PRD 분석 (선택)

```bash
# digging 스킬로 취약점 분석
"PRD 검토해줘"
```

### 3. 기능 구현

```bash
/implement 사용자 인증
```

또는:
```
"이제 만들어줘"
```

### 4. 품질 검사 + 커밋

```bash
/auto-commit
```

또는:
```
"커밋해줘"
```

---

## Integration

### Component Dependencies

```
/prd
  └── (출력) PRD 문서

digging
  ├── (입력) PRD 문서
  └── (출력) 분석 리포트, 개선된 PRD

/implement
  ├── (입력) PRD 문서
  ├── (호출) architecture-decision agent
  ├── (호출) digging skill (상세 검토 시)
  └── (출력) 구현된 코드

/auto-commit
  ├── (호출) code-review skill
  ├── (호출) code-formatter agent (60-79점 시)
  └── (출력) 커밋 + 푸시
```

---

## Examples

### Full Workflow

```bash
# 1. PRD 생성
User: "결제 기능 만들고 싶어"
→ /prd 실행 → docs/prd/payment.md 생성

# 2. PRD 분석
User: "PRD 검토해줘"
→ digging 실행 → Critical 2개, Major 3개 발견

# 3. PRD 수정 후 구현
User: "이제 만들어줘"
→ /implement 실행
→ architecture-decision: Modular Monolith 추천
→ 사용자 확인: "진행"
→ 코드 구현 완료

# 4. 커밋
User: "커밋해줘"
→ /auto-commit 실행
→ code-review: 85/100 ✅
→ 커밋 + 푸시 완료
```

### Quality Gate Flow

```bash
# Case 1: 고품질 코드
/auto-commit
→ code-review: 88/100 ✅
→ 바로 커밋

# Case 2: 개선 필요
/auto-commit
→ code-review: 72/100 ⚠️
→ code-formatter 자동 실행
→ 재평가: 84/100 ✅
→ 커밋

# Case 3: 품질 미달
/auto-commit
→ code-review: 55/100 ❌
→ 커밋 중단
→ 수동 수정 필요 항목 안내
```

---

## License

MIT License - see [LICENSE](../../LICENSE)
