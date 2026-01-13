---
description: Generate structured PRD documents from vague feature requests. Trigger on "/prd", "PRD 작성해줘", "기능 정의서", "요구사항 문서", "만들어줘", "구현해줘", or when user requests feature specification.
---

# PRD Generation

모호한 기능 요청을 구조화된 PRD 문서로 변환합니다.

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

### 5.1 API Endpoints
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/v1/resource | List resources |
| POST | /api/v1/resource | Create resource |

### 5.2 Database Schema
[스키마 변경 사항]

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

### Phase 3: Output Location

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
- [ ] 우선순위가 명확한가?
- [ ] 의존성이 식별되었는가?

## Rules

1. **Specific**: "카테고리별 필터링 가능" (O) / "검색 가능" (X)
2. **Measurable**: "응답시간 < 200ms" (O) / "빠른 응답" (X)
3. **Testable**: 명확한 수용 기준
4. **Independent**: 요구사항 간 의존성 최소화
