# Spec Sync

모노레포/멀티레포 환경에서 프론트엔드, 백엔드, AI 서비스 간 스펙 불일치를 감지하고 자동 동기화합니다.

## 문제 상황

```
Frontend: { name, email }           →  POST /api/users
Backend:  { name, email, password } ←  POST /api/users
                    ↑
              불일치 발생!
```

## 사용법

```bash
/sync apps/web apps/api              # 두 프로젝트 비교
/sync apps/web apps/api packages/shared  # 공유 패키지 포함
/sync --endpoint /api/users          # 특정 API만
/sync --dry-run                      # 리포트만 (수정 없음)
```

## 감지 대상

| 대상           | Frontend          | Backend         |
| -------------- | ----------------- | --------------- |
| API 엔드포인트 | fetch, axios 호출 | 라우트 핸들러   |
| 요청/응답 타입 | interface, type   | DTO, Entity     |
| 데이터 스키마  | Zod, Yup          | Prisma, TypeORM |
| 환경 변수      | NEXT*PUBLIC*\*    | process.env.\*  |

## 출력 예시

```
┌─────────────────────────────────────────────────────────────┐
│ 🔍 Spec Analysis Result                                     │
├─────────────────────────────────────────────────────────────┤
│ ✅ 일치: 12개                                               │
│ ⚠️ 불일치: 3개                                              │
├─────────────────────────────────────────────────────────────┤
│ 1. [API] POST /api/users                                    │
│    Frontend: { name, email }                                │
│    Backend:  { name, email, password }                      │
│    💡 권장: Backend → Frontend                              │
│                                                             │
│ 2. [TYPE] User.role                                         │
│    Frontend: string                                         │
│    Backend:  "admin" | "user"                               │
│    💡 권장: Backend → Frontend                              │
└─────────────────────────────────────────────────────────────┘

[1] 개별 선택  [A] 전체 동기화  [S] 건너뛰기
```

## Source of Truth 기준

| 유형      | 기준               | 이유             |
| --------- | ------------------ | ---------------- |
| API 스펙  | **Backend**        | 실제 서버 구현   |
| DB 스키마 | **Prisma/DB**      | 단일 진실의 원천 |
| 공유 타입 | **Shared Package** | 공유 타입 우선   |
| UI 전용   | **Frontend**       | 클라이언트 전용  |

## 동기화 결과

```
┌─────────────────────────────────────────────────────────────┐
│ ✅ Sync Complete                                            │
├─────────────────────────────────────────────────────────────┤
│ 📝 수정된 파일:                                              │
│   • apps/web/types/user.ts (password 필드 추가)            │
│   • apps/web/lib/api/users.ts (파라미터 업데이트)          │
│                                                             │
│ ⚠️ 수동 확인 필요:                                          │
│   • apps/web/components/UserForm.tsx (UI 업데이트)         │
└─────────────────────────────────────────────────────────────┘
```

## 옵션

```
--endpoint <path>   특정 엔드포인트만 분석
--type <name>       특정 타입만 분석
--dry-run           수정 없이 리포트만
--force             권장 방향으로 자동 동기화
--output <file>     리포트 JSON 저장
```

## 특징

- 🧠 **Opus 모델** - 복잡한 코드 구조 분석
- 🔄 **양방향 동기화** - Frontend ↔ Backend 선택 가능
- 📊 **상세 리포트** - 불일치 원인과 권장 해결책
- 🛡️ **안전한 수정** - dry-run, 선택적 동기화
- 📦 **모노레포 지원** - 공유 패키지 인식
