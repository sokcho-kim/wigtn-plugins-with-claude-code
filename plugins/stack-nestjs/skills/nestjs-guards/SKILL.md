---
name: nestjs-guards
description: NestJS guards, authentication, authorization patterns. Use when implementing access control.
---

# NestJS Guards

인증/인가를 위한 Guard 패턴입니다.

## Basic Guard Structure

```typescript
// common/guards/auth.guard.ts
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';

@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const token = this.extractToken(request);

    if (!token) {
      throw new UnauthorizedException('Token not provided');
    }

    // Validate token logic here
    return true;
  }

  private extractToken(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
```

## JWT Authentication Guard

```typescript
// auth/guards/jwt-auth.guard.ts
import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    // Check for @Public() decorator
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    return super.canActivate(context);
  }
}
```

### Public Decorator

```typescript
// auth/decorators/public.decorator.ts
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

// Usage
@Public()
@Get('health')
healthCheck() {
  return { status: 'ok' };
}
```

## Role-Based Access Control

### Roles Decorator

```typescript
// auth/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';

export enum Role {
  USER = 'USER',
  ADMIN = 'ADMIN',
  MODERATOR = 'MODERATOR',
}

export const ROLES_KEY = 'roles';
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);
```

### Roles Guard

```typescript
// auth/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY, Role } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true;  // No roles required
    }

    const { user } = context.switchToHttp().getRequest();

    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}

// Usage
@Roles(Role.ADMIN)
@Get('admin/users')
getAdminUsers() {
  return this.usersService.findAll();
}
```

## Permission-Based Guard

```typescript
// auth/decorators/permissions.decorator.ts
export const PERMISSIONS_KEY = 'permissions';
export const Permissions = (...permissions: string[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);

// auth/guards/permissions.guard.ts
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredPermissions) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();
    return requiredPermissions.every((perm) =>
      user.permissions?.includes(perm),
    );
  }
}

// Usage
@Permissions('users:read', 'users:write')
@Post('users')
createUser(@Body() dto: CreateUserDto) {
  return this.usersService.create(dto);
}
```

## Resource Ownership Guard

```typescript
// common/guards/ownership.guard.ts
import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

export const OWNER_KEY = 'ownerKey';
export const CheckOwnership = (ownerKey: string = 'userId') =>
  SetMetadata(OWNER_KEY, ownerKey);

@Injectable()
export class OwnershipGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const ownerKey = this.reflector.get<string>(OWNER_KEY, context.getHandler());

    if (!ownerKey) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const resourceId = request.params.id;

    // Admin bypass
    if (user.role === 'ADMIN') {
      return true;
    }

    // Check ownership based on route
    const resource = await this.getResource(context, resourceId);

    if (resource?.[ownerKey] !== user.id) {
      throw new ForbiddenException('You do not own this resource');
    }

    return true;
  }
}

// Usage
@CheckOwnership('authorId')
@Patch('posts/:id')
updatePost(@Param('id') id: string, @Body() dto: UpdatePostDto) {
  return this.postsService.update(id, dto);
}
```

## Guard Composition

```typescript
// Apply multiple guards
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
@Roles(Role.ADMIN)
@Permissions('users:delete')
@Delete('users/:id')
deleteUser(@Param('id') id: string) {
  return this.usersService.delete(id);
}
```

## Global Guards

```typescript
// main.ts or app.module.ts
import { APP_GUARD } from '@nestjs/core';

@Module({
  providers: [
    // Global JWT guard
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    // Global roles guard
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
  ],
})
export class AppModule {}
```

## Best Practices

```yaml
guard_guidelines:
  - Keep guards focused (single responsibility)
  - Use decorators for metadata
  - Combine guards with composition
  - Handle errors with proper exceptions
  - Cache permission checks when possible

guard_order:
  1. Authentication (who are you?)
  2. Authorization (what can you do?)
  3. Ownership (is this yours?)
  4. Rate limiting (how often?)

common_patterns:
  - @Public() for public routes
  - @Roles() for role-based access
  - @Permissions() for fine-grained access
  - Global guards with decorator overrides
```
