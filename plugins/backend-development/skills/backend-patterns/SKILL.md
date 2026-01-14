---
name: backend-patterns
description: Backend architecture patterns and stack references. Use when implementing backend features or making technical decisions. Provides stack selection guides, architecture patterns, and integration references.
---

# Backend Patterns

백엔드 구현 시 참조할 수 있는 아키텍처 패턴과 스택 레퍼런스입니다.

## Purpose

- **스택 선정 가이드** - 상황별 최적 스택 추천
- **아키텍처 패턴** - 모놀리식, 모듈러, 마이크로서비스
- **통합 패턴** - 프론트엔드 연동, AI 서비스, 공통 기능

## Reference Documents

| 문서 | 용도 |
|------|------|
| [stack-selection.md](references/stack-selection.md) | 스택별 장단점, 선택 기준 |
| [architecture-patterns.md](references/architecture-patterns.md) | 아키텍처 패턴 가이드 |
| [frontend-interactions.md](references/frontend-interactions.md) | 프론트엔드 연동 백엔드 패턴 |
| [common-patterns.md](references/common-patterns.md) | 인증, 결제, 알림 등 공통 패턴 |
| [ai-service-patterns.md](references/ai-service-patterns.md) | LLM, RAG, 벡터 검색 패턴 |

## Quick Reference

### Stack Selection

| 상황 | 권장 스택 |
|------|----------|
| 빠른 프로토타입 | Express/Fastify + Drizzle + SQLite |
| 구조화된 대규모 | NestJS + Prisma + PostgreSQL |
| 서버리스/Edge | Hono + Drizzle + Neon |
| Python 팀 | FastAPI + SQLAlchemy + PostgreSQL |
| 엔터프라이즈 | Spring Boot + JPA + PostgreSQL |
| 고성능 | Go + Gin + GORM + PostgreSQL |
| BaaS | Supabase (DB + Auth 통합) |

### Architecture Patterns

| 패턴 | 적합한 상황 |
|------|------------|
| **Monolithic** | MVP, 소규모 팀, 빠른 개발 |
| **Modular Monolith** | 중규모, 향후 분리 가능성 |
| **Microservices** | 대규모, 독립 배포 필요 |
| **Serverless** | 이벤트 기반, 가변 트래픽 |

### Layer Structure

```
┌─────────────────────────────────────────┐
│  Presentation (Controller/Handler)      │
├─────────────────────────────────────────┤
│  Application (Service/UseCase)          │
├─────────────────────────────────────────┤
│  Domain (Entity/Model)                  │
├─────────────────────────────────────────┤
│  Infrastructure (Repository/External)   │
└─────────────────────────────────────────┘
```

### Domain Separation Strategy

| 전략 | 설명 |
|------|------|
| **Feature-based** | User, Product, Order 모듈 |
| **Bounded Context** | DDD 기반 경계 설정 |
| **Layer-based** | API, Service, Data 레이어 |

### Infrastructure Options

| 항목 | 옵션 |
|------|------|
| 배포 | Docker / K8s / Serverless (Lambda) |
| 스케일링 | Vertical / Horizontal / Auto (HPA) |
| 캐싱 | Redis / In-memory / CDN |
| 메시지 큐 | Redis Pub/Sub / RabbitMQ / Kafka |
| 파일 스토리지 | S3 / Cloudflare R2 / Local |

### Integration Services

| 분야 | 옵션 |
|------|------|
| 결제 | Toss Payments / Stripe / Iamport |
| 알림 | FCM (Push) / Slack / Resend (Email) |
| 모니터링 | Sentry / Datadog / Prometheus + Grafana |
| 이벤트 | Synchronous / Redis Pub/Sub / Kafka |

### Common Backend Features

**인증/인가:**
- JWT / Session / OAuth
- Social login (Google, Kakao, Naver)
- 2FA / RBAC

**실시간 기능:**
- WebSocket (Socket.io)
- SSE (Server-Sent Events)
- Polling

**파일 처리:**
- Multipart upload
- S3/R2 storage
- CDN integration

**검색/필터링:**
- Full-text search
- Elasticsearch
- Cursor-based pagination

### AI Service Patterns

| 패턴 | 구현 |
|------|------|
| LLM 통합 | OpenAI / Anthropic API |
| 벡터 검색 | Pinecone / pgvector |
| RAG | Vector DB + LLM |
| 음성 처리 | Whisper / Google STT |

## Usage

백엔드 구현 시 필요한 패턴을 레퍼런스 문서에서 찾아 참조합니다.

**예시: 실시간 채팅 구현 시**
1. `frontend-interactions.md` → WebSocket 패턴 확인
2. `common-patterns.md` → 채팅 시스템 패턴 확인
3. `architecture-patterns.md` → 적절한 레이어 구조 확인

**예시: AI 챗봇 구현 시**
1. `ai-service-patterns.md` → LLM 통합 패턴 확인
2. `common-patterns.md` → 스트리밍 응답 패턴 확인
3. `stack-selection.md` → 적합한 스택 선택

## Integration

`backend-architect` 에이전트가 이 스킬의 레퍼런스 문서를 참조하여 기술 결정을 지원합니다.

```
사용자 요청
    ↓
backend-architect 에이전트
    ↓ (참조)
backend-patterns 스킬 레퍼런스
    ↓
기술 결정 & 구현 계획 제공
```
