# Backend Architect Plugin

백엔드 개발 경험이 없어도 올바른 아키텍처를 설계하고 구현할 수 있도록 도와주는 플러그인입니다.

## Installation

```bash
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code
/plugin install backend-architect
```

## Usage

```bash
/backend                   # 대화형 가이드 시작
"백엔드 만들어줘"           # 자연어로 요청
"쇼핑몰 API 설계해줘"       # 서비스별 요청
```

## What It Does

PRD 문서를 분석하고, 단계별로 백엔드를 설계합니다:

```
┌─────────────────────────────────────────────┐
│ 📋 PRD 분석                                  │
│   ↓                                         │
│ 🛠️ 스택 선정 (NestJS, Prisma, PostgreSQL)   │
│   ↓                                         │
│ 📊 데이터 모델링 (ERD, 관계 설계)            │
│   ↓                                         │
│ 🔌 API 설계 (엔드포인트, 응답 형식)          │
│   ↓                                         │
│ 🚀 구현 (코드 생성, 테스트 안내)             │
└─────────────────────────────────────────────┘
```

## Features

- **PRD 기반 설계**: 요구사항 문서에서 도메인 자동 추출
- **스택 추천**: 상황에 맞는 기술 스택 비교 및 추천
- **데이터 모델링**: ERD 시각화, 관계 설계
- **API 설계**: RESTful 엔드포인트, 응답 형식 표준화
- **중복 방지**: 기존 모듈 자동 감지, 덮어쓰기 방지
- **초보자 친화적**: 전문 용어 쉽게 설명

## Example

```
User: "중고거래 앱 백엔드 만들어줘"

Claude:
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
[추천 스택으로 바로 시작] [직접 선택] [가장 빠르게]
```

## Supported Stacks

| 카테고리         | 옵션                                                   |
| ---------------- | ------------------------------------------------------ |
| **언어**         | TypeScript, Python, Java, Go                           |
| **프레임워크**   | NestJS, Express, Fastify, Hono, FastAPI, Spring        |
| **데이터베이스** | PostgreSQL, MySQL, SQLite, MongoDB, Supabase, Neon     |
| **ORM**          | Prisma, TypeORM, Drizzle, Mongoose                     |
| **인증**         | JWT, Session, Passport, Clerk, Supabase Auth, Firebase |
| **추가 기술**    | Redis, Bull, Socket.io, S3, GraphQL, gRPC              |

### 빠른 시작 프리셋

| 프리셋    | 구성                               |
| --------- | ---------------------------------- |
| 추천 ⭐   | NestJS + Prisma + PostgreSQL + JWT |
| 빠른 시작 | NestJS + Prisma + SQLite           |
| 서버리스  | Hono + Drizzle + Neon              |
| BaaS      | Supabase (올인원)                  |

## License

MIT
