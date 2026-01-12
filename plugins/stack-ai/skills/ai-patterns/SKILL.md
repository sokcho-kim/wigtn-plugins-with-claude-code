---
name: ai-patterns
description: Common AI patterns including RAG, document chunking, context management. Use when designing AI pipelines.
---

# AI Patterns

AI 파이프라인 설계 패턴입니다.

## RAG (Retrieval Augmented Generation)

### Basic RAG Pipeline

```typescript
// services/rag.service.ts
import { Injectable } from '@nestjs/common';
import { VectorStoreService } from './vector-store.service';
import { ChatService } from './chat.service';
import { PROMPTS } from '../prompts/templates';

interface RAGOptions {
  topK?: number;
  maxContextTokens?: number;
  systemPrompt?: string;
}

@Injectable()
export class RAGService {
  constructor(
    private vectorStore: VectorStoreService,
    private chatService: ChatService,
  ) {}

  async query(
    question: string,
    options: RAGOptions = {},
  ) {
    const { topK = 5, maxContextTokens = 3000 } = options;

    // 1. Retrieve relevant documents
    const results = await this.vectorStore.search(question, { topK });

    // 2. Build context from retrieved documents
    const context = this.buildContext(results, maxContextTokens);

    // 3. Generate answer with context
    const prompt = PROMPTS.RAG_CONTEXT.format({
      context,
      question,
    });

    const response = await this.chatService.chat([
      { role: 'user', content: prompt },
    ], {
      systemPrompt: options.systemPrompt,
    });

    return {
      answer: response.content,
      sources: results.map((r) => ({
        id: r.id,
        text: r.text.substring(0, 200) + '...',
        score: r.score,
        metadata: r.metadata,
      })),
      usage: response.usage,
    };
  }

  private buildContext(
    results: Array<{ text: string; score: number }>,
    maxTokens: number,
  ): string {
    let context = '';
    let tokenCount = 0;

    for (const result of results) {
      const chunkTokens = Math.ceil(result.text.length / 4); // Rough estimate

      if (tokenCount + chunkTokens > maxTokens) break;

      context += `[Relevance: ${(result.score * 100).toFixed(1)}%]\n`;
      context += result.text + '\n\n---\n\n';
      tokenCount += chunkTokens;
    }

    return context.trim();
  }
}
```

### Conversational RAG

```typescript
// services/conversational-rag.service.ts
import { Injectable } from '@nestjs/common';
import { RAGService } from './rag.service';
import { ChatService } from './chat.service';
import { PrismaService } from '@/prisma/prisma.service';

@Injectable()
export class ConversationalRAGService {
  constructor(
    private ragService: RAGService,
    private chatService: ChatService,
    private prisma: PrismaService,
  ) {}

  async chat(
    conversationId: string,
    userMessage: string,
  ) {
    // 1. Get conversation history
    const history = await this.getConversationHistory(conversationId);

    // 2. Reformulate query using history context
    const reformulatedQuery = await this.reformulateQuery(
      userMessage,
      history,
    );

    // 3. Perform RAG with reformulated query
    const ragResult = await this.ragService.query(reformulatedQuery, {
      systemPrompt: `You are a helpful assistant. Use the conversation history to provide contextual answers.

Previous conversation:
${history.map((m) => `${m.role}: ${m.content}`).join('\n')}`,
    });

    // 4. Save messages
    await this.saveMessages(conversationId, userMessage, ragResult.answer);

    return ragResult;
  }

  private async reformulateQuery(
    question: string,
    history: Array<{ role: string; content: string }>,
  ): Promise<string> {
    if (history.length === 0) return question;

    const response = await this.chatService.chat([
      {
        role: 'system',
        content: `Given the conversation history and a follow-up question, reformulate the question to be standalone and clear. Return ONLY the reformulated question.`,
      },
      {
        role: 'user',
        content: `History:\n${history.slice(-4).map((m) => `${m.role}: ${m.content}`).join('\n')}\n\nFollow-up question: ${question}\n\nReformulated question:`,
      },
    ], {
      temperature: 0,
      maxTokens: 200,
    });

    return response.content || question;
  }

  private async getConversationHistory(conversationId: string) {
    const messages = await this.prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' },
      take: 10,
      select: { role: true, content: true },
    });
    return messages;
  }

  private async saveMessages(
    conversationId: string,
    userMessage: string,
    assistantMessage: string,
  ) {
    await this.prisma.message.createMany({
      data: [
        { conversationId, role: 'user', content: userMessage },
        { conversationId, role: 'assistant', content: assistantMessage },
      ],
    });
  }
}
```

## Document Chunking

### Chunking Strategies

```typescript
// utils/chunking.ts

interface ChunkOptions {
  chunkSize?: number;
  chunkOverlap?: number;
  separators?: string[];
}

// Simple character-based chunking
export function chunkByCharacters(
  text: string,
  options: ChunkOptions = {},
): string[] {
  const { chunkSize = 1000, chunkOverlap = 200 } = options;
  const chunks: string[] = [];

  let start = 0;
  while (start < text.length) {
    const end = Math.min(start + chunkSize, text.length);
    chunks.push(text.slice(start, end));
    start = end - chunkOverlap;
  }

  return chunks;
}

// Recursive character text splitter (like LangChain)
export function chunkRecursively(
  text: string,
  options: ChunkOptions = {},
): string[] {
  const {
    chunkSize = 1000,
    chunkOverlap = 200,
    separators = ['\n\n', '\n', '. ', ' ', ''],
  } = options;

  const chunks: string[] = [];

  function splitText(text: string, separatorIndex: number): string[] {
    if (text.length <= chunkSize) return [text];
    if (separatorIndex >= separators.length) {
      return chunkByCharacters(text, { chunkSize, chunkOverlap });
    }

    const separator = separators[separatorIndex];
    const splits = separator ? text.split(separator) : [text];

    const result: string[] = [];
    let currentChunk = '';

    for (const split of splits) {
      const potentialChunk = currentChunk
        ? currentChunk + separator + split
        : split;

      if (potentialChunk.length <= chunkSize) {
        currentChunk = potentialChunk;
      } else {
        if (currentChunk) {
          result.push(currentChunk);
        }

        if (split.length > chunkSize) {
          result.push(...splitText(split, separatorIndex + 1));
          currentChunk = '';
        } else {
          currentChunk = split;
        }
      }
    }

    if (currentChunk) {
      result.push(currentChunk);
    }

    return result;
  }

  return splitText(text, 0);
}

// Semantic chunking (by paragraphs/sections)
export function chunkByParagraphs(
  text: string,
  options: { maxChunkSize?: number } = {},
): string[] {
  const { maxChunkSize = 1500 } = options;
  const paragraphs = text.split(/\n\n+/);
  const chunks: string[] = [];
  let currentChunk = '';

  for (const paragraph of paragraphs) {
    if (currentChunk.length + paragraph.length > maxChunkSize) {
      if (currentChunk) chunks.push(currentChunk.trim());
      currentChunk = paragraph;
    } else {
      currentChunk += (currentChunk ? '\n\n' : '') + paragraph;
    }
  }

  if (currentChunk) chunks.push(currentChunk.trim());

  return chunks;
}

// Markdown-aware chunking
export function chunkMarkdown(
  markdown: string,
  options: { maxChunkSize?: number } = {},
): Array<{ content: string; heading?: string }> {
  const { maxChunkSize = 1500 } = options;
  const headingRegex = /^(#{1,6})\s+(.+)$/gm;

  const sections: Array<{ heading: string; content: string; level: number }> = [];
  let lastIndex = 0;
  let currentHeading = '';
  let currentLevel = 0;

  let match;
  while ((match = headingRegex.exec(markdown)) !== null) {
    if (lastIndex < match.index) {
      const content = markdown.slice(lastIndex, match.index).trim();
      if (content) {
        sections.push({
          heading: currentHeading,
          content,
          level: currentLevel,
        });
      }
    }

    currentHeading = match[2];
    currentLevel = match[1].length;
    lastIndex = match.index + match[0].length;
  }

  // Last section
  const remaining = markdown.slice(lastIndex).trim();
  if (remaining) {
    sections.push({
      heading: currentHeading,
      content: remaining,
      level: currentLevel,
    });
  }

  // Merge small sections, split large ones
  const chunks: Array<{ content: string; heading?: string }> = [];

  for (const section of sections) {
    const fullContent = section.heading
      ? `# ${section.heading}\n\n${section.content}`
      : section.content;

    if (fullContent.length <= maxChunkSize) {
      chunks.push({ content: fullContent, heading: section.heading });
    } else {
      // Split large sections
      const subChunks = chunkRecursively(section.content, {
        chunkSize: maxChunkSize - 100,
      });

      subChunks.forEach((chunk, i) => {
        chunks.push({
          content: section.heading
            ? `# ${section.heading} (Part ${i + 1})\n\n${chunk}`
            : chunk,
          heading: section.heading,
        });
      });
    }
  }

  return chunks;
}
```

### Document Processing Pipeline

```typescript
// services/document-processor.service.ts
import { Injectable } from '@nestjs/common';
import { VectorStoreService } from './vector-store.service';
import { chunkMarkdown, chunkRecursively } from '../utils/chunking';
import { v4 as uuid } from 'uuid';

interface ProcessedChunk {
  id: string;
  text: string;
  metadata: {
    documentId: string;
    chunkIndex: number;
    heading?: string;
    source: string;
  };
}

@Injectable()
export class DocumentProcessorService {
  constructor(private vectorStore: VectorStoreService) {}

  async processDocument(
    documentId: string,
    content: string,
    options: {
      source: string;
      contentType?: 'markdown' | 'text';
      chunkSize?: number;
    },
  ): Promise<ProcessedChunk[]> {
    const { source, contentType = 'text', chunkSize = 1000 } = options;

    // Chunk based on content type
    let chunks: Array<{ content: string; heading?: string }>;

    if (contentType === 'markdown') {
      chunks = chunkMarkdown(content, { maxChunkSize: chunkSize });
    } else {
      const textChunks = chunkRecursively(content, { chunkSize });
      chunks = textChunks.map((c) => ({ content: c }));
    }

    // Create processed chunks with metadata
    const processedChunks: ProcessedChunk[] = chunks.map((chunk, index) => ({
      id: `${documentId}-chunk-${index}`,
      text: chunk.content,
      metadata: {
        documentId,
        chunkIndex: index,
        heading: chunk.heading,
        source,
      },
    }));

    // Store in vector database
    await this.vectorStore.upsertBatch(
      processedChunks.map((c) => ({
        id: c.id,
        text: c.text,
        metadata: c.metadata,
      })),
    );

    return processedChunks;
  }

  async deleteDocument(documentId: string): Promise<void> {
    await this.vectorStore.deleteByFilter({ documentId });
  }
}
```

## Context Window Management

```typescript
// utils/context-manager.ts
import { TokenCounter } from './token-counter';

interface Message {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

interface ContextWindow {
  messages: Message[];
  totalTokens: number;
  truncated: boolean;
}

export class ContextManager {
  constructor(
    private maxTokens: number = 8000,
    private reservedTokens: number = 1000, // For response
  ) {}

  buildContext(
    systemPrompt: string,
    history: Message[],
    newMessage: string,
  ): ContextWindow {
    const availableTokens = this.maxTokens - this.reservedTokens;
    const result: Message[] = [];
    let totalTokens = 0;

    // Always include system prompt
    const systemTokens = TokenCounter.count(systemPrompt);
    result.push({ role: 'system', content: systemPrompt });
    totalTokens += systemTokens;

    // Always include new message
    const newMessageTokens = TokenCounter.count(newMessage);
    totalTokens += newMessageTokens;

    // Add history from most recent, while we have room
    const reversedHistory = [...history].reverse();
    const historyToInclude: Message[] = [];

    for (const message of reversedHistory) {
      const messageTokens = TokenCounter.count(message.content);

      if (totalTokens + messageTokens > availableTokens) {
        break;
      }

      historyToInclude.unshift(message);
      totalTokens += messageTokens;
    }

    result.push(...historyToInclude);
    result.push({ role: 'user', content: newMessage });

    return {
      messages: result,
      totalTokens,
      truncated: historyToInclude.length < history.length,
    };
  }

  summarizeHistory(history: Message[]): string {
    // Simple summary - in production, use LLM to summarize
    const summary = history
      .slice(0, -4) // Keep last 4 messages as-is
      .map((m) => `${m.role}: ${m.content.substring(0, 100)}...`)
      .join('\n');

    return `[Earlier conversation summary]\n${summary}\n[End summary]`;
  }
}
```

## Re-ranking

```typescript
// services/reranker.service.ts
import { Injectable } from '@nestjs/common';
import { ChatService } from './chat.service';

interface RerankResult {
  id: string;
  text: string;
  originalScore: number;
  rerankScore: number;
  metadata: Record<string, any>;
}

@Injectable()
export class RerankerService {
  constructor(private chatService: ChatService) {}

  async rerank(
    query: string,
    results: Array<{
      id: string;
      text: string;
      score: number;
      metadata?: Record<string, any>;
    }>,
    topK: number = 5,
  ): Promise<RerankResult[]> {
    // Use LLM to score relevance
    const scoringPrompt = `Given the query and document, rate the relevance from 0-10.
Query: ${query}

Respond with ONLY a JSON object: {"score": <number>, "reason": "<brief reason>"}`;

    const scored = await Promise.all(
      results.map(async (result) => {
        try {
          const response = await this.chatService.chat([
            { role: 'system', content: scoringPrompt },
            { role: 'user', content: `Document:\n${result.text.substring(0, 1000)}` },
          ], {
            temperature: 0,
            maxTokens: 100,
          });

          const parsed = JSON.parse(response.content || '{"score": 0}');

          return {
            ...result,
            originalScore: result.score,
            rerankScore: parsed.score / 10,
            metadata: result.metadata || {},
          };
        } catch {
          return {
            ...result,
            originalScore: result.score,
            rerankScore: result.score,
            metadata: result.metadata || {},
          };
        }
      }),
    );

    return scored
      .sort((a, b) => b.rerankScore - a.rerankScore)
      .slice(0, topK);
  }

  // Cohere reranker integration
  async rerankWithCohere(
    query: string,
    documents: string[],
    topK: number = 5,
  ): Promise<Array<{ index: number; relevanceScore: number }>> {
    // Requires Cohere SDK
    // const cohere = new CohereClient({ token: process.env.COHERE_API_KEY });
    // const response = await cohere.rerank({
    //   model: 'rerank-english-v3.0',
    //   query,
    //   documents,
    //   topN: topK,
    // });
    // return response.results;

    // Placeholder
    return documents.map((_, i) => ({
      index: i,
      relevanceScore: 1 - i * 0.1,
    }));
  }
}
```

## Best Practices

```yaml
rag_guidelines:
  - Use semantic chunking for better retrieval
  - Include metadata for filtering and citations
  - Implement hybrid search for better recall
  - Use re-ranking for precision
  - Cache frequent queries

chunking_guidelines:
  - Match chunk size to context window
  - Use overlap to preserve context
  - Respect document structure (headings)
  - Include source metadata

context_management:
  - Reserve tokens for response
  - Prioritize recent messages
  - Summarize old conversations
  - Monitor token usage

performance:
  - Batch embedding requests
  - Cache embeddings and results
  - Use async processing
  - Implement timeouts
```
