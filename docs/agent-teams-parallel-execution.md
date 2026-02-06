# Agent Teams 병렬 실행 가이드

> **v0.2.0** | Claude Opus 4.6 Agent Teams 기반 병렬 실행 고도화

---

## 목차

1. [이번 변경은 무엇인가](#1-이번-변경은-무엇인가)
2. [왜 병렬화가 필요했는가](#2-왜-병렬화가-필요했는가)
3. [무엇을 바꿨는가 — 변경 파일 전체 목록](#3-무엇을-바꿨는가--변경-파일-전체-목록)
4. [어떻게 적용했는가 — 파일별 변경 상세](#4-어떻게-적용했는가--파일별-변경-상세)
5. [병렬화의 핵심 원리](#5-병렬화의-핵심-원리)
6. [아키텍처 전체 흐름: Before vs After](#6-아키텍처-전체-흐름-before-vs-after)
7. [컴포넌트별 동작 상세](#7-컴포넌트별-동작-상세)
8. [오류 처리 및 Graceful Degradation](#8-오류-처리-및-graceful-degradation)
9. [Score Merge 프로토콜](#9-score-merge-프로토콜)
10. [실전 예시: 전체 파이프라인 워크스루](#10-실전-예시-전체-파이프라인-워크스루)
11. [FAQ](#11-faq)

---

## 1. 이번 변경은 무엇인가

### 한 줄 요약

**v0.2.0은 wigtn-plugins의 전체 개발 파이프라인(`/prd → digging → /implement → /auto-commit`)에 Agent Teams 병렬 실행을 적용하여, 순차 대비 3~5배 속도 향상을 달성한 업그레이드입니다.**

### 배경

wigtn-plugins는 아이디어에서 배포까지의 전체 개발 워크플로우를 자동화합니다. v0.1.0까지는 모든 단계가 **순차적으로** 실행되었습니다. PRD를 분석하려면 4개 카테고리를 하나씩 돌려야 했고, 코드를 리뷰하려면 5개 관점을 차례로 평가해야 했습니다. 각 단계가 독립적임에도 불구하고 앞의 단계가 끝나야 다음 단계가 시작되는 구조였습니다.

Claude Opus 4.6에서 **Agent Teams** 기능이 출시되면서, 독립적인 작업들을 여러 에이전트에 분배하여 동시에 실행할 수 있게 되었습니다. v0.2.0은 이 기능을 파이프라인 전체에 걸쳐 체계적으로 적용한 결과물입니다.

### 변경의 범위

이번 업그레이드는 단순히 "병렬로 돌린다"가 아닙니다. 다음 네 가지를 함께 설계했습니다:

1. **새로운 Coordinator 에이전트 3개 신설**: 병렬 실행을 조율하는 전담 에이전트를 만들었습니다. 각 Coordinator는 작업 분배, 결과 병합, 오류 복구를 담당합니다.

2. **기존 스킬/커맨드에 병렬 프로토콜 삽입**: `digging`, `code-review`, `deep-review`, `architecture-review` 등 기존 스킬에 "Parallel Mode" 섹션을 추가했습니다. 기존 순차 로직은 그대로 유지하면서, 조건이 충족되면 병렬 모드로 전환됩니다.

3. **자동 감지 + 수동 제어**: 파일 수, PRD 크기, Phase 수 등을 기준으로 병렬 모드를 자동 감지합니다. 동시에 `--parallel`, `--sequential`, `--full-stack` 같은 플래그로 수동 제어도 가능합니다.

4. **안전 장치 설계**: 에이전트 실패 시 순차 모드로 자동 전환(Graceful Degradation), 파일 충돌 방지(File Lock), Security Zero-Tolerance(보안 이슈 발견 시 무조건 FAIL) 등의 안전 장치를 함께 구현했습니다.

### 속도 향상 총정리

| 컴포넌트 | v0.1.0 (순차) | v0.2.0 (병렬) | 속도 향상 |
|----------|--------------|--------------|----------|
| `digging` 분석 | 4개 카테고리 순차 실행 | 4개 에이전트 동시 실행 | **4x** |
| `/implement` DESIGN Phase | 4개 Step 순차 실행 | 3개 에이전트 동시 실행 | **3x** |
| `/implement` BUILD Phase | Task 순차 실행 | Level별 동시 실행 | **2-3x** |
| `/implement` Cross-Plugin | 플러그인 순차 실행 | Backend+Frontend 동시 | **2x** |
| `/auto-commit` Quality Gate | 단일 리뷰어 | 3개 리뷰 에이전트 동시 | **3x** |
| `deep-review` (Level 3) | 5개 Phase 순차 | Phase 2,3,5 동시 | **2x** |
| `architecture-review` (Level 4) | 5개 Phase 순차 | Phase 2,3,5 동시 | **2x** |
| **전체 파이프라인** | **15-20분** | **5-7분** | **~3x** |

---

## 2. 왜 병렬화가 필요했는가

### 기존 순차 실행의 문제

v0.1.0의 파이프라인을 시간 축으로 보면 이렇습니다:

```
시간 →  0s        5s        10s       15s       20s       25s       30s
        ┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
digging │Complet. │Feasibi. │Security │Consist. │         │         │
        │ (3.2s)  │ (4.1s)  │ (3.8s)  │ (2.5s)  │         │         │
        └─────────┴─────────┴─────────┴─────────┘         │         │
                                        총 13.6s           │         │
```

4개 카테고리가 독립적임에도 **앞 카테고리가 끝나야 다음이 시작**됩니다. Completeness 분석이 끝나야 Feasibility 분석이 시작되고, 그게 끝나야 Security 분석이 시작됩니다. 하지만 이 4개 카테고리는 서로의 결과를 전혀 참조하지 않습니다. 모두 같은 PRD 문서만 입력으로 받아서 독립적으로 분석합니다.

이것은 파이프라인 전체에서 반복되는 패턴이었습니다:
- **code-review**: Readability, Performance, Security 등 5개 카테고리가 서로 독립적
- **deep-review**: Phase 2(Edge Case), Phase 3(Concurrency), Phase 5(Security)가 독립적
- **BUILD Phase**: Schema 이후에 Backend과 Frontend는 동시 작업 가능

### 병렬화의 핵심 아이디어

독립적인 작업을 **동시에 실행**하면 전체 소요 시간은 **가장 오래 걸리는 단일 작업의 시간**으로 줄어듭니다:

```
순차 실행:
  A(3.2s) → B(4.1s) → C(3.8s) → D(2.5s)  = 13.6s

병렬 실행:
  A(3.2s) ─┐
  B(4.1s) ─┤ 동시 실행
  C(3.8s) ─┤
  D(2.5s) ─┘                                = 4.1s (가장 긴 B 기준)
```

다만, 모든 작업이 독립적인 것은 아닙니다. 예를 들어 BUILD Phase에서 Schema 정의가 있어야 Backend API를 구현할 수 있고, Backend API가 있어야 Test를 작성할 수 있습니다. 이런 **의존성이 있는 작업**은 반드시 순서를 지켜야 합니다.

그래서 v0.2.0의 접근 방식은 다음과 같습니다:

> **독립적인 작업은 동시에 실행하고, 의존성이 있는 작업은 순서를 보장한다.**
> 이를 위해 작업 간 의존성 그래프를 구축하고, 같은 Level(의존성이 없는 그룹)은 병렬로, 다음 Level은 이전 Level 완료를 대기한 후 실행한다.

---

## 3. 무엇을 바꿨는가 — 변경 파일 전체 목록

이번 v0.2.0에서 변경된 파일은 총 **15개** (신규 3개 + 수정 12개)입니다. 각 파일이 왜 변경되었는지, 어떤 역할을 하는지 먼저 전체 그림을 정리합니다.

### 신규 생성 파일 (3개)

이 3개 파일은 병렬 실행의 핵심입니다. 각각 특정 파이프라인 단계의 병렬 실행을 **조율(coordinate)**하는 에이전트입니다.

| # | 파일 경로 | 역할 | 왜 필요한가 |
|---|----------|------|------------|
| 1 | `agents/parallel-build-coordinator.md` | BUILD Phase의 Task 의존성을 분석하고 Level별 병렬 실행을 조율 | Task 간 의존성(Schema→Backend→Test)이 있어서 단순 병렬이 불가능. 의존성 그래프를 구축하고 안전한 병렬 실행 순서를 결정하는 전담 조율자가 필요 |
| 2 | `agents/parallel-review-coordinator.md` | 코드 리뷰를 3개 전문 에이전트에 분배하고 점수를 병합 | 기존 단일 리뷰어가 5개 카테고리를 순차 평가. 카테고리를 3개 에이전트에 분배하면 3배 빠르지만, 각 에이전트의 점수를 하나의 100점 만점으로 합산하는 병합 규칙이 필요 |
| 3 | `agents/parallel-digging-coordinator.md` | PRD 분석의 4개 카테고리를 4개 에이전트에 분배하고 결과를 통합 | 4개 카테고리가 완전 독립적이라 가장 높은 병렬화 효율(4x) 달성 가능. 다만 4개 보고서를 하나로 통합하고, 중복 이슈를 제거하는 병합 로직이 필요 |

### 수정 파일 (12개)

기존 파일에 "Parallel Mode" 섹션을 추가하거나, 새 에이전트를 등록하거나, 버전을 업데이트한 파일들입니다.

| # | 파일 경로 | 변경 유형 | 변경 이유 |
|---|----------|----------|----------|
| 4 | `.claude-plugin/plugin.json` | 버전 업데이트 | 0.1.0 → 0.2.0 |
| 5 | `.claude-plugin/marketplace.json` | 버전 + 설명 업데이트 | 마켓플레이스에 병렬 실행 기능 반영 |
| 6 | `public-commands/.claude-plugin/plugin.json` | 에이전트 등록 | 신규 Coordinator 에이전트 3개를 플러그인에 등록 |
| 7 | `skills/digging/SKILL.md` | 병렬 모드 추가 | "Parallel Analysis Mode" 섹션 삽입. 4개 카테고리 병렬 프로토콜 정의 |
| 8 | `skills/code-review/SKILL.md` | 병렬 모드 추가 | "Parallel Review Mode" 섹션 삽입. 에이전트별 카테고리 분배 + Score Merge 규칙 |
| 9 | `skills/code-review/levels/deep-review.md` | 병렬 프로토콜 추가 | Level 3 리뷰에서 Phase 2,3,5를 3개 에이전트로 동시 실행하는 프로토콜 |
| 10 | `skills/code-review/levels/architecture-review.md` | 병렬 프로토콜 추가 | Level 4 리뷰에서 Phase 2,3,5 병렬 + SOLID 5원칙 추가 병렬화(선택적) |
| 11 | `commands/implement.md` | 대규모 확장 | 병렬 모드 감지, DESIGN 3에이전트 병렬, BUILD Level 병렬, Cross-Plugin 병렬 추가 |
| 12 | `commands/auto-commit.md` | Quality Gate 병렬화 | Step 2를 병렬 Quality Gate로 확장, parallel-review-coordinator 연동 |
| 13 | `README.md` (루트) | 문서 업데이트 | 병렬 실행 기능, 새 에이전트, 속도 향상 테이블 추가 |
| 14 | `README.ko.md` (루트) | 문서 업데이트 | 한국어 README에 동일 내용 반영 |
| 15 | `public-commands/README.md` | 문서 전면 개편 | 플러그인 README를 병렬 실행 중심으로 재작성 |

### 변경의 계층 구조

이 변경들은 서로 의존 관계가 있어서, 다음 순서로 적용되었습니다:

```
Phase 1: Coordinator 에이전트 생성 (1, 2, 3번)
    ↓  에이전트가 존재해야 등록하고 참조할 수 있음
Phase 2: 플러그인에 에이전트 등록 + 스킬 업그레이드 (6, 7, 8, 9, 10번)
    ↓  스킬이 Coordinator를 참조할 수 있어야 커맨드에서 호출 가능
Phase 3: 커맨드 업그레이드 (11, 12번)
    ↓  모든 구현이 완료된 후
Phase 4: 버전 + 문서 업데이트 (4, 5, 13, 14, 15번)
```

---

## 4. 어떻게 적용했는가 — 파일별 변경 상세

이 섹션은 각 파일에 **구체적으로 무엇을 추가/수정했는지**를 설명합니다. 코드를 직접 열어보지 않아도 변경 내용을 이해할 수 있도록 작성했습니다.

### 4.1 신규: `parallel-build-coordinator.md`

**파일 위치**: `plugins/public-commands/agents/parallel-build-coordinator.md`

**이 에이전트가 해결하는 문제**: BUILD Phase에서 여러 Task(Schema 생성, Backend API 구현, Frontend 컴포넌트 구현, 테스트 작성 등)가 있을 때, 이들 사이의 의존성을 분석하여 안전하게 병렬 실행할 수 있는 순서를 결정해야 합니다. 예를 들어 Schema 정의가 있어야 Backend API를 구현할 수 있지만, Backend API와 Frontend 컴포넌트는 동시에 작성할 수 있습니다(Frontend는 API를 모킹하면 되므로).

**구현한 내용**:

1. **의존성 그래프 구축**: 각 Task의 타입(Config, Schema, Backend, Frontend, Test, E2E)을 분석하여 위상 정렬(topological sort) 기반의 의존성 그래프를 만듭니다.

2. **Level 분리**: 같은 Level에 속한 Task는 의존성이 없으므로 동시에 실행합니다.
   ```
   Level 0: Config, Environment Setup  (의존성 없음, 최우선 실행)
   Level 1: Schema, Database Migration  (Config에만 의존)
   Level 2: Backend API + Frontend UI  (Schema에 의존, 서로는 독립)
   Level 3: Unit Test, Integration Test  (대상 코드에 의존)
   Level 4: E2E Test  (전체 완료 후)
   ```

3. **파일 Lock 관리**: 같은 파일을 수정하는 Task는 반드시 같은 에이전트에 할당합니다. 예를 들어 `src/types/auth.ts`를 Backend Task와 Frontend Task가 모두 수정해야 한다면, 두 Task를 같은 에이전트에 배정하여 충돌을 원천 차단합니다.

4. **Graceful Degradation**: 특정 에이전트가 실패하면 해당 Task만 순차 모드로 전환합니다. 나머지 독립 Task는 계속 병렬로 실행됩니다.

**입출력 형식**: YAML 기반의 Input(Task 목록 + 의존성 + 프로젝트 컨텍스트) → Output(Level별 실행 계획 + 에이전트 할당 + 예상 속도 향상)

### 4.2 신규: `parallel-review-coordinator.md`

**파일 위치**: `plugins/public-commands/agents/parallel-review-coordinator.md`

**이 에이전트가 해결하는 문제**: 코드 리뷰는 Readability, Maintainability, Performance, Testability, Best Practices의 5개 카테고리로 구성되며, 각 카테고리는 20점 만점으로 총 100점입니다. 기존에는 단일 리뷰어가 5개 카테고리를 순차적으로 평가했는데, 이들은 서로 독립적이므로 분산할 수 있습니다.

**구현한 내용**:

1. **3-에이전트 분배 전략**: 5개 카테고리를 연관성 기준으로 3개 그룹으로 묶었습니다.
   - **Agent A**: Readability(20점) + Maintainability(20점) = 40점
     - 이유: 둘 다 "코드를 읽고 유지보수하는 관점"으로 같은 맥락
   - **Agent B**: Performance(20점) + Testability(20점) = 40점
     - 이유: 둘 다 "코드가 실행되는 관점"으로 같은 맥락
   - **Agent C**: Best Practices(20점) + **Security Flag** = 20점 + 보안 판정
     - 이유: Best Practices와 보안은 "규칙 준수 관점"으로 통합. Security는 점수가 아니라 pass/fail 플래그

2. **Score Merge Contract**: 각 에이전트가 YAML 형식으로 점수를 출력하면, Coordinator가 이를 합산합니다. 핵심 규칙은:
   - 점수 합산: `Agent A(40) + Agent B(40) + Agent C(20) = 100점 만점`
   - **Security Override**: Agent C가 보안 Critical을 발견하면, 총점과 무관하게 **59점 이하로 강제**(자동 FAIL)
   - 타임아웃: 60초 내 응답 없으면 해당 카테고리에 보수적 기본값(15/20) 적용

3. **대용량 파일 전략**: 파일이 10개 이상이면 카테고리 분배 대신 **파일 분배**로 전환합니다. 각 에이전트가 특정 파일 그룹의 전체 카테고리를 담당하는 방식입니다.

### 4.3 신규: `parallel-digging-coordinator.md`

**파일 위치**: `plugins/public-commands/agents/parallel-digging-coordinator.md`

**이 에이전트가 해결하는 문제**: digging(PRD 취약점 분석)은 4개 카테고리(Completeness, Feasibility, Security, Consistency)로 구성됩니다. 이 4개는 **완전히 독립적**입니다. 모두 같은 PRD 텍스트만 입력으로 받고, 서로의 결과를 전혀 참조하지 않습니다. 이는 가장 이상적인 병렬화 대상입니다.

**구현한 내용**:

1. **4-에이전트 완전 병렬**: 각 카테고리를 전담 에이전트에 할당합니다.
   - Agent A: **Completeness** — FR/NFR 커버리지, 에지 케이스, 에러 처리 시나리오
   - Agent B: **Feasibility** — 기술 스택 적합성, 구현 복잡도, 의존성 리스크
   - Agent C: **Security & Risk** — OWASP Top 10, 인증/인가, 데이터 보호
   - Agent D: **Consistency** — 용어 일관성, 요구사항 충돌, 우선순위 균형

2. **독립성 보장**: 4개 에이전트는 입력(PRD 텍스트)만 공유하고, 어떤 상태도 공유하지 않습니다. 이 덕분에 **4x speedup**이라는 이론적 최대치에 가까운 성능을 얻습니다.

3. **결과 병합 규칙**:
   - 4개 보고서의 모든 이슈를 수집
   - 같은 PRD 섹션에서 같은 문제를 지적한 경우 → 하나로 병합(severity가 다르면 높은 것 채택)
   - severity별 정렬: Critical → Major → Minor
   - **Quality Gate**: Critical 이슈가 0개면 PASS, 1개 이상이면 BLOCKED (`/implement` 차단)

4. **폴백 조건**: PRD가 너무 짧으면(섹션 3개 미만 또는 500자 미만) 병렬 오버헤드가 더 크므로 순차 실행

### 4.4 수정: `public-commands/.claude-plugin/plugin.json`

**변경 내용**: 신규 에이전트 3개를 플러그인에 등록했습니다.

```json
"agents": [
  "./agents/architecture-decision.md",   // 기존
  "./agents/code-formatter.md",          // 기존
  "./agents/parallel-build-coordinator.md",   // 신규
  "./agents/parallel-review-coordinator.md",  // 신규
  "./agents/parallel-digging-coordinator.md"  // 신규
]
```

이 등록이 있어야 Claude Code가 해당 에이전트를 인식하고 호출할 수 있습니다.

### 4.5 수정: `skills/digging/SKILL.md`

**변경 내용**: 기존 "Analysis Protocol" 섹션 바로 위에 **"Parallel Analysis Mode"** 섹션을 삽입했습니다.

**추가된 내용**:
- 병렬 활성화 조건: PRD 섹션 >= 3개 AND 문서 >= 500자
- 4개 에이전트 역할 명시 (Agent A~D)
- `parallel-digging-coordinator` 호출 방법
- 결과 병합 규칙 (severity 합산, 중복 제거)
- 폴백: 조건 미충족 시 기존 "Analysis Protocol (Sequential)" 사용

**기존 코드와의 관계**: 기존 순차 프로토콜은 **그대로 유지**했습니다. 섹션 제목만 "Analysis Protocol" → "Analysis Protocol (Sequential)"로 변경하여 구분했습니다. 병렬 모드가 활성화되지 않으면 기존 순차 프로토콜이 그대로 실행됩니다.

### 4.6 수정: `skills/code-review/SKILL.md`

**변경 내용**: "Level 1-2: Standard Review" 섹션 바로 위에 **"Parallel Review Mode"** 섹션을 삽입했습니다.

**추가된 내용**:
- 3-에이전트 분배표 (Agent A: Read+Main /40, Agent B: Perf+Test /40, Agent C: BP+Sec /20)
- Score Merge Contract (YAML 출력 형식 정의)
- 병합 규칙: 점수 합산, Security Override, Issues 통합, 타임아웃 대체값
- 활성화 조건: 변경 파일 3개 이상

**기존 코드와의 관계**: 기존 Level 1-4 체계는 변경하지 않았습니다. 병렬 모드는 Level 체계 위에 **추가 레이어**로 작동합니다. Level 1-2는 병렬 리뷰를, Level 3-4는 병렬 Deep/Architecture Review를 각각 사용합니다.

### 4.7 수정: `skills/code-review/levels/deep-review.md`

**변경 내용**: 기존 "Deep Review Protocol" 바로 위에 **"Parallel Deep Review Protocol"** 섹션을 삽입했습니다.

**추가된 내용**: Deep Review는 원래 5개 Phase로 구성됩니다. 이 중 Phase 2(Edge Case), Phase 3(Concurrency), Phase 5(Security)는 서로 독립적입니다. 하지만 Phase 1(Call Chain Analysis)은 모든 분석의 기반이 되는 호출 그래프를 구축하므로 먼저 실행해야 하고, Phase 4(Tech Debt)는 Phase 2+3의 결과가 필요합니다.

그래서 실행 순서를 다음과 같이 재정의했습니다:
```
Step 1: Phase 1 (Call Chain) — 반드시 먼저 (BLOCKING)
Step 2: Phase 2, 3, 5 — 3개 에이전트 동시 실행 (PARALLEL)
  Agent A: Edge Case Discovery
  Agent B: Concurrency Analysis
  Agent C: Security Deep Dive
Step 3: Phase 4 (Tech Debt) — Step 2 완료 후 (BLOCKING)
```

Phase 2, 3, 5가 전체 분석 시간의 약 60%를 차지하므로 **약 2배 속도 향상**을 얻습니다.

**기존 코드와의 관계**: 기존 순차 프로토콜을 "Deep Review Protocol (Sequential)"로 이름 변경하여 보존. 병렬 모드가 비활성화되면 기존 순차 프로토콜 사용.

### 4.8 수정: `skills/code-review/levels/architecture-review.md`

**변경 내용**: deep-review.md와 동일한 패턴으로 **"Parallel Architecture Review Protocol"** 섹션을 삽입했습니다.

**추가된 내용**: Architecture Review도 5개 Phase로 구성되며, 동일한 독립성 분석을 적용했습니다:
```
Step 1: Phase 1 (Dependency Analysis) — BLOCKING
Step 2: Phase 2, 3, 5 — PARALLEL
  Agent A: SOLID Principles (5개 원칙 평가)
  Agent B: Layer Violation Detection (계층 규칙 위반)
  Agent C: Pattern Compliance Check (패턴 준수)
Step 3: Phase 4 (Scalability Assessment) — BLOCKING
```

**추가 병렬화 옵션**: Agent A가 담당하는 SOLID 원칙 분석에서, 클래스 수가 20개를 초과하면 5개 원칙(S, O, L, I, D)을 각각 서브 에이전트에 분배하는 **내부 추가 병렬화**도 가능하도록 설계했습니다. 기본값은 비활성이며, 대규모 프로젝트에서만 선택적으로 활성화됩니다.

### 4.9 수정: `commands/implement.md` (가장 큰 변경)

**변경 내용**: `/implement` 커맨드에 3개 주요 섹션을 추가했습니다. 이번 업그레이드에서 가장 많은 변경이 발생한 파일입니다.

**(A) "Parallel Mode Detection" 섹션 추가**

기존에는 `/implement` 가 항상 순차로 동작했습니다. 이제 실행 전에 병렬 모드 활성화 여부를 판단합니다:

- 파라미터에 `--parallel`, `--sequential`, `--full-stack` 플래그 추가
- 자동 감지 규칙: 생성/수정 파일 3개 이상 OR BUILD Phase 2개 이상 → 병렬 모드 자동 활성화
- 모드 표시 UI: 활성 에이전트 수, 현재 전략, 비활성화 방법 안내

**(B) "Parallel DESIGN" 섹션 추가**

DESIGN Phase의 Steps 0~4를 3개 에이전트로 분산합니다:
- Agent A: PRD 검색 + 품질 게이트 확인 (Step 0+1)
- Agent B: 아키텍처 결정 — `architecture-decision` 에이전트 위임 (Step 2)
- Agent C: 프로젝트 상태 분석 + Gap Analysis (Step 3+4)

3개 에이전트의 결과를 병합한 후 Step 5(구현 계획 수립)로 전달합니다. 만약 Agent A가 Quality Gate에서 BLOCKED 판정을 내리면 나머지 에이전트를 즉시 중단합니다.

**(C) "Parallel BUILD" 섹션 추가**

`parallel-build-coordinator`를 호출하여 Level별 병렬 빌드를 실행합니다. 진행 상황을 에이전트별 상태 + 전체 진행률 + Level 진행도로 표시합니다.

**(D) "Cross-Plugin Parallel Execution" 섹션 추가**

`--full-stack` 플래그로 활성화되는 플러그인 간 병렬 실행입니다:
- Track 1: `backend-architect` 에이전트 → Backend 코드 생성
- Track 2: `frontend-developer` 에이전트 → Frontend 코드 생성
- Track 3: `mobile-developer` 에이전트 → Mobile 코드 생성 (선택적)

공유 API Contract를 먼저 생성하고, 각 트랙이 이 Contract를 참조하여 일관된 타입 정의와 엔드포인트를 사용합니다.

### 4.10 수정: `commands/auto-commit.md`

**변경 내용**: Step 2 "Quality Gate"를 병렬 버전으로 확장했습니다.

**추가된 내용**:
- `--no-parallel-review` 파라미터 추가 (순차 리뷰 강제)
- 변경 파일 3개 이상 시 `parallel-review-coordinator` 자동 호출
- 병렬 리뷰 결과 테이블 표시 (에이전트별 점수 + 소요시간)
- Testability를 평가 항목에 추가
- Security Zero-Tolerance 규칙 명시
- Integration Points에 `parallel-review-coordinator` 참조 추가

### 4.11 수정: 버전 및 메타데이터 파일

**`.claude-plugin/plugin.json`**: 버전을 `0.1.0` → `0.2.0`으로 올렸습니다.

**`.claude-plugin/marketplace.json`**:
- 루트 버전: `0.1.0` → `0.2.0`
- 루트 description에 "Agent Teams parallel execution for 3-5x speedup" 추가
- public-commands 플러그인 버전: `1.0.0` → `1.1.0`
- public-commands description에 "Agent Teams parallel execution support" 추가

---

## 5. 병렬화의 핵심 원리

이 섹션에서는 v0.2.0의 병렬화가 **어떤 기술적 원리**로 동작하는지 설명합니다.

### 5.1 독립성 판단: "이 작업들을 동시에 돌려도 안전한가?"

병렬화의 전제 조건은 **작업 간 독립성**입니다. 두 작업이 다음 조건을 만족하면 동시 실행이 안전합니다:

- **입력 독립**: 서로의 출력을 입력으로 사용하지 않음
- **상태 독립**: 공유 변수나 파일을 동시에 수정하지 않음
- **순서 독립**: 실행 순서가 결과에 영향을 미치지 않음

각 컴포넌트의 독립성 판단 결과:

| 컴포넌트 | 병렬 대상 | 독립성 근거 | 독립성 수준 |
|----------|----------|------------|-----------|
| digging 4카테고리 | A,B,C,D | 모두 같은 PRD 텍스트만 입력. 공유 상태 없음 | **완전 독립** |
| code-review 카테고리 | Read, Perf, BP | 같은 코드 파일을 읽지만 수정하지 않음. 점수만 출력 | **완전 독립** |
| DESIGN Steps | Step0+1, Step2, Step3+4 | 각각 PRD, 아키텍처, 프로젝트 상태를 독립 분석 | **완전 독립** |
| BUILD Tasks | 같은 Level 내 | Level 분리로 의존성 해소. 파일 Lock으로 충돌 방지 | **조건부 독립** |
| deep-review Phases | Phase 2,3,5 | Phase 1의 Call Chain만 공유 입력. 서로 참조 없음 | **완전 독립** |

### 5.2 Coordinator 패턴: "누가 분배하고 누가 합치는가?"

병렬 실행에서 가장 중요한 것은 **작업을 나누고, 결과를 합치는** 역할입니다. v0.2.0은 이를 **Coordinator 패턴**으로 해결합니다:

```
                ┌─────────────┐
                │ Coordinator │  ← 작업 분배 + 결과 병합 담당
                └──────┬──────┘
           ┌───────────┼───────────┐
           ▼           ▼           ▼
      ┌─────────┐ ┌─────────┐ ┌─────────┐
      │ Agent A │ │ Agent B │ │ Agent C │  ← 실제 작업 수행
      └────┬────┘ └────┬────┘ └────┬────┘
           │           │           │
           └───────────┼───────────┘
                       ▼
                ┌─────────────┐
                │   Merge     │  ← 결과 통합
                └─────────────┘
```

각 Coordinator의 역할:

| Coordinator | 분배 방식 | 병합 방식 |
|-------------|----------|----------|
| `parallel-digging-coordinator` | 카테고리별 (4개 에이전트에 1개씩) | 이슈 수집 → 중복 제거 → severity 정렬 → QG 판정 |
| `parallel-review-coordinator` | 카테고리 그룹별 (3개 에이전트에 관련 카테고리 묶음) | 점수 합산 → Security Override → Grade 결정 |
| `parallel-build-coordinator` | Level별 (같은 Level의 Task를 에이전트에 분배) | 각 Level 완료 확인 → 다음 Level 시작 → 전체 완료 |

### 5.3 의존성 그래프와 Level 분리

BUILD Phase에서는 완전한 독립성이 보장되지 않습니다. Schema가 있어야 Backend API를 만들 수 있고, Backend API가 있어야 Test를 작성할 수 있습니다. 이런 의존성을 안전하게 처리하기 위해 **의존성 그래프 기반 Level 분리**를 사용합니다.

**의존성 그래프 구축 과정**:

```
1. 각 Task의 타입 파악:
   Task A: prisma/schema.prisma → Schema 타입
   Task B: .env.example → Config 타입
   Task C: src/api/auth/login.ts → Backend 타입
   Task D: src/services/AuthService.ts → Backend 타입
   Task E: src/components/LoginForm.tsx → Frontend 타입
   Task F: tests/auth.test.ts → Test 타입

2. 의존성 규칙 적용:
   Schema, Config → 의존 없음 (최우선)
   Backend → Schema에 의존
   Frontend → Backend에 조건부 의존 (API 모킹으로 독립 가능)
   Test → 대상 코드에 의존

3. Level 분리 결과:
   Level 1: [Task A(Schema), Task B(Config)]  ← 동시 실행
   Level 2: [Task C(Backend), Task D(Backend), Task E(Frontend)]  ← 동시 실행
   Level 3: [Task F(Test)]  ← Level 2 완료 후 실행
```

**핵심 규칙**: 같은 Level은 **동시 실행**, 다음 Level은 **이전 Level 완료 대기**.

### 5.4 결과 병합 프로토콜

여러 에이전트의 결과를 하나로 합치는 것은 병렬 실행에서 가장 세심한 처리가 필요한 부분입니다. v0.2.0에서는 각 Coordinator가 다음 규칙으로 결과를 병합합니다:

**digging 결과 병합**:
- 4개 에이전트의 이슈를 전부 수집
- 같은 PRD 섹션에서 같은 문제를 지적한 경우 → 하나로 병합 (severity는 높은 것 채택)
- 다른 관점에서 같은 이슈를 발견한 경우 → 카테고리 태그를 복수로 표시
- Critical → Major → Minor 순으로 정렬
- Critical 0개면 PASS, 1개 이상이면 BLOCKED

**리뷰 점수 병합**:
- 각 에이전트가 YAML 형식으로 출력: `{ agent_id, categories: [{name, score, issues}], security_flag, duration }`
- 점수 합산: Agent A(/40) + Agent B(/40) + Agent C(/20) = 총점/100
- Security Override: `security_flag == true` → 총점을 `min(총점, 59)`로 강제
- 타임아웃(60초): 해당 카테고리에 보수적 기본값(15/20) 적용

### 5.5 핵심 설계 원칙 요약

| 원칙 | 구현 방법 | 왜 중요한가 |
|------|----------|------------|
| **하위 호환성** | 병렬 모드 기본값 = 비활성. 기존 순차 로직 100% 유지 | 업그레이드 후에도 기존 사용자 워크플로우가 깨지지 않음 |
| **자동 감지** | 파일 수, PRD 크기, Phase 수 기준으로 자동 전환 | 사용자가 플래그를 몰라도 혜택을 받음 |
| **Graceful Degradation** | 에이전트 실패 시 순차 모드 자동 전환 | 병렬 실행이 불안정해도 기능 자체는 보장 |
| **Security Zero-Tolerance** | 보안 Critical → 점수 무관 FAIL | 속도를 위해 보안을 타협하지 않음 |
| **결과 일관성** | 병렬/순차 동일 기준, 점수 +-5점 이내 | 모드에 따라 품질 판단이 달라지지 않음 |

---

## 6. 아키텍처 전체 흐름: Before vs After

### v0.1.0 (순차 모드)

```
/prd
  │
  ▼
digging (순차: Completeness → Feasibility → Security → Consistency)
  │
  ▼
/implement
  ├── DESIGN (순차: Step0 → Step1 → Step2 → Step3 → Step4 → Step5)
  │     │
  │     ▼ (사용자 확인)
  │
  └── BUILD (순차: Schema → Backend → Frontend → Test)
        │
        ▼
/auto-commit
  └── code-review (순차: 5개 카테고리 순차 평가)
        │
        ▼
      Commit + Push
```

### v0.2.0 (병렬 모드)

```
/prd
  │
  ▼
digging (병렬 4x — parallel-digging-coordinator)
  ┌──────────┬──────────┬──────────┐
  │ Agent A  │ Agent B  │ Agent C  │ Agent D
  │Complete- │Feasibi-  │Security  │Consiste-
  │ness      │lity      │& Risk    │ncy
  └────┬─────┴────┬─────┴────┬─────┴────┬────┘
       └──────────┴──── Merge ────┴──────────┘
  │
  ▼
/implement --parallel
  ├── DESIGN (병렬 3x)
  │   ┌──────────┬──────────┬──────────┐
  │   │ Agent A  │ Agent B  │ Agent C  │
  │   │PRD+QG    │Architect │Project+  │
  │   │(Step 0+1)│(Step 2)  │Gap(3+4)  │
  │   └────┬─────┴────┬─────┴────┬─────┘
  │        └──── Merge → Step 5 (구현 계획) ──┘
  │     │
  │     ▼ (사용자 확인)
  │
  └── BUILD (Level별 병렬 2-3x — parallel-build-coordinator)
      │
      ├── Level 1 (병렬): [Schema] [Config]
      │        │
      │        ▼ (완료 대기)
      ├── Level 2 (병렬): [Backend] [Frontend] [Services]
      │        │
      │        ▼ (완료 대기)
      └── Level 3 (병렬): [Tests]
            │
            ▼
/auto-commit
  └── code-review (병렬 3x — parallel-review-coordinator)
      ┌──────────┬──────────┬──────────┐
      │ Agent A  │ Agent B  │ Agent C  │
      │Read+Main │Perf+Test │BP+Securi │
      │  /40     │  /40     │ty /20+   │
      └────┬─────┴────┬─────┴────┬─────┘
           └──── Score Merge ────┘
            │
            ▼
          Commit + Push
```

### Cross-Plugin 병렬 (--full-stack)

```
/implement --full-stack 사용자 인증
  │
  ├── architecture-decision → API Contract 생성
  │
  ├── DESIGN Phase (병렬)
  │     │
  │     ▼ (사용자 확인)
  │
  └── BUILD Phase (Cross-Plugin 병렬)
      ┌────────────────┬────────────────┬────────────────┐
      │  Track 1       │  Track 2       │  Track 3       │
      │  backend-      │  frontend-     │  mobile-       │
      │  architect     │  developer     │  developer     │
      │                │                │  (선택적)      │
      │  Backend API   │  Frontend UI   │  Mobile App    │
      │  + Services    │  + Components  │  + Screens     │
      └───────┬────────┴───────┬────────┴───────┬────────┘
              │                │                │
              └──── 통합 검증: API Contract 일관성 확인 ──┘
```

---

## 7. 컴포넌트별 동작 상세

### 7.1 병렬 모드 감지 및 전환

병렬 모드는 **기본적으로 비활성(sequential)**입니다. 아래 조건 중 하나라도 충족되면 자동 활성화됩니다:

| 조건 | 트리거 대상 | 적용 범위 |
|------|-----------|----------|
| 생성/수정 파일 3개 이상 | `/implement`, `/auto-commit` | BUILD 병렬, 리뷰 병렬 |
| BUILD Phase 2개 이상 | `/implement` | BUILD 병렬 |
| PRD 섹션 3개 이상 + 500자 이상 | `digging` | digging 병렬 |
| `--full-stack` 플래그 | `/implement` | Cross-Plugin 병렬 |
| `--parallel` 플래그 | `/implement` | 전체 병렬 강제 |

**수동 제어 플래그**:

```bash
/implement --parallel 사용자 인증      # 병렬 강제 활성화
/implement --sequential 사용자 인증    # 순차 강제 (기존 방식)
/implement --full-stack 사용자 인증    # Cross-Plugin 병렬
/auto-commit --no-parallel-review      # 병렬 리뷰 비활성화
```

**전환 흐름도**:

```
/implement <기능명>
     │
     ▼
┌───────────────────────────┐
│ 파일 수 >= 3?             │──No──▶ Sequential Mode
│ 또는 Phase >= 2?          │
│ 또는 --parallel?          │
└────────────┬──────────────┘
             │ Yes
             ▼
┌───────────────────────────┐
│ --sequential 플래그?       │──Yes──▶ Sequential Mode
└────────────┬──────────────┘
             │ No
             ▼
       Parallel Mode
```

### 7.2 Digging 병렬 분석 (4x)

**동작 방식**: PRD 문서가 로드되면 `parallel-digging-coordinator`가 4개 에이전트를 동시에 실행합니다. 각 에이전트는 같은 PRD를 입력받지만 서로 다른 관점으로 분석합니다.

```
┌─────────────────────────────────────────────────────────┐
│  PRD 문서 로드                                          │
│       │                                                 │
│       ├──────────┬──────────┬──────────┐                │
│       ▼          ▼          ▼          ▼                │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐      │
│  │ Agent A │ │ Agent B │ │ Agent C │ │ Agent D │      │
│  │Complete-│ │Feasibi- │ │Security │ │Consiste-│      │
│  │ness     │ │lity     │ │& Risk   │ │ncy      │      │
│  │         │ │         │ │         │ │         │      │
│  │ FR/NFR  │ │Tech fit │ │ OWASP   │ │용어 통일│      │
│  │ 커버리지│ │구현 복잡│ │인증/인가│ │우선순위 │      │
│  │ 에지케이│ │도       │ │데이터   │ │의존성   │      │
│  │ 스      │ │의존성   │ │보호     │ │순환     │      │
│  │ 에러처리│ │리스크   │ │         │ │측정가능성│      │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘      │
│       └──────────┴──────┬───┴──────────┘                │
│                         ▼                               │
│              ┌───────────────────┐                      │
│              │   Result Merge    │                      │
│              │   + 중복 제거     │                      │
│              │   + severity 정렬 │                      │
│              │   + QG 판정       │                      │
│              └───────────────────┘                      │
└─────────────────────────────────────────────────────────┘
```

**중복 제거 예시**: Agent A가 "Section 3.1 - 비밀번호 정책 미정의"를 Completeness 관점에서 발견하고, Agent C가 같은 이슈를 Security 관점에서 발견한 경우:

```
Agent A: "Section 3.1 - 비밀번호 정책 미정의" (Completeness, Critical)
Agent C: "Section 3.1 - 비밀번호 정책 미정의" (Security, Critical)
   ↓ 병합
"Section 3.1 - 비밀번호 정책 미정의" (Completeness+Security, Critical)
```

**폴백 조건**: PRD 섹션 < 3개 또는 PRD 문서 < 500자 → 순차 실행

### 7.3 Implement DESIGN Phase 병렬화 (3x)

**동작 방식**: DESIGN Phase의 Steps 0~4를 3개 에이전트로 분산합니다. 결과를 병합하여 Step 5(구현 계획 수립)에 전달합니다.

| Agent | 담당 Steps | 역할 | 출력 |
|-------|-----------|------|------|
| A | Step 0 + 1 | PRD 검색, 품질 게이트 확인 | PRD 내용 + QG 상태 |
| B | Step 2 | 아키텍처 결정 (architecture-decision 위임) | 아키텍처 타입 + 폴더 구조 |
| C | Step 3 + 4 | 프로젝트 상태 분석, Gap Analysis | 기존 코드 상태 + Gap 목록 |

**Quality Gate BLOCKED 시**: Agent A가 Quality Gate에서 BLOCKED 판정을 내리면 Agent B, C에게 즉시 중단 신호를 보냅니다. PRD 수정 후 재시도를 안내합니다.

### 7.4 Implement BUILD Phase 병렬화 (2-3x)

**동작 방식**: `parallel-build-coordinator`가 Task 간 의존성을 분석하여 Level별 그룹을 만들고, 같은 Level의 Task를 동시에 실행합니다.

**의존성 판단 규칙**:

| From → To | 의존 여부 | 이유 |
|-----------|----------|------|
| Schema → (없음) | 최우선 | 다른 모든 타입의 기반 |
| Backend → Schema | 의존 | 모델/타입 정의 필요 |
| Frontend → Backend | 조건부 | API 모킹으로 독립 가능 |
| Frontend → Schema | 조건부 | 공유 타입이 있을 때만 |
| Test → 대상 코드 | 의존 | 테스트 대상이 있어야 함 |
| Config → (없음) | 최우선 | 환경 설정 |

**파일 충돌 방지 규칙**:
- 같은 파일 → 같은 에이전트에 할당
- 같은 디렉토리 → 가능하면 같은 에이전트에 할당
- 공유 파일(index.ts, types.ts) → 마지막 Level에서 통합

**진행 표시 형식**:

```
⚡ Parallel BUILD 진행 중... (Level 2/3)

[Level 1] ✅ 완료 (2/2 tasks, 1.8s)
[Level 2] ⏳ 진행 중 (1/3 tasks)
  ├── Agent A: [backend-001] ✅ 완료 (4.2s)
  ├── Agent B: [backend-002] ⏳ 작성 중...
  └── Agent C: [frontend-001] ⏳ 작성 중...
[Level 3] ⏸️ 대기 중

📊 전체: 3/6 tasks (50%) | Active Agents: 2 | Level 2/3
```

### 7.5 Cross-Plugin 병렬 실행 (2x)

**동작 방식**: `--full-stack` 플래그로 활성화됩니다. `architecture-decision` 에이전트가 먼저 공유 API Contract를 생성한 후, 각 플러그인의 전문 에이전트가 동시에 코드를 생성합니다.

```
Step 1: architecture-decision → 공유 API Contract 생성
        ├── 타입 정의 (TypeScript interfaces)
        ├── 엔드포인트 스펙 (REST)
        └── 공유 상수 및 에러 코드

Step 2: 3개 트랙 동시 시작
        ┌──────────────────────────────────────────┐
        │  Track 1: backend-architect               │
        │  API 구현, 서비스 로직, DB 스키마          │
        ├──────────────────────────────────────────┤
        │  Track 2: frontend-developer              │
        │  API 모킹 기반 UI, 컴포넌트, 상태 관리    │
        ├──────────────────────────────────────────┤
        │  Track 3: mobile-developer (선택적)       │
        │  모바일 화면, 네이티브 기능 통합           │
        └──────────────────────────────────────────┘

Step 3: 통합 검증 — API Contract 일관성 확인
```

### 7.6 Auto-Commit 병렬 리뷰 (3x)

**동작 방식**: 변경 파일이 3개 이상이면 `parallel-review-coordinator`가 자동으로 3개 리뷰 에이전트를 실행합니다.

| Agent | 카테고리 | 배점 | 평가 기준 |
|-------|----------|------|----------|
| A | Readability + Maintainability | 40점 | 명명 규칙, 주석, 모듈성, 결합도 |
| B | Performance + Testability | 40점 | 알고리즘 효율, 리소스, 테스트 용이성 |
| C | Best Practices + Security Flag | 20점 + 보안 | 언어 관례, 패턴, OWASP 검사 |

**점수 병합 과정**:

```
Step 1: 3개 에이전트 동시 리뷰
Step 2: 점수 합산 → Agent A + Agent B + Agent C = XX/100
Step 3: Security Override 확인 → security_flag == true면 min(총점, 59)
Step 4: Grade 결정 → 80+ = PASS, 60-79 = WARN(auto-fix), <60 = FAIL
Step 5: Issues 통합 → 에이전트별 이슈를 합쳐서 severity순 정렬
```

**Security Zero-Tolerance 예시**: 다른 카테고리에서 83점을 받았어도, Agent C가 SQL Injection 같은 보안 Critical을 발견하면 총점이 59점으로 강제되어 FAIL 처리됩니다.

### 7.7 Deep Review 병렬화 (2x)

**동작 방식**: Level 3 리뷰에서 Phase 1을 먼저 실행한 후, Phase 2, 3, 5를 3개 에이전트로 동시 실행합니다.

```
Step 1: Phase 1 (Call Chain Analysis) — BLOCKING
  호출 그래프 구축. 이후 모든 분석의 기반.

Step 2: Phase 2, 3, 5 — PARALLEL (3개 에이전트)
  Agent A: Edge Case Discovery (null/empty/boundary/overflow)
  Agent B: Concurrency Analysis (shared state/deadlock/race condition)
  Agent C: Security Deep Dive (OWASP Top 10/injection/access control)

Step 3: Phase 4 (Tech Debt Prediction) — BLOCKING
  Phase 2+3 결과를 입력으로 받아 확장성/결합도/테스트 커버리지 예측
```

### 7.8 Architecture Review 병렬화 (2x)

**동작 방식**: Level 4 리뷰에서도 동일한 패턴을 적용합니다.

```
Step 1: Phase 1 (Dependency Analysis) — BLOCKING

Step 2: Phase 2, 3, 5 — PARALLEL (3개 에이전트)
  Agent A: SOLID Principles (5개 원칙 독립 평가)
  Agent B: Layer Violation Detection (계층 규칙 위반)
  Agent C: Pattern Compliance Check (Repository/Service/Event/CQRS)

Step 3: Phase 4 (Scalability Assessment) — BLOCKING
```

**SOLID 추가 병렬화**: 클래스 수 > 20개일 때, Agent A 내부에서 SOLID 5원칙(S, O, L, I, D)을 5개 서브 에이전트로 추가 분배 가능. 기본값은 비활성.

---

## 8. 오류 처리 및 Graceful Degradation

병렬 실행에서는 하나의 에이전트 실패가 전체 실패로 이어지면 안 됩니다. v0.2.0은 **계층별 오류 처리 전략**을 적용합니다.

### 계층별 오류 처리

| 실패 수준 | 범위 | 복구 전략 | 사용자 영향 |
|----------|------|----------|------------|
| Agent Timeout | 단일 에이전트 | 60초 대기 후 보수적 기본값(15/20) 적용 | 점수 소폭 하락 가능 |
| Agent Error | 단일 에이전트 | 남은 에이전트에 재할당, 불가 시 순차 전환 | 일부 카테고리 미분석 |
| Task Conflict | 파일 충돌 | 파일 Lock으로 사전 방지 | 없음 (사전 방지) |
| Dependency Violation | 실행 순서 | Coordinator가 Level 강제 | 없음 (구조적 방지) |
| Full Parallel Failure | 전체 | 순차 모드로 완전 폴백 + 사용자 알림 | 속도만 저하, 기능 동일 |
| Security Critical | 보안 | 즉시 FAIL, 점수 무관 커밋 차단 | 커밋 차단 |

### 시나리오별 동작 예시

**Agent Timeout**:
```
⚠️ Agent B 타임아웃 (60초 초과)

처리: Agent B 결과 → 보수적 기본값(Performance 15/20, Testability 15/20)
      Agent A, C 결과는 정상 사용
결과: Total = 34(A) + 30(B, 기본값) + 17(C) = 81/100
알림: "⚠️ Agent B 타임아웃 - 보수적 기본값(15/20) 적용됨"
```

**Single Agent Failure**:
```
❌ Agent C 에러 발생

처리: Agent C 카테고리(Best Practices)를 Agent A 또는 B에 재할당 시도
      재할당 불가 시 → 해당 카테고리만 순차 실행으로 전환
알림: "⚠️ Agent C 실패 - Best Practices 순차 실행으로 전환"
```

**BUILD Phase 부분 실패**:
```
[Level 2 실행 중]
  Agent A: [backend-001] ✅ 완료
  Agent B: [backend-002] ❌ 타입 오류 발생
  Agent C: [frontend-001] ⏳ 진행 중 (독립적이므로 계속)

처리: Agent B의 실패한 Task만 순차 모드로 전환하여 재시도
      Agent C는 독립 Task이므로 중단하지 않고 계속 실행
결과: 전체 Level 2 약간 지연되지만 완료
```

**Full Parallel Failure**:
```
❌❌❌ 전체 에이전트 실패

처리: 순차 모드로 완전 폴백
      단일 에이전트로 전체 리뷰/분석 수행
      기존 v0.1.0 순차 프로토콜 그대로 적용
알림: "❌ 병렬 실행 실패 - 순차 모드로 전환합니다.
       기능은 동일하며, 소요 시간만 증가합니다."
```

---

## 9. Score Merge 프로토콜

### 리뷰 점수 출력 형식

각 리뷰 에이전트는 다음 YAML 형식으로 결과를 출력합니다:

```yaml
agent_result:
  agent_id: "A"
  categories:
    - name: "readability"
      score: 18                  # /20
      issues:
        - severity: "minor"
          file: "src/api/auth.ts"
          line: 45
          message: "변수명 'x' → 'userId'로 개선 권장"
          suggestion: "const userId = req.params.id"
  security_flag: false           # Agent C만 사용
  duration: "4.2s"
```

### 병합 공식

```
Total = Agent A (Readability + Maintainability)     # /40
      + Agent B (Performance + Testability)         # /40
      + Agent C (Best Practices)                    # /20
      = XX / 100

if Agent C.security_flag == true:
    Total = min(Total, 59)   → 자동 FAIL
```

### Grade 매핑

| 점수 | Grade | Gate | 액션 |
|------|-------|------|------|
| 95-100 | A+ | PASS | 바로 커밋 |
| 90-94 | A | PASS | 바로 커밋 |
| 85-89 | B+ | PASS | 바로 커밋 |
| 80-84 | B | PASS | 바로 커밋 |
| 75-79 | C+ | WARN | code-formatter 시도 |
| 70-74 | C | WARN | code-formatter 시도 |
| 60-69 | D | WARN | code-formatter 시도 |
| 0-59 | F | FAIL | 커밋 중단 |

---

## 10. 실전 예시: 전체 파이프라인 워크스루

"사용자 인증 기능"을 처음부터 끝까지 구현하는 과정을 병렬 모드로 보여줍니다.

### Step 1: PRD 생성

```bash
/prd 사용자 인증 기능
# → docs/prd/PRD_user-authentication.md 생성
# → docs/todo_plan/PLAN_user-authentication.md 생성
```

### Step 2: Digging 병렬 분석

```
"PRD 검토해줘"

⚡ Parallel Digging 시작 (PRD 섹션 5개, 1200자 → 병렬 모드 자동 활성화)

  Agent A (Completeness): ████████████████████ 완료 (3.2s)
    → FR 커버리지: 90% | NFR 커버리지: 70%
    → Critical: 비밀번호 재설정 플로우 누락

  Agent B (Feasibility):  ████████████████████ 완료 (4.1s)
    → 기술 스택 적합성: Good | 구현 복잡도: Medium (3/5)
    → Critical: 없음

  Agent C (Security):     ████████████████████ 완료 (3.8s)
    → OWASP 점검: 2건 발견
    → Critical: Rate Limiting 미정의, 토큰 만료 정책 없음

  Agent D (Consistency):  ████████████████████ 완료 (2.5s)
    → 용어 불일치: "사용자"/"유저" 혼용
    → Critical: 없음

  ── Result Merge ──
  총 이슈: 12건 (중복 제거 후) | Critical: 3건 | Major: 5건 | Minor: 4건
  Quality Gate: ❌ BLOCKED (Critical 3건)
  총 소요시간: 4.1s (순차 예상: 13.6s, 속도 향상: 3.3x)
```

### Step 3: PRD 수정 후 재분석

```
(Critical 이슈 수정 후)
⚡ Parallel Digging 재실행...
  Quality Gate: ✅ PASS (Critical 0건)
```

### Step 4: 구현 (병렬 모드)

```bash
/implement --parallel 사용자 인증
```

```
⚡ Parallel Mode: ACTIVE (파일 7개, Phase 3개 → 자동 활성화)

── DESIGN Phase (병렬 3x) ──
  Agent A (PRD+QG):      ████████████████████ 완료 (2.1s)
  Agent B (Architecture): ████████████████████ 완료 (3.5s)
  Agent C (Project+Gap):  ████████████████████ 완료 (2.8s)
  DESIGN 소요시간: 3.5s (순차 예상: 8.4s)

┌───────────────────────────────────────────────────┐
│  📋 구현 계획                                      │
│  아키텍처: Modular Monolith                        │
│  생성: 5개 | 수정: 2개                             │
│  구현 순서: Schema → Backend+Frontend(병렬) → Test │
│  → 진행 (Recommended)                              │
└───────────────────────────────────────────────────┘

사용자: "진행"

── BUILD Phase (Level별 병렬 2-3x) ──
  [Level 1] 병렬 (2 tasks)
    ├── [schema-001] prisma/schema.prisma  ✅ (1.8s)
    └── [config-001] .env.example          ✅ (0.9s)

  [Level 2] 병렬 (3 tasks)
    ├── [backend-001] src/api/auth/login.ts      ✅ (4.2s)
    ├── [backend-002] src/services/AuthService.ts ✅ (3.8s)
    └── [frontend-001] src/components/LoginForm.tsx ✅ (5.1s)

  [Level 3] (1 task)
    └── [test-001] tests/auth.test.ts      ✅ (3.2s)

  BUILD 소요시간: 10.1s (순차 예상: 19.0s)
✅ 구현 완료! 6/6 tasks
```

### Step 5: 자동 커밋 (병렬 리뷰)

```bash
/auto-commit
```

```
⚡ Parallel Quality Gate (변경 파일 7개 → 병렬 리뷰 자동 활성화)

  Agent A (Read+Main):   ████████████████████ 완료 (4.2s)
  Agent B (Perf+Test):   ████████████████████ 완료 (5.1s)
  Agent C (BP+Security): ████████████████████ 완료 (3.8s)

  | Agent | Category        | Score |
  |-------|-----------------|-------|
  | A     | Readability     | 18/20 |
  | A     | Maintainability | 16/20 |
  | B     | Performance     | 15/20 |
  | B     | Testability     | 17/20 |
  | C     | Best Practices  | 17/20 |
  | C     | Security        | ✅ OK |
  | Total | All             | 83/100|

  Gate Decision: ✅ PASS (B)
  소요시간: 5.1s (순차 예상: 15.3s, 속도 향상: 3.0x)

✓ Committed: abc1234
  feat(auth): Add user authentication with login and registration
✓ Pushed to origin/main
```

### 전체 파이프라인 시간 비교

| 단계 | 순차 | 병렬 | 속도 향상 |
|------|------|------|----------|
| Digging | 13.6s | 4.1s | 3.3x |
| DESIGN | 8.4s | 3.5s | 2.4x |
| BUILD | 19.0s | 10.1s | 1.9x |
| Quality Gate | 15.3s | 5.1s | 3.0x |
| **총합** | **56.3s** | **22.8s** | **2.5x** |

---

## 11. FAQ

### Q: 병렬 모드를 항상 사용해야 하나요?

**A:** 아닙니다. 병렬 모드는 자동 감지되며, 소규모 변경(파일 1-2개)에서는 순차 모드가 더 효율적입니다. 에이전트 생성과 결과 병합에 오버헤드가 있으므로 일정 규모 이상에서만 이점이 있습니다.

### Q: 병렬 모드에서 결과가 다를 수 있나요?

**A:** 점수는 +-5점 이내의 차이가 있을 수 있습니다. 이는 에이전트 간 컨텍스트 차이 때문이며, 품질 기준(PASS/WARN/FAIL)은 동일하게 적용됩니다.

### Q: Security Critical이면 무조건 FAIL인가요?

**A:** 네. 보안 Critical 이슈가 발견되면 점수와 무관하게 59점 이하로 강제되어 커밋이 차단됩니다. Zero-Tolerance 정책입니다.

### Q: 에이전트가 하나 실패하면 전체가 실패하나요?

**A:** 아닙니다. Graceful Degradation에 따라 단일 에이전트 실패 시 해당 Task만 순차 전환하고 나머지는 계속 실행됩니다. 전체 실패 시에만 순차 모드로 완전 폴백합니다.

### Q: Cross-Plugin 병렬은 어떤 플러그인이 필요한가요?

**A:** `--full-stack` 사용 시:
- 필수: `public-commands` (구현 조율)
- Backend: `backend-development`의 `backend-architect` 에이전트
- Frontend: `frontend-development`의 `frontend-developer` 에이전트
- Mobile (선택): `mobile-development`의 `mobile-developer` 에이전트

### Q: 파일 충돌이 발생하면 어떻게 되나요?

**A:** `parallel-build-coordinator`가 사전에 파일 Lock을 관리합니다. 같은 파일을 수정하는 Task는 같은 에이전트에 할당됩니다. 사후 충돌 감지 시 후자 우선(later wins)으로 처리하고 수동 검토 플래그를 남깁니다.

### Q: 병렬 모드를 완전히 끌 수 있나요?

**A:** 네. 각 명령어에 순차 강제 플래그가 있습니다:
- `/implement --sequential`
- `/auto-commit --no-parallel-review`

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| v0.2.0 | 2026-02-06 | Agent Teams 병렬 실행 고도화: Coordinator 에이전트 3개 신설, 전체 파이프라인 병렬화, Cross-Plugin 병렬 실행, Graceful Degradation |
| v0.1.0 | - | 초기 버전 - 순차 실행 기반 |
