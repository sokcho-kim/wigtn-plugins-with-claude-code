# Implement Plugin

PRD에 정의된 기능을 즉시 구현합니다. 계획 확인 없이 바로 코드 작성을 시작합니다.

## Installation

```bash
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code
/plugin install implement
```

## Usage

```bash
# 기능명으로 구현
/implement 사용자 인증

# 기능 ID로 구현
/implement FR-006
```

## Features

- **PRD 자동 검색**: 기능명 또는 ID로 관련 PRD 자동 탐색
- **프로젝트 구조 감지**: Next.js, Monorepo, Python 등 자동 인식
- **Gap Analysis**: 기존 구현 상태 분석
- **즉시 구현**: 계획 확인 없이 바로 코드 작성

## Workflow

1. **PRD 검색**: `prd/`, `docs/prd/`, `requirements/` 등에서 검색
2. **구현 상태 확인**: 기존 코드 분석
3. **Gap Analysis**: 완료/부분/미구현 분류
4. **즉시 구현**: DB → API → UI 순서로 구현
5. **검증**: 타입체크, 테스트, 빌드 확인

## Supported Project Types

| Type | Source | API | Components |
|------|--------|-----|------------|
| General | `src/` | `src/api/` | `src/components/` |
| Next.js | `app/` | `app/api/` | `components/` |
| Monorepo | `apps/*/src/` | `apps/api/` | `apps/web/src/` |
| Python | `src/`, `app/` | `app/api/` | - |

## License

MIT
