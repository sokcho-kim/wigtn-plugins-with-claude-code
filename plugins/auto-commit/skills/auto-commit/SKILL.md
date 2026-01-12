---
name: auto-commit
description: Analyze changes and auto-commit with intelligent message generation. Trigger on "/auto-commit", "자동 커밋", "커밋해줘", "변경사항 커밋", or when user asks to commit their work after completing a task.
---

# Auto Commit

작업 완료 후 변경사항을 분석하여 자동으로 커밋하고 푸시합니다.

## Usage

```bash
/auto-commit                      # 자동 메시지 생성 + 푸시
/auto-commit --no-push            # 커밋만, 푸시 안함
/auto-commit --message "메시지"   # 수동 메시지 지정
```

## Parameters

- `--no-push`: 커밋만 하고 푸시하지 않음
- `--message`: 커밋 메시지 직접 지정

## Protocol

### Step 1: 변경사항 수집

```bash
# 상태 확인
git status

# 변경 통계
git diff --stat

# 스테이징 안된 파일 포함
git diff --stat HEAD
```

### Step 2: 변경 분석 및 타입 결정

| 변경 패턴 | 커밋 타입 | 예시 |
|----------|----------|------|
| `agents/`, `.claude/agents/` | `feat(agent)` | Agent 추가/수정 |
| `skills/`, `.claude/skills/` | `feat(skill)` | Skill 추가/수정 |
| `commands/`, `.claude/commands/` | `feat(command)` | Command 추가/수정 |
| `rules/`, `.claude/rules/` | `chore(rules)` | Rule 수정 |
| `hooks/`, `.claude/hooks/` | `feat(hook)` | Hook 추가/수정 |
| `docs/`, `*.md` (문서) | `docs` | 문서 변경 |
| `src/`, `lib/`, `app/` | `feat` | 소스 코드 |
| `tests/`, `*.test.*`, `*.spec.*` | `test` | 테스트 |
| `package.json`, `*-lock.*`, `requirements.txt` | `chore(deps)` | 의존성 |
| `Dockerfile`, `docker-compose.*`, `*.yaml` (k8s) | `chore(infra)` | 인프라 |
| 버그 수정 키워드 (fix, bug, error) | `fix` | 버그 수정 |
| 리팩토링 키워드 (refactor, cleanup) | `refactor` | 구조 개선 |

### Step 3: 커밋 메시지 형식

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Subject 규칙:**
- 50자 이내
- 동사 원형으로 시작 (Add, Update, Fix, Remove)
- 마침표 없음

**Body 규칙:**
- 변경된 주요 파일/기능 나열
- 72자 줄바꿈

### Step 4: 커밋 실행

```bash
# 모든 변경사항 스테이징
git add -A

# 커밋 (HEREDOC으로 메시지 전달)
git commit -m "$(cat <<'EOF'
<generated message>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# 푸시 (--no-push 없을 때)
git push
```

### Step 5: 결과 출력

```
✓ Committed: <SHA>
  <commit message 첫 줄>

✓ Pushed to origin/<branch>

📊 Changes:
  - X files changed
  - +Y insertions, -Z deletions
```

## Examples

### 자동 메시지 생성

```
입력: /auto-commit

분석:
- src/components/Button.tsx 변경
- tests/Button.test.tsx 추가

생성된 메시지:
feat: Update Button component and add tests
```

### 수동 메시지

```
입력: /auto-commit --message "feat(api): 사용자 인증 API 추가"

결과: 지정된 메시지로 커밋
```

## Rules

1. **민감한 파일 확인**: `.env`, `credentials`, `secrets` 등은 커밋하지 않음
2. **대규모 변경**: 100개 이상 파일 변경 시 확인 요청
3. **충돌 감지**: 푸시 실패 시 pull --rebase 제안
4. **빈 커밋 방지**: 변경사항 없으면 커밋하지 않음
