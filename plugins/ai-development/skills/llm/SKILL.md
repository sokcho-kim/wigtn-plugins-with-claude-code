---
name: llm
description: LLM API integration patterns for OpenAI and Anthropic. Use when implementing AI chat, text analysis, or content generation features.
---

# LLM Integration

OpenAI and Anthropic LLM API integration patterns.

## When to Use This Skill

- Text generation/analysis
- Chatbot implementation
- Content summarization
- Keyword extraction
- JSON structured responses

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
      { role: "system", content: systemPrompt + "\n\nReturn JSON only." },
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
  "Analyze the text and return summary, keywords, score as JSON.",
  "Text to analyze..."
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
Summarize the following text in {{sentences}} sentences.

Text:
{{text}}
`),

  EXTRACT_KEYWORDS: new PromptTemplate(`
Extract {{count}} key keywords from the following text.
Return as JSON array: ["keyword1", "keyword2", ...]

Text:
{{text}}
`),
};

// Usage
const prompt = PROMPTS.SUMMARIZE.format({
  sentences: "3",
  text: "Text to summarize...",
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

## Prompt Engineering Guide

### System Prompt Design

```typescript
// Structure: Role + Context + Task + Constraints + Output Format
const systemPrompt = `
You are a [ROLE] specialized in [DOMAIN].

Context:
- [Background information]
- [Relevant constraints]

Task:
[Clear description of what to do]

Output Format:
[Specify exact format expected]

Rules:
- [Constraint 1]
- [Constraint 2]
`;
```

**Example:**
```typescript
const analyzerPrompt = `
You are a content analyst specialized in video summarization.

Context:
- Input is a video transcript
- Target audience: general users
- Length limit: 3 sentences

Task:
Analyze the transcript and extract key points.

Output Format:
Return JSON with: summary, keywords (max 5), sentiment (positive/neutral/negative)

Rules:
- Be concise and factual
- No speculation beyond the content
- Keywords must appear in the transcript
`;
```

### Chain of Thought (CoT)

Use CoT for complex reasoning tasks:

```typescript
// Basic CoT
const cotPrompt = `
Solve this step by step:
1. First, identify...
2. Then, analyze...
3. Finally, conclude...

Think through each step before answering.
`;

// Zero-shot CoT (simple trigger)
const zeroShotCoT = `
Let's think step by step.
`;

// Self-consistency CoT
const selfConsistencyPrompt = `
Solve this problem using 3 different approaches, then select the most reliable answer.
`;
```

**When to use CoT:**
- Math/logic problems
- Multi-step reasoning
- Decision making with tradeoffs
- Code debugging

### Few-shot Examples

```typescript
const fewShotPrompt = `
Extract entities from text.

Example 1:
Input: "Apple CEO Tim Cook announced new iPhone in Cupertino."
Output: {"people": ["Tim Cook"], "organizations": ["Apple"], "products": ["iPhone"], "locations": ["Cupertino"]}

Example 2:
Input: "Microsoft acquired GitHub for $7.5 billion."
Output: {"people": [], "organizations": ["Microsoft", "GitHub"], "products": [], "locations": [], "amounts": ["$7.5 billion"]}

Now extract entities from:
Input: "${userInput}"
Output:
`;
```

**Few-shot tips:**
- 2-3 examples usually sufficient
- Cover edge cases in examples
- Keep examples consistent in format
- Order: simple → complex

### Output Format Control

```typescript
// JSON with schema
const jsonSchemaPrompt = `
Return a JSON object with this exact structure:
{
  "title": string,
  "score": number (1-10),
  "tags": string[] (max 5),
  "recommended": boolean
}

No additional fields. No markdown formatting.
`;

// Markdown structured output
const markdownPrompt = `
Format your response as:

## Summary
[2-3 sentences]

## Key Points
- Point 1
- Point 2
- Point 3

## Recommendation
[1 sentence]
`;

// Delimiter-based parsing
const delimiterPrompt = `
Respond in this format:
<summary>Your summary here</summary>
<keywords>keyword1, keyword2, keyword3</keywords>
<score>8</score>
`;
```

### Token Optimization

```typescript
// 1. Concise instructions (avoid redundancy)
// Bad
const verbose = "I would like you to please summarize the following text for me in a brief manner";
// Good
const concise = "Summarize in 2 sentences:";

// 2. Use abbreviations in system prompts
const optimized = `
Role: Analyst
Task: Extract (name, date, amount) from invoice
Format: JSON array
Rules: Skip missing fields, dates as YYYY-MM-DD
`;

// 3. Truncate long inputs
function truncateForContext(text: string, maxTokens: number = 3000): string {
  const approxCharsPerToken = 4;
  const maxChars = maxTokens * approxCharsPerToken;
  if (text.length <= maxChars) return text;
  return text.slice(0, maxChars) + "\n[truncated]";
}

// 4. Use appropriate model
const modelSelection = {
  simple: "gpt-4o-mini",      // Classification, extraction, simple Q&A
  complex: "gpt-4o",          // Analysis, reasoning, creative
  coding: "gpt-4o",           // Code generation, debugging
};
```

### Temperature Guide

| Temperature | Use Case | Example |
|-------------|----------|---------|
| 0.0 - 0.3 | Factual, deterministic | Data extraction, classification |
| 0.4 - 0.7 | Balanced | Summarization, Q&A |
| 0.8 - 1.0 | Creative | Brainstorming, content generation |

```typescript
const temperatureByTask = {
  extraction: 0.1,
  summarization: 0.5,
  chatbot: 0.7,
  creative_writing: 0.9,
};
```

### Anti-patterns to Avoid

```typescript
// 1. Vague instructions
// Bad: "Analyze this text"
// Good: "Extract the main argument and list 3 supporting points"

// 2. Conflicting instructions
// Bad: "Be concise but include all details"
// Good: "Summarize in 3 sentences, prioritizing key facts"

// 3. No output format specification
// Bad: "Tell me about the product"
// Good: "Describe the product in JSON: {name, features: [], price}"

// 4. Prompt injection vulnerability
// Bad: const prompt = `Translate: ${userInput}`;
// Good: const prompt = `Translate the text between <input> tags:\n<input>${sanitize(userInput)}</input>`;
```

## Best Practices

```yaml
prompt_engineering:
  - Write clear instructions
  - Specify output format (JSON, markdown, etc.)
  - Include examples (few-shot)
  - Explicitly request language if needed

performance:
  - Choose appropriate model (gpt-4o-mini vs gpt-4o)
  - Adjust temperature for use case
  - Set max_tokens only as needed

error_handling:
  - Handle rate limits (retry with backoff)
  - Manage API keys via env variables
  - Prepare for response parsing failures

security:
  - Never expose API keys to client
  - Validate user input
  - Monitor costs
```
