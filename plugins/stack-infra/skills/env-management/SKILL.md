---
name: env-management
description: Environment variable management, configuration patterns, secrets handling. Use when managing application configuration.
---

# Environment Management

환경 변수 관리와 설정 패턴입니다.

## Directory Structure

```
project/
├── .env                    # Local defaults (gitignored)
├── .env.example            # Template (committed)
├── .env.local              # Local overrides (gitignored)
├── .env.development        # Development defaults
├── .env.production         # Production defaults
├── .env.test               # Test environment
└── src/
    └── config/
        ├── index.ts        # Config aggregation
        ├── database.ts     # Database config
        ├── auth.ts         # Auth config
        └── env.ts          # Env validation
```

## Environment File Template

```bash
# .env.example

# ===========================================
# Application
# ===========================================
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# ===========================================
# Database
# ===========================================
DATABASE_URL="postgresql://user:password@localhost:5432/dbname?schema=public"

# ===========================================
# Authentication
# ===========================================
JWT_SECRET=your-jwt-secret-here
JWT_EXPIRES_IN=7d

# ===========================================
# OAuth (optional)
# ===========================================
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# ===========================================
# External Services
# ===========================================
REDIS_URL=redis://localhost:6379
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=

# ===========================================
# Storage
# ===========================================
S3_BUCKET=
S3_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

## Environment Validation with Zod

```typescript
// src/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  // Application
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  APP_URL: z.string().url(),

  // Database
  DATABASE_URL: z.string().min(1),

  // Auth
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),

  // Optional OAuth
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),

  // Redis
  REDIS_URL: z.string().url().optional(),

  // AWS S3
  S3_BUCKET: z.string().optional(),
  S3_REGION: z.string().optional(),
  AWS_ACCESS_KEY_ID: z.string().optional(),
  AWS_SECRET_ACCESS_KEY: z.string().optional(),
});

export type Env = z.infer<typeof envSchema>;

function validateEnv(): Env {
  const parsed = envSchema.safeParse(process.env);

  if (!parsed.success) {
    console.error('❌ Invalid environment variables:');
    console.error(parsed.error.flatten().fieldErrors);
    throw new Error('Invalid environment variables');
  }

  return parsed.data;
}

export const env = validateEnv();
```

## Next.js Environment Types

```typescript
// src/env.mjs (Next.js with T3 Env)
import { createEnv } from '@t3-oss/env-nextjs';
import { z } from 'zod';

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    JWT_SECRET: z.string().min(32),
    NODE_ENV: z.enum(['development', 'test', 'production']),
  },
  client: {
    NEXT_PUBLIC_APP_URL: z.string().url(),
    NEXT_PUBLIC_API_URL: z.string().url(),
  },
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    JWT_SECRET: process.env.JWT_SECRET,
    NODE_ENV: process.env.NODE_ENV,
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
  },
  skipValidation: !!process.env.SKIP_ENV_VALIDATION,
});
```

## NestJS Config Module

```typescript
// src/config/configuration.ts
export default () => ({
  port: parseInt(process.env.PORT || '3000', 10),
  database: {
    url: process.env.DATABASE_URL,
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  redis: {
    url: process.env.REDIS_URL,
  },
});

// src/config/config.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule as NestConfigModule } from '@nestjs/config';
import * as Joi from 'joi';
import configuration from './configuration';

@Module({
  imports: [
    NestConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: Joi.object({
        NODE_ENV: Joi.string()
          .valid('development', 'production', 'test')
          .default('development'),
        PORT: Joi.number().default(3000),
        DATABASE_URL: Joi.string().required(),
        JWT_SECRET: Joi.string().required(),
      }),
      validationOptions: {
        allowUnknown: true,
        abortEarly: true,
      },
    }),
  ],
})
export class ConfigModule {}

// Usage in service
@Injectable()
export class AppService {
  constructor(private configService: ConfigService) {}

  getDatabaseUrl(): string {
    return this.configService.get<string>('database.url');
  }
}
```

## Config by Feature

```typescript
// src/config/database.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('database', () => ({
  url: process.env.DATABASE_URL,
  poolSize: parseInt(process.env.DB_POOL_SIZE || '10', 10),
  logging: process.env.DB_LOGGING === 'true',
}));

// src/config/auth.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('auth', () => ({
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  oauth: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    },
  },
}));

// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({
      load: [databaseConfig, authConfig],
    }),
  ],
})
export class AppModule {}

// Usage
const jwtSecret = this.configService.get<string>('auth.jwt.secret');
```

## Docker Environment

```yaml
# docker-compose.yml
services:
  app:
    env_file:
      - .env
      - .env.${NODE_ENV:-development}
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp
```

## CI/CD Environment Variables

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    environment: production
    env:
      NODE_ENV: production
    steps:
      - name: Build
        run: npm run build
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
```

## Secrets Management

### Local Development

```bash
# Use direnv for automatic env loading
# .envrc
dotenv
export NODE_ENV=development

# Or use dotenv-cli
npx dotenv -e .env.local -- npm run dev
```

### Production Secrets

```yaml
# Kubernetes secrets
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  DATABASE_URL: "postgresql://..."
  JWT_SECRET: "..."

---
# Deployment using secrets
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
        - name: app
          envFrom:
            - secretRef:
                name: app-secrets
```

## Environment Switching

```typescript
// src/config/index.ts
const configs = {
  development: {
    apiUrl: 'http://localhost:4000',
    debug: true,
  },
  staging: {
    apiUrl: 'https://staging-api.example.com',
    debug: true,
  },
  production: {
    apiUrl: 'https://api.example.com',
    debug: false,
  },
};

export const config = configs[process.env.NODE_ENV || 'development'];
```

## .gitignore Pattern

```gitignore
# Environment files
.env
.env.local
.env.*.local
.env.development.local
.env.test.local
.env.production.local

# Keep example file
!.env.example
```

## Best Practices

```yaml
env_guidelines:
  - Never commit actual .env files
  - Always provide .env.example
  - Validate env vars at startup
  - Use typed config objects
  - Group related variables

naming_conventions:
  - Use UPPER_SNAKE_CASE
  - Prefix client-exposed vars (NEXT_PUBLIC_)
  - Group by feature (DB_, AUTH_, SMTP_)
  - Be descriptive (DATABASE_URL not DB)

security:
  - Rotate secrets regularly
  - Use secrets managers in production
  - Never log sensitive values
  - Limit env access by environment
  - Use separate credentials per env

validation:
  - Validate at application startup
  - Fail fast on missing required vars
  - Provide sensible defaults
  - Type coerce where needed (numbers, booleans)
```
