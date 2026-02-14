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

| Field | Type | Required | Description |
|-------|------|:--------:|-------------|
| audio | binary | Yes | Audio file (webm, mp3, wav, m4a, ogg) |
| language | string | No | Language code or `"auto"` (default) |

### Request Parameters Detail

#### audio
- **Supported formats**: webm, mp3, wav, m4a, ogg, flac
- **Max file size**: ~500MB (depends on server config)
- **Recommended**: webm or mp3 for smaller file size

#### language
Specify language for better accuracy, or use `"auto"` for detection.

| Code | Language | Code | Language |
|------|----------|------|----------|
| `auto` | Auto detect | `ja` | Japanese |
| `ko` | Korean | `zh` | Chinese |
| `en` | English | `es` | Spanish |
| `de` | German | `fr` | French |
| `ru` | Russian | `pt` | Portuguese |

**Tip**: Specifying language improves accuracy and speed vs auto-detection.

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

### Response Fields Detail

| Field | Type | Description |
|-------|------|-------------|
| `text` | string | Full transcribed text (all segments concatenated) |
| `language` | string | Detected or specified language code |
| `language_probability` | number | Confidence score (0.0 - 1.0). Below 0.5 = unreliable |
| `segments` | array | Time-aligned text segments |
| `segments[].start` | number | Segment start time in seconds |
| `segments[].end` | number | Segment end time in seconds |
| `segments[].text` | string | Transcribed text for this segment |

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

## Audio Format Guide

### Format Comparison

| Format | Size | Quality | Compatibility | Recommended |
|--------|------|---------|---------------|:-----------:|
| webm (opus) | Small | Good | High | Yes |
| mp3 | Small | Good | Universal | Yes |
| wav | Large | Lossless | Universal | For quality |
| m4a (aac) | Small | Good | High | OK |
| flac | Large | Lossless | Medium | For archival |

### Recommended Settings

```typescript
// For web/streaming: prioritize size
const webConfig = {
  format: "webm",
  codec: "opus",
  bitrate: "48k-96k",
  sampleRate: 16000,  // 16kHz sufficient for speech
};

// For high accuracy: prioritize quality
const qualityConfig = {
  format: "wav",
  bitrate: "lossless",
  sampleRate: 44100,
  channels: 1,  // mono is fine for speech
};
```

### Audio Preprocessing Tips

```typescript
// Convert to optimal format with ffmpeg
const ffmpegCommand = `ffmpeg -i input.mp4 -vn -ac 1 -ar 16000 -b:a 48k output.webm`;

// Options explained:
// -vn: no video
// -ac 1: mono channel
// -ar 16000: 16kHz sample rate (optimal for speech)
// -b:a 48k: 48kbps bitrate
```

## Segments Usage

### Generate SRT Subtitles

```typescript
function segmentsToSRT(segments: STTSegment[]): string {
  return segments.map((seg, i) => {
    const startTime = formatSRTTime(seg.start);
    const endTime = formatSRTTime(seg.end);
    return `${i + 1}\n${startTime} --> ${endTime}\n${seg.text}\n`;
  }).join("\n");
}

function formatSRTTime(seconds: number): string {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  const ms = Math.floor((seconds % 1) * 1000);
  return `${pad(h)}:${pad(m)}:${pad(s)},${pad(ms, 3)}`;
}

function pad(n: number, len = 2): string {
  return n.toString().padStart(len, "0");
}
```

### Generate VTT Subtitles (Web)

```typescript
function segmentsToVTT(segments: STTSegment[]): string {
  const lines = ["WEBVTT\n"];
  segments.forEach((seg, i) => {
    const start = formatVTTTime(seg.start);
    const end = formatVTTTime(seg.end);
    lines.push(`${i + 1}`);
    lines.push(`${start} --> ${end}`);
    lines.push(`${seg.text}\n`);
  });
  return lines.join("\n");
}

function formatVTTTime(seconds: number): string {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = (seconds % 60).toFixed(3);
  return `${pad(h)}:${pad(m)}:${s.padStart(6, "0")}`;
}
```

### Timestamp-based Search

```typescript
function findSegmentByTime(
  segments: STTSegment[],
  targetSeconds: number
): STTSegment | undefined {
  return segments.find(
    seg => targetSeconds >= seg.start && targetSeconds <= seg.end
  );
}

function searchInTranscript(
  segments: STTSegment[],
  query: string
): { segment: STTSegment; timestamp: number }[] {
  const results: { segment: STTSegment; timestamp: number }[] = [];
  const lowerQuery = query.toLowerCase();

  for (const seg of segments) {
    if (seg.text.toLowerCase().includes(lowerQuery)) {
      results.push({ segment: seg, timestamp: seg.start });
    }
  }
  return results;
}
```

## Error Handling

### Comprehensive Error Handler

```typescript
interface STTError {
  code: "TIMEOUT" | "FILE_TOO_LARGE" | "INVALID_FORMAT" | "SERVER_ERROR" | "NETWORK_ERROR";
  message: string;
  retryable: boolean;
}

async function transcribeWithErrorHandling(
  audioBuffer: Buffer,
  language: string = "auto"
): Promise<STTResult> {
  const MAX_FILE_SIZE = 500 * 1024 * 1024; // 500MB
  const TIMEOUT = 5 * 60 * 1000; // 5 minutes

  // Validate file size
  if (audioBuffer.length > MAX_FILE_SIZE) {
    throw {
      code: "FILE_TOO_LARGE",
      message: `File size ${(audioBuffer.length / 1024 / 1024).toFixed(1)}MB exceeds limit`,
      retryable: false,
    } as STTError;
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), TIMEOUT);

  try {
    const formData = new FormData();
    const blob = new Blob([audioBuffer], { type: "audio/webm" });
    formData.append("audio", blob, "audio.webm");
    formData.append("language", language);

    const response = await fetch(`${STT_API_URL}/whisperX/transcribe`, {
      method: "POST",
      body: formData,
      signal: controller.signal,
    });

    if (!response.ok) {
      throw {
        code: "SERVER_ERROR",
        message: `Server returned ${response.status}`,
        retryable: response.status >= 500,
      } as STTError;
    }

    return await response.json();
  } catch (error: any) {
    if (error.name === "AbortError") {
      throw {
        code: "TIMEOUT",
        message: "Request timed out after 5 minutes",
        retryable: true,
      } as STTError;
    }
    if (error.code) throw error; // Already STTError
    throw {
      code: "NETWORK_ERROR",
      message: error.message || "Network request failed",
      retryable: true,
    } as STTError;
  } finally {
    clearTimeout(timeoutId);
  }
}
```

### Retry with Backoff

```typescript
async function transcribeWithRetry(
  audioBuffer: Buffer,
  language: string = "auto",
  maxRetries: number = 3
): Promise<STTResult> {
  let lastError: STTError;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await transcribeWithErrorHandling(audioBuffer, language);
    } catch (error) {
      lastError = error as STTError;

      if (!lastError.retryable) throw lastError;

      // Exponential backoff: 1s, 2s, 4s
      const delay = 1000 * Math.pow(2, attempt);
      await new Promise(r => setTimeout(r, delay));
    }
  }

  throw lastError!;
}
```

## Quality Optimization

### When to Specify Language

```typescript
// Use auto-detection for:
// - Unknown source language
// - Multi-language content
const autoDetect = await transcribe(audio, "auto");

// Specify language for:
// - Known single-language content (faster, more accurate)
// - Low audio quality (helps model)
// - Accented speech
const korean = await transcribe(audio, "ko");
```

### Handling Low Confidence

```typescript
function processSTTResult(result: STTResult): ProcessedResult {
  const CONFIDENCE_THRESHOLD = 0.5;

  if (result.languageProbability < CONFIDENCE_THRESHOLD) {
    return {
      text: result.text,
      warning: `Low confidence (${(result.languageProbability * 100).toFixed(0)}%). Results may be inaccurate.`,
      reliable: false,
    };
  }

  return {
    text: result.text,
    warning: null,
    reliable: true,
  };
}
```

### Long Audio Handling

```typescript
// For very long audio (>30 min), consider chunking
async function transcribeLongAudio(
  audioBuffer: Buffer,
  chunkMinutes: number = 10
): Promise<STTResult> {
  const CHUNK_SIZE = chunkMinutes * 60; // seconds

  // If short enough, process directly
  const estimatedDuration = estimateAudioDuration(audioBuffer);
  if (estimatedDuration <= CHUNK_SIZE) {
    return transcribeAudio(audioBuffer);
  }

  // For long audio: warn user or implement chunking
  console.warn(`Audio is ~${Math.round(estimatedDuration / 60)} minutes. Consider splitting.`);

  // Option: Process anyway (server handles it)
  return transcribeAudio(audioBuffer);
}
```

## Best Practices Summary

| Category | Recommendation |
|----------|----------------|
| **Format** | webm/opus for web, wav for quality |
| **Sample Rate** | 16kHz sufficient for speech |
| **Channels** | Mono (reduces size, same accuracy) |
| **Language** | Specify if known (faster + accurate) |
| **Timeout** | 5+ minutes for long audio |
| **Confidence** | Warn user if < 50% |
| **Error Handling** | Retry with backoff for transient errors |
| **Cleanup** | Always delete temp files |
