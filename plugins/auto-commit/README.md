# Auto Commit Plugin

변경사항을 분석하여 적절한 커밋 메시지를 자동 생성하고 커밋/푸시합니다.

## Installation

```bash
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code
/plugin install auto-commit
```

## Usage

```bash
# 자동 메시지 생성 + 푸시
/auto-commit

# 커밋만, 푸시 안함
/auto-commit --no-push

# 수동 메시지 지정
/auto-commit --message "feat: Add new feature"
```

## Features

- **변경 패턴 분석**: 파일 경로를 분석하여 적절한 커밋 타입 결정
- **Conventional Commits**: `type(scope): subject` 형식 준수
- **안전 장치**: 민감한 파일 자동 감지, 대규모 변경 시 확인

## Commit Types

| Pattern | Type |
|---------|------|
| `src/`, `lib/` | `feat` |
| `tests/`, `*.test.*` | `test` |
| `docs/`, `*.md` | `docs` |
| `fix`, `bug` 키워드 | `fix` |
| `package.json` | `chore(deps)` |

## License

MIT
