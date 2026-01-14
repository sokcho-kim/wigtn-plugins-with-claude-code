<div align="center">

[English](README.md) | [한국어](README.ko.md)

# WIGTN Claude Code Plugin Tools

**아이디어에서 배포까지, 마찰 없이**

![Ship Fast](https://img.shields.io/badge/🚀_Ship-Fast-FF6B6B?style=for-the-badge)
![One Command](https://img.shields.io/badge/One_Command-Full_Feature-5A67D8?style=for-the-badge)
![No Boilerplate](https://img.shields.io/badge/No-Boilerplate-00D4AA?style=for-the-badge)

[![GitHub Stars](https://img.shields.io/github/stars/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Contributors](https://img.shields.io/github/contributors/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/commits/main)

</div>

---

## 개요

**WIGTN Claude Code Plugin Tools**는 Claude Code를 활용한 AI 기반 개발 역량을 극대화하기 위해 설계된 플러그인 모음입니다. 우리의 목표는 **바이브 코딩(Vibe Coding)** — 아이디어에서 프로덕션까지 최소한의 마찰로 진행되는 매끄러운 개발 경험을 가능하게 하는 것입니다.

### 주요 특징

- **End-to-End 워크플로우**: PRD 생성부터 구현, 자동 커밋까지 전체 흐름 지원
- **디자인 우선 접근**: 12개 이상의 전문 디자인 스타일로 독창적인 UI/UX 구현
- **풀스택 대응**: 데이터베이스, 인증, API를 포함한 완전한 Next.js 솔루션
- **품질 보증**: 내장된 코드 리뷰 및 자동 포맷팅 기능

---

## 플러그인

### 1. public-commands

> **핵심 개발 워크플로우 플러그인**

지능형 자동화로 전체 개발 라이프사이클을 지원하는 필수 플러그인입니다.

#### 워크플로우 파이프라인

```
/prd → digging → /implement → /auto-commit
  ↓       ↓          ↓            ↓
 PRD    분석      코드구현     품질게이트
```

#### 명령어

| 명령어 | 설명 |
|--------|------|
| `/prd <기능명>` | 모호한 기능 요청을 구조화된 PRD로 변환 |
| `/implement <기능명>` | PRD 기반으로 기능 즉시 구현 |
| `/auto-commit` | 품질 검사를 통과한 지능형 자동 커밋 |

#### 스킬 & 에이전트

| 타입 | 이름 | 설명 |
|------|------|------|
| Skill | `code-review` | 코드 품질 점수(0-100) 및 상세 피드백 제공 |
| Skill | `digging` | PRD 취약점 분석 및 리스크 식별 |
| Agent | `code-formatter` | 다중 언어 포맷팅 및 린팅 자동화 |

#### 품질 게이트 시스템

| 점수 | 등급 | 액션 |
|------|------|------|
| 80+ | A/B | ✅ 자동 커밋 |
| 60-79 | C/D | ⚠️ 자동 수정 후 재시도 |
| < 60 | F | ❌ 커밋 차단 |

---

### 2. frontend-development

> **전문 프론트엔드 개발 솔루션** `v1.1.0`

12개 이상의 디자인 스타일을 제공하여 일반적인 AI 생성 디자인이 아닌 독창적인 UI를 만들 수 있는 완전한 프론트엔드 개발 도구입니다.

#### 하이라이트

- **12+ 디자인 스타일**: Editorial, Brutalist, Glassmorphism, Swiss Minimal, Neomorphism, Bento Grid 등
- **Next.js 16 & React 19** 지원
- **상태 관리**: Zustand, Jotai, Valtio 패턴
- **13개 전문 스킬**로 포괄적인 프론트엔드 개발 지원

#### 명령어

| 명령어 | 설명 |
|--------|------|
| `/component-scaffold` | TypeScript, 테스트, Storybook을 포함한 반응형 컴포넌트 생성 |

#### 디자인 스타일

| 스타일 | 설명 |
|--------|------|
| Editorial | 강렬한 타이포그래피의 매거진 스타일 레이아웃 |
| Brutalist | 날것의, 대담하고 비관습적인 디자인 |
| Glassmorphism | 블러와 투명도를 활용한 프로스티드 글래스 효과 |
| Swiss Minimal | 깔끔하고 그리드 기반의 타이포그래피 중심 디자인 |
| Neomorphism | 부드러운 그림자의 소프트 UI |
| Bento Grid | 모던한 그리드 기반 카드 레이아웃 |
| Dark Mode First | 다크 인터페이스 최적화 |
| Minimal Corporate | 깔끔한 비즈니스 스타일 |

<details>
<summary><strong>13개 스킬 전체 보기</strong></summary>

| 카테고리 | 스킬 |
|----------|------|
| 디자인 | `design-skill`, `tailwind-design-system` |
| React | `react-state-management`, `react-hooks`, `component-library` |
| Next.js | `nextjs-app-router-patterns` |
| 기능 | `api-integration`, `authentication`, `forms-validation`, `realtime-features` |
| 품질 | `frontend-test`, `seo`, `data-visualization` |

</details>

---

### 3. fullstack-nextjs

> **완전한 풀스택 Next.js 솔루션** `v1.1.0`

프로덕션 레디 풀스택 애플리케이션 구축에 필요한 모든 것을 제공합니다.

#### 기술 스택

- **Next.js 15+** App Router 포함
- **React 19** Server Components 지원
- **Prisma ORM** 데이터베이스 관리
- **NextAuth** 인증
- **TypeScript** 타입 안정성
- **Tailwind CSS** 스타일링
- **Vitest & Playwright** 테스팅

#### 명령어

| 명령어 | 설명 | 예시 |
|--------|------|------|
| `/component` | React 컴포넌트 생성 | `/component LoginForm --form` |
| `/page` | Next.js 페이지 생성 | `/page products/[id] --dynamic` |
| `/api` | API 라우트 생성 | `/api posts --crud` |
| `/model` | Prisma 모델 정의 | `/model Post --fields "title:String"` |
| `/action` | Server Actions 생성 | `/action createUser` |
| `/hook` | 커스텀 훅 생성 | `/hook useAuth` |
| `/feature` | 전체 기능 스캐폴딩 | `/feature blog --crud` |
| `/test` | 테스트 파일 생성 | `/test LoginForm` |

<details>
<summary><strong>12개 스킬 전체 보기</strong></summary>

| 카테고리 | 스킬 |
|----------|------|
| Frontend | `react-patterns`, `nextjs-app-router`, `tailwind`, `frontend-design` |
| Backend | `api-routes`, `server-actions`, `database-prisma`, `auth-patterns`, `error-handling` |
| Shared | `typescript`, `testing`, `form-validation` |

</details>

---

## Coming Soon

2개의 플러그인이 현재 개발 중입니다:

| 플러그인 | 상태 | 설명 |
|----------|------|------|
| 🔜 TBD | 개발 중 | 곧 공개 예정 |
| 🔜 TBD | 기획 중 | 곧 공개 예정 |

*업데이트를 기대해 주세요!*

---

## 설치 방법

### 방법 1: 마켓플레이스 (권장)

```bash
# Claude Code에 마켓플레이스 추가
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# 플러그인 설치
/plugin install public-commands
/plugin install frontend-development
/plugin install fullstack-nextjs
```

### 방법 2: CLI 설치

```bash
# 스코프 지정 설치
claude plugin install public-commands@wigtn-plugins --scope user      # 글로벌 (기본값)
claude plugin install frontend-development@wigtn-plugins --scope project   # 팀과 공유
claude plugin install fullstack-nextjs@wigtn-plugins --scope local     # 로컬 전용
```

### 방법 3: 수동 설치 (심볼릭 링크)

```bash
# 1. 저장소 클론
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn

# 2. 심볼릭 링크 생성
mkdir -p ~/.claude/plugins
ln -s ~/.claude-plugins/wigtn/plugins/public-commands ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/frontend-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/fullstack-nextjs ~/.claude/plugins/

# 업데이트
git -C ~/.claude-plugins/wigtn pull
```

### 설치 스코프

| 스코프 | 설정 파일 | 용도 |
|--------|----------|------|
| `user` | `~/.claude/settings.json` | 모든 프로젝트에서 개인용으로 사용 |
| `project` | `.claude/settings.json` | 버전 관리를 통해 팀과 공유 |
| `local` | `.claude/settings.local.json` | 로컬 전용, gitignored |

---

## 빠른 시작

### 완전한 개발 워크플로우

```bash
# 1. 아이디어에서 PRD 생성
/prd user-authentication

# 2. 계획 분석 및 개선 (선택사항)
# 'digging' 스킬이 누락점과 리스크를 식별합니다

# 3. 기능 구현
/implement user-authentication

# 4. 품질 검사와 함께 자동 커밋
/auto-commit
```

### 프론트엔드 개발

```bash
# 디자인 스타일로 컴포넌트 스캐폴드
/component-scaffold Dashboard --style=bento-grid

# 폼 컴포넌트 생성
/component-scaffold ContactForm --style=glassmorphism
```

### 풀스택 개발

```bash
# 완전한 CRUD 기능 생성
/feature blog --crud --auth

# 생성 결과:
# - Prisma 모델
# - API 라우트
# - Server actions
# - 페이지 & 컴포넌트
# - 타입 & 훅
```

---

## 플러그인 구조

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/
│   └── plugin.json              # 마켓플레이스 메타데이터
├── plugins/
│   ├── public-commands/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/
│   │   │   └── code-formatter.md
│   │   ├── commands/
│   │   │   ├── prd.md
│   │   │   ├── implement.md
│   │   │   └── auto-commit.md
│   │   └── skills/
│   │       ├── code-review/
│   │       └── digging/
│   ├── frontend-development/
│   │   ├── agents/
│   │   ├── commands/
│   │   └── skills/              # 13개 스킬
│   └── fullstack-nextjs/
│       ├── agents/
│       ├── commands/            # 8개 명령어
│       └── skills/              # 12개 스킬
├── README.md
├── README.ko.md
└── LICENSE
```

---

## 기여하기

기여를 환영합니다! 다음 단계를 따라주세요:

1. 저장소 **포크**
2. 기능 브랜치 **생성** (`git checkout -b feature/amazing-plugin`)
3. 변경사항 **커밋** (`git commit -m 'feat: 멋진 플러그인 추가'`)
4. 브랜치에 **푸시** (`git push origin feature/amazing-plugin`)
5. **Pull Request** 생성

---

## 라이선스

이 프로젝트는 **MIT 라이선스**로 배포됩니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

<div align="center">

**Made with ❤️ by [WIGTN Crew](https://github.com/wigtn)**

</div>
