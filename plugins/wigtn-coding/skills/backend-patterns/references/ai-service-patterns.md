# AI Service Integration Patterns

Backend patterns for communication with AI model servers.

## LLM API Integration

### OpenAI API

**Communication Pattern:**
```typescript
// Chat Completion
POST https://api.openai.com/v1/chat/completions
Headers: {
  Authorization: "Bearer ${API_KEY}",
  Content-Type: "application/json"
}
Body: {
  model: "gpt-4",
  messages: [...],
  stream: true,
  temperature: 0.7
}

// Streaming Response
Response: Stream of Server-Sent Events
```

**Backend Design:**
```
- API key management (environment variables, Secrets)
- Request/response logging
- Token usage tracking
- Error handling and retry
- Rate limiting
```

### Anthropic API

**Communication Pattern:**
```typescript
POST https://api.anthropic.com/v1/messages
Headers: {
  "x-api-key": "${API_KEY}",
  "anthropic-version": "2023-06-01"
}
Body: {
  model: "claude-3-opus",
  max_tokens: 1024,
  messages: [...]
}
```

### Google Gemini API

**Communication Pattern:**
```typescript
POST https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent
Headers: {
  "x-goog-api-key": "${API_KEY}"
}
Body: {
  contents: [...]
}
```

## Streaming Response Handling

### Server-Sent Events (SSE)

**Backend Design:**
```
- Stream parsing
- Chunk-based processing
- Forward to client
- Connection management
```

**Implementation Pattern:**
```typescript
// Receive AI API stream
const stream = await openai.chat.completions.create({
  stream: true,
  ...
});

// Forward to client
for await (const chunk of stream) {
  const delta = chunk.choices[0]?.delta?.content;
  if (delta) {
    res.write(`data: ${JSON.stringify({ content: delta })}\n\n`);
  }
}
```

### WebSocket Streaming

**Backend Design:**
```
- WebSocket connection management
- Real-time stream delivery
- Connection drop handling
- Reconnection logic
```

## Error Handling & Retry

### API Error Patterns

**Error Types:**
```
- Rate Limit (429)
- Authentication (401)
- Invalid Request (400)
- Server Error (500)
- Timeout
```

**Backend Design:**
```
- Error classification
- Retry strategy (Exponential Backoff)
- Fallback handling
- Error logging
```

**Retry Pattern:**
```typescript
async function callWithRetry(apiCall, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await apiCall();
    } catch (error) {
      if (error.status === 429) {
        await delay(Math.pow(2, i) * 1000); // Exponential backoff
        continue;
      }
      throw error;
    }
  }
}
```

## Cost Management

### Token Usage Tracking

**Backend Design:**
```
- Input/output token calculation
- Usage storage
- Cost calculation
- Usage limits
```

**Data Structure:**
```typescript
TokenUsage {
  userId: UUID
  requestId: UUID
  model: string
  inputTokens: number
  outputTokens: number
  cost: number
  timestamp: DateTime
}
```

### Usage Limits

**Backend Design:**
```
- Per-user quota
- Daily/monthly limits
- Exceeded notification
- Limit release process
```

## Rate Limiting

### API Rate Limits

**Constraints:**
```
- OpenAI: RPM (Requests Per Minute), TPM (Tokens Per Minute)
- Anthropic: RPD (Requests Per Day)
- Per-user limits
```

**Backend Design:**
```
- Redis-based counter
- Sliding window
- Priority queue
- Queue management
```

**Implementation Pattern:**
```typescript
// Rate limit check
const key = `rate_limit:${userId}:${model}`;
const current = await redis.incr(key);
if (current === 1) {
  await redis.expire(key, 60); // 1 minute
}
if (current > limit) {
  throw new RateLimitError();
}
```

## Prompt Management

### Prompt Templates

**Backend Design:**
```
- Template storage
- Variable substitution
- Version management
- A/B testing
```

**Data Structure:**
```typescript
PromptTemplate {
  id: UUID
  name: string
  template: string
  variables: string[]
  version: number
  isActive: boolean
}
```

**Usage Pattern:**
```typescript
const prompt = renderTemplate(template, {
  user: user.name,
  context: context
});
```

### Prompt Optimization

**Backend Design:**
```
- Prompt effectiveness tracking
- Performance comparison
- Optimization suggestions
- Version rollback
```

## Conversation Management

### Session Handling

**Backend Design:**
```
- Conversation session storage
- Message history management
- Context maintenance
- Session expiration handling
```

**Data Structure:**
```typescript
Conversation {
  id: UUID
  userId: UUID
  title?: string
  messages: Message[]
  createdAt: DateTime
  updatedAt: DateTime
}

Message {
  id: UUID
  role: 'user' | 'assistant' | 'system'
  content: string
  tokens?: number
  createdAt: DateTime
}
```

### Context Management

**Backend Design:**
```
- Context window management
- Token limit check
- Remove old messages
- Summary generation (long conversations)
```

## Vector Database Integration

### Pinecone

**Communication Pattern:**
```typescript
// Upsert vectors
POST https://api.pinecone.io/vectors/upsert
Headers: {
  "Api-Key": "${API_KEY}"
}
Body: {
  vectors: [
    {
      id: "vec1",
      values: [0.1, 0.2, ...],
      metadata: {...}
    }
  ],
  namespace: "default"
}

// Query
POST https://api.pinecone.io/query
Body: {
  vector: [0.1, 0.2, ...],
  topK: 10,
  includeMetadata: true
}
```

**Backend Design:**
```
- Index management
- Vector upload/query
- Metadata management
- Namespace separation
```

### Weaviate

**Communication Pattern:**
```typescript
// GraphQL Query
POST https://${CLUSTER}.weaviate.network/v1/graphql
Body: {
  query: `
    {
      Get {
        Document(nearVector: {...}) {
          content
          metadata
        }
      }
    }
  `
}
```

### pgvector (PostgreSQL)

**Backend Design:**
```
- Vector column type
- Similarity search query
- Index optimization
```

**SQL Pattern:**
```sql
SELECT id, content, 
       1 - (embedding <=> $1) as similarity
FROM documents
ORDER BY embedding <=> $1
LIMIT 10;
```

## Embedding API Integration

### OpenAI Embeddings

**Communication Pattern:**
```typescript
POST https://api.openai.com/v1/embeddings
Body: {
  model: "text-embedding-3-small",
  input: "text to embed"
}

Response: {
  data: [{
    embedding: [0.1, 0.2, ...],
    index: 0
  }]
}
```

**Backend Design:**
```
- Batch embedding generation
- Vector storage
- Caching (same text)
- Dimension management
```

### Cohere Embeddings

**Communication Pattern:**
```typescript
POST https://api.cohere.ai/v1/embed
Headers: {
  "Authorization": "Bearer ${API_KEY}"
}
Body: {
  texts: ["text1", "text2"],
  model: "embed-english-v3.0"
}
```

## Speech API Integration

### OpenAI Whisper (STT)

**Communication Pattern:**
```typescript
POST https://api.openai.com/v1/audio/transcriptions
Headers: {
  Authorization: "Bearer ${API_KEY}"
}
Body: FormData {
  file: File,
  model: "whisper-1",
  language: "ko"
}

Response: {
  text: "transcribed text"
}
```

**Backend Design:**
```
- Audio file upload
- File format conversion
- Streaming processing
- Timestamp extraction
```

### Google Cloud STT

**Communication Pattern:**
```typescript
POST https://speech.googleapis.com/v1/speech:recognize
Headers: {
  "Authorization": "Bearer ${ACCESS_TOKEN}"
}
Body: {
  config: {
    encoding: "WEBM_OPUS",
    sampleRateHertz: 48000,
    languageCode: "ko-KR"
  },
  audio: {
    content: base64Audio
  }
}
```

### ElevenLabs TTS

**Communication Pattern:**
```typescript
POST https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}
Headers: {
  "xi-api-key": "${API_KEY}"
}
Body: {
  text: "text to speak",
  model_id: "eleven_multilingual_v2"
}

Response: Audio stream
```

**Backend Design:**
```
- Speech generation
- Audio file storage
- Caching (same text)
- CDN deployment
```

## Image API Integration

### OpenAI DALL-E

**Communication Pattern:**
```typescript
POST https://api.openai.com/v1/images/generations
Body: {
  prompt: "a cat",
  n: 1,
  size: "1024x1024"
}

Response: {
  data: [{
    url: "https://..."
  }]
}
```

**Backend Design:**
```
- Image generation request
- Image download
- S3 storage
- CDN deployment
- Generation history management
```

### Stability AI

**Communication Pattern:**
```typescript
POST https://api.stability.ai/v2beta/stable-image/generate/core
Headers: {
  "Authorization": "Bearer ${API_KEY}"
}
Body: FormData {
  prompt: "...",
  aspect_ratio: "16:9"
}
```

## Caching Strategy

### Response Caching

**Backend Design:**
```
- Same input caching
- TTL configuration
- Cache invalidation
- Cost reduction
```

**Cache Key Pattern:**
```typescript
const cacheKey = `ai:${model}:${hash(prompt)}`;
const cached = await redis.get(cacheKey);
if (cached) return JSON.parse(cached);
```

### Embedding Caching

**Backend Design:**
```
- Text → embedding caching
- Separate from vector store
- Fast lookup
```

## Batch Processing

### Bulk API Calls

**Backend Design:**
```
- Job queue (Bull, Celery)
- Batch size management
- Progress tracking
- Error handling
```

**Implementation Pattern:**
```typescript
// Generate batch embeddings
const batch = texts.map(text => ({
  text,
  id: uuid()
}));

const embeddings = await Promise.all(
  batch.map(item => generateEmbedding(item.text))
);
```

## Monitoring & Analytics

### API Metrics

**Tracking Items:**
```
- Request count
- Response time
- Error rate
- Token usage
- Cost
```

**Backend Design:**
```
- Metric collection
- Dashboard integration
- Alert configuration
- Report generation
```

### Logging

**Backend Design:**
```
- Request/response logging
- Error logging
- Performance logging
- Structured logs (JSON)
```

## Security Patterns

### API Key Management

**Backend Design:**
```
- Environment variable storage
- Secrets Manager (AWS, GCP)
- Key rotation
- Access control
```

### Input Validation

**Backend Design:**
```
- Prompt validation
- Length limits
- Prohibited word filtering
- Prompt Injection prevention
```

### Output Filtering

**Backend Design:**
```
- Response validation
- Inappropriate content filtering
- PII masking
- Safe response guarantee
```

## API Design Patterns

### Unified AI Service Layer

**Backend Design:**
```
- Multiple AI provider abstraction
- Unified interface
- Easy provider switching
- Fallback handling
```

**Structure:**
```typescript
interface AIService {
  chat(messages: Message[]): Promise<Response>;
  embed(text: string): Promise<Vector>;
  transcribe(audio: File): Promise<string>;
}

class OpenAIAdapter implements AIService { ... }
class AnthropicAdapter implements AIService { ... }
```

### Request/Response Transformation

**Backend Design:**
```
- Request transformation (provider-specific format)
- Response normalization
- Error mapping
- Type conversion
```

## Error Patterns

### Timeout Handling

**Backend Design:**
```
- Timeout configuration
- Retry logic
- User notification
- Partial response handling
```

### Partial Failure

**Backend Design:**
```
- Batch job partial failure handling
- Return successful items
- Retry failed items
- Error reporting
```

## Cost Optimization

### Token Optimization

**Backend Design:**
```
- Prompt optimization
- Context compression
- Summary utilization
- Remove unnecessary tokens
```

### Caching Strategy

**Backend Design:**
```
- Cache frequently used responses
- Embedding caching
- Cost reduction
```

## Integration Examples

### Complete Flow: RAG System

```typescript
// 1. Generate document embedding
const embedding = await openai.embeddings.create({
  input: documentText
});

// 2. Store in vector DB
await pinecone.upsert({
  vectors: [{
    id: docId,
    values: embedding.data[0].embedding,
    metadata: { text: documentText }
  }]
});

// 3. Search
const queryEmbedding = await openai.embeddings.create({
  input: userQuestion
});

const results = await pinecone.query({
  vector: queryEmbedding.data[0].embedding,
  topK: 5
});

// 4. Pass context to LLM
const response = await openai.chat.completions.create({
  messages: [
    { role: "system", content: "You are a helpful assistant." },
    { role: "user", content: `Context: ${results}\n\nQuestion: ${userQuestion}` }
  ]
});
```

### Complete Flow: Chat with History

```typescript
// 1. Retrieve conversation history
const conversation = await db.conversation.findUnique({
  where: { id: conversationId },
  include: { messages: true }
});

// 2. Manage context window
const messages = trimToTokenLimit(conversation.messages, 4000);

// 3. Call LLM
const response = await openai.chat.completions.create({
  model: "gpt-4",
  messages: messages,
  stream: true
});

// 4. Process stream and save
for await (const chunk of response) {
  // Forward to client
  // Save message
}
```
