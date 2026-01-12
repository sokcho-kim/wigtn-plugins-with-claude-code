---
name: vector-db
description: Vector database integration patterns for embeddings storage and similarity search. Use when implementing semantic search and RAG.
---

# Vector Database

벡터 데이터베이스 연동 패턴입니다.

## Embedding Generation

### OpenAI Embeddings

```typescript
// services/embedding.service.ts
import { Injectable } from '@nestjs/common';
import { OpenAIProvider } from '../providers/openai.provider';

@Injectable()
export class EmbeddingService {
  constructor(private openai: OpenAIProvider) {}

  async generateEmbedding(text: string): Promise<number[]> {
    const response = await this.openai.getClient().embeddings.create({
      model: 'text-embedding-3-small',
      input: text,
    });

    return response.data[0].embedding;
  }

  async generateBatchEmbeddings(texts: string[]): Promise<number[][]> {
    // OpenAI supports up to 2048 inputs per request
    const batchSize = 2048;
    const results: number[][] = [];

    for (let i = 0; i < texts.length; i += batchSize) {
      const batch = texts.slice(i, i + batchSize);
      const response = await this.openai.getClient().embeddings.create({
        model: 'text-embedding-3-small',
        input: batch,
      });

      results.push(...response.data.map((d) => d.embedding));
    }

    return results;
  }
}
```

## Pinecone Integration

### Provider Setup

```typescript
// providers/pinecone.provider.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Pinecone } from '@pinecone-database/pinecone';

@Injectable()
export class PineconeProvider implements OnModuleInit {
  private client: Pinecone;

  constructor(private config: ConfigService) {}

  async onModuleInit() {
    this.client = new Pinecone({
      apiKey: this.config.getOrThrow('PINECONE_API_KEY'),
    });
  }

  getClient(): Pinecone {
    return this.client;
  }

  getIndex(indexName: string) {
    return this.client.index(indexName);
  }
}
```

### Vector Store Service

```typescript
// services/pinecone-vector-store.service.ts
import { Injectable } from '@nestjs/common';
import { PineconeProvider } from '../providers/pinecone.provider';
import { EmbeddingService } from './embedding.service';
import { ConfigService } from '@nestjs/config';

interface VectorMetadata {
  text: string;
  source?: string;
  documentId?: string;
  chunkIndex?: number;
  [key: string]: any;
}

interface SearchResult {
  id: string;
  score: number;
  text: string;
  metadata: VectorMetadata;
}

@Injectable()
export class PineconeVectorStoreService {
  private indexName: string;

  constructor(
    private pinecone: PineconeProvider,
    private embeddingService: EmbeddingService,
    private config: ConfigService,
  ) {
    this.indexName = this.config.getOrThrow('PINECONE_INDEX');
  }

  async upsert(
    id: string,
    text: string,
    metadata: Omit<VectorMetadata, 'text'> = {},
  ): Promise<void> {
    const embedding = await this.embeddingService.generateEmbedding(text);
    const index = this.pinecone.getIndex(this.indexName);

    await index.upsert([
      {
        id,
        values: embedding,
        metadata: { ...metadata, text },
      },
    ]);
  }

  async upsertBatch(
    items: Array<{
      id: string;
      text: string;
      metadata?: Omit<VectorMetadata, 'text'>;
    }>,
  ): Promise<void> {
    const texts = items.map((item) => item.text);
    const embeddings = await this.embeddingService.generateBatchEmbeddings(texts);
    const index = this.pinecone.getIndex(this.indexName);

    const vectors = items.map((item, i) => ({
      id: item.id,
      values: embeddings[i],
      metadata: { ...item.metadata, text: item.text },
    }));

    // Pinecone batch limit is 100
    const batchSize = 100;
    for (let i = 0; i < vectors.length; i += batchSize) {
      const batch = vectors.slice(i, i + batchSize);
      await index.upsert(batch);
    }
  }

  async search(
    query: string,
    options: {
      topK?: number;
      filter?: Record<string, any>;
      namespace?: string;
    } = {},
  ): Promise<SearchResult[]> {
    const { topK = 5, filter, namespace } = options;

    const queryEmbedding = await this.embeddingService.generateEmbedding(query);
    const index = this.pinecone.getIndex(this.indexName);

    const results = await index.query({
      vector: queryEmbedding,
      topK,
      filter,
      namespace,
      includeMetadata: true,
    });

    return results.matches?.map((match) => ({
      id: match.id,
      score: match.score || 0,
      text: (match.metadata as VectorMetadata)?.text || '',
      metadata: match.metadata as VectorMetadata,
    })) || [];
  }

  async delete(ids: string[]): Promise<void> {
    const index = this.pinecone.getIndex(this.indexName);
    await index.deleteMany(ids);
  }

  async deleteByFilter(filter: Record<string, any>): Promise<void> {
    const index = this.pinecone.getIndex(this.indexName);
    await index.deleteMany({ filter });
  }
}
```

## Qdrant Integration

```typescript
// providers/qdrant.provider.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { QdrantClient } from '@qdrant/js-client-rest';

@Injectable()
export class QdrantProvider implements OnModuleInit {
  private client: QdrantClient;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    this.client = new QdrantClient({
      url: this.config.getOrThrow('QDRANT_URL'),
      apiKey: this.config.get('QDRANT_API_KEY'),
    });
  }

  getClient(): QdrantClient {
    return this.client;
  }
}

// services/qdrant-vector-store.service.ts
@Injectable()
export class QdrantVectorStoreService {
  constructor(
    private qdrant: QdrantProvider,
    private embeddingService: EmbeddingService,
  ) {}

  async ensureCollection(collectionName: string, vectorSize: number = 1536) {
    const client = this.qdrant.getClient();

    const collections = await client.getCollections();
    const exists = collections.collections.some(
      (c) => c.name === collectionName,
    );

    if (!exists) {
      await client.createCollection(collectionName, {
        vectors: {
          size: vectorSize,
          distance: 'Cosine',
        },
      });
    }
  }

  async upsert(
    collectionName: string,
    items: Array<{
      id: string;
      text: string;
      metadata?: Record<string, any>;
    }>,
  ) {
    const client = this.qdrant.getClient();
    const texts = items.map((item) => item.text);
    const embeddings = await this.embeddingService.generateBatchEmbeddings(texts);

    await client.upsert(collectionName, {
      wait: true,
      points: items.map((item, i) => ({
        id: item.id,
        vector: embeddings[i],
        payload: { ...item.metadata, text: item.text },
      })),
    });
  }

  async search(
    collectionName: string,
    query: string,
    options: { limit?: number; filter?: any } = {},
  ) {
    const { limit = 5, filter } = options;
    const client = this.qdrant.getClient();

    const queryEmbedding = await this.embeddingService.generateEmbedding(query);

    const results = await client.search(collectionName, {
      vector: queryEmbedding,
      limit,
      filter,
      with_payload: true,
    });

    return results.map((result) => ({
      id: result.id,
      score: result.score,
      text: (result.payload as any)?.text || '',
      metadata: result.payload,
    }));
  }
}
```

## Chroma Integration (Local/Self-hosted)

```typescript
// providers/chroma.provider.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ChromaClient, Collection } from 'chromadb';

@Injectable()
export class ChromaProvider implements OnModuleInit {
  private client: ChromaClient;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    this.client = new ChromaClient({
      path: this.config.get('CHROMA_URL', 'http://localhost:8000'),
    });
  }

  getClient(): ChromaClient {
    return this.client;
  }
}

// services/chroma-vector-store.service.ts
@Injectable()
export class ChromaVectorStoreService {
  constructor(
    private chroma: ChromaProvider,
    private embeddingService: EmbeddingService,
  ) {}

  async getOrCreateCollection(name: string): Promise<Collection> {
    return this.chroma.getClient().getOrCreateCollection({ name });
  }

  async add(
    collectionName: string,
    items: Array<{
      id: string;
      text: string;
      metadata?: Record<string, any>;
    }>,
  ) {
    const collection = await this.getOrCreateCollection(collectionName);
    const embeddings = await this.embeddingService.generateBatchEmbeddings(
      items.map((i) => i.text),
    );

    await collection.add({
      ids: items.map((i) => i.id),
      embeddings,
      documents: items.map((i) => i.text),
      metadatas: items.map((i) => i.metadata || {}),
    });
  }

  async query(
    collectionName: string,
    queryText: string,
    options: { nResults?: number; where?: Record<string, any> } = {},
  ) {
    const { nResults = 5, where } = options;
    const collection = await this.getOrCreateCollection(collectionName);

    const queryEmbedding = await this.embeddingService.generateEmbedding(queryText);

    const results = await collection.query({
      queryEmbeddings: [queryEmbedding],
      nResults,
      where,
    });

    return results.ids[0].map((id, i) => ({
      id,
      text: results.documents?.[0]?.[i] || '',
      metadata: results.metadatas?.[0]?.[i] || {},
      distance: results.distances?.[0]?.[i] || 0,
    }));
  }
}
```

## Hybrid Search (Vector + Keyword)

```typescript
// services/hybrid-search.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { PineconeVectorStoreService } from './pinecone-vector-store.service';

interface HybridSearchResult {
  id: string;
  text: string;
  vectorScore: number;
  keywordScore: number;
  combinedScore: number;
  metadata: Record<string, any>;
}

@Injectable()
export class HybridSearchService {
  constructor(
    private prisma: PrismaService,
    private vectorStore: PineconeVectorStoreService,
  ) {}

  async search(
    query: string,
    options: {
      topK?: number;
      vectorWeight?: number;
      keywordWeight?: number;
    } = {},
  ): Promise<HybridSearchResult[]> {
    const {
      topK = 10,
      vectorWeight = 0.7,
      keywordWeight = 0.3,
    } = options;

    // Vector search
    const vectorResults = await this.vectorStore.search(query, { topK: topK * 2 });

    // Keyword search using PostgreSQL full-text search
    const keywordResults = await this.prisma.$queryRaw<
      Array<{ id: string; rank: number }>
    >`
      SELECT id, ts_rank(search_vector, plainto_tsquery('english', ${query})) as rank
      FROM documents
      WHERE search_vector @@ plainto_tsquery('english', ${query})
      ORDER BY rank DESC
      LIMIT ${topK * 2}
    `;

    // Combine and re-rank
    const scoreMap = new Map<string, { vector: number; keyword: number }>();

    // Normalize vector scores (already 0-1 for cosine)
    for (const result of vectorResults) {
      scoreMap.set(result.id, {
        vector: result.score,
        keyword: 0,
      });
    }

    // Normalize keyword scores
    const maxKeywordRank = Math.max(...keywordResults.map((r) => r.rank), 1);
    for (const result of keywordResults) {
      const existing = scoreMap.get(result.id);
      const normalizedScore = result.rank / maxKeywordRank;

      if (existing) {
        existing.keyword = normalizedScore;
      } else {
        scoreMap.set(result.id, { vector: 0, keyword: normalizedScore });
      }
    }

    // Calculate combined scores
    const combined = Array.from(scoreMap.entries())
      .map(([id, scores]) => ({
        id,
        vectorScore: scores.vector,
        keywordScore: scores.keyword,
        combinedScore:
          scores.vector * vectorWeight + scores.keyword * keywordWeight,
      }))
      .sort((a, b) => b.combinedScore - a.combinedScore)
      .slice(0, topK);

    // Fetch full documents
    const documents = await this.prisma.document.findMany({
      where: { id: { in: combined.map((c) => c.id) } },
    });

    const docMap = new Map(documents.map((d) => [d.id, d]));

    return combined.map((item) => {
      const doc = docMap.get(item.id);
      return {
        ...item,
        text: doc?.content || '',
        metadata: doc?.metadata || {},
      };
    });
  }
}
```

## Index Management

```typescript
// services/index-manager.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { PineconeProvider } from '../providers/pinecone.provider';

@Injectable()
export class IndexManagerService {
  private readonly logger = new Logger(IndexManagerService.name);

  constructor(private pinecone: PineconeProvider) {}

  async createIndex(
    name: string,
    options: {
      dimension?: number;
      metric?: 'cosine' | 'euclidean' | 'dotproduct';
      cloud?: string;
      region?: string;
    } = {},
  ) {
    const {
      dimension = 1536,
      metric = 'cosine',
      cloud = 'aws',
      region = 'us-east-1',
    } = options;

    await this.pinecone.getClient().createIndex({
      name,
      dimension,
      metric,
      spec: {
        serverless: {
          cloud,
          region,
        },
      },
    });

    this.logger.log(`Created index: ${name}`);
  }

  async deleteIndex(name: string) {
    await this.pinecone.getClient().deleteIndex(name);
    this.logger.log(`Deleted index: ${name}`);
  }

  async describeIndex(name: string) {
    return this.pinecone.getClient().describeIndex(name);
  }

  async listIndexes() {
    return this.pinecone.getClient().listIndexes();
  }
}
```

## Best Practices

```yaml
vector_db_guidelines:
  - Choose dimension based on embedding model
  - Use namespaces for multi-tenant isolation
  - Implement metadata filtering
  - Batch upserts for efficiency
  - Monitor index size and performance

embedding_guidelines:
  - Use consistent model for query and docs
  - Normalize text before embedding
  - Cache embeddings when possible
  - Consider smaller models for cost

search_optimization:
  - Use hybrid search for better recall
  - Implement re-ranking for precision
  - Set appropriate topK values
  - Use filters to reduce search space

data_management:
  - Implement document chunking
  - Store source references in metadata
  - Plan for index updates/rebuilds
  - Monitor storage costs
```
