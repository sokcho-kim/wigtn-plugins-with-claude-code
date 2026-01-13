---
name: orchestration-protocol
description: Multi-plugin orchestration protocol for coordinating parallel execution, ownership enforcement, and conflict prevention.
---

# Orchestration Protocol

멀티 플러그인 오케스트레이션을 위한 8단계 프로토콜입니다.

## 8-Phase Protocol

### Phase 1: Discovery
프로젝트 구조와 기술 스택을 분석합니다.

```
분석 대상:
- package.json (dependencies)
- prisma/schema.prisma
- src/ 또는 app/ 구조
- 기존 파일 패턴
```

### Phase 2: Analysis
요청을 분석하여 필요한 작업을 파악합니다.

```
분석 항목:
- 영향받는 레이어 (DB, API, UI)
- 필요한 파일 생성/수정
- 의존성 관계
```

### Phase 3: Dependencies
작업 간 의존성을 파악합니다.

```
의존성 순서:
1. Prisma Schema (먼저)
2. NestJS Service/Controller
3. Next.js Components
4. Tests
```

### Phase 4: Ownership
각 플러그인의 파일 소유권을 결정합니다.

```
소유권 규칙:
- prisma/** → stack-prisma
- src/modules/** → stack-nestjs
- app/** → stack-nextjs
- Dockerfile, .github/** → stack-infra
```

### Phase 5: Locking
동시 수정 방지를 위한 파일 잠금입니다.

```typescript
interface FileLock {
  path: string;
  owner: string;
  timestamp: Date;
  operation: 'create' | 'modify' | 'delete';
}
```

### Phase 6: Conflict Detection
충돌 가능성을 사전에 감지합니다.

```
충돌 유형:
- 동일 파일 수정 시도
- 순환 의존성
- 호환되지 않는 변경
```

### Phase 7: Duplicate Detection
중복 작업을 방지합니다.

```
중복 체크:
- 동일 엔티티 생성
- 동일 API 엔드포인트
- 동일 컴포넌트 이름
```

### Phase 8: Dispatch
작업을 적절한 플러그인에 배분합니다.

```
배분 순서:
1. Tier 1: stack-prisma (DB 스키마)
2. Tier 2: stack-nestjs (백엔드 API)
3. Tier 3: stack-nextjs, stack-admin (프론트엔드)
4. Tier 4: stack-infra (인프라)
```

## Execution Rules

1. **순차 실행**: Tier는 순서대로 실행
2. **병렬 실행**: 같은 Tier 내에서는 병렬 가능
3. **잠금 해제**: 작업 완료 후 즉시 잠금 해제
4. **롤백**: 실패 시 이전 상태로 복구

## Usage

오케스트레이터는 자동으로 작업을 분배합니다:

```
사용자: "User 엔티티와 CRUD API, 관리자 페이지 만들어줘"

오케스트레이터 분석:
→ stack-prisma: User 모델 생성
→ stack-nestjs: UserModule, UserService, UserController
→ stack-admin: User 관리 페이지
```
