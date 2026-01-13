---
description: NestJS 프로젝트에 JWT 기반 인증 시스템을 추가합니다. Trigger on "/auth", "인증 추가해줘", "로그인 만들어줘", "JWT 설정해줘", or when user needs authentication setup.
---

# Auth

NestJS 프로젝트에 완전한 인증 시스템을 추가합니다.

## Usage

```bash
/auth [options]
```

## Parameters

- `--strategy <type>`: 인증 전략 (jwt, session, oauth)
- `--refresh`: Refresh Token 포함
- `--roles`: 역할 기반 접근 제어 추가
- `--social <providers>`: 소셜 로그인 추가 (google, github)

## Protocol

### Step 1: 기존 상태 확인

```bash
# 인증 모듈 존재 확인
Glob: "src/auth/**"

# User 모델 확인
Grep: "model User" in prisma/schema.prisma
```

**이미 존재하는 경우:**

```
⚠️ AuthModule이 이미 존재합니다.

선택해주세요:
1. Refresh Token 추가
2. 역할(Roles) 기능 추가
3. 소셜 로그인 추가
4. 기존 설정 확인
5. 취소
```

### Step 2: 의존성 확인/설치

```bash
npm install @nestjs/passport @nestjs/jwt passport passport-jwt bcrypt
npm install -D @types/passport-jwt @types/bcrypt
```

### Step 3: 파일 생성

```
src/auth/
├── auth.module.ts
├── auth.controller.ts
├── auth.service.ts
├── strategies/
│   └── jwt.strategy.ts
├── guards/
│   ├── jwt-auth.guard.ts
│   └── roles.guard.ts        # --roles
├── decorators/
│   ├── current-user.decorator.ts
│   └── roles.decorator.ts    # --roles
└── dto/
    ├── signup.dto.ts
    ├── login.dto.ts
    └── token.dto.ts
```

### Step 4: 환경 변수 안내

```
.env에 추가할 변수:

JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
```

### Step 5: 결과 출력

```
✅ 인증 모듈 생성 완료

생성된 파일:
  • src/auth/auth.module.ts
  • src/auth/auth.controller.ts
  • src/auth/auth.service.ts
  • src/auth/strategies/jwt.strategy.ts
  • src/auth/guards/jwt-auth.guard.ts
  • src/auth/decorators/current-user.decorator.ts
  • src/auth/dto/*.ts

엔드포인트:
  POST /api/auth/signup    회원가입
  POST /api/auth/login     로그인 → JWT 발급
  POST /api/auth/refresh   토큰 갱신 (--refresh)
  GET  /api/auth/me        내 정보 [Auth]

다음 단계:
  1. .env 파일에 JWT_SECRET 설정
  2. npx prisma migrate dev (User 모델 변경 시)
  3. npm run start:dev
```

## Templates

### Auth Controller

```typescript
@Controller("api/auth")
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post("signup")
  async signup(@Body() dto: SignupDto) {
    return this.authService.signup(dto);
  }

  @Post("login")
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post("refresh")
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Get("me")
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() user: User) {
    return user;
  }
}
```

### JWT Strategy

```typescript
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  async validate(payload: JwtPayload) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
    });
    if (!user) throw new UnauthorizedException();
    return user;
  }
}
```

### Roles Guard (--roles)

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.role === role);
  }
}
```

## Examples

### 기본 JWT 인증

```
입력: /auth

결과: 기본 JWT 인증 시스템 (signup, login, me)
```

### Refresh Token 포함

```
입력: /auth --refresh

결과: JWT + Refresh Token (자동 갱신 지원)
```

### 역할 기반 접근 제어

```
입력: /auth --roles

결과: JWT + @Roles('ADMIN') 데코레이터 + RolesGuard
```

### 소셜 로그인

```
입력: /auth --social google,github

결과: JWT + Google OAuth + GitHub OAuth
```

## Skill Reference

> 📚 이 Command는 `backend-architect` 스킬의 인증 모듈 구현을 실행합니다.
> 전체 설계가 필요하면 `/backend` 명령어를 먼저 사용하세요.

## Integration Points

| 연결 대상                | 역할                              |
| ------------------------ | --------------------------------- |
| `backend-architect` 스킬 | 인증 패턴 참조                    |
| `/model` 명령어          | User 모델이 없을 경우             |
| `/api` 명령어            | `--auth` 옵션으로 인증된 API 생성 |
| `/backend` 명령어        | 전체 백엔드 설계가 필요한 경우    |

## Next Step

인증 모듈 생성 완료 후:

```
💡 인증 시스템이 추가되었습니다!

다음 단계:
  1. .env 파일에 JWT_SECRET 설정
  2. npx prisma migrate dev (User 모델 변경 시)
  3. `/api <resource> --crud --auth`로 인증된 API 생성
  4. `/auto-commit`으로 커밋
```

## Rules

1. **중복 방지**: 기존 AuthModule 존재 시 확인
2. **User 모델 연동**: Prisma User 모델 자동 확인/생성
3. **보안 기본값**: bcrypt 해싱, 토큰 만료 시간 설정
4. **환경 변수**: 민감한 정보는 .env로 분리

## $ARGUMENTS
