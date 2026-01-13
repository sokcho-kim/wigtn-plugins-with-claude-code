# Stack Reference

스택 선정 시 참고하는 상세 비교표입니다.

## 1. 프레임워크

### TypeScript/JavaScript

| Framework     | 장점                              | 단점                     | 추천 상황                       |
| ------------- | --------------------------------- | ------------------------ | ------------------------------- |
| **NestJS** ⭐ | 구조화, DI, 데코레이터, 큰 생태계 | 러닝커브 중간            | 팀 프로젝트, 장기 유지보수      |
| **Express**   | 자유도, 가벼움, 레퍼런스 많음     | 구조 없음, 스파게티 위험 | MVP, 프로토타입, 학습용         |
| **Fastify**   | 성능 최고, 스키마 검증 내장       | 생태계 작음              | 고성능 API, 마이크로서비스      |
| **Hono**      | Edge 최적화, 경량, 빠름           | 신생, 레퍼런스 적음      | Cloudflare Workers, Vercel Edge |
| **Koa**       | 미들웨어 체인, 깔끔한 API         | 배터리 없음              | 커스텀 프레임워크 구축          |

### Python

| Framework      | 장점                         | 단점                | 추천 상황                |
| -------------- | ---------------------------- | ------------------- | ------------------------ |
| **FastAPI** ⭐ | 자동 문서화, 타입 힌트, 빠름 | 생태계 작음         | ML/AI 백엔드, 현대적 API |
| **Django**     | 배터리 포함, Admin, ORM      | 무거움, 유연성 낮음 | 풀스택, Admin 필요, CMS  |
| **Flask**      | 가벼움, 유연함               | 구조 없음           | 소규모, 마이크로서비스   |

### 기타 언어

| Framework       | 언어        | 장점                   | 추천 상황                   |
| --------------- | ----------- | ---------------------- | --------------------------- |
| **Spring Boot** | Java/Kotlin | 엔터프라이즈급, 안정성 | 대기업, 레거시, 금융        |
| **Gin**         | Go          | 성능, 동시성, 간결     | 마이크로서비스, 고성능      |
| **Echo**        | Go          | Gin보다 기능 풍부      | REST API, 미들웨어          |
| **Actix**       | Rust        | 극한 성능              | 시스템 프로그래밍, 임베디드 |

---

## 2. 데이터베이스

### 관계형 (SQL)

| Database          | 특징                      | 추천 상황              |
| ----------------- | ------------------------- | ---------------------- |
| **PostgreSQL** ⭐ | JSON, Array, 확장성, 무료 | 대부분의 프로젝트      |
| **MySQL**         | 읽기 성능, 레거시 호환    | 기존 MySQL 시스템 연동 |
| **MariaDB**       | MySQL 포크, 오픈소스      | MySQL 대체             |
| **SQLite**        | 서버 없음, 파일 기반      | 개발/테스트, 임베디드  |

### 서버리스 SQL

| Database        | 특징                         | 추천 상황                |
| --------------- | ---------------------------- | ------------------------ |
| **Neon**        | 서버리스 PostgreSQL, 브랜칭  | Vercel 배포, 서버리스    |
| **PlanetScale** | 서버리스 MySQL, 브랜칭       | MySQL 선호 + 서버리스    |
| **Turso**       | SQLite 기반, Edge            | Edge 배포, 낮은 레이턴시 |
| **Supabase**    | PostgreSQL + Auth + Realtime | BaaS 원하면              |

### NoSQL

| Database     | 유형      | 추천 상황                   |
| ------------ | --------- | --------------------------- |
| **MongoDB**  | Document  | 유연한 스키마, 프로토타이핑 |
| **Redis**    | Key-Value | 캐싱, 세션, 실시간 데이터   |
| **DynamoDB** | Key-Value | AWS 종속 OK, 서버리스       |

### 특수 목적

| Database            | 유형   | 추천 상황                |
| ------------------- | ------ | ------------------------ |
| **Elasticsearch**   | 검색   | 전문 검색, 로그 분석     |
| **Meilisearch**     | 검색   | 간단한 검색, 타이포 허용 |
| **ClickHouse**      | 분석   | 대용량 분석, 실시간 집계 |
| **TimescaleDB**     | 시계열 | IoT, 모니터링, 메트릭    |
| **Pinecone/Qdrant** | 벡터   | AI/LLM, 유사도 검색      |

---

## 3. ORM / Query Builder

| ORM           | 언어  | 장점                        | 단점           |
| ------------- | ----- | --------------------------- | -------------- |
| **Prisma** ⭐ | TS    | 타입 안전, 마이그레이션, DX | Raw SQL 제한   |
| **TypeORM**   | TS    | 데코레이터, Active Record   | 타입 추론 약함 |
| **Drizzle**   | TS    | 경량, SQL에 가까움, 빠름    | 생태계 작음    |
| **Kysely**    | TS    | 타입 안전 쿼리 빌더         | ORM 아님       |
| **MikroORM**  | TS    | Unit of Work, Identity Map  | 러닝커브       |
| **Sequelize** | JS    | 오래됨, 안정적              | 타입 지원 약함 |
| **Knex.js**   | JS/TS | 쿼리 빌더, 유연함           | ORM 아님       |
| **Mongoose**  | JS/TS | MongoDB 전용, 스키마        | SQL 불가       |

---

## 4. 인증

### 직접 구현

| 방식                 | 특징                      | 추천 상황           |
| -------------------- | ------------------------- | ------------------- |
| **JWT** ⭐           | Stateless, 확장 용이      | API 서버, 모바일 앱 |
| **Session + Cookie** | 서버 상태 관리, CSRF 가능 | SSR, 브라우저만     |
| **API Key**          | 단순함                    | 내부 서비스, B2B    |

### 라이브러리/서비스

| 서비스          | 특징                 | 추천 상황                         |
| --------------- | -------------------- | --------------------------------- |
| **Passport.js** | 전략 기반, 소셜 다양 | 소셜 로그인 (Google/GitHub/Kakao) |
| **NextAuth.js** | Next.js 전용, 간편   | Next.js 풀스택                    |

### 관리형 서비스 (Auth-as-a-Service)

| 서비스            | 특징                      | 추천 상황               |
| ----------------- | ------------------------- | ----------------------- |
| **Supabase Auth** | PostgreSQL 연동, 무료     | Supabase 사용시         |
| **Firebase Auth** | 모바일 강점, 무료 티어    | Firebase 사용시, 모바일 |
| **Clerk**         | 완성형 UI, DX 좋음        | 빠른 출시, 스타트업     |
| **Auth0**         | 엔터프라이즈급, 규정 준수 | 대기업, 보안 규정       |

---

## 5. 추가 기술

### 캐싱

| 기술           | 용도                     |
| -------------- | ------------------------ |
| **Redis**      | 분산 캐시, 세션, Pub/Sub |
| **node-cache** | 인메모리, 단일 서버      |
| **Memcached**  | 단순 캐시, 수평 확장     |

### 작업 큐

| 기술         | 용도                         |
| ------------ | ---------------------------- |
| **BullMQ**   | Redis 기반, NestJS 통합      |
| **RabbitMQ** | 메시지 브로커, 복잡한 라우팅 |
| **Kafka**    | 이벤트 스트리밍, 대용량      |
| **AWS SQS**  | 서버리스 큐                  |

### 실시간

| 기술          | 용도                     |
| ------------- | ------------------------ |
| **Socket.io** | WebSocket + 폴백         |
| **ws**        | 순수 WebSocket           |
| **SSE**       | 서버 → 클라이언트 단방향 |
| **Pusher**    | 관리형 실시간            |

### 파일 저장

| 기술              | 용도                 |
| ----------------- | -------------------- |
| **AWS S3**        | 표준, 무제한         |
| **Cloudflare R2** | S3 호환, egress 무료 |
| **MinIO**         | 셀프 호스팅 S3       |
| **Uploadthing**   | 간편 업로드 서비스   |

### 검색

| 기술              | 용도                  |
| ----------------- | --------------------- |
| **Elasticsearch** | 전문 검색, 로그, 분석 |
| **Meilisearch**   | 타이포 허용, 간단     |
| **Algolia**       | 관리형, 빠름          |
| **Typesense**     | 오픈소스 Algolia 대안 |

### API 스타일

| 기술        | 용도                        |
| ----------- | --------------------------- |
| **REST**    | 표준, 캐싱 용이             |
| **GraphQL** | 유연한 쿼리, 프론트 주도    |
| **gRPC**    | 마이크로서비스, 성능        |
| **tRPC**    | TypeScript 풀스택, E2E 타입 |

### 모니터링/로깅

| 기술                     | 용도             |
| ------------------------ | ---------------- |
| **Prometheus + Grafana** | 메트릭, 대시보드 |
| **Sentry**               | 에러 추적        |
| **Datadog**              | 올인원 APM       |
| **Winston/Pino**         | Node.js 로깅     |
| **ELK Stack**            | 로그 분석        |

### 배포

| 플랫폼      | 특징                   |
| ----------- | ---------------------- |
| **Vercel**  | 프론트엔드 + 서버리스  |
| **Railway** | 쉬운 배포, PostgreSQL  |
| **Render**  | Heroku 대안, 무료 티어 |
| **Fly.io**  | Edge, 컨테이너         |
| **AWS**     | 엔터프라이즈, 복잡함   |

---

## 6. 스택 조합 추천

### 초보자 / 빠른 시작

```
NestJS + Prisma + SQLite + JWT
→ 설치 없이 바로 시작
→ 나중에 PostgreSQL로 전환 쉬움
```

### 일반 프로덕션

```
NestJS + Prisma + PostgreSQL + JWT + Redis
→ 대부분의 서비스에 적합
→ 캐싱, 세션 관리 가능
```

### 서버리스

```
Hono + Drizzle + Neon + JWT
→ Vercel/Cloudflare 배포
→ 콜드 스타트 최소화
```

### BaaS (최소 백엔드 코드)

```
Supabase (PostgreSQL + Auth + Realtime + Storage)
→ 백엔드 거의 필요 없음
→ Row Level Security로 보안
```

### ML/AI 백엔드

```
FastAPI + SQLAlchemy + PostgreSQL + Redis
→ Python ML 라이브러리 직접 사용
→ 비동기 처리 가능
```

### 엔터프라이즈

```
Spring Boot + JPA + PostgreSQL + Redis + Kafka
→ 대기업 표준
→ 트랜잭션 관리, 보안
```

### 실시간 앱 (채팅)

```
NestJS + Prisma + PostgreSQL + Socket.io + Redis
→ Redis Adapter로 수평 확장
→ Presence, Room 관리
```
