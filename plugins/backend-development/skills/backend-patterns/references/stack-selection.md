# Stack Selection Guide

A guide to stack selection criteria and recommended stacks by situation.

## Quick Decision Matrix

| Situation | Recommended Stack |
|-----------|------------------|
| Rapid prototyping | Express/Fastify + Drizzle + SQLite |
| Structured large-scale | NestJS + Prisma + PostgreSQL |
| Serverless/Edge | Hono + Drizzle + Neon |
| Python team | FastAPI + SQLAlchemy + PostgreSQL |
| Enterprise | Spring Boot + JPA + PostgreSQL |
| High performance | Go + Gin + GORM + PostgreSQL |
| BaaS | Supabase (DB + Auth integrated) |

## Language Selection

### TypeScript

**Advantages:**
- Type safety
- Code sharing with frontend
- Rich ecosystem

**Disadvantages:**
- Runtime overhead (Node.js)
- Build step required

**Suitable Cases:**
- Full-stack JavaScript/TypeScript team
- Integration with frontend like Next.js
- Fast development cycle

### Python

**Advantages:**
- Concise syntax
- Rich AI/ML libraries
- Fast prototyping

**Disadvantages:**
- Complex concurrency handling (GIL)
- Optional type hints

**Suitable Cases:**
- AI/ML services
- Data processing focused
- Python-experienced team

### Java

**Advantages:**
- Mature ecosystem
- Enterprise-proven
- Strong type system

**Disadvantages:**
- Lots of boilerplate
- High resource usage

**Suitable Cases:**
- Large-scale enterprise
- Legacy system integration
- Long-term maintenance projects

### Go

**Advantages:**
- Excellent performance
- Simple concurrency (goroutines)
- Small binary

**Disadvantages:**
- Limited generics
- Relatively small ecosystem

**Suitable Cases:**
- High performance requirements
- Microservices
- Systems programming

## Framework Comparison

### TypeScript Frameworks

| Framework | Characteristics | Suitable Cases |
|-----------|----------------|----------------|
| **NestJS** | Structured, DI, decorators | Large-scale, team projects |
| **Express** | Minimal, flexible | Small-scale, rapid development |
| **Fastify** | High performance, schema-based | API-focused, performance critical |
| **Hono** | Lightweight, Edge support | Serverless, Edge |

### Python Frameworks

| Framework | Characteristics | Suitable Cases |
|-----------|----------------|----------------|
| **FastAPI** | Async, auto documentation | Modern API, AI services |
| **Django** | Full-stack, batteries included | Rapid development, admin needed |
| **Flask** | Micro, flexible | Small-scale, custom structure |

### Java Frameworks

| Framework | Characteristics | Suitable Cases |
|-----------|----------------|----------------|
| **Spring Boot** | Enterprise, rich ecosystem | Large-scale, complex business |
| **Quarkus** | Cloud-native, fast startup | Containers, serverless |
| **Micronaut** | Compile-time DI | Microservices |

### Go Frameworks

| Framework | Characteristics | Suitable Cases |
|-----------|----------------|----------------|
| **Gin** | Fast, minimal | REST API |
| **Echo** | Rich middleware | Web applications |
| **Fiber** | Express-style | Node.js developers |

## Database Selection

### Relational

| Database | Characteristics | Suitable Cases |
|----------|----------------|----------------|
| **PostgreSQL** | Feature-rich, scalable | Recommended for most cases |
| **MySQL** | Performance, replication | Read-heavy workloads |
| **SQLite** | File-based, simple | Development, small-scale |

### NoSQL

| Database | Characteristics | Suitable Cases |
|----------|----------------|----------------|
| **MongoDB** | Document-based, flexible | Variable schema |
| **Redis** | In-memory, fast | Caching, sessions, queues |
| **DynamoDB** | Serverless, scalable | AWS environment |

### Managed

| Service | Characteristics | Suitable Cases |
|---------|----------------|----------------|
| **Supabase** | PostgreSQL + Auth | Rapid development, BaaS |
| **Neon** | Serverless PostgreSQL | Edge, serverless |
| **PlanetScale** | Serverless MySQL | Scaling needed |

## ORM Selection

### TypeScript

| ORM | Characteristics | Suitable Cases |
|-----|----------------|----------------|
| **Prisma** | Type-safe, migrations | Most projects |
| **Drizzle** | Lightweight, close to SQL | Performance-focused, Edge |
| **TypeORM** | Decorators, Active Record | NestJS integration |

### Python

| ORM | Characteristics | Suitable Cases |
|-----|----------------|----------------|
| **SQLAlchemy** | Mature, flexible | Most projects |
| **Django ORM** | Django integration | Django projects |
| **Tortoise** | Async | FastAPI integration |

### Java

| ORM | Characteristics | Suitable Cases |
|-----|----------------|----------------|
| **JPA/Hibernate** | Standard, feature-rich | Spring Boot |
| **jOOQ** | Type-safe SQL | Complex queries |
| **MyBatis** | SQL-focused | Legacy integration |

### Go

| ORM | Characteristics | Suitable Cases |
|-----|----------------|----------------|
| **GORM** | Feature-rich | Most projects |
| **sqlx** | Lightweight, SQL-focused | Performance-focused |
| **Ent** | Graph-based, type-safe | Complex relationships |

## Authentication Options

| Option | Characteristics | Suitable Cases |
|--------|----------------|----------------|
| **JWT** | Stateless, scalable | API, microservices |
| **Session** | Server-based, controllable | Traditional web apps |
| **OAuth** | Social login | Third-party auth needed |
| **Clerk** | Managed, fast integration | Rapid development |
| **Supabase Auth** | Supabase integration | When using Supabase |

## Decision Checklist

Items to check when selecting a stack:

- [ ] What is the team's technical experience?
- [ ] What is the project scale and complexity?
- [ ] What are the performance requirements?
- [ ] What is the maintenance period?
- [ ] What is the cloud environment?
- [ ] What is the frontend integration?
- [ ] What are the AI/ML requirements?
- [ ] What are the budget constraints?

## Common Stacks

### Startup MVP
```
TypeScript + Express/Fastify + Prisma + PostgreSQL + JWT
```

### Enterprise
```
Java + Spring Boot + JPA + PostgreSQL + OAuth2
```

### AI Service
```
Python + FastAPI + SQLAlchemy + PostgreSQL + Redis
```

### High Performance
```
Go + Gin + GORM + PostgreSQL + Redis
```

### Serverless
```
TypeScript + Hono + Drizzle + Neon + Clerk
```

### BaaS (Fastest)
```
Supabase (PostgreSQL + Auth + Storage + Realtime)
```
