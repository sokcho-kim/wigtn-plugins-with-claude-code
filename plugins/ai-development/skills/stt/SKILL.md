---
name: stt
description: Speech-to-Text integration patterns using WhisperX API. Use when implementing audio transcription features.
---

# STT (Speech-to-Text) Integration

WhisperX STT API integration patterns.

## When to Use This Skill

- Convert audio files to text
- Multi-language auto detection
- Extract segments with timestamps
- Generate subtitles for video/audio

## STT Server

```
URL: http://work.soundmind.life:12321
Endpoint: POST /whisperX/transcribe
```

## API Specification

### Request

```
POST http://work.soundmind.life:12321/whisperX/transcribe
Content-Type: multipart/form-data
```

| Field | Type | Description |
|-------|------|-------------|
| audio | binary | Audio file (webm, mp3, wav) |
| language | string | `"auto"` (auto detect) or `"ko"`, `"en"` |

### Response

```json
{
  "text": "Full transcribed text",
  "language": "ko",
  "language_probability": 0.95,
  "segments": [
    {
      "start": 0.0,
      "end": 5.2,
      "text": "Segment text"
    }
  ]
}
```

## Implementation

### Types

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

### STT Service

```typescript
// lib/stt.ts
const STT_API_URL = process.env.STT_API_URL || "http://work.soundmind.life:12321";

export async function transcribeAudio(
  audioBuffer: Buffer,
  language: string = "auto"
): Promise<STTResult> {
  const formData = new FormData();

  const uint8Array = new Uint8Array(audioBuffer);
  const blob = new Blob([uint8Array], { type: "audio/webm" });
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

### Duration Limit

```typescript
export function isWithinSTTLimit(durationSeconds: number): boolean {
  const maxMinutes = parseInt(process.env.STT_MAX_DURATION_MINUTES || "120", 10);
  return durationSeconds <= maxMinutes * 60;
}
```

## Audio Download (yt-dlp)

```typescript
// lib/audio-download.ts
import { exec } from "child_process";
import { promisify } from "util";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";

const execAsync = promisify(exec);
const YT_DLP_PATH = process.env.YT_DLP_PATH || "yt-dlp";

export async function downloadAudio(videoUrl: string): Promise<Buffer> {
  const tempDir = os.tmpdir();
  const outputPath = path.join(tempDir, `audio-${Date.now()}.webm`);

  try {
    const command = `"${YT_DLP_PATH}" -f "bestaudio[ext=webm]/bestaudio" -o "${outputPath}" --no-playlist "${videoUrl}"`;
    await execAsync(command, { timeout: 300000 });

    const audioBuffer = fs.readFileSync(outputPath);
    fs.unlinkSync(outputPath);
    return audioBuffer;
  } catch (error) {
    if (fs.existsSync(outputPath)) fs.unlinkSync(outputPath);
    throw error;
  }
}
```

## Environment Variables

```env
STT_API_URL=http://work.soundmind.life:12321
STT_MAX_DURATION_MINUTES=120
YT_DLP_PATH=/path/to/yt-dlp
```

## Best Practices

```yaml
performance:
  - Audio format: webm recommended
  - Timeout: set 5+ minutes

error_handling:
  - Graceful fallback on API failure
  - Always cleanup temp files

language:
  - Default "auto"
  - Show warning if confidence < 50%
```
