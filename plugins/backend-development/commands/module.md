---
description: NestJS 모듈을 구조화된 형태로 생성합니다. Trigger on "/module", "모듈 만들어줘", "서비스 추가해줘", or when user needs to create NestJS modules.
---

# Module

NestJS 모듈을 구조화된 형태로 생성합니다.

## Usage

```bash
/module <module-name> [options]
```

## Parameters

- `module-name`: 모듈 이름 (required)
- `--crud`: 전체 CRUD 구조 생성
- `--service-only`: 서비스만 생성
- `--with-dto`: DTO 파일 포함
- `--with-entity`: Prisma 모델 확장용 엔티티 포함

## Protocol

### Step 1: 기존 상태 확인

```bash
# 모듈 존재 확인
Glob: "src/<module>/**"

# app.module.ts 등록 확인
Grep: "<Module>Module" in src/app.module.ts
```

**이미 존재하는 경우:**

```
⚠️ NotificationsModule이 이미 존재합니다.

선택해주세요:
1. 기존 모듈에 기능 추가
2. 기존 모듈 확인
3. 취소
```

### Step 2: 파일 생성

**Basic:**

```
src/<module>/
├── <module>.module.ts
├── <module>.controller.ts
└── <module>.service.ts
```

**With CRUD (--crud):**

```
src/<module>/
├── <module>.module.ts
├── <module>.controller.ts
├── <module>.service.ts
├── <module>.repository.ts
├── dto/
│   ├── create-<module>.dto.ts
│   ├── update-<module>.dto.ts
│   └── query-<module>.dto.ts
└── interfaces/
    └── <module>.interface.ts
```

### Step 3: app.module.ts 등록

자동으로 `app.module.ts`에 모듈 import 추가

### Step 4: 결과 출력

```
✅ 모듈 생성 완료

생성된 파일:
  • src/notifications/notifications.module.ts
  • src/notifications/notifications.controller.ts
  • src/notifications/notifications.service.ts

app.module.ts에 자동 등록됨
```

## Templates

### Module

```typescript
import { Module } from '@nestjs/common';
import { <Module>Controller } from './<module>.controller';
import { <Module>Service } from './<module>.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [<Module>Controller],
  providers: [<Module>Service],
  exports: [<Module>Service],
})
export class <Module>Module {}
```

### Service

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class <Module>Service {
  constructor(private prisma: PrismaService) {}

  // Implement your business logic here
}
```

### Controller

```typescript
import { Controller, Get, Post, Body, Param, Patch, Delete } from '@nestjs/common';
import { <Module>Service } from './<module>.service';

@Controller('api/<module>')
export class <Module>Controller {
  constructor(private readonly service: <Module>Service) {}

  // Implement your endpoints here
}
```

## Examples

### 기본 모듈

```
입력: /module notifications

결과:
- notifications.module.ts
- notifications.controller.ts
- notifications.service.ts
```

### CRUD 모듈

```
입력: /module payments --crud

결과:
- 전체 CRUD 구조
- repository 패턴
- DTO 파일들
```

### 서비스만

```
입력: /module email --service-only

결과:
- email.module.ts
- email.service.ts (controller 없음)
```

## Skill Reference

> 📚 이 Command는 `backend-architect` 스킬의 모듈 생성 패턴을 따릅니다.
> 전체 설계가 필요하면 `/backend` 명령어를 먼저 사용하세요.

## Integration Points

| 연결 대상                | 역할                                  |
| ------------------------ | ------------------------------------- |
| `backend-architect` 스킬 | 모듈 구조 패턴 참조                   |
| `/model` 명령어          | 모듈에 필요한 Prisma 모델 생성        |
| `/api` 명령어            | CRUD API가 필요한 경우 (더 많은 옵션) |
| `/backend` 명령어        | 전체 백엔드 설계가 필요한 경우        |

## Next Step

모듈 생성 완료 후:

```
💡 NestJS 모듈이 생성되었습니다!

다음 단계:
  → 비즈니스 로직 구현
  → `/auto-commit`으로 커밋
```

## Rules

1. **중복 방지**: 기존 모듈 존재 시 확인
2. **자동 등록**: app.module.ts에 자동 import
3. **PrismaService 연동**: DB 접근이 필요한 경우 자동 주입
4. **네이밍 컨벤션**: 기존 프로젝트 스타일 준수

## $ARGUMENTS
