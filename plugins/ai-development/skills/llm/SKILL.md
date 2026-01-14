---
name: llm
description: LLM API integration patterns for OpenAI and Anthropic. Use when implementing AI chat, text analysis, or content generation features.
---

# LLM Integration

OpenAI, Anthropic LLM API 연동 패턴입니다.

## When to Use This Skill

- 텍스트 생성/분석
- 챗봇 구현
- 콘텐츠 요약
- 키워드 추출
- JSON 구조화 응답

## Provider Setup

### OpenAI

```typescript
// lib/openai.ts
import OpenAI from "openai";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export { openai };
```

### Anthropic

```typescript
// lib/anthropic.ts
import Anthropic from "@anthropic-ai/sdk";

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

export { anthropic };
```

## Chat Completion

### OpenAI Chat

```typescript
import { openai } from "@/lib/openai";

interface ChatOptions {
  model?: string;
  temperature?: number;
  maxTokens?: number;
}

export async function chat(
  systemPrompt: string,
  userMessage: string,
  options: ChatOptions = {}
) {
  const {
    model = "gpt-4o-mini",
    temperature = 0.7,
    maxTokens = 4096,
  } = options;

  const response = await openai.chat.completions.create({
    model,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userMessage },
    ],
    temperature,
    max_tokens: maxTokens,
  });

  return response.choices[0].message.content;
}
```

### Anthropic Chat

```typescript
import { anthropic } from "@/lib/anthropic";

export async function chatAnthropic(
  systemPrompt: string,
  userMessage: string
) {
  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 4096,
    system: systemPrompt,
    messages: [
      { role: "user", content: userMessage },
    ],
  });

  return response.content[0].type === "text"
    ? response.content[0].text
    : "";
}
```

## JSON Response

### OpenAI JSON Mode

```typescript
export async function chatJSON<T>(
  systemPrompt: string,
  userMessage: string
): Promise<T> {
  const response = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: systemPrompt + "\n\nJSON만 반환하세요." },
      { role: "user", content: userMessage },
    ],
    temperature: 0.7,
    response_format: { type: "json_object" },
  });

  return JSON.parse(response.choices[0].message.content || "{}");
}
```

### Usage Example

```typescript
interface AnalysisResult {
  summary: string;
  keywords: string[];
  score: number;
}

const result = await chatJSON<AnalysisResult>(
  "텍스트를 분석하여 summary, keywords, score를 JSON으로 반환하세요.",
  "분석할 텍스트..."
);
```

## Streaming Response

### OpenAI Streaming

```typescript
export async function* chatStream(
  systemPrompt: string,
  userMessage: string
) {
  const stream = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userMessage },
    ],
    stream: true,
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) yield content;
  }
}
```

### Next.js Streaming API Route

```typescript
// app/api/chat/route.ts
import { NextRequest } from "next/server";
import { openai } from "@/lib/openai";

export async function POST(request: NextRequest) {
  const { message } = await request.json();

  const stream = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: message }],
    stream: true,
  });

  const encoder = new TextEncoder();
  const readable = new ReadableStream({
    async start(controller) {
      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content;
        if (content) {
          controller.enqueue(encoder.encode(content));
        }
      }
      controller.close();
    },
  });

  return new Response(readable, {
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}
```

## Prompt Templates

```typescript
// lib/prompts.ts
export class PromptTemplate {
  constructor(private template: string) {}

  format(variables: Record<string, string>): string {
    return this.template.replace(
      /\{\{(\w+)\}\}/g,
      (_, key) => variables[key] || ""
    );
  }
}

export const PROMPTS = {
  SUMMARIZE: new PromptTemplate(`
다음 텍스트를 {{sentences}}문장으로 요약하세요.

텍스트:
{{text}}
`),

  EXTRACT_KEYWORDS: new PromptTemplate(`
다음 텍스트에서 핵심 키워드 {{count}}개를 추출하세요.
JSON 배열로 반환: ["키워드1", "키워드2", ...]

텍스트:
{{text}}
`),
};

// Usage
const prompt = PROMPTS.SUMMARIZE.format({
  sentences: "3",
  text: "요약할 텍스트...",
});
```

## Error Handling

```typescript
export async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  let lastError: Error;

  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error: any) {
      lastError = error;

      // Rate limit - wait and retry
      if (error.status === 429) {
        const retryAfter = error.headers?.["retry-after"] || 60;
        await new Promise(r => setTimeout(r, retryAfter * 1000));
        continue;
      }

      // Auth error - don't retry
      if (error.status === 401 || error.status === 403) {
        throw error;
      }

      // Exponential backoff
      await new Promise(r => setTimeout(r, 1000 * Math.pow(2, i)));
    }
  }

  throw lastError!;
}
```

## Environment Variables

```env
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

## Best Practices

```yaml
prompt_engineering:
  - 명확한 지시사항 작성
  - 출력 형식 명시 (JSON, markdown 등)
  - 예시 포함 (few-shot)
  - 한국어 응답 필요시 명시

performance:
  - 적절한 model 선택 (gpt-4o-mini vs gpt-4o)
  - temperature 용도에 맞게 조정
  - max_tokens 필요한 만큼만

error_handling:
  - Rate limit 대응 (retry with backoff)
  - API 키 환경변수 관리
  - 응답 파싱 실패 대비

security:
  - API 키 클라이언트 노출 금지
  - 사용자 입력 검증
  - 비용 모니터링
```
