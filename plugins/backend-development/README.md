# Backend Development Plugin

백엔드 개발 경험이 없어도 올바른 아키텍처를 설계하고 구현할 수 있도록 도와주는 플러그인입니다.

## Features

- **백엔드 아키텍처 설계**: PRD 분석, 스택 선정, 데이터 모델링, API 설계
- **DevOps 가이드**: CI/CD, 컨테이너화, 클라우드 배포, 모니터링
- **초보자 친화적**: 전문 용어 쉽게 설명, 단계별 가이드

## Commands

| 명령어            | 설명                                 |
| ----------------- | ------------------------------------ |
| `/backend`        | 백엔드 설계부터 구현까지 전체 가이드 |
| `/api <resource>` | NestJS API 엔드포인트 생성           |
| `/model <Model>`  | Prisma 데이터 모델 생성              |
| `/auth`           | JWT 인증 모듈 생성                   |
| `/module <name>`  | NestJS 모듈 생성                     |
| `/devops`         | CI/CD, Docker, 배포 설정 가이드      |

## Quick Start

### 새 프로젝트 시작

```
/backend
```

또는 자연어로:

```
"쇼핑몰 백엔드 만들어줘"
"API 설계해줘"
"인증 기능 추가해줘"
```

### 빠른 시작 (추천 스택)

```
/backend --quick
```

→ NestJS + Prisma + PostgreSQL + JWT로 바로 시작

### 특정 기능만

```
/api products --crud              # Product API 생성
/model Order --with-crud          # Order 모델 + CRUD
/auth --refresh --roles           # 인증 + 역할 관리
/devops --docker --ci             # Docker + CI/CD
```

## Structure

```
plugins/backend-development/
├── agents/
│   └── orchestrator.md       # 전체 조율 에이전트
├── commands/
│   ├── backend.md            # /backend
│   ├── api.md                # /api
│   ├── model.md              # /model
│   ├── auth.md               # /auth
│   ├── module.md             # /module
│   └── devops.md             # /devops
└── skills/
    ├── backend-architect/    # 백엔드 설계 스킬
    │   ├── agents/
    │   │   └── orchestrator.md
    │   ├── skills/
    │   │   ├── SKILL.md
    │   │   └── stack-reference.md
    │   └── README.md
    └── devops-architect/     # DevOps 스킬
        ├── skills/
        │   ├── SKILL.md
        │   └── devops-reference.md
        └── README.md
```

## Skills

### Backend Architect

백엔드 아키텍처 설계 전문:

- PRD 분석 → 도메인 추출
- 스택 선정 (NestJS, Prisma, PostgreSQL 등)
- 데이터 모델링 (ERD, 관계 설계)
- API 설계 (RESTful 엔드포인트)
- 코드 생성 (모듈, 서비스, 컨트롤러)

### DevOps Architect

인프라 및 배포 전문:

- 컨테이너화 (Dockerfile, Docker Compose)
- CI/CD (GitHub Actions, GitLab CI)
- 클라우드 배포 (AWS, GCP, Kubernetes)
- 모니터링 (Prometheus, Grafana)
- 로깅 (ELK Stack, Loki)

## Supported Stacks

### Backend

| 카테고리     | 옵션                                               |
| ------------ | -------------------------------------------------- |
| 언어         | TypeScript, Python, Java, Go                       |
| 프레임워크   | NestJS ⭐, Express, Fastify, Hono, FastAPI, Spring |
| 데이터베이스 | PostgreSQL ⭐, MySQL, SQLite, MongoDB, Supabase    |
| ORM          | Prisma ⭐, TypeORM, Drizzle, Mongoose              |
| 인증         | JWT ⭐, Session, Passport, Clerk, Supabase Auth    |

### DevOps

| 카테고리       | 옵션                                         |
| -------------- | -------------------------------------------- |
| 컨테이너       | Docker ⭐, Podman                            |
| 오케스트레이션 | Kubernetes ⭐, Docker Swarm, Nomad           |
| CI/CD          | GitHub Actions ⭐, GitLab CI, CircleCI       |
| 클라우드       | AWS ⭐, GCP, Azure, DigitalOcean             |
| 모니터링       | Prometheus + Grafana ⭐, Datadog, CloudWatch |

## Flow Example

```
User: "중고거래 앱 백엔드 만들어줘"

┌─────────────────────────────────────────────┐
│ 📊 Project Status                           │
├─────────────────────────────────────────────┤
│ Type     : New                              │
│ PRD      : Not found                        │
└─────────────────────────────────────────────┘

도메인을 추출했어요:
• User (사용자)
• Product (상품)
• Chat (채팅)
• Transaction (거래)

스택을 선택해주세요:
[추천 스택 ⭐] [빠른 시작] [직접 선택]
```

## License

MIT
