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
- **백엔드 & DevOps**: CI/CD 파이프라인을 포함한 완전한 백엔드 아키텍처
- **AI 통합**: 지능형 애플리케이션을 위한 STT 및 LLM 기능
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
| Agent | `architecture-decision` | PRD 분석 기반 MSA vs 모놀리식 아키텍처 결정 |
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

### 3. backend-development

> **백엔드 아키텍처 & DevOps 솔루션** `v2.0.0`

초보자 친화적인 아키텍처 가이드와 DevOps 자동화를 제공하는 완전한 백엔드 개발 도구입니다.

#### 하이라이트

- **초보자 친화적**: 명확한 설명과 함께 단계별 가이드 제공
- **풀 스택**: NestJS, Prisma, PostgreSQL, JWT
- **DevOps 지원**: Docker, Kubernetes, CI/CD 파이프라인
- **안전한 설계**: 자동 감지로 덮어쓰기 방지

#### 명령어

| 명령어 | 설명 | 예시 |
|--------|------|------|
| `/backend` | 백엔드 기능 고도화 및 아키텍처 개선 | `/backend 실시간 채팅 성능 개선` |
| `/devops` | CI/CD 및 배포 인프라 설정 | `/devops Docker + CI/CD` |

#### 기술 스택

| 카테고리 | 옵션 |
|----------|------|
| 프레임워크 | NestJS, Express, Fastify, FastAPI |
| 데이터베이스 | PostgreSQL, MySQL, MongoDB, SQLite |
| ORM | Prisma, TypeORM, Drizzle |
| DevOps | Docker, Kubernetes, GitHub Actions |

<details>
<summary><strong>스킬 전체 보기</strong></summary>

| 카테고리 | 스킬 |
|----------|------|
| Backend Patterns | `backend-patterns` - 아키텍처 패턴, 공통 패턴, AI 서비스 패턴, 프론트엔드 상호작용, 스택 선택 |
| DevOps Patterns | `devops-patterns` - CI/CD, 클라우드 가이드, Docker, Kubernetes, 모니터링, 보안 |
| DevOps Setup | `devops-setup` - Docker 설정 가이드 |

</details>

---

### 4. ai-development

> **STT 및 LLM을 위한 AI 통합** `v1.0.0`

Speech-to-Text 및 대규모 언어 모델 기능을 프로젝트에 원활하게 통합합니다.

#### 기능

- **STT (Speech-to-Text)**: 다국어 지원의 WhisperX 기반 음성 인식
- **LLM 통합**: OpenAI (GPT) 및 Anthropic (Claude) 지원
- **스트리밍**: 실시간 스트리밍 응답
- **JSON 모드**: 구조화된 JSON 출력 생성

#### 스킬

| 스킬 | 설명 |
|------|------|
| `stt` | 타임스탬프 및 언어 감지를 포함한 오디오 변환 |
| `llm` | 텍스트 생성, 요약 및 구조화된 응답 |

#### 지원 프로바이더

| 프로바이더 | 모델 |
|------------|------|
| OpenAI | GPT-4, GPT-4o-mini |
| Anthropic | Claude Sonnet |

---

## 설치 방법

### 방법 1: 마켓플레이스 (권장)

```bash
# Claude Code에 마켓플레이스 추가
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# 플러그인 설치
/plugin install public-commands
/plugin install frontend-development
/plugin install backend-development
/plugin install ai-development
```

### 방법 2: CLI 설치

```bash
# 스코프 지정 설치
claude plugin install public-commands@wigtn-plugins --scope user      # 글로벌 (기본값)
claude plugin install frontend-development@wigtn-plugins --scope project   # 팀과 공유
claude plugin install backend-development@wigtn-plugins --scope local     # 로컬 전용
```

### 방법 3: 수동 설치 (심볼릭 링크)

```bash
# 1. 저장소 클론
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn

# 2. 심볼릭 링크 생성
mkdir -p ~/.claude/plugins
ln -s ~/.claude-plugins/wigtn/plugins/public-commands ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/frontend-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/backend-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/ai-development ~/.claude/plugins/

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

### 백엔드 개발

```bash
# 백엔드 기능 고도화 및 아키텍처 개선
/backend 실시간 채팅 성능 개선

# CI/CD 및 배포 설정
/devops Docker + CI/CD
```

---

## 플러그인 구조

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/
│   └── plugin.json              # 마켓플레이스 메타데이터
├── plugins/
│   ├── public-commands/
│   │   ├── agents/
│   │   ├── commands/            # 3개 명령어
│   │   └── skills/              # 2개 스킬
│   ├── frontend-development/
│   │   ├── agents/
│   │   ├── commands/
│   │   └── skills/              # 13개 스킬
│   ├── backend-development/
│   │   ├── agents/
│   │   ├── commands/            # 2개 명령어
│   │   └── skills/              # 3개 스킬
│   └── ai-development/
│       ├── agents/
│       └── skills/              # 2개 스킬
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
