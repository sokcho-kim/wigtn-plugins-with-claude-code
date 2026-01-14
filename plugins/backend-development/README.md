# Backend Development Plugin

개발 사이클 완료 후 백엔드 기능 고도화 및 배포 준비를 지원하는 플러그인입니다.

## Features

- **백엔드 기능 고도화**: 개발 완료된 기능의 성능, 확장성, 안정성 개선
- **배포 인프라 구성**: CI/CD, 컨테이너화, 클라우드 배포, 모니터링
- **프로덕션 레벨 가이드**: 베스트 프랙티스 및 고급 패턴 적용

## Workflow Position

```
개발 사이클 (public-commands):
/prd → digging → /implement → /auto-commit
                              ^^^^^^^^^^^^
                              개발 사이클 완료

사이클 완료 후 (backend-development):
/backend [기능 고도화]  →  /devops [배포 설정]
```

## Commands

| 명령어            | 설명                                    | 사용 시점              |
| ----------------- | --------------------------------------- | ---------------------- |
| `/backend`        | 백엔드 기능 고도화 및 아키텍처 개선     | 개발 사이클 완료 후    |
| `/devops`         | 배포 인프라 설정 (CI/CD, Docker, K8s)   | 배포 준비 시           |
| `/api <resource>` | NestJS API 엔드포인트 생성              | (참고용)               |
| `/model <Model>`  | Prisma 데이터 모델 생성                 | (참고용)               |
| `/auth`           | JWT 인증 모듈 생성                      | (참고용)               |
| `/module <name>`  | NestJS 모듈 생성                        | (참고용)               |

## Usage

### 개발 사이클 완료 후

```
1. 기능 고도화:
   /backend [기능명]              # 예: /backend 실시간 채팅 성능 개선
   
2. 배포 준비:
   /devops [배포 설정]            # 예: /devops Docker 설정
```

### 예시 시나리오

```
# 시나리오 1: 기능 고도화
/prd → digging → /implement → /auto-commit
                              (개발 사이클 완료)
/backend API 성능 최적화        # 캐싱 전략, DB 쿼리 최적화

# 시나리오 2: 배포 준비
/prd → digging → /implement → /auto-commit
                              (개발 사이클 완료)
/devops Docker + CI/CD          # Dockerfile, GitHub Actions 설정
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
