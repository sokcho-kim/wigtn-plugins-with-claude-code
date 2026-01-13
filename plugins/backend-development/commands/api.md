---
description: NestJS 기반 RESTful API 엔드포인트를 생성합니다. Trigger on "/api", "API 만들어줘", "엔드포인트 추가해줘", "CRUD 만들어줘", or when user needs to create API endpoints.
---

# API

NestJS 모듈과 RESTful API 엔드포인트를 생성합니다.

## Usage

```bash
/api <resource-name> [options]
```

## Parameters

- `resource-name`: 리소스 이름 (required)
- `--crud`: 전체 CRUD 작업 생성
- `--auth`: 인증 필요 엔드포인트
- `--owner`: 소유자 권한 체크 추가
- `--paginate`: 페이지네이션 포함
- `--dto`: DTO 파일만 생성

## Protocol

### Step 1: 기존 상태 확인

```bash
# 모듈 존재 여부
Glob: "src/<resource>/**"

# app.module.ts 등록 여부
Grep: "<Resource>Module"
```

**이미 존재하는 경우:**

```
⚠️ src/products/ 모듈이 이미 존재합니다.

선택해주세요:
1. 기존 모듈에 엔드포인트 추가
2. 기존 모듈 확인
3. 취소
```

### Step 2: 파일 생성

```
src/<resource>/
├── <resource>.module.ts
├── <resource>.controller.ts
├── <resource>.service.ts
└── dto/
    ├── create-<resource>.dto.ts
    └── update-<resource>.dto.ts
```

### Step 3: app.module.ts 등록

자동으로 `app.module.ts`에 모듈 등록

### Step 4: 결과 출력

```
✅ API 생성 완료

생성된 파일:
  • src/products/products.module.ts
  • src/products/products.controller.ts
  • src/products/products.service.ts
  • src/products/dto/create-product.dto.ts
  • src/products/dto/update-product.dto.ts

엔드포인트:
  GET    /api/products          목록
  GET    /api/products/:id      상세
  POST   /api/products          생성 [Auth]
  PATCH  /api/products/:id      수정 [Auth]
  DELETE /api/products/:id      삭제 [Auth]
```

## Templates

### Controller (--crud)

```typescript
@Controller('api/<resource>')
export class <Resource>Controller {
  constructor(private readonly service: <Resource>Service) {}

  @Get()
  findAll(@Query() query: PaginationDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: Create<Resource>Dto, @CurrentUser() user: User) {
    return this.service.create(dto, user.id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() dto: Update<Resource>Dto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
```

### Service

```typescript
@Injectable()
export class <Resource>Service {
  constructor(private prisma: PrismaService) {}

  async findAll(query: PaginationDto) {
    const { page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      this.prisma.<resource>.findMany({ skip, take: limit }),
      this.prisma.<resource>.count(),
    ]);

    return {
      data,
      meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string) {
    const item = await this.prisma.<resource>.findUnique({ where: { id } });
    if (!item) throw new NotFoundException('<Resource> not found');
    return item;
  }

  async create(dto: Create<Resource>Dto, userId: string) {
    return this.prisma.<resource>.create({
      data: { ...dto, userId },
    });
  }

  async update(id: string, dto: Update<Resource>Dto) {
    await this.findOne(id);
    return this.prisma.<resource>.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.<resource>.delete({ where: { id } });
  }
}
```

## Examples

### 기본 CRUD

```
입력: /api products --crud

결과: products 모듈 + 전체 CRUD 엔드포인트 생성
```

### 인증 + 페이지네이션

```
입력: /api orders --crud --auth --paginate

결과: orders 모듈 + 인증 가드 + 페이지네이션 적용
```

### 소유자 권한

```
입력: /api posts --crud --auth --owner

결과: posts 모듈 + 소유자만 수정/삭제 가능
```

## Skill Reference

> 📚 이 Command는 `backend-architect` 스킬의 Phase 4 (API 설계) + Phase 6 (구현)을 실행합니다.
> 전체 설계가 필요하면 `/backend` 명령어를 먼저 사용하세요.

## Integration Points

| 연결 대상                | 역할                                 |
| ------------------------ | ------------------------------------ |
| `backend-architect` 스킬 | API 설계 패턴 참조                   |
| `/model` 명령어          | API에 필요한 Prisma 모델이 없을 경우 |
| `/auth` 명령어           | `--auth` 옵션 사용 시 인증 모듈 필요 |
| `/backend` 명령어        | 전체 백엔드 설계가 필요한 경우       |

## Next Step

API 생성 완료 후:

```
💡 API 엔드포인트가 생성되었습니다!

다음 단계:
  → `/api <다른-리소스> --crud`로 추가 API 생성
  → `/devops --docker`로 Docker 설정
  → `/auto-commit`으로 커밋
```

## Rules

1. **중복 방지**: 기존 모듈 존재 시 확인
2. **Prisma 연동**: PrismaService 자동 주입
3. **DTO 검증**: class-validator 데코레이터 적용
4. **일관된 응답**: 표준 응답 형식 사용

## $ARGUMENTS
