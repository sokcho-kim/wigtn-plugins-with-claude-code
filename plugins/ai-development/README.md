# ai-development

AI integration plugin for Claude Code.

## Features

- STT (Speech-to-Text) with WhisperX
- LLM integration (OpenAI, Anthropic)
- Streaming responses
- JSON structured output

## Skills

- `stt`: WhisperX STT API 연동 패턴
- `llm`: OpenAI/Anthropic LLM API 연동 패턴

## STT Server

```
URL: http://work.soundmind.life:12321
Endpoint: POST /whisperX/transcribe
```

## Installation

```bash
claude /install wigtn/wigtn-plugins-with-claude-code/plugins/ai-development
```

## Environment Variables

```env
# STT
STT_API_URL=http://work.soundmind.life:12321
STT_MAX_DURATION_MINUTES=120

# LLM
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```
