# Architecture Patterns Guide

A guide to backend architecture patterns and design.

## Architecture Pattern Selection

| Pattern | Suitable Situation | Team Size |
|---------|-------------------|-----------|
| **Monolithic** | MVP, rapid development | 1-3 people |
| **Modular Monolith** | Medium scale, future separation possibility | 3-10 people |
| **Microservices** | Large scale, independent deployment needed | 10+ people |
| **Serverless** | Event-driven, variable traffic | 1-5 people |

## Monolithic Architecture

Single codebase, single deployment unit.

### Structure

```
src/
├── controllers/
│   ├── user.controller.ts
│   ├── product.controller.ts
│   └── order.controller.ts
├── services/
│   ├── user.service.ts
│   ├── product.service.ts
│   └── order.service.ts
├── repositories/
│   ├── user.repository.ts
│   ├── product.repository.ts
│   └── order.repository.ts
├── entities/
│   ├── user.entity.ts
│   ├── product.entity.ts
│   └── order.entity.ts
└── app.ts
```

### Advantages
- Simple development/deployment
- Easy debugging
- Simple transaction management

### Disadvantages
- Limited scaling
- Fixed technology stack
- Complexity as codebase grows

### Suitable Cases
- MVP, early startup
- Small team (1-3 people)
- Need for rapid release

## Modular Monolith

Single deployment unit but internally modularized.

### Structure

```
src/
├── modules/
│   ├── users/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── repositories/
│   │   ├── entities/
│   │   └── users.module.ts
│   ├── products/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── repositories/
│   │   ├── entities/
│   │   └── products.module.ts
│   └── orders/
│       ├── controllers/
│       ├── services/
│       ├── repositories/
│       ├── entities/
│       └── orders.module.ts
├── shared/
│   ├── database/
│   ├── auth/
│   └── utils/
└── app.ts
```

### Advantages
- Clear boundaries
- Easy future microservices separation
- Team-based module ownership possible

### Disadvantages
- More complex than monolithic
- Need to manage inter-module dependencies

### Suitable Cases
- Medium-scale projects
- 3-10 person team
- Future expansion expected

### NestJS Example

```typescript
// users/users.module.ts
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService], // Available for use in other modules
})
export class UsersModule {}

// app.module.ts
@Module({
  imports: [
    UsersModule,
    ProductsModule,
    OrdersModule,
    SharedModule,
  ],
})
export class AppModule {}
```

## Microservices Architecture

A combination of independent services.

### Structure

```
services/
├── user-service/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── product-service/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── order-service/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
└── api-gateway/
    ├── src/
    ├── Dockerfile
    └── package.json
```

### Advantages
- Independent deployment/scaling
- Technology stack freedom
- Fault isolation

### Disadvantages
- High operational complexity
- Difficult distributed transactions
- Network overhead

### Suitable Cases
- Large-scale systems
- 10+ person team
- Need for independent deployment

### Communication Patterns

| Pattern | Use Case |
|---------|----------|
| **REST** | Synchronous communication, simple CRUD |
| **gRPC** | High performance, internal communication |
| **Message Queue** | Asynchronous, event-driven |

## Serverless Architecture

Cloud function-based.

### Structure

```
functions/
├── users/
│   ├── create.ts
│   ├── get.ts
│   └── list.ts
├── products/
│   ├── create.ts
│   └── search.ts
└── orders/
    ├── create.ts
    └── process.ts
```

### Advantages
- Auto-scaling
- Usage-based billing
- No infrastructure management needed

### Disadvantages
- Cold start latency
- Execution time limits
- Vendor lock-in

### Suitable Cases
- Event-driven workloads
- Variable traffic
- Small team

## Layer Architecture

### Standard 4 Layers

```
┌─────────────────────────────────────────┐
│  Presentation (Controller/Handler)      │
│  - HTTP request/response handling       │
│  - Input validation                     │
│  - Response formatting                  │
├─────────────────────────────────────────┤
│  Application (Service/UseCase)          │
│  - Business logic orchestration         │
│  - Transaction management               │
│  - External service calls               │
├─────────────────────────────────────────┤
│  Domain (Entity/Model)                  │
│  - Core business rules                  │
│  - Entities, value objects             │
│  - Domain events                        │
├─────────────────────────────────────────┤
│  Infrastructure (Repository/External)   │
│  - Database access                      │
│  - External API clients                 │
│  - Message queues                       │
└─────────────────────────────────────────┘
```

### Dependency Direction

```
Controller → Service → Repository
                ↓
            Entity (Domain)
```

## Domain Separation Strategies

### Feature-based

```
src/
├── users/         # User-related
├── products/      # Product-related
├── orders/        # Order-related
└── payments/      # Payment-related
```

### Bounded Context (DDD)

```
src/
├── identity/           # Authentication/Authorization context
│   ├── user/
│   └── auth/
├── catalog/            # Product catalog context
│   ├── product/
│   └── category/
├── ordering/           # Order context
│   ├── order/
│   └── cart/
└── billing/            # Billing context
    ├── payment/
    └── invoice/
```

### Layer-based

```
src/
├── api/               # Presentation
│   ├── controllers/
│   └── middlewares/
├── application/       # Application
│   └── services/
├── domain/            # Domain
│   └── entities/
└── infrastructure/    # Infrastructure
    ├── repositories/
    └── external/
```

## Common Patterns

### Repository Pattern

```typescript
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<User>;
  delete(id: string): Promise<void>;
}

class PrismaUserRepository implements UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }
  // ...
}
```

### Service Pattern

```typescript
class OrderService {
  constructor(
    private orderRepo: OrderRepository,
    private productService: ProductService,
    private paymentService: PaymentService,
  ) {}

  async createOrder(dto: CreateOrderDto): Promise<Order> {
    // Check inventory
    await this.productService.checkStock(dto.items);

    // Create order
    const order = await this.orderRepo.save(
      Order.create(dto)
    );

    // Process payment
    await this.paymentService.process(order);

    return order;
  }
}
```

### Event-Driven Pattern

```typescript
// Event publishing
class OrderService {
  async createOrder(dto: CreateOrderDto) {
    const order = await this.orderRepo.save(Order.create(dto));

    // Publish event
    this.eventEmitter.emit('order.created', {
      orderId: order.id,
      userId: order.userId,
      items: order.items,
    });

    return order;
  }
}

// Event subscription
@OnEvent('order.created')
async handleOrderCreated(event: OrderCreatedEvent) {
  // Decrease inventory
  await this.inventoryService.decreaseStock(event.items);

  // Send notification
  await this.notificationService.sendOrderConfirmation(event);
}
```

## Decision Checklist

Considerations when selecting architecture:

- [ ] What is the expected traffic scale?
- [ ] What is the team size and structure?
- [ ] Is independent deployment needed?
- [ ] What are the scalability requirements?
- [ ] Is technology stack diversity needed?
- [ ] What is the operational capability?
- [ ] What are the budget constraints?

## Migration Path

```
Monolithic
    ↓ (scale increase)
Modular Monolith
    ↓ (team/deployment independence needed)
Microservices
```

It's important to design each stage to allow transition to the next stage.
