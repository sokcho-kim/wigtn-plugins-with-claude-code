---
description: Analyze changes, run quality gate, and auto-commit with intelligent message generation. Trigger on "/auto-commit", "git 푸시", "git push", "자동 커밋", "커밋해줘", "변경사항 커밋", or when user asks to commit their work after completing a task.
---

# Auto Commit

작업 완료 후 변경사항을 분석하고, 품질 검사를 거쳐 자동으로 커밋합니다.

## Pipeline Position

```
┌─────────────────────────────────────────────────────────────┐
│  [/prd] → [digging] → [/implement] → [/auto-commit]        │
│                                        ^^^^^^^^^^^^         │
│                                        현재 단계            │
└─────────────────────────────────────────────────────────────┘
```

| 이전 단계 | 현재 | 다음 단계 |
|----------|------|----------|
| `/implement` - 구현 완료 | `/auto-commit` - 품질 검사 & 커밋 | 완료 또는 다음 기능 |

## Usage

```bash
/auto-commit                      # 품질 검사 + 자동 메시지 + 푸시
/auto-commit --no-push            # 커밋만, 푸시 안함
/auto-commit --no-review          # 품질 검사 스킵 (권장하지 않음)
/auto-commit --message "메시지"   # 수동 메시지 지정
```

## Parameters

- `--no-push`: 커밋만 하고 푸시하지 않음
- `--no-review`: 품질 검사 스킵 (긴급 핫픽스용)
- `--message`: 커밋 메시지 직접 지정

## Protocol

### Step 1: 변경사항 및 Remote 수집

```bash
# 상태 확인
git status

# 변경 통계
git diff --stat

# 스테이징 안된 파일 포함
git diff --stat HEAD

# Remote 목록 확인
git remote -v
```

**Remote 확인:**
- 연결된 remote가 여러 개인 경우 나중에 push 전 사용자 확인 필요
- remote 이름과 URL을 기록해둠

### Step 2: 품질 검사 (Quality Gate)

> **연동**: `code-review` 스킬을 사용하여 변경된 코드를 평가합니다.

**품질 기준:**

| 점수 | 등급 | 액션 |
|------|------|------|
| **80점 이상** | A/B | ✅ Step 4로 진행 (바로 커밋) |
| **60-79점** | C | ⚠️ Step 3으로 진행 (자동 개선 시도) |
| **60점 미만** | D/F | ❌ 커밋 중단, 수동 수정 안내 |

**평가 항목:**
- Readability (가독성)
- Maintainability (유지보수성)
- Performance (성능)
- Best Practices (모범 사례)

```markdown
## Quality Gate Result

| 항목 | 점수 | 상태 |
|------|------|------|
| Readability | 18/20 | ✅ |
| Maintainability | 16/20 | ✅ |
| Performance | 15/20 | ⚠️ |
| Best Practices | 17/20 | ✅ |
| **Total** | **82/100** | **✅ PASS** |

→ 품질 기준 충족, 커밋을 진행합니다.
```

### Step 3: 자동 개선 (조건부)

> **연동**: 품질 미달 시 `code-formatter` 에이전트를 호출합니다.

**60-79점인 경우:**

```
⚠️ 품질 점수가 기준에 미달합니다 (72/100)

자동 개선을 시도합니다...

🔧 code-formatter 에이전트 호출:
  - ESLint/Prettier 자동 수정
  - import 정리
  - 포맷팅 통일

재평가 중...

✅ 개선 후 점수: 81/100
→ 품질 기준 충족, 커밋을 진행합니다.
```

**자동 개선 후에도 미달 시:**

```
❌ 자동 개선 후에도 품질 기준 미달 (68/100)

수동 수정이 필요한 항목:
1. [Major] src/utils/helper.ts:45 - 복잡도 높은 함수
2. [Major] src/api/user.ts:23 - 에러 처리 누락

커밋을 중단합니다.
수정 후 다시 `/auto-commit`을 실행해주세요.
```

### Step 4: 변경 분석 및 타입 결정

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

### Step 5: 커밋 메시지 형식

```
<type>(<scope>): <subject>

<body>

Quality Score: XX/100
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Subject 규칙:**
- 50자 이내
- 동사 원형으로 시작 (Add, Update, Fix, Remove)
- 마침표 없음

**Body 규칙:**
- 변경된 주요 파일/기능 나열
- 72자 줄바꿈

### Step 6: 커밋 실행

```bash
# 모든 변경사항 스테이징
git add -A

# 커밋 (HEREDOC으로 메시지 전달)
git commit -m "$(cat <<'EOF'
<generated message>

Quality Score: 82/100
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Step 6.5: Remote 선택 (Multiple Remote인 경우)

> **조건**: `--no-push` 옵션이 없고, remote가 2개 이상일 때만 실행

**Remote가 1개인 경우:**
```bash
# 바로 푸시
git push
```

**Remote가 2개 이상인 경우:**

1. 사용자에게 확인 요청:

```markdown
📡 여러 개의 remote가 감지되었습니다:

| Remote | URL |
|--------|-----|
| origin | https://github.com/user/repo.git |
| upstream | https://github.com/original/repo.git |
| backup | https://github.com/backup/repo.git |

어떤 remote에 push하시겠습니까?
- **모든 remote에 push** (origin, upstream, backup 전체)
- **origin만** (기본)
- **특정 remote 선택** (쉼표로 구분: origin, backup)
- **push 안함** (커밋만 유지)
```

2. 사용자 선택에 따라 실행:

```bash
# 모든 remote에 push
git push origin && git push upstream && git push backup

# 특정 remote만
git push origin

# 여러 remote 선택
git push origin && git push backup
```

**자동 선택 규칙 (사용자가 응답하지 않을 경우):**
- tracking branch가 설정된 remote 우선 (`git rev-parse --abbrev-ref @{upstream}`)
- tracking이 없으면 `origin` 기본 사용

### Step 7: 결과 출력

```
✅ Quality Gate: PASSED (82/100)

✓ Committed: abc1234
  feat(auth): Add user authentication API

✓ Pushed to origin/feature/user-auth

📊 Changes:
  - 5 files changed
  - +234 insertions, -12 deletions

📋 Files:
  - src/api/auth/login.ts (new)
  - src/api/auth/register.ts (new)
  - src/services/AuthService.ts (new)
  - src/types/auth.ts (new)
  - tests/auth.test.ts (new)
```

## Quality Gate Flow

```
                    ┌─────────────────┐
                    │  변경사항 수집   │
                    │  + Remote 확인  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  code-review    │
                    │  품질 점수 평가  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌─────────┐    ┌─────────┐    ┌─────────┐
        │ ≥80점   │    │ 60-79점 │    │ <60점   │
        │  PASS   │    │  WARN   │    │  FAIL   │
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
             │              ▼              │
             │    ┌─────────────────┐      │
             │    │ code-formatter  │      │
             │    │   자동 개선     │      │
             │    └────────┬────────┘      │
             │              │              │
             │         재평가              │
             │              │              │
             │    ┌────────┴────────┐      │
             │    │                 │      │
             │    ▼                 ▼      │
             │  ≥80점            <80점     │
             │    │                 │      │
             ▼    ▼                 ▼      ▼
        ┌─────────────┐       ┌─────────────┐
        │   COMMIT    │       │    STOP     │
        └──────┬──────┘       │  수동 수정   │
               │              └─────────────┘
               ▼
        ┌─────────────┐
        │ Remote 개수 │
        │    확인     │
        └──────┬──────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
   ┌─────────┐   ┌─────────────┐
   │ 1개     │   │ 2개 이상    │
   │         │   │ 사용자 확인  │
   └────┬────┘   └──────┬──────┘
        │               │
        ▼               ▼
   ┌─────────┐   ┌─────────────┐
   │  PUSH   │   │ 선택된 곳에  │
   │         │   │    PUSH     │
   └─────────┘   └─────────────┘
```

## Integration Points

### 호출하는 스킬/에이전트

| 구성요소 | 역할 | 호출 조건 |
|----------|------|----------|
| `code-review` 스킬 | 품질 점수 평가 | 항상 (--no-review 제외) |
| `code-formatter` 에이전트 | 자동 코드 개선 | 점수 60-79점일 때 |

### 이전 단계에서 받는 입력

```
/implement 명령 결과물:
- 새로 생성된 파일들
- 수정된 파일들
- 구현된 기능 목록 (PRD 기반)
```

## Examples

### 품질 통과 후 커밋

```
입력: /auto-commit

분석:
- src/components/Button.tsx 변경
- tests/Button.test.tsx 추가

품질 검사:
- code-review 실행 → 85/100 ✅

결과:
✅ Quality Gate: PASSED
✓ Committed: abc1234
  feat: Update Button component and add tests
✓ Pushed to origin/main
```

### 자동 개선 후 커밋

```
입력: /auto-commit

분석:
- src/utils/helper.ts 변경

품질 검사:
- code-review 실행 → 72/100 ⚠️

자동 개선:
- code-formatter 실행
- ESLint 오류 3건 수정
- import 정리

재평가:
- code-review 재실행 → 84/100 ✅

결과:
✅ Quality Gate: PASSED (after auto-fix)
✓ Committed: def5678
  fix: Improve helper utilities
```

### 품질 미달로 중단

```
입력: /auto-commit

분석:
- src/api/complex.ts 변경

품질 검사:
- code-review 실행 → 55/100 ❌

결과:
❌ Quality Gate: FAILED

수동 수정 필요:
1. [Critical] Line 45: SQL 인젝션 취약점
2. [Major] Line 78: 에러 처리 누락
3. [Major] Line 102: 하드코딩된 비밀번호

커밋이 중단되었습니다.
위 항목을 수정 후 다시 시도해주세요.
```

## Rules

1. **민감한 파일 확인**: `.env`, `credentials`, `secrets` 등은 커밋하지 않음
2. **대규모 변경**: 100개 이상 파일 변경 시 확인 요청
3. **충돌 감지**: 푸시 실패 시 pull --rebase 제안
4. **빈 커밋 방지**: 변경사항 없으면 커밋하지 않음
5. **품질 우선**: 기본적으로 품질 검사 수행 (긴급 시 --no-review)
6. **Multiple Remote 처리**:
   - remote가 2개 이상이면 push 전 사용자에게 반드시 확인
   - 사용자가 명시적으로 선택할 때까지 자동으로 모든 remote에 push하지 않음
   - tracking branch가 설정된 remote를 기본값으로 제안

## Skip Quality Gate

긴급 핫픽스 등 품질 검사를 건너뛰어야 할 때:

```bash
/auto-commit --no-review --message "hotfix: 긴급 버그 수정"
```

⚠️ **경고**: 품질 검사 스킵은 권장하지 않습니다. 가능하면 나중에 코드 리뷰를 받으세요.
