# Team Convention

팀 컨벤션(코드 스타일, Git 규칙, PR 템플릿 등)을 가이드하고 자동 설정합니다.

## 사용법

```bash
/convention                    # 전체 설정 가이드
/convention 코드 스타일         # ESLint + Prettier만
/convention Git 규칙           # 커밋 + 브랜치 + PR
커밋 규칙 만들어줘              # 자연어로 요청
```

## 설정 항목

| 카테고리        | 파일                           | 내용                   |
| --------------- | ------------------------------ | ---------------------- |
| **코드 스타일** | `.eslintrc`, `.prettierrc`     | 린트, 포맷팅           |
| **에디터**      | `.editorconfig`, `.vscode/`    | 들여쓰기, 저장 시 포맷 |
| **Git**         | `.gitattributes`, `.gitignore` | LF 강제, 무시 패턴     |
| **커밋**        | `commitlint`, `.husky/`        | 커밋 메시지 규칙       |
| **브랜치**      | `CONTRIBUTING.md`              | 브랜치 전략, PR 가이드 |
| **템플릿**      | `.github/`                     | PR, Issue 양식         |

## 옵션

### ESLint 프리셋

- Airbnb (엄격)
- Standard (중간)
- Next.js 기본
- 커스텀

### 커밋 컨벤션

- Conventional Commits (`feat:`, `fix:`, ...)
- Gitmoji (🎨, 🐛, ✨, ...)
- Angular Style
- 커스텀

### 브랜치 전략

- Git Flow (`feature/`, `release/`, `hotfix/`)
- GitHub Flow (`main` + `feature`)
- Trunk Based (`main` only)

## 생성 파일 예시

```
프로젝트/
├── .eslintrc.json
├── .prettierrc
├── .prettierignore
├── .editorconfig
├── .gitattributes
├── .gitignore
├── commitlint.config.js
├── lint-staged.config.js
├── CONTRIBUTING.md
├── .vscode/
│   ├── settings.json
│   └── extensions.json
├── .husky/
│   ├── pre-commit
│   └── commit-msg
└── .github/
    ├── pull_request_template.md
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

## 출력 예시

```
┌─────────────────────────────────────────────────────────────┐
│ ✅ Team Convention Setup Complete                           │
├─────────────────────────────────────────────────────────────┤
│ 📝 코드 스타일: .eslintrc, .prettierrc ✅                   │
│ 🔧 에디터: .editorconfig, .vscode/ ✅                       │
│ 🔀 Git: .gitattributes, .gitignore ✅                       │
│ 📋 커밋: commitlint, husky ✅                               │
│ 📄 문서: CONTRIBUTING.md, PR/Issue 템플릿 ✅                │
├─────────────────────────────────────────────────────────────┤
│ 💡 다음: npm install → npx husky install                    │
└─────────────────────────────────────────────────────────────┘
```

## 특징

- 🎯 **프레임워크 감지** - Next.js, NestJS 등에 맞는 설정 자동 선택
- 📦 **한 번에 설정** - 모든 컨벤션 일괄 생성
- 🔧 **선택적 적용** - 필요한 부분만 개별 설정
- 📖 **문서화 포함** - CONTRIBUTING.md로 팀원 온보딩
- 🔒 **Git Hooks** - pre-commit, commit-msg 자동 검사
