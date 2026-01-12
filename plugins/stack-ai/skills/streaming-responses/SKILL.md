---
name: streaming-responses
description: SSE and WebSocket patterns for streaming AI responses. Use when implementing real-time AI interactions.
---

# Streaming Responses

AI 응답 스트리밍 패턴입니다.

## Server-Sent Events (SSE)

### NestJS SSE Controller

```typescript
// controllers/ai-stream.controller.ts
import {
  Controller,
  Post,
  Body,
  Res,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { StreamingChatService } from '../services/streaming-chat.service';

@Controller('ai')
export class AIStreamController {
  constructor(private streamingChat: StreamingChatService) {}

  @Post('chat/stream')
  async streamChat(
    @Body() body: { message: string; conversationId?: string },
    @Res() res: Response,
  ) {
    // Set SSE headers
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.setHeader('X-Accel-Buffering', 'no'); // Disable nginx buffering
    res.flushHeaders();

    try {
      const stream = await this.streamingChat.streamResponse(
        body.message,
        body.conversationId,
      );

      for await (const chunk of stream) {
        // Send SSE event
        res.write(`data: ${JSON.stringify(chunk)}\n\n`);
      }

      // Send done event
      res.write(`data: ${JSON.stringify({ type: 'done' })}\n\n`);
      res.end();
    } catch (error) {
      res.write(
        `data: ${JSON.stringify({ type: 'error', message: error.message })}\n\n`,
      );
      res.end();
    }
  }
}
```

### OpenAI Streaming Service

```typescript
// services/streaming-chat.service.ts
import { Injectable } from '@nestjs/common';
import { OpenAIProvider } from '../providers/openai.provider';

interface StreamChunk {
  type: 'content' | 'done' | 'error';
  content?: string;
  message?: string;
}

@Injectable()
export class StreamingChatService {
  constructor(private openai: OpenAIProvider) {}

  async *streamResponse(
    message: string,
    conversationId?: string,
  ): AsyncGenerator<StreamChunk> {
    const stream = await this.openai.getClient().chat.completions.create({
      model: 'gpt-4o',
      messages: [{ role: 'user', content: message }],
      stream: true,
    });

    let fullContent = '';

    for await (const chunk of stream) {
      const content = chunk.choices[0]?.delta?.content;

      if (content) {
        fullContent += content;
        yield { type: 'content', content };
      }
    }

    // Optionally save to database
    if (conversationId) {
      await this.saveMessage(conversationId, message, fullContent);
    }
  }

  private async saveMessage(
    conversationId: string,
    userMessage: string,
    assistantMessage: string,
  ) {
    // Save to database
  }
}
```

### Anthropic Streaming

```typescript
// services/anthropic-streaming.service.ts
import { Injectable } from '@nestjs/common';
import { AnthropicProvider } from '../providers/anthropic.provider';

@Injectable()
export class AnthropicStreamingService {
  constructor(private anthropic: AnthropicProvider) {}

  async *streamResponse(message: string): AsyncGenerator<{
    type: string;
    content?: string;
    inputTokens?: number;
    outputTokens?: number;
  }> {
    const stream = await this.anthropic.getClient().messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      messages: [{ role: 'user', content: message }],
      stream: true,
    });

    for await (const event of stream) {
      if (event.type === 'content_block_delta') {
        if (event.delta.type === 'text_delta') {
          yield { type: 'content', content: event.delta.text };
        }
      } else if (event.type === 'message_delta') {
        yield {
          type: 'usage',
          outputTokens: event.usage?.output_tokens,
        };
      } else if (event.type === 'message_start') {
        yield {
          type: 'start',
          inputTokens: event.message.usage?.input_tokens,
        };
      }
    }
  }
}
```

## WebSocket Integration

### NestJS WebSocket Gateway

```typescript
// gateways/ai-chat.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { StreamingChatService } from '../services/streaming-chat.service';

@WebSocketGateway({
  cors: {
    origin: process.env.FRONTEND_URL,
    credentials: true,
  },
  namespace: '/ai',
})
export class AIChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(private streamingChat: StreamingChatService) {}

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('chat:message')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody()
    data: {
      message: string;
      conversationId: string;
    },
  ) {
    try {
      // Send start event
      client.emit('chat:start', { conversationId: data.conversationId });

      const stream = await this.streamingChat.streamResponse(
        data.message,
        data.conversationId,
      );

      let fullContent = '';

      for await (const chunk of stream) {
        if (chunk.type === 'content') {
          fullContent += chunk.content;
          client.emit('chat:chunk', {
            conversationId: data.conversationId,
            content: chunk.content,
          });
        }
      }

      // Send complete event
      client.emit('chat:complete', {
        conversationId: data.conversationId,
        fullContent,
      });
    } catch (error) {
      client.emit('chat:error', {
        conversationId: data.conversationId,
        message: error.message,
      });
    }
  }

  @SubscribeMessage('chat:stop')
  handleStop(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string },
  ) {
    // Implement abort logic
    client.emit('chat:stopped', { conversationId: data.conversationId });
  }
}
```

### WebSocket Module Setup

```typescript
// ai.module.ts
import { Module } from '@nestjs/common';
import { AIChatGateway } from './gateways/ai-chat.gateway';
import { StreamingChatService } from './services/streaming-chat.service';

@Module({
  providers: [AIChatGateway, StreamingChatService],
})
export class AIModule {}
```

## Client-Side Integration

### React SSE Hook

```typescript
// hooks/use-sse-chat.ts
import { useState, useCallback, useRef } from 'react';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export function useSSEChat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);
  const abortControllerRef = useRef<AbortController | null>(null);

  const sendMessage = useCallback(async (content: string) => {
    // Add user message
    setMessages((prev) => [...prev, { role: 'user', content }]);
    setIsStreaming(true);

    // Create abort controller
    abortControllerRef.current = new AbortController();

    try {
      const response = await fetch('/api/ai/chat/stream', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: content }),
        signal: abortControllerRef.current.signal,
      });

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();
      let assistantContent = '';

      // Add empty assistant message
      setMessages((prev) => [...prev, { role: 'assistant', content: '' }]);

      while (reader) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n');

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = JSON.parse(line.slice(6));

            if (data.type === 'content') {
              assistantContent += data.content;
              setMessages((prev) => {
                const newMessages = [...prev];
                newMessages[newMessages.length - 1] = {
                  role: 'assistant',
                  content: assistantContent,
                };
                return newMessages;
              });
            }
          }
        }
      }
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Stream error:', error);
      }
    } finally {
      setIsStreaming(false);
      abortControllerRef.current = null;
    }
  }, []);

  const stopStreaming = useCallback(() => {
    abortControllerRef.current?.abort();
  }, []);

  return { messages, isStreaming, sendMessage, stopStreaming };
}
```

### React WebSocket Hook

```typescript
// hooks/use-ws-chat.ts
import { useState, useEffect, useCallback, useRef } from 'react';
import { io, Socket } from 'socket.io-client';

export function useWSChat(conversationId: string) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const [isStreaming, setIsStreaming] = useState(false);
  const socketRef = useRef<Socket | null>(null);
  const currentContentRef = useRef('');

  useEffect(() => {
    const socket = io('/ai', {
      withCredentials: true,
    });

    socket.on('connect', () => setIsConnected(true));
    socket.on('disconnect', () => setIsConnected(false));

    socket.on('chat:start', () => {
      setIsStreaming(true);
      currentContentRef.current = '';
      setMessages((prev) => [...prev, { role: 'assistant', content: '' }]);
    });

    socket.on('chat:chunk', (data: { content: string }) => {
      currentContentRef.current += data.content;
      setMessages((prev) => {
        const newMessages = [...prev];
        newMessages[newMessages.length - 1] = {
          role: 'assistant',
          content: currentContentRef.current,
        };
        return newMessages;
      });
    });

    socket.on('chat:complete', () => {
      setIsStreaming(false);
    });

    socket.on('chat:error', (data: { message: string }) => {
      setIsStreaming(false);
      console.error('Chat error:', data.message);
    });

    socketRef.current = socket;

    return () => {
      socket.disconnect();
    };
  }, []);

  const sendMessage = useCallback(
    (content: string) => {
      setMessages((prev) => [...prev, { role: 'user', content }]);
      socketRef.current?.emit('chat:message', {
        message: content,
        conversationId,
      });
    },
    [conversationId],
  );

  const stopStreaming = useCallback(() => {
    socketRef.current?.emit('chat:stop', { conversationId });
  }, [conversationId]);

  return {
    messages,
    isConnected,
    isStreaming,
    sendMessage,
    stopStreaming,
  };
}
```

## Streaming UI Component

```typescript
// components/chat/streaming-message.tsx
'use client';

import { useEffect, useRef } from 'react';
import { cn } from '@/lib/utils';

interface StreamingMessageProps {
  content: string;
  isStreaming: boolean;
}

export function StreamingMessage({ content, isStreaming }: StreamingMessageProps) {
  const contentRef = useRef<HTMLDivElement>(null);

  // Auto-scroll as content streams
  useEffect(() => {
    if (contentRef.current) {
      contentRef.current.scrollIntoView({ behavior: 'smooth', block: 'end' });
    }
  }, [content]);

  return (
    <div className="flex gap-3">
      <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white text-sm">
        AI
      </div>
      <div className="flex-1">
        <div
          ref={contentRef}
          className={cn(
            'prose prose-sm max-w-none',
            isStreaming && 'animate-pulse',
          )}
        >
          {content || (
            <span className="text-muted-foreground">Thinking...</span>
          )}
          {isStreaming && (
            <span className="inline-block w-2 h-4 bg-primary animate-blink ml-1" />
          )}
        </div>
      </div>
    </div>
  );
}
```

## Token-by-Token Animation

```typescript
// hooks/use-typewriter.ts
import { useState, useEffect } from 'react';

export function useTypewriter(
  text: string,
  options: { speed?: number; enabled?: boolean } = {},
) {
  const { speed = 20, enabled = true } = options;
  const [displayedText, setDisplayedText] = useState('');

  useEffect(() => {
    if (!enabled) {
      setDisplayedText(text);
      return;
    }

    let index = displayedText.length;

    if (index >= text.length) return;

    const timer = setTimeout(() => {
      setDisplayedText(text.slice(0, index + 1));
    }, speed);

    return () => clearTimeout(timer);
  }, [text, displayedText, speed, enabled]);

  return displayedText;
}

// Usage
function Message({ content, isNew }: { content: string; isNew: boolean }) {
  const displayed = useTypewriter(content, { enabled: isNew });
  return <div>{displayed}</div>;
}
```

## Best Practices

```yaml
streaming_guidelines:
  - Use SSE for simple streaming
  - Use WebSocket for bidirectional communication
  - Implement abort/cancel mechanism
  - Handle reconnection gracefully
  - Buffer chunks for smooth display

sse_best_practices:
  - Set proper headers (no-cache, keep-alive)
  - Disable proxy buffering
  - Send heartbeat for long connections
  - Handle connection drops

websocket_best_practices:
  - Implement authentication
  - Use rooms for conversations
  - Handle reconnection
  - Implement backpressure

ui_best_practices:
  - Show loading state immediately
  - Auto-scroll during streaming
  - Allow stopping generation
  - Display token count/cost
  - Handle errors gracefully
```
