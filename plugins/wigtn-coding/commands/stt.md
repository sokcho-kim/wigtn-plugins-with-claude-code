# /stt

Integrate STT (Speech-to-Text) functionality into your project.

## Usage

```
/stt
```

## What It Does

1. Generate STT type definitions (`types/stt.ts`)
2. Generate STT service (`lib/stt.ts`)
3. Provide environment variable guidance

## Generated Files

### types/stt.ts

```typescript
export interface STTSegment {
  start: number;
  end: number;
  text: string;
}

export interface STTResult {
  text: string;
  language: string;
  languageProbability: number;
  segments: STTSegment[];
}
```

### lib/stt.ts

```typescript
const STT_API_URL = process.env.STT_API_URL || "http://work.soundmind.life:12321";

export async function transcribeAudio(
  audioBuffer: Buffer,
  language: string = "auto"
): Promise<STTResult> {
  const formData = new FormData();
  const blob = new Blob([new Uint8Array(audioBuffer)], { type: "audio/webm" });
  formData.append("audio", blob, "audio.webm");
  formData.append("language", language);

  const response = await fetch(`${STT_API_URL}/whisperX/transcribe`, {
    method: "POST",
    body: formData,
  });

  if (!response.ok) {
    throw new Error(`STT API error: ${response.status}`);
  }

  const result = await response.json();
  return {
    text: result.text || "",
    language: result.language || language,
    languageProbability: result.language_probability ?? 1.0,
    segments: result.segments || [],
  };
}
```

## Environment Variables

```env
STT_API_URL=http://work.soundmind.life:12321
STT_MAX_DURATION_MINUTES=120
```

## Reference

See `skills/stt/SKILL.md` for detailed patterns
