---
name: nestjs-services
description: NestJS service layer patterns, business logic organization, error handling. Use when implementing business logic.
---

# NestJS Services

서비스 레이어 패턴과 비즈니스 로직 구성입니다.

## Basic Service Structure

```typescript
// users/users.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(dto: CreateUserDto) {
    return this.prisma.user.create({
      data: dto,
    });
  }

  async findAll() {
    return this.prisma.user.findMany();
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  async update(id: string, dto: UpdateUserDto) {
    await this.findOne(id);  // Ensure exists

    return this.prisma.user.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: string) {
    await this.findOne(id);  // Ensure exists

    return this.prisma.user.delete({
      where: { id },
    });
  }
}
```

## Service with Repository Pattern

```typescript
// users/users.repository.ts
@Injectable()
export class UsersRepository {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.UserCreateInput) {
    return this.prisma.user.create({ data });
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findMany(params: {
    skip?: number;
    take?: number;
    where?: Prisma.UserWhereInput;
    orderBy?: Prisma.UserOrderByWithRelationInput;
  }) {
    return this.prisma.user.findMany(params);
  }

  async update(id: string, data: Prisma.UserUpdateInput) {
    return this.prisma.user.update({ where: { id }, data });
  }

  async delete(id: string) {
    return this.prisma.user.delete({ where: { id } });
  }

  async count(where?: Prisma.UserWhereInput) {
    return this.prisma.user.count({ where });
  }
}

// users/users.service.ts
@Injectable()
export class UsersService {
  constructor(private usersRepository: UsersRepository) {}

  async create(dto: CreateUserDto) {
    const existingUser = await this.usersRepository.findByEmail(dto.email);
    if (existingUser) {
      throw new ConflictException('Email already in use');
    }

    const hashedPassword = await hash(dto.password, 10);
    return this.usersRepository.create({
      ...dto,
      password: hashedPassword,
    });
  }
}
```

## Pagination Pattern

```typescript
// common/services/pagination.service.ts
export interface PaginationParams {
  page: number;
  limit: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface PaginatedResult<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

// users/users.service.ts
@Injectable()
export class UsersService {
  async findAllPaginated(
    params: PaginationParams,
    filters?: { status?: string; search?: string },
  ): Promise<PaginatedResult<User>> {
    const { page, limit, sortBy = 'createdAt', sortOrder = 'desc' } = params;
    const skip = (page - 1) * limit;

    const where: Prisma.UserWhereInput = {};

    if (filters?.status) {
      where.status = filters.status;
    }

    if (filters?.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { email: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
```

## Transaction Pattern

```typescript
@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async createOrder(dto: CreateOrderDto) {
    return this.prisma.$transaction(async (tx) => {
      // 1. Check stock
      const product = await tx.product.findUnique({
        where: { id: dto.productId },
      });

      if (!product || product.stock < dto.quantity) {
        throw new BadRequestException('Insufficient stock');
      }

      // 2. Create order
      const order = await tx.order.create({
        data: {
          userId: dto.userId,
          items: {
            create: {
              productId: dto.productId,
              quantity: dto.quantity,
              price: product.price,
            },
          },
        },
      });

      // 3. Update stock
      await tx.product.update({
        where: { id: dto.productId },
        data: { stock: { decrement: dto.quantity } },
      });

      return order;
    });
  }
}
```

## Error Handling

```typescript
// common/exceptions/business.exception.ts
export class BusinessException extends HttpException {
  constructor(
    public readonly code: string,
    message: string,
    status: HttpStatus = HttpStatus.BAD_REQUEST,
    public readonly details?: Record<string, unknown>,
  ) {
    super({ code, message, details }, status);
  }
}

export class InsufficientStockException extends BusinessException {
  constructor(productId: string, available: number, requested: number) {
    super(
      'INSUFFICIENT_STOCK',
      `Insufficient stock for product ${productId}`,
      HttpStatus.BAD_REQUEST,
      { productId, available, requested },
    );
  }
}

// Usage in service
async checkout(dto: CheckoutDto) {
  const product = await this.productsRepository.findById(dto.productId);

  if (product.stock < dto.quantity) {
    throw new InsufficientStockException(
      dto.productId,
      product.stock,
      dto.quantity,
    );
  }
}
```

## Event-Driven Pattern

```typescript
// events/user-created.event.ts
export class UserCreatedEvent {
  constructor(
    public readonly userId: string,
    public readonly email: string,
    public readonly name: string,
  ) {}
}

// users/users.service.ts
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class UsersService {
  constructor(
    private prisma: PrismaService,
    private eventEmitter: EventEmitter2,
  ) {}

  async create(dto: CreateUserDto) {
    const user = await this.prisma.user.create({ data: dto });

    // Emit event
    this.eventEmitter.emit(
      'user.created',
      new UserCreatedEvent(user.id, user.email, user.name),
    );

    return user;
  }
}

// listeners/user.listener.ts
@Injectable()
export class UserListener {
  constructor(private mailService: MailService) {}

  @OnEvent('user.created')
  async handleUserCreated(event: UserCreatedEvent) {
    await this.mailService.sendWelcomeEmail(event.email, event.name);
  }
}
```

## Best Practices

```yaml
service_guidelines:
  - Single responsibility per service
  - Keep business logic in services
  - Use repositories for data access abstraction
  - Handle errors with custom exceptions
  - Use transactions for multi-step operations

organization:
  - One service per entity/feature
  - Compose services for complex operations
  - Emit events for side effects
  - Cache frequently accessed data

naming:
  - Methods: verb + noun (createUser, findById)
  - Clear, descriptive names
  - Async methods return Promise

error_handling:
  - Use NestJS built-in exceptions
  - Create custom business exceptions
  - Include error codes for client
  - Log errors appropriately
```
