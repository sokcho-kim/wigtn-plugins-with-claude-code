# Frontend Interactions - Backend Requirements

Backend feature patterns needed for frontend interactions.

## Real-time Updates

### WebSocket / SSE

**Use Cases:**
- Real-time chat
- Live notifications
- Collaborative editing (simultaneous editing)
- Real-time order status updates
- Real-time dashboard

**Backend Requirements:**
```
- WebSocket server (Socket.io, ws)
- Connection management (connection pool, reconnection handling)
- Message broadcasting
- Room management
- Heartbeat/Keep-alive
```

**Infrastructure:**
- Redis Pub/Sub (message delivery between multiple servers)
- Load Balancer (Sticky Session or Redis-based)

### Server-Sent Events (SSE)

**Use Cases:**
- Real-time notification stream
- Progress updates
- Real-time feed

**Backend Requirements:**
```
- SSE endpoint
- Event stream management
- Connection timeout handling
```

## Optimistic UI Support

**Use Cases:**
- Immediate like/bookmark reflection
- Immediate comment display
- Immediate UI update on form submission

**Backend Requirements:**
```
- API supporting optimistic updates
- Rollback-capable transactions
- Client ID-based duplicate prevention
- Final consistency guarantee
```

**API Pattern:**
```typescript
POST /api/posts/:id/like
{
  "clientId": "uuid",  // Duplicate prevention
  "optimistic": true   // Optimistic update flag
}

// Rollback on failure
DELETE /api/posts/:id/like/:clientId
```

## Infinite Scroll / Pagination

**Use Cases:**
- Infinite scroll feed
- Paginated list
- Cursor-based pagination

**Backend Requirements:**
```
- Cursor-based pagination
- Offset-based pagination
- Sort options (latest, popular, recommended)
- Filtering (category, tags, search terms)
```

**API Pattern:**
```typescript
GET /api/posts?cursor=abc123&limit=20&sort=latest
{
  "data": [...],
  "nextCursor": "def456",
  "hasMore": true
}
```

## Search & Filtering

**Use Cases:**
- Real-time search
- Multiple filter combinations
- Autocomplete

**Backend Requirements:**
```
- Full-text search (PostgreSQL, Elasticsearch)
- Index optimization
- Search result caching
- Autocomplete API (Trie, Prefix matching)
```

**Infrastructure:**
- Elasticsearch / OpenSearch (large-scale)
- PostgreSQL Full-text Search (small-medium scale)
- Redis (autocomplete caching)

## Drag & Drop Ordering

**Use Cases:**
- List order change
- Board column order
- Menu order change

**Backend Requirements:**
```
- Order/Position field
- Batch update API
- Concurrent edit conflict prevention
```

**API Pattern:**
```typescript
PATCH /api/items/reorder
{
  "items": [
    { "id": 1, "order": 0 },
    { "id": 2, "order": 1 },
    { "id": 3, "order": 2 }
  ]
}
```

## File Upload/Download

**Use Cases:**
- Image upload
- File download
- Large file upload

**Backend Requirements:**
```
- Multipart upload
- Chunk upload (large files)
- File validation (type, size)
- Thumbnail generation
- CDN integration
```

**Infrastructure:**
- S3 / Cloudflare R2 (storage)
- CDN (CloudFront, Cloudflare)
- Image processing (Sharp, ImageMagick)

## Real-time Notifications

**Use Cases:**
- Push notifications
- In-app notifications
- Email notifications

**Backend Requirements:**
```
- Notification queue system
- Per-user notification settings
- Read/unread status
- Notification grouping
```

**Infrastructure:**
- Redis Queue (notification queue)
- FCM / APNS (push)
- Resend / SendGrid (email)

## Form Interactions

### Multi-step Forms

**Backend Requirements:**
```
- Step-by-step temporary data storage
- Session/cache-based temporary data
- Validation on final submission
```

### Auto-save

**Backend Requirements:**
```
- Periodic auto-save API
- Delta updates (only changed parts)
- Conflict resolution (last save wins)
```

## Interactive Features

### Like/Bookmark

**Backend Requirements:**
```
- Duplicate prevention (Unique constraint)
- Count caching (Redis)
- Batch query (multiple items' status at once)
```

### Follow/Subscribe

**Backend Requirements:**
```
- Follow relationship table
- Follower/following count caching
- Notification trigger
```

### Comments/Replies

**Backend Requirements:**
```
- Hierarchical structure (Nested comments)
- Real-time comment stream
- Comment count caching
- Comment likes
```

## Performance Considerations

### Lazy Loading

**Backend Requirements:**
```
- Query only needed data
- GraphQL or field selection
- Lazy loading of related data
```

### Prefetching

**Backend Requirements:**
```
- Preload next page data
- Include related data option
- Caching strategy
```

### Debouncing/Throttling

**Backend Requirements:**
```
- Rate limiting
- Search API debouncing
- Autocomplete query optimization
```
