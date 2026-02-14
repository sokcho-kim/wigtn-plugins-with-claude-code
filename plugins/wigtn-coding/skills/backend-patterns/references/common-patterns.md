# Common Service Patterns

Common feature patterns used in production services.

## Authentication & Authorization

### User Authentication

**Features:**
- Sign up (email, social)
- Login (email/password, social)
- Logout
- Password reset
- Email verification
- 2FA (Two-Factor Authentication)

**Backend Requirements:**
```
- JWT / Session-based authentication
- Password hashing (bcrypt, argon2)
- Token refresh (Refresh Token)
- Rate limiting (Brute force prevention)
- Account lockout policy
```

### Social Login

**Supported:**
- Google, GitHub, Kakao, Naver

**Backend Requirements:**
```
- OAuth 2.0 flow
- Social account linking
- Merge with existing account
```

### Role-Based Access Control (RBAC)

**Features:**
- Role management (Admin, User, Moderator)
- Permission management (CRUD permissions)
- Resource-based access control

**Backend Requirements:**
```
- Role table
- Permission table
- Middleware/guard-based validation
```

## User Management

### Profile Management

**Features:**
- Profile view/edit
- Avatar upload
- Profile visibility settings

**Backend Requirements:**
```
- User information CRUD
- Image upload processing
- Profile visibility level settings
```

### Account Settings

**Features:**
- Email change
- Password change
- Notification settings
- Account deletion

**Backend Requirements:**
```
- Settings table
- Change history logging
- Soft delete
```

## Content Management

### CRUD Operations

**Features:**
- Create, Read, Update, Delete
- Draft saving
- Version management

**Backend Requirements:**
```
- Standard REST API
- Soft delete
- Modification history (Audit log)
- Permission validation
```

### Content Moderation

**Features:**
- Report feature
- Admin approval
- Auto filtering

**Backend Requirements:**
```
- Report table
- Approval status management
- Keyword filtering
```

## Social Features

### Follow/Unfollow

**Features:**
- Follow user
- Follower/following list
- Mutual follow display

**Backend Requirements:**
```
- Follow relationship table
- Follower count caching
- Notification trigger
```

### Like/Bookmark

**Features:**
- Like
- Bookmark
- Like count display

**Backend Requirements:**
```
- Like/bookmark table
- Count caching (Redis)
- Duplicate prevention
```

### Comments/Replies

**Features:**
- Comment create/edit/delete
- Reply
- Comment like

**Backend Requirements:**
```
- Hierarchical comment structure
- Comment count caching
- Real-time comment stream
```

## E-commerce Patterns

### Product Management

**Features:**
- Product create/edit/delete
- Product search
- Category management
- Inventory management

**Backend Requirements:**
```
- Product table
- Inventory management
- Search index
- Category tree structure
```

### Shopping Cart

**Features:**
- Add/remove from cart
- Quantity change
- Cart persistence

**Backend Requirements:**
```
- Shopping cart table
- Session-based or DB-based
- Inventory check
```

### Order Management

**Features:**
- Order creation
- Order status tracking
- Order history view
- Refund/cancellation

**Backend Requirements:**
```
- Order table
- Order state machine
- Payment integration
- Refund processing
```

### Payment Integration

**Features:**
- Payment processing
- Payment history
- Refund processing

**Backend Requirements:**
```
- Payment gateway integration
- Payment status management
- Webhook handling
- Payment verification
```

## Notification System

### In-app Notifications

**Features:**
- Notification list
- Read/unread
- Notification deletion
- Notification settings

**Backend Requirements:**
```
- Notification table
- Real-time push (WebSocket/SSE)
- Notification grouping
- Read status management
```

### Email Notifications

**Features:**
- Email sending
- Email templates
- Sending history

**Backend Requirements:**
```
- Email queue
- Template system
- Sending status tracking
```

## Search & Discovery

### Full-text Search

**Features:**
- Keyword search
- Filtering
- Sorting

**Backend Requirements:**
```
- Search index (Elasticsearch, PostgreSQL)
- Search result caching
- Autocomplete
```

### Recommendations

**Features:**
- Recommended content
- Related items
- Popular items

**Backend Requirements:**
```
- Recommendation algorithm
- User behavior analysis
- Caching strategy
```

## Analytics & Reporting

### Statistics

**Features:**
- View count, like count
- User statistics
- Revenue statistics

**Backend Requirements:**
```
- Statistics aggregation
- Real-time counter (Redis)
- Batch aggregation (daily/weekly/monthly)
```

### Activity Logging

**Features:**
- User activity logs
- Error logs
- Performance logs

**Backend Requirements:**
```
- Log table
- Structured logging
- Log analysis tool integration
```

## File Management

### File Upload

**Features:**
- File upload
- Image upload
- Large file upload

**Backend Requirements:**
```
- Multipart upload
- Chunk upload
- File validation
- Thumbnail generation
```

### File Storage

**Features:**
- File storage
- CDN integration
- File download

**Backend Requirements:**
```
- S3 / Cloudflare R2
- CDN configuration
- Access permission management
```

## Real-time Features

### Live Updates

**Features:**
- Real-time notifications
- Real-time chat
- Real-time collaboration

**Backend Requirements:**
```
- WebSocket / SSE
- Message queue
- Connection management
```

### Presence

**Features:**
- Online status
- Typing indicator
- Last access time

**Backend Requirements:**
```
- Status management (Redis)
- Heartbeat handling
- Timeout management
```

## Security Patterns

### Rate Limiting

**Features:**
- API call limits
- IP-based limits
- User-based limits

**Backend Requirements:**
```
- Redis-based counter
- Sliding window
- Token bucket
```

### Data Validation

**Features:**
- Input validation
- SQL Injection prevention
- XSS prevention

**Backend Requirements:**
```
- Schema validation (Zod, Joi)
- ORM usage (SQL Injection prevention)
- Input sanitization
```

### Audit Logging

**Features:**
- Change history
- Access logs
- Security events

**Backend Requirements:**
```
- Audit table
- Store before/after values
- Event logging
```

## Performance Patterns

### Caching Strategy

**Features:**
- Data caching
- Query result caching
- Session caching

**Backend Requirements:**
```
- Redis caching
- Cache invalidation strategy
- TTL configuration
```

### Database Optimization

**Features:**
- Index optimization
- Query optimization
- Connection pooling

**Backend Requirements:**
```
- Proper indexing
- N+1 query prevention
- Batch processing
```

### Background Jobs

**Features:**
- Async jobs
- Scheduling
- Job queue

**Backend Requirements:**
```
- Job queue (Bull, Celery)
- Scheduler (Cron)
- Retry logic
```
