---
name: llm-integration
description: LLM API integration patterns for OpenAI, Anthropic, and other providers. Use when implementing AI chat and completion features.
---

# LLM Integration

LLM API 연동 패턴입니다.

## Provider Setup

### OpenAI Integration

```typescript
// providers/openai.provider.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';

@Injectable()
export class OpenAIProvider implements OnModuleInit {
  private client: OpenAI;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    this.client = new OpenAI({
      apiKey: this.config.getOrThrow('OPENAI_API_KEY'),
    });
  }

  getClient(): OpenAI {
    return this.client;
  }
}
```

### Anthropic Integration

```typescript
// providers/anthropic.provider.ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Anthropic from '@anthropic-ai/sdk';

@Injectable()
export class AnthropicProvider implements OnModuleInit {
  private client: Anthropic;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    this.client = new Anthropic({
      apiKey: this.config.getOrThrow('ANTHROPIC_API_KEY'),
    });
  }

  getClient(): Anthropic {
    return this.client;
  }
}
```

### Provider Factory Pattern

```typescript
// providers/llm-provider.factory.ts
import { Injectable } from '@nestjs/common';
import { OpenAIProvider } from './openai.provider';
import { AnthropicProvider } from './anthropic.provider';

export type LLMProvider = 'openai' | 'anthropic';

@Injectable()
export class LLMProviderFactory {
  constructor(
    private openai: OpenAIProvider,
    private anthropic: AnthropicProvider,
  ) {}

  getProvider(provider: LLMProvider) {
    switch (provider) {
      case 'openai':
        return this.openai.getClient();
      case 'anthropic':
        return this.anthropic.getClient();
      default:
        throw new Error(`Unknown provider: ${provider}`);
    }
  }
}
```

## Chat Completion

### Basic Chat Service

```typescript
// services/chat.service.ts
import { Injectable } from '@nestjs/common';
import { OpenAIProvider } from '../providers/openai.provider';
import { ChatCompletionMessageParam } from 'openai/resources/chat';

interface ChatOptions {
  model?: string;
  temperature?: number;
  maxTokens?: number;
  systemPrompt?: string;
}

@Injectable()
export class ChatService {
  constructor(private openai: OpenAIProvider) {}

  async chat(
    messages: ChatCompletionMessageParam[],
    options: ChatOptions = {},
  ) {
    const {
      model = 'gpt-4o',
      temperature = 0.7,
      maxTokens = 4096,
      systemPrompt,
    } = options;

    const allMessages: ChatCompletionMessageParam[] = systemPrompt
      ? [{ role: 'system', content: systemPrompt }, ...messages]
      : messages;

    const response = await this.openai.getClient().chat.completions.create({
      model,
      messages: allMessages,
      temperature,
      max_tokens: maxTokens,
    });

    return {
      content: response.choices[0]?.message.content,
      usage: response.usage,
      model: response.model,
    };
  }
}
```

### Conversation with History

```typescript
// services/conversation.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/prisma/prisma.service';
import { ChatService } from './chat.service';

@Injectable()
export class ConversationService {
  constructor(
    private prisma: PrismaService,
    private chatService: ChatService,
  ) {}

  async continueConversation(
    conversationId: string,
    userMessage: string,
    systemPrompt?: string,
  ) {
    // Get conversation history
    const messages = await this.prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' },
      select: { role: true, content: true },
    });

    // Add new user message
    const allMessages = [
      ...messages.map((m) => ({ role: m.role as 'user' | 'assistant', content: m.content })),
      { role: 'user' as const, content: userMessage },
    ];

    // Get AI response
    const response = await this.chatService.chat(allMessages, { systemPrompt });

    // Save messages to database
    await this.prisma.$transaction([
      this.prisma.message.create({
        data: {
          conversationId,
          role: 'user',
          content: userMessage,
        },
      }),
      this.prisma.message.create({
        data: {
          conversationId,
          role: 'assistant',
          content: response.content || '',
          tokenUsage: response.usage?.total_tokens,
        },
      }),
    ]);

    return response;
  }
}
```

## Function Calling / Tools

### OpenAI Function Calling

```typescript
// services/function-calling.service.ts
import { Injectable } from '@nestjs/common';
import { OpenAIProvider } from '../providers/openai.provider';
import { ChatCompletionTool } from 'openai/resources/chat';

interface Tool {
  name: string;
  description: string;
  parameters: Record<string, unknown>;
  handler: (args: Record<string, unknown>) => Promise<unknown>;
}

@Injectable()
export class FunctionCallingService {
  private tools: Map<string, Tool> = new Map();

  constructor(private openai: OpenAIProvider) {}

  registerTool(tool: Tool) {
    this.tools.set(tool.name, tool);
  }

  async chatWithTools(messages: any[], options: { model?: string } = {}) {
    const { model = 'gpt-4o' } = options;

    const openaiTools: ChatCompletionTool[] = Array.from(this.tools.values()).map(
      (tool) => ({
        type: 'function',
        function: {
          name: tool.name,
          description: tool.description,
          parameters: tool.parameters,
        },
      }),
    );

    const response = await this.openai.getClient().chat.completions.create({
      model,
      messages,
      tools: openaiTools,
      tool_choice: 'auto',
    });

    const message = response.choices[0]?.message;

    // Handle tool calls
    if (message?.tool_calls) {
      const toolResults = await Promise.all(
        message.tool_calls.map(async (toolCall) => {
          const tool = this.tools.get(toolCall.function.name);
          if (!tool) {
            return {
              tool_call_id: toolCall.id,
              role: 'tool' as const,
              content: JSON.stringify({ error: 'Tool not found' }),
            };
          }

          const args = JSON.parse(toolCall.function.arguments);
          const result = await tool.handler(args);

          return {
            tool_call_id: toolCall.id,
            role: 'tool' as const,
            content: JSON.stringify(result),
          };
        }),
      );

      // Continue conversation with tool results
      return this.chatWithTools(
        [...messages, message, ...toolResults],
        options,
      );
    }

    return message?.content;
  }
}

// Usage example
functionCallingService.registerTool({
  name: 'get_weather',
  description: 'Get current weather for a location',
  parameters: {
    type: 'object',
    properties: {
      location: { type: 'string', description: 'City name' },
    },
    required: ['location'],
  },
  handler: async (args) => {
    // Call weather API
    return { temperature: 22, condition: 'sunny' };
  },
});
```

### Anthropic Tool Use

```typescript
// services/anthropic-tools.service.ts
import { Injectable } from '@nestjs/common';
import { AnthropicProvider } from '../providers/anthropic.provider';
import Anthropic from '@anthropic-ai/sdk';

@Injectable()
export class AnthropicToolsService {
  constructor(private anthropic: AnthropicProvider) {}

  async chatWithTools(
    messages: Anthropic.MessageParam[],
    tools: Anthropic.Tool[],
    toolHandlers: Record<string, (input: any) => Promise<any>>,
  ) {
    const response = await this.anthropic.getClient().messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      messages,
      tools,
    });

    // Check for tool use
    const toolUseBlock = response.content.find(
      (block): block is Anthropic.ToolUseBlock => block.type === 'tool_use',
    );

    if (toolUseBlock && response.stop_reason === 'tool_use') {
      const handler = toolHandlers[toolUseBlock.name];
      const result = await handler(toolUseBlock.input);

      // Continue with tool result
      return this.chatWithTools(
        [
          ...messages,
          { role: 'assistant', content: response.content },
          {
            role: 'user',
            content: [
              {
                type: 'tool_result',
                tool_use_id: toolUseBlock.id,
                content: JSON.stringify(result),
              },
            ],
          },
        ],
        tools,
        toolHandlers,
      );
    }

    return response.content
      .filter((block): block is Anthropic.TextBlock => block.type === 'text')
      .map((block) => block.text)
      .join('');
  }
}
```

## Prompt Management

### Template Pattern

```typescript
// prompts/prompt-template.ts
export class PromptTemplate {
  constructor(private template: string) {}

  format(variables: Record<string, string>): string {
    return this.template.replace(
      /\{\{(\w+)\}\}/g,
      (_, key) => variables[key] || '',
    );
  }
}

// prompts/templates.ts
export const PROMPTS = {
  SUMMARIZE: new PromptTemplate(`
You are a helpful assistant that summarizes text.

Summarize the following text in {{language}}:

{{text}}

Provide a concise summary in {{maxSentences}} sentences or less.
`),

  ANALYZE_SENTIMENT: new PromptTemplate(`
Analyze the sentiment of the following text and respond with JSON:
{
  "sentiment": "positive" | "negative" | "neutral",
  "confidence": 0-1,
  "keywords": ["keyword1", "keyword2"]
}

Text: {{text}}
`),

  RAG_CONTEXT: new PromptTemplate(`
Answer the question based on the provided context. If the answer cannot be found in the context, say "I don't have enough information to answer this question."

Context:
{{context}}

Question: {{question}}

Answer:
`),
};

// Usage
const prompt = PROMPTS.SUMMARIZE.format({
  text: 'Long article text here...',
  language: 'Korean',
  maxSentences: '3',
});
```

## Token Management

```typescript
// utils/token-counter.ts
import { encoding_for_model, TiktokenModel } from 'tiktoken';

export class TokenCounter {
  static count(text: string, model: TiktokenModel = 'gpt-4o'): number {
    const encoder = encoding_for_model(model);
    const tokens = encoder.encode(text);
    encoder.free();
    return tokens.length;
  }

  static estimateCost(
    inputTokens: number,
    outputTokens: number,
    model: string,
  ): number {
    const pricing: Record<string, { input: number; output: number }> = {
      'gpt-4o': { input: 0.0025, output: 0.01 },
      'gpt-4o-mini': { input: 0.00015, output: 0.0006 },
      'claude-sonnet-4-20250514': { input: 0.003, output: 0.015 },
    };

    const price = pricing[model] || pricing['gpt-4o'];
    return (inputTokens * price.input + outputTokens * price.output) / 1000;
  }

  static truncateToTokenLimit(
    text: string,
    maxTokens: number,
    model: TiktokenModel = 'gpt-4o',
  ): string {
    const encoder = encoding_for_model(model);
    const tokens = encoder.encode(text);

    if (tokens.length <= maxTokens) {
      encoder.free();
      return text;
    }

    const truncated = encoder.decode(tokens.slice(0, maxTokens));
    encoder.free();
    return new TextDecoder().decode(truncated);
  }
}
```

## Error Handling

```typescript
// utils/llm-error-handler.ts
import { HttpException, HttpStatus } from '@nestjs/common';

export class LLMError extends HttpException {
  constructor(
    public readonly provider: string,
    public readonly originalError: any,
    message: string,
  ) {
    super(message, HttpStatus.SERVICE_UNAVAILABLE);
  }
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  options: {
    maxRetries?: number;
    baseDelay?: number;
    maxDelay?: number;
  } = {},
): Promise<T> {
  const { maxRetries = 3, baseDelay = 1000, maxDelay = 10000 } = options;

  let lastError: Error | undefined;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error: any) {
      lastError = error;

      // Don't retry on certain errors
      if (error.status === 401 || error.status === 403) {
        throw error;
      }

      // Rate limit - use retry-after header
      if (error.status === 429) {
        const retryAfter = error.headers?.['retry-after'] || 60;
        await sleep(retryAfter * 1000);
        continue;
      }

      // Exponential backoff
      const delay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
      await sleep(delay);
    }
  }

  throw lastError;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
```

## Best Practices

```yaml
integration_guidelines:
  - Use environment variables for API keys
  - Implement retry with exponential backoff
  - Track token usage for cost management
  - Cache responses when appropriate
  - Validate inputs before API calls

prompt_engineering:
  - Use structured prompts with clear instructions
  - Include examples for complex tasks
  - Specify output format (JSON, markdown)
  - Set appropriate temperature for use case

error_handling:
  - Handle rate limits gracefully
  - Provide meaningful error messages
  - Log API errors for debugging
  - Implement circuit breaker for resilience

security:
  - Never expose API keys to client
  - Validate and sanitize user inputs
  - Implement content moderation
  - Set up usage quotas per user
```
