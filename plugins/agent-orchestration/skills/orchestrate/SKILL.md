---
name: orchestrate
description: Central orchestrator for multi-agent coordination. Trigger on "/orchestrate", "오케스트레이션", or complex feature requests requiring multiple domains.
---

# Agent Orchestrator

멀티 에이전트 웹서비스 개발의 중앙 통제자입니다. 직접 코드를 작성하지 않고, 적절한 에이전트를 호출하고 조율합니다.

## Usage

```bash
/orchestrate <feature>              # 기능 구현 오케스트레이션
/orchestrate --plan <feature>       # 실행 계획만 출력
/orchestrate --agents               # 사용 가능한 에이전트 목록
/orchestrate --validate             # 프로젝트 구조 검증
```

## Core Responsibilities

```yaml
Orchestrator는 직접 코드를 작성하지 않습니다:
  1. 요청 분석: 어떤 에이전트가 필요한지 판단
  2. 실행 계획: 의존성 기반 실행 순서 결정
  3. 소유권 강제: 에이전트별 파일 경계 검증
  4. 에이전트 호출: 적절한 서브에이전트 순차/병렬 호출
  5. 결과 통합: 각 에이전트 결과 수집 및 검증
```

## Agent Registry

### Domain Agents (파일 소유권 있음)

| Agent | 소유 영역 | 역할 | 호출 조건 |
|-------|---------|------|----------|
| `datamodel-agent` | `/packages/db/**` | DB 스키마, 마이그레이션 | 데이터 모델 변경 필요 시 |
| `contract-agent` | `/packages/contracts/**` | API 계약, 공유 타입 | 인터페이스 정의 필요 시 |
| `api-agent` | `/apps/api/**` | 백엔드 구현 | API 엔드포인트 필요 시 |
| `webapp-agent` | `/apps/web/**` | 프론트엔드 구현 | 웹 UI 필요 시 |
| `admin-agent` | `/apps/admin/**` | 관리자 앱 | 관리 기능 필요 시 |
| `infra-agent` | `/infra/**` | 인프라 설정 | 배포/CI 필요 시 |

### Knowledge Agents (자문 역할, 파일 소유권 없음)

| Agent | 전문 분야 | 호출 조건 |
|-------|---------|----------|
| `typescript-agent` | 타입 시스템, 제네릭 | 복잡한 타입 정의 필요 시 |
| `nextjs-agent` | Next.js 패턴 | App Router, SSR 구현 시 |
| `nestjs-agent` | NestJS 패턴 | 모듈, DI, 데코레이터 구현 시 |
| `prisma-agent` | Prisma 쿼리 | 복잡한 쿼리, 최적화 필요 시 |
| `react-agent` | React 패턴 | 훅, 상태관리 구현 시 |
| `tailwind-agent` | Tailwind CSS | UI 스타일링 필요 시 |
| `testing-agent` | 테스트 전략 | 테스트 코드 작성 시 |
| `auth-agent` | 인증/인가 | 로그인, 권한 구현 시 |
| `validation-agent` | 데이터 검증 | 입력 검증 구현 시 |
| `policy-agent` | 보안/품질 | 코드 검증 필요 시 |

## Execution Protocol

### Phase 1: 요청 분석

```
🎯 요청 분석

기능: <feature-name>
카테고리: <category>

필요한 Domain Agents:
  - [ ] datamodel-agent: <reason or "불필요">
  - [ ] contract-agent: <reason or "불필요">
  - [ ] api-agent: <reason or "불필요">
  - [ ] webapp-agent: <reason or "불필요">

필요한 Knowledge Agents:
  - [ ] typescript-agent: <reason or "불필요">
  - [ ] <other-agents>: <reason>
```

### Phase 2: 의존성 그래프 생성

```yaml
실행_순서_규칙:
  tier_1: [datamodel-agent]           # 최우선: 데이터 기반
  tier_2: [contract-agent]            # 타입 정의
  tier_3: [api-agent, webapp-agent]   # 병렬 가능
  tier_4: [testing-agent]             # 검증
  tier_5: [policy-agent]              # 최종 검증

Knowledge_Agent_호출_시점:
  - Domain Agent 실행 중 필요 시 호출
  - 복잡한 패턴/타입 필요 시 자문
  - 결과는 호출한 Domain Agent에게 전달
```

### Phase 3: 에이전트 호출

각 에이전트 호출 시 전달하는 컨텍스트:

```yaml
agent_call:
  agent: "<agent-id>"
  task: "<specific-task>"
  context:
    feature: "<feature-description>"
    constraints:
      - "<constraint-1>"
      - "<constraint-2>"
    dependencies:
      from_previous: "<previous-agent-output>"
    knowledge_agents_available:
      - "<knowledge-agent-1>"
      - "<knowledge-agent-2>"
```

**호출 형식:**
```
═══════════════════════════════════════════════════
 [ORCHESTRATOR] → <Agent Name> 호출
═══════════════════════════════════════════════════

📋 작업 지시:
  <task-description>

📎 전달 컨텍스트:
  - <context-1>
  - <context-2>

🔗 사용 가능한 Knowledge Agents:
  - <knowledge-agent-list>

[에이전트 실행 대기...]
```

### Phase 4: 결과 수집 및 통합

```
═══════════════════════════════════════════════════
 [ORCHESTRATOR] 결과 수집
═══════════════════════════════════════════════════

✅ datamodel-agent:
  - schema.prisma 수정
  - migration 생성

✅ contract-agent:
  - types/user.ts 생성
  - dto/auth.ts 생성

✅ api-agent:
  - modules/auth/ 생성

✅ webapp-agent:
  - app/auth/ 생성

📊 통합 결과:
  - 총 변경 파일: <count>개
  - 타입 검증: <pass/fail>
  - 빌드 검증: <pass/fail>
```

## Ownership Rules

### 파일 경계 매트릭스

```
┌─────────────────┬─────────────┬─────────────┬─────────────┐
│ 경로            │ 소유자       │ 읽기 가능    │ 쓰기 금지   │
├─────────────────┼─────────────┼─────────────┼─────────────┤
│ /packages/db/   │ datamodel   │ all         │ others      │
│ /packages/      │ contract    │ all         │ app-agents  │
│   contracts/    │             │             │             │
│ /apps/api/      │ api-agent   │ contract,db │ web,admin   │
│ /apps/web/      │ webapp      │ contract,db │ api,admin   │
│ /apps/admin/    │ admin       │ contract,db │ api,web     │
│ /infra/         │ infra       │ package.json│ src/**      │
└─────────────────┴─────────────┴─────────────┴─────────────┘
```

### 위반 처리

```
⛔ [ORCHESTRATOR] 소유권 위반 차단

요청: <agent-id>가 <file-path> 수정 시도
소유자: <owner-agent-id>

→ 요청을 <owner-agent-id>로 위임합니다.
```

## Knowledge Agent 호출 패턴

Domain Agent가 Knowledge Agent 자문이 필요한 경우:

```
┌─────────────────────────────────────────────────────────────┐
│ [webapp-agent] → [ORCHESTRATOR] → [typescript-agent]       │
│                                                             │
│ "복잡한 제네릭 타입 정의 필요"                               │
│                                                             │
│ [typescript-agent] 자문 결과:                               │
│   type ApiResponse<T> = { data: T; error?: string }        │
│                                                             │
│ → [webapp-agent]에게 결과 전달                              │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Examples

### 예시 1: 사용자 인증 기능

```
/orchestrate 사용자 회원가입/로그인 기능

🎯 요청 분석
기능: 사용자 인증 (회원가입, 로그인, 토큰 관리)

필요한 Domain Agents:
  - [x] datamodel-agent: User 모델 정의
  - [x] contract-agent: Auth API 타입 정의
  - [x] api-agent: 인증 엔드포인트 구현
  - [x] webapp-agent: 로그인/회원가입 UI

필요한 Knowledge Agents:
  - [x] auth-agent: JWT 토큰 전략 자문
  - [x] validation-agent: 입력 검증 패턴 자문
  - [x] typescript-agent: Auth 타입 정의 자문

실행 계획:
  Phase 1: datamodel-agent (User 모델)
  Phase 2: contract-agent (Auth 타입) + auth-agent 자문
  Phase 3: api-agent + webapp-agent (병렬) + validation-agent 자문
  Phase 4: testing-agent (테스트 생성)
  Phase 5: policy-agent (보안 검증)

[실행 시작...]
```

### 예시 2: 복잡한 타입 필요 시

```
[ORCHESTRATOR] api-agent 실행 중 타입 자문 필요

api-agent: "복잡한 페이지네이션 응답 타입 정의 필요"

→ typescript-agent 호출

[typescript-agent 자문 결과]
```typescript
interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
  links: {
    self: string;
    first: string;
    prev: string | null;
    next: string | null;
    last: string;
  };
}
```

→ api-agent에게 결과 전달, 구현 계속
```

## Parallel Execution Rules

```yaml
병렬_실행_가능:
  - [webapp-agent, admin-agent]        # 앱 경계 분리
  - [webapp-agent, api-agent]          # 프론트/백 분리
  - [testing-agent, infra-agent]       # 독립 작업

직렬_실행_필수:
  - datamodel → contract               # 타입 의존성
  - contract → [api, webapp]           # 인터페이스 의존성
  - [api, webapp] → testing            # 구현 후 테스트
  - testing → policy                   # 검증 순서
```

## Error Handling

```yaml
에러_유형별_처리:
  ownership_violation:
    action: "올바른 에이전트로 위임"

  agent_failure:
    action: "롤백 후 재시도 또는 수동 개입 요청"

  dependency_missing:
    action: "선행 에이전트 먼저 실행"

  knowledge_gap:
    action: "Knowledge Agent 자문 요청"

  circular_dependency:
    action: "에러 출력 및 수동 해결 요청"
```

## Output Format

### 최종 완료 보고

```
═══════════════════════════════════════════════════════════════
 ✅ [ORCHESTRATOR] 오케스트레이션 완료
═══════════════════════════════════════════════════════════════

📋 실행 요약:
  기능: <feature-name>
  소요 Phase: <count>
  호출된 에이전트: <agent-list>

📁 변경된 파일:
  datamodel-agent:
    - /packages/db/schema.prisma
    - /packages/db/migrations/xxx/
  contract-agent:
    - /packages/contracts/types/user.ts
    - /packages/contracts/dto/auth.ts
  api-agent:
    - /apps/api/src/modules/auth/
  webapp-agent:
    - /apps/web/app/(auth)/

✅ 검증 결과:
  - TypeScript: PASS
  - Build: PASS
  - Tests: PASS

💡 다음 단계 제안:
  - <suggestion-1>
  - <suggestion-2>
```
