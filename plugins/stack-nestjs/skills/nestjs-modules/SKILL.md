---
name: nestjs-modules
description: NestJS module architecture, providers, imports/exports patterns. Use when structuring API modules.
---

# NestJS Modules

NestJS 모듈 구조와 의존성 주입 패턴입니다.

## Module Structure

### Basic Module

```typescript
// users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';

@Module({
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],  // Export for other modules
})
export class UsersModule {}
```

### Directory Structure

```
src/
├── app.module.ts           # Root module
├── common/                 # Shared utilities
│   ├── common.module.ts
│   ├── decorators/
│   ├── filters/
│   ├── guards/
│   ├── interceptors/
│   └── pipes/
├── config/                 # Configuration
│   ├── config.module.ts
│   └── database.config.ts
├── users/                  # Feature module
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.repository.ts
│   ├── dto/
│   │   ├── create-user.dto.ts
│   │   └── update-user.dto.ts
│   └── entities/
│       └── user.entity.ts
└── prisma/                 # Prisma module
    ├── prisma.module.ts
    └── prisma.service.ts
```

## Root Module Pattern

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ProductsModule } from './products/products.module';

@Module({
  imports: [
    // Global config
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),

    // Database
    PrismaModule,

    // Feature modules
    AuthModule,
    UsersModule,
    ProductsModule,
  ],
})
export class AppModule {}
```

## Global Modules

### Prisma Module

```typescript
// prisma/prisma.module.ts
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()  // Available everywhere without importing
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

### Common Module

```typescript
// common/common.module.ts
import { Global, Module } from '@nestjs/common';
import { LoggerService } from './services/logger.service';
import { CacheService } from './services/cache.service';

@Global()
@Module({
  providers: [LoggerService, CacheService],
  exports: [LoggerService, CacheService],
})
export class CommonModule {}
```

## Feature Module Pattern

```typescript
// products/products.module.ts
import { Module } from '@nestjs/common';
import { ProductsController } from './products.controller';
import { ProductsService } from './products.service';
import { ProductsRepository } from './products.repository';
import { CategoriesModule } from '../categories/categories.module';

@Module({
  imports: [CategoriesModule],  // Import other feature modules
  controllers: [ProductsController],
  providers: [
    ProductsService,
    ProductsRepository,
  ],
  exports: [ProductsService],
})
export class ProductsModule {}
```

## Dynamic Modules

### Config Module Pattern

```typescript
// mail/mail.module.ts
import { DynamicModule, Module } from '@nestjs/common';
import { MailService } from './mail.service';

interface MailModuleOptions {
  apiKey: string;
  defaultFrom: string;
}

@Module({})
export class MailModule {
  static forRoot(options: MailModuleOptions): DynamicModule {
    return {
      module: MailModule,
      global: true,
      providers: [
        {
          provide: 'MAIL_OPTIONS',
          useValue: options,
        },
        MailService,
      ],
      exports: [MailService],
    };
  }

  static forRootAsync(options: {
    useFactory: (...args: any[]) => MailModuleOptions;
    inject?: any[];
  }): DynamicModule {
    return {
      module: MailModule,
      global: true,
      providers: [
        {
          provide: 'MAIL_OPTIONS',
          useFactory: options.useFactory,
          inject: options.inject || [],
        },
        MailService,
      ],
      exports: [MailService],
    };
  }
}

// Usage in app.module.ts
MailModule.forRootAsync({
  useFactory: (config: ConfigService) => ({
    apiKey: config.get('MAIL_API_KEY'),
    defaultFrom: config.get('MAIL_FROM'),
  }),
  inject: [ConfigService],
})
```

## Provider Patterns

### Custom Providers

```typescript
@Module({
  providers: [
    // Class provider (standard)
    UsersService,

    // Value provider
    {
      provide: 'API_VERSION',
      useValue: '1.0.0',
    },

    // Factory provider
    {
      provide: 'DATABASE_CONNECTION',
      useFactory: async (config: ConfigService) => {
        return createConnection(config.get('DATABASE_URL'));
      },
      inject: [ConfigService],
    },

    // Alias provider
    {
      provide: 'AliasedService',
      useExisting: UsersService,
    },
  ],
})
export class AppModule {}
```

### Token-based Injection

```typescript
// tokens.ts
export const MAIL_OPTIONS = Symbol('MAIL_OPTIONS');
export const CACHE_MANAGER = Symbol('CACHE_MANAGER');

// mail.service.ts
@Injectable()
export class MailService {
  constructor(
    @Inject(MAIL_OPTIONS) private options: MailModuleOptions,
  ) {}
}
```

## Module Re-exports

```typescript
// shared/shared.module.ts
@Module({
  imports: [
    ConfigModule,
    HttpModule,
    CacheModule,
  ],
  exports: [
    ConfigModule,  // Re-export for consuming modules
    HttpModule,
    CacheModule,
  ],
})
export class SharedModule {}
```

## Best Practices

```yaml
module_guidelines:
  - One feature per module
  - Keep modules focused and cohesive
  - Export only what's needed
  - Use Global sparingly
  - Avoid circular dependencies

organization:
  - Group by feature, not by type
  - Co-locate related files
  - Use barrel exports (index.ts)

naming:
  - Module: <feature>.module.ts
  - Controller: <feature>.controller.ts
  - Service: <feature>.service.ts
  - Repository: <feature>.repository.ts

imports_order:
  1. NestJS core modules
  2. Third-party modules
  3. Global modules
  4. Feature modules
```

## Module Checklist

```yaml
new_module_checklist:
  - [ ] Create module directory
  - [ ] Create <feature>.module.ts
  - [ ] Create <feature>.controller.ts
  - [ ] Create <feature>.service.ts
  - [ ] Create dto/ directory with DTOs
  - [ ] Add module to parent module imports
  - [ ] Export services if needed by other modules
```
