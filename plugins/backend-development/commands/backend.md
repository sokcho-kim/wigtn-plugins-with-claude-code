---
description: 백엔드 아키텍처 설계부터 구현까지 단계별로 안내합니다. Trigger on "/backend", "백엔드 만들어줘", "백엔드 설계해줘", "API 서버 만들어줘", or when user needs backend architecture guidance.
---

# Backend

PRD 문서를 분석하고, 단계별로 백엔드를 설계합니다.

## Pipeline Position

```
┌─────────────────────────────────────────────────────────────┐
│  [PRD 작성] → [/backend] → [/api] → [/devops]              │
│               ^^^^^^^^^^                                    │
│               현재 단계                                      │
└─────────────────────────────────────────────────────────────┘
```

## Usage

```bash
/backend                       # 대화형 가이드 시작
/backend --quick               # 추천 스택으로 바로 진행
/backend --prd docs/prd.md     # PRD 문서 경로 지정
/backend --stack recommended   # 스택 프리셋 선택
```

## Parameters

- `--quick`: 빠른 시작 (추천 스택: NestJS + Prisma + PostgreSQL + JWT)
- `--prd <path>`: PRD 문서 경로 지정
- `--stack <preset>`: 스택 프리셋 (recommended, quick, serverless, baas)

## Stack Presets

| 프리셋        | 구성                                    |
| ------------- | --------------------------------------- |
| `recommended` | NestJS + Prisma + PostgreSQL + JWT      |
| `quick`       | NestJS + Prisma + SQLite (DB 설치 없이) |
| `serverless`  | Hono + Drizzle + Neon                   |
| `baas`        | Supabase (올인원)                       |

## Protocol

### Phase 0: 상태 확인 (필수)

모든 작업 전 현재 상태를 파악합니다:

```
┌─────────────────────────────────────────────┐
│ 📊 Project Status                           │
├─────────────────────────────────────────────┤
│ Type     : [New / Existing NestJS]          │
│ Modules  : [없음 / users, products, ...]    │
│ Database : [없음 / Prisma / TypeORM]        │
│ Auth     : [없음 / JWT 설정됨]              │
│ PRD      : [발견됨: prd/main.md / 없음]     │
├─────────────────────────────────────────────┤
│ 💡 Recommendation: [다음 단계 제안]          │
└─────────────────────────────────────────────┘
```

### Phase 1: PRD 분석

PRD 문서에서 도메인, 기능 요구사항, 기술 제약 추출

### Phase 2: 스택 선정

사용자에게 스택 선택지 제공 또는 자동 선택

### Phase 3: 데이터 모델링

ERD 및 엔티티 설계

### Phase 4: API 설계

RESTful 엔드포인트 정의

### Phase 5: 구현 계획

단계별 구현 체크리스트 제시

### Phase 6: 구현 실행

사용자 확인 후 실제 코드 생성

## Output

각 단계에서 명확한 상태 리포트와 선택지를 제공합니다.

```
┌─────────────────────────────────────────────────────────────┐
│ ✅ Implementation Complete                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Created:                                                    │
│   • src/auth/auth.module.ts                                 │
│   • src/auth/auth.controller.ts                             │
│   • src/auth/auth.service.ts                                │
│                                                             │
│ Next Steps:                                                 │
│   1. npx prisma migrate dev --name init                     │
│   2. npm run start:dev                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Skill Reference

> 📚 이 Command는 `backend-architect` 스킬의 전체 플로우(Phase 0-6)를 실행합니다.
> 상세 프로토콜: [skills/backend-architect/skills/SKILL.md](../skills/backend-architect/skills/SKILL.md)

## Integration Points

| 연결 대상                | 역할                                         |
| ------------------------ | -------------------------------------------- |
| `backend-architect` 스킬 | Phase 0-6 전체 플로우 실행                   |
| `/api` 명령어            | Phase 4 (API 설계) 후 개별 API 생성 시       |
| `/model` 명령어          | Phase 3 (데이터 모델링) 후 개별 모델 추가 시 |
| `/auth` 명령어           | 인증 모듈 추가 시                            |
| `/devops` 명령어         | 백엔드 완료 후 배포 설정 시                  |

## Next Step

백엔드 구현 완료 후:

```
💡 백엔드 기본 구조가 완성되었습니다!

다음 단계:
  → `/api <resource> --crud`로 추가 API 생성
  → `/auth`로 인증 추가
  → `/auto-commit`으로 커밋

배포 준비가 되면:
  → `/devops`로 배포 환경 설정 (선택 사항)
```

## Rules

1. **상태 확인 필수**: 모든 작업 전 Phase 0 실행
2. **중복 방지**: 기존 모듈 절대 덮어쓰지 않음
3. **선택권 제공**: 강요하지 말고 옵션 제시
4. **이유 설명**: 왜 이걸 추천하는지 설명
5. **점진적 진행**: 한 번에 다 하지 말고 단계별로
6. **초보자 언어**: 전문 용어는 쉽게 풀어서

## Examples

### 새 프로젝트 시작

```
입력: /backend

Phase 0: 프로젝트 상태 확인 → 새 프로젝트
Phase 1: PRD 문서 검색 → 없음
Phase 1: 서비스 타입 질문 → 쇼핑몰
Phase 2: 스택 선택 → 추천 스택
Phase 3-6: 순차 진행
```

### 빠른 시작

```
입력: /backend --quick

Phase 0: 상태 확인
→ NestJS + Prisma + SQLite로 즉시 프로젝트 생성
→ 기본 구조 세팅 완료
```

## $ARGUMENTS
