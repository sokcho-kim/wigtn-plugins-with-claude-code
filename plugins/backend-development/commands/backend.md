---
description: Backend enhancement helper. Trigger on "/backend", "백엔드 설계", "아키텍처 설계", "스택 추천", or when user needs technical planning for complex backend features.
---

# /backend

백엔드 기능 고도화 헬퍼. 개발 사이클 완료 후 기존 기능을 개선하거나 프로덕션 레벨로 고도화할 때 사용합니다.

## Purpose

- **기능 고도화** - 개발 완료된 기능의 성능, 확장성, 안정성 개선
- **아키텍처 개선** - 프로덕션 레벨 패턴 적용, 최적화 전략 수립
- **고급 패턴 조언** - 복잡한 기능 구현을 위한 고급 패턴 및 베스트 프랙티스

## Usage

```bash
/backend 실시간 채팅           # 특정 기능 고도화 계획
/backend 결제 시스템 연동       # 통합 설계
/backend                      # 대화형 모드
```

## When to Use

**개발 사이클 완료 후 사용:**

| 상황               | 예시                             |
| ------------------ | -------------------------------- |
| 기능 고도화 필요   | "실시간 채팅 기능 성능 개선"     |
| 프로덕션 레벨 개선 | "API 응답 속도 최적화"           |
| 확장성 고려        | "트래픽 증가 대비 아키텍처 개선" |
| 고급 패턴 적용     | "캐싱 전략 개선"                 |
| 통합 최적화        | "결제 시스템 연동 최적화"        |

## Protocol

### Phase 1: 요청 파악

사용자의 요청을 파악합니다:

- 어떤 기능/문제인가?
- 현재 프로젝트 상태는?
- 제약 조건은?

### Phase 2: 컨텍스트 수집

필요한 정보를 수집합니다:

- 기존 코드베이스 구조
- 사용 중인 스택
- 관련 파일/모듈

### Phase 3: 기술 결정

스킬 레퍼런스를 참조하여 결정:

| 레퍼런스                                                      | 참조 시점         |
| ------------------------------------------------------------- | ----------------- |
| `skills/backend-patterns/references/stack-selection.md`       | 스택 선정 시      |
| `skills/backend-patterns/references/architecture-patterns.md` | 아키텍처 결정 시  |
| `skills/backend-patterns/references/frontend-interactions.md` | 프론트 연동 시    |
| `skills/backend-patterns/references/common-patterns.md`       | 공통 기능 구현 시 |
| `skills/backend-patterns/references/ai-service-patterns.md`   | AI 기능 구현 시   |
| `skills/devops-patterns/references/*`                         | 인프라 설정 시    |

### Phase 4: 계획 제공

구체적인 구현 계획을 제공:

```
## 기술 결정
- [스택/패턴 선택과 이유]

## 구현 순서
1. [단계 1]
2. [단계 2]
...

## 주요 고려사항
- [고려사항 1]
- [고려사항 2]
```

### Phase 5: 후속 지원

- 추가 질문에 답변
- 필요 시 더 상세한 설명 제공
- 개선 작업 시작 시 `/implement`로 안내

## Example Interaction

**User:** `/backend 실시간 채팅`

**Response:**

```
실시간 채팅 기능 설계를 도와드리겠습니다.

먼저 몇 가지 확인이 필요합니다:
1. 예상 동시 접속자 수는?
2. 1:1 채팅만? 그룹 채팅도?
3. 메시지 히스토리 저장 필요?
4. 현재 사용 중인 스택은?
```

**User:** "100명, 1:1+그룹, 히스토리 필요, NestJS"

**Response:**

```
## 기술 결정
- Real-time: Socket.io (NestJS 공식 지원)
- Message Store: PostgreSQL + Redis (캐싱)
- Scaling: Redis Adapter (다중 인스턴스 대비)

## 구현 순서
1. ChatMessage 엔티티 & 스키마 설계
2. WebSocket Gateway 설정 (Socket.io)
3. 채팅방 관리 서비스
4. 메시지 송수신 핸들러
5. 메시지 히스토리 API
6. Redis 캐싱 레이어 (선택)

## 주요 고려사항
- 그룹 채팅: Room 기반 브로드캐스트
- 히스토리: Cursor-based pagination
- 인증: JWT 토큰 검증 (handshake 시점)

바로 구현을 시작할까요?
```

## Integration

이 커맨드는 **개발 사이클 완료 후** 사용합니다.

```
개발 사이클:
/prd → digging → /implement → /auto-commit
                              ^^^^^^^^^^^^
                              개발 사이클 완료

사이클 완료 후:
/backend [기능 고도화] → 개선 계획 → 구현
```

**사용 시점:**

- `/auto-commit` 완료 후
- 기존 기능의 성능/확장성/안정성 개선이 필요할 때
- 프로덕션 레벨로 고도화가 필요할 때

## Agent Reference

> 이 커맨드는 `backend-architect` 에이전트를 호출합니다.
> 📚 상세 프로토콜: [agents/backend-architect.md](../agents/backend-architect.md)

## $ARGUMENTS
