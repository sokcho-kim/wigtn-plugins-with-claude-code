---
name: team-convention
description: 팀 컨벤션(코드 스타일, Git 규칙, PR 템플릿 등)을 가이드하고 자동 설정합니다. Trigger on "/convention", "/컨벤션", "팀 규칙 설정해줘", "ESLint 설정해줘", "커밋 규칙 만들어줘", or when user needs team convention setup.
model: sonnet
allowed-tools: ["Read", "Edit", "Write", "Grep", "Glob"]
---

# Team Convention

팀 컨벤션을 체계적으로 설정하고 문서화합니다.

## When to Use

- 새 프로젝트 시작 시 팀 규칙 설정
- 기존 프로젝트에 컨벤션 도입
- 팀원 온보딩용 규칙 문서화
- 코드 품질 도구 설정 (ESLint, Prettier 등)

## Convention Categories

| 카테고리        | 설정 파일                      | 내용                   |
| --------------- | ------------------------------ | ---------------------- |
| **코드 스타일** | `.eslintrc`, `.prettierrc`     | 린트 규칙, 포맷팅      |
| **에디터 설정** | `.editorconfig`, `.vscode/`    | 들여쓰기, 인코딩       |
| **Git 설정**    | `.gitattributes`, `.gitignore` | LF 강제, 무시 파일     |
| **커밋 규칙**   | `commitlint.config.js`         | 커밋 메시지 포맷       |
| **브랜치 전략** | `CONTRIBUTING.md`              | 브랜치 네이밍, 플로우  |
| **PR/Issue**    | `.github/` 템플릿              | PR, Issue 양식         |
| **Git Hooks**   | `.husky/`                      | pre-commit, commit-msg |

## Protocol

### Step 1: 프로젝트 분석

```
현재 프로젝트 상태를 확인합니다:

✅ 존재함 / ❌ 없음 / ⚠️ 설정 불완전

• ESLint: [상태]
• Prettier: [상태]
• EditorConfig: [상태]
• Git Hooks: [상태]
• 커밋 규칙: [상태]
• PR 템플릿: [상태]
```

### Step 2: 컨벤션 선택

```
어떤 컨벤션을 설정할까요?

[1] 🎯 전체 설정 (권장) - 모든 컨벤션 한 번에
[2] 📝 코드 스타일만 - ESLint + Prettier
[3] 🔀 Git 규칙만 - 커밋 + 브랜치 + PR
[4] 🛠️ 개별 선택 - 원하는 항목만
```

### Step 3: 옵션 선택

**코드 스타일:**

```
ESLint 프리셋:
[1] Airbnb (엄격)
[2] Standard (중간)
[3] Next.js 기본 (프레임워크 권장)
[4] 커스텀

Prettier 설정:
• 탭/스페이스: [space 2 / space 4 / tab]
• 세미콜론: [yes / no]
• 따옴표: [single / double]
• 줄 길이: [80 / 100 / 120]
```

**Git 컨벤션:**

```
커밋 메시지 형식:
[1] Conventional Commits (feat:, fix:, ...)
[2] Gitmoji (🎨, 🐛, ✨, ...)
[3] Angular Style
[4] 커스텀

브랜치 전략:
[1] Git Flow (feature/, release/, hotfix/)
[2] GitHub Flow (main + feature)
[3] Trunk Based (main only)
[4] 커스텀
```

### Step 4: 파일 생성

선택한 옵션에 따라 파일을 생성합니다.

## Generated Files

### 코드 스타일

**.eslintrc.json:**

```json
{
  "extends": ["next/core-web-vitals", "prettier"],
  "rules": {
    "no-unused-vars": "warn",
    "no-console": ["warn", { "allow": ["warn", "error"] }]
  }
}
```

**.prettierrc:**

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

**.prettierignore:**

```
node_modules
.next
dist
build
coverage
```

### 에디터 설정

**.editorconfig:**

```ini
root = true

[*]
end_of_line = lf
charset = utf-8
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

**.vscode/settings.json:**

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "files.eol": "\n"
}
```

**.vscode/extensions.json:**

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "editorconfig.editorconfig"
  ]
}
```

### Git 설정

**.gitattributes:**

```
* text=auto eol=lf
*.md text eol=lf
*.json text eol=lf
*.js text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.jsx text eol=lf
*.css text eol=lf
*.yml text eol=lf
*.sh text eol=lf
```

**.gitignore (추가 권장):**

```
# Dependencies
node_modules/

# Build
dist/
build/
.next/
out/

# Environment
.env
.env.local
.env.*.local

# IDE
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Test
coverage/
```

### 커밋 규칙

**commitlint.config.js:**

```javascript
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      [
        "feat", // 새 기능
        "fix", // 버그 수정
        "docs", // 문서 변경
        "style", // 코드 포맷팅
        "refactor", // 리팩토링
        "perf", // 성능 개선
        "test", // 테스트
        "chore", // 빌드, 설정 변경
        "revert", // 되돌리기
      ],
    ],
    "subject-max-length": [2, "always", 72],
  },
};
```

**.husky/pre-commit:**

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

**.husky/commit-msg:**

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit $1
```

**lint-staged.config.js:**

```javascript
module.exports = {
  "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml,yaml}": ["prettier --write"],
};
```

### PR/Issue 템플릿

**.github/pull_request_template.md:**

```markdown
## 📋 변경 사항

<!-- 이 PR에서 변경된 내용을 설명해주세요 -->

## 🎯 관련 이슈

<!-- 관련 이슈 번호를 적어주세요 (예: #123) -->

Closes #

## ✅ 체크리스트

- [ ] 코드가 컨벤션을 따릅니다
- [ ] 테스트를 추가/수정했습니다
- [ ] 문서를 업데이트했습니다

## 📸 스크린샷 (UI 변경 시)

<!-- 변경 전/후 스크린샷 -->
```

**.github/ISSUE_TEMPLATE/bug_report.md:**

```markdown
---
name: 🐛 버그 리포트
about: 버그를 발견했을 때 사용해주세요
---

## 🐛 버그 설명

<!-- 버그에 대해 설명해주세요 -->

## 📋 재현 단계

1.
2.
3.

## ✅ 예상 동작

<!-- 어떻게 동작해야 하나요? -->

## 📸 스크린샷

<!-- 가능하면 스크린샷을 첨부해주세요 -->

## 🔧 환경

- OS:
- Browser:
- Version:
```

**.github/ISSUE_TEMPLATE/feature_request.md:**

```markdown
---
name: ✨ 기능 요청
about: 새로운 기능을 제안할 때 사용해주세요
---

## ✨ 기능 설명

<!-- 원하는 기능을 설명해주세요 -->

## 🎯 문제/동기

<!-- 왜 이 기능이 필요한가요? -->

## 💡 대안

<!-- 다른 해결 방법을 고려해보셨나요? -->
```

### 브랜치 전략

**CONTRIBUTING.md:**

```markdown
# Contributing Guide

## 브랜치 전략

### 브랜치 종류

| 브랜치      | 용도      | 예시                    |
| ----------- | --------- | ----------------------- |
| `main`      | 프로덕션  | -                       |
| `develop`   | 개발 통합 | -                       |
| `feature/*` | 새 기능   | `feature/user-auth`     |
| `fix/*`     | 버그 수정 | `fix/login-error`       |
| `hotfix/*`  | 긴급 수정 | `hotfix/security-patch` |

### 브랜치 네이밍
```

<type>/<issue-number>-<short-description>
예: feature/123-user-authentication

```

## 커밋 컨벤션

### 형식
```

<type>(<scope>): <subject>

<body>

<footer>
```

### 타입

| 타입       | 설명            |
| ---------- | --------------- |
| `feat`     | 새 기능         |
| `fix`      | 버그 수정       |
| `docs`     | 문서 변경       |
| `style`    | 코드 포맷팅     |
| `refactor` | 리팩토링        |
| `perf`     | 성능 개선       |
| `test`     | 테스트          |
| `chore`    | 빌드, 설정 변경 |

### 예시

```
feat(auth): 소셜 로그인 추가

- Google OAuth 연동
- Kakao OAuth 연동

Closes #123
```

## PR 가이드

1. `develop` 브랜치에서 feature 브랜치 생성
2. 작업 완료 후 PR 생성
3. 코드 리뷰 후 머지
4. feature 브랜치 삭제

````

## Setup Commands

설정 완료 후 실행할 명령어:

```bash
# 패키지 설치
npm install -D eslint prettier eslint-config-prettier
npm install -D @commitlint/cli @commitlint/config-conventional
npm install -D husky lint-staged

# Husky 초기화
npx husky install
npm pkg set scripts.prepare="husky install"

# Git hooks 설정
npx husky add .husky/pre-commit "npx lint-staged"
npx husky add .husky/commit-msg "npx --no -- commitlint --edit \$1"
````

## Output Report

```
┌─────────────────────────────────────────────────────────────┐
│ ✅ Team Convention Setup Complete                           │
├─────────────────────────────────────────────────────────────┤
│ 📝 코드 스타일                                               │
│   • .eslintrc.json ✅                                       │
│   • .prettierrc ✅                                          │
│   • .prettierignore ✅                                      │
│                                                             │
│ 🔧 에디터 설정                                               │
│   • .editorconfig ✅                                        │
│   • .vscode/settings.json ✅                                │
│   • .vscode/extensions.json ✅                              │
│                                                             │
│ 🔀 Git 설정                                                  │
│   • .gitattributes ✅                                       │
│   • .gitignore (업데이트) ✅                                │
│                                                             │
│ 📋 커밋 규칙                                                 │
│   • commitlint.config.js ✅                                 │
│   • .husky/pre-commit ✅                                    │
│   • .husky/commit-msg ✅                                    │
│   • lint-staged.config.js ✅                                │
│                                                             │
│ 📄 문서/템플릿                                               │
│   • CONTRIBUTING.md ✅                                      │
│   • .github/pull_request_template.md ✅                     │
│   • .github/ISSUE_TEMPLATE/*.md ✅                          │
├─────────────────────────────────────────────────────────────┤
│ 💡 다음 단계:                                                │
│   1. npm install (패키지 설치)                              │
│   2. npx husky install (Git hooks 활성화)                   │
│   3. 팀원에게 CONTRIBUTING.md 공유                          │
└─────────────────────────────────────────────────────────────┘
```

## Rules

1. **기존 설정 존중**: 이미 있는 설정은 덮어쓰지 않고 병합 제안
2. **프레임워크 감지**: Next.js, NestJS 등에 맞는 설정 자동 선택
3. **점진적 도입**: 한 번에 다 하지 않고 단계별 적용 가능
4. **문서화 필수**: 규칙만 설정하지 않고 CONTRIBUTING.md로 문서화

## Examples

### 예시 1: 전체 설정

```
User: /convention

Claude:
1. 프로젝트 분석 (Next.js 감지)
2. 전체 설정 선택
3. Airbnb + Prettier + Conventional Commits + Git Flow
4. 모든 파일 생성
5. 설치 명령어 안내
```

### 예시 2: 커밋 규칙만

```
User: /convention 커밋 규칙만

Claude:
1. commitlint.config.js 생성
2. husky 설정
3. CONTRIBUTING.md에 커밋 가이드 추가
```
