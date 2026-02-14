# /llm

Integrate LLM (Large Language Model) functionality into your project.

## Usage

```
/llm [provider]
```

- `provider`: `openai` (default) or `anthropic`

## What It Does

1. Generate LLM client (`lib/openai.ts` or `lib/anthropic.ts`)
2. Generate Chat service (`lib/chat.ts`)
3. Provide environment variable guidance

## Generated Files

### lib/openai.ts (OpenAI)

```typescript
import OpenAI from "openai";

export const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});
```

### lib/anthropic.ts (Anthropic)

```typescript
import Anthropic from "@anthropic-ai/sdk";

export const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});
```

### lib/chat.ts

```typescript
import { openai } from "./openai";

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
  const { model = "gpt-4o-mini", temperature = 0.7, maxTokens = 4096 } = options;

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

export async function chatJSON<T>(
  systemPrompt: string,
  userMessage: string
): Promise<T> {
  const response = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: systemPrompt + "\n\nReturn JSON only." },
      { role: "user", content: userMessage },
    ],
    response_format: { type: "json_object" },
  });

  return JSON.parse(response.choices[0].message.content || "{}");
}
```

## Environment Variables

```env
# OpenAI
OPENAI_API_KEY=sk-...

# Anthropic
ANTHROPIC_API_KEY=sk-ant-...
```

## Reference

See `skills/llm/SKILL.md` for detailed patterns
