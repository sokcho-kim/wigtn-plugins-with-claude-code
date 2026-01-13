---
name: team-convention
description: 팀 컨벤션 검토 및 보완. 기존 설정 확인 후 누락된 부분만 추가합니다. Trigger on "/convention", "/컨벤션", "컨벤션 검토해줘", "husky 설정해줘", "PR 템플릿 만들어줘".
model: sonnet
allowed-tools: ["Read", "Edit", "Write", "Grep", "Glob"]
---

# Team Convention - 검토 및 보완

기존 설정을 검토하고, 누락된 부분만 보완합니다.

## When to Use

- 프레임워크로 생성한 프로젝트의 컨벤션을 검토할 때
- husky, commitlint 등 누락된 설정을 추가할 때
- PR/Issue 템플릿, CONTRIBUTING.md를 추가할 때

## 프레임워크별 기본 포함 여부

| 설정         | CRA | Next.js | NestJS | Vite |
| ------------ | --- | ------- | ------ | ---- |
| ESLint       | ✅  | ✅      | ✅     | ✅   |
| Prettier     | ❌  | ❌      | ✅     | ❌   |
| EditorConfig | ❌  | ❌      | ✅     | ❌   |
| husky        | ❌  | ❌      | ❌     | ❌   |
| commitlint   | ❌  | ❌      | ❌     | ❌   |
| PR 템플릿    | ❌  | ❌      | ❌     | ❌   |
| CONTRIBUTING | ❌  | ❌      | ❌     | ❌   |

**→ 대부분 husky, commitlint, 템플릿은 직접 추가해야 함**

## Protocol

### Step 1: 기존 설정 검토

```
현재 프로젝트 설정:
• ESLint: ✅ 있음 (next/core-web-vitals)
• Prettier: ❌ 없음
• husky: ❌ 없음
• commitlint: ❌ 없음
• PR 템플릿: ❌ 없음

💡 추천: Prettier, husky, commitlint, PR 템플릿 추가
```

### Step 2: 보완할 항목 선택 (사용자 질문)

```
어떤 설정을 추가할까요?

[1] 💡 추천 항목 전체
[2] 🔀 Git 규칙만 (husky + commitlint)
[3] 📄 문서만 (PR 템플릿 + CONTRIBUTING.md)
[4] 🛠️ 개별 선택

번호를 선택해 주세요:
```

**사용자 답변 대기**

### Step 3: 세부 옵션 (필요시)

**commitlint 형식:**

```
커밋 형식: [1] Conventional Commits / [2] Gitmoji
```

**브랜치 전략 (CONTRIBUTING.md 작성용):**

```
브랜치 전략: [1] Git Flow / [2] GitHub Flow / [3] Trunk Based
```

**사용자 답변 대기**

### Step 4: 확인 후 생성

```
추가할 설정:
• Prettier: .prettierrc
• husky: .husky/pre-commit, commit-msg
• commitlint: commitlint.config.js
• PR 템플릿: .github/pull_request_template.md

기존 ESLint 설정은 유지됩니다. 진행할까요? (y/n):
```

**사용자 확인 대기** → 파일 생성

### Step 5: 설치 명령어 안내

```bash
npm install -D prettier
npm install -D @commitlint/cli @commitlint/config-conventional husky lint-staged
npx husky install
```

## Rules

1. **기존 설정 유지**: 이미 있는 ESLint, Prettier는 수정하지 않음
2. **누락된 부분만 추가**: 없는 것만 생성 제안
3. **사용자 선택 필수**: 질문하고 답변 대기

## Example

```
User: /convention

Claude:
1. "현재 설정:
   • ESLint: ✅ 있음 (next/core-web-vitals)
   • Prettier: ❌ 없음
   • husky: ❌ 없음
   💡 추천: Prettier, husky, commitlint 추가"

2. "[1] 추천 전체 / [2] Git 규칙만 / [3] 문서만 / [4] 개별"

User: 1

Claude:
3. "커밋 형식: [1] Conventional / [2] Gitmoji"

User: 1

Claude:
4. "추가: Prettier, husky, commitlint. 기존 ESLint 유지. 진행? (y/n)"

User: y

Claude:
5. 파일 생성 → npm install 명령어 안내
```
