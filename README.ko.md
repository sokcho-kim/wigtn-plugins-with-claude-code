<div align="center">

[English](README.md) | [한국어](README.ko.md)

# WIGTN Coding

**아이디어에서 배포까지, 마찰 제로**

![Version](https://img.shields.io/badge/v2.0.0-Unified_Plugin-FF6B6B?style=for-the-badge)
![Agents](https://img.shields.io/badge/12-Agents-5A67D8?style=for-the-badge)
![Skills](https://img.shields.io/badge/29-Skills-00D4AA?style=for-the-badge)
![Styles](https://img.shields.io/badge/12+-Design_Styles-F59E0B?style=for-the-badge)

[![GitHub Stars](https://img.shields.io/github/stars/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Contributors](https://img.shields.io/github/contributors/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/commits/main)

</div>

---

## WIGTN Coding이란?

**WIGTN Coding**은 막연한 아이디어를 완성된 프로덕트로 만들어주는 단일 통합 Claude Code 플러그인입니다. 하나의 플러그인 — 접두사 없이 바로 사용.

```
"사용자 인증이 있는 SaaS 대시보드를 만들고 싶어"
  → /prd        (요구사항 정의)
  → digging     (분석)
  → /implement  (병렬 빌드)
  → /auto-commit (품질 검증 + 커밋)
```

**12개 에이전트**, **9개 명령어**, **29개 스킬**, **12+ 디자인 스타일** — 팀 기반 병렬 실행으로 3-5배 속도 향상.

---

## 한눈에 보기

| 구성 | 개수 | 주요 내용 |
|------|------|----------|
| 에이전트 | 12 | 병렬 코디네이터, 아키텍처 결정, 전문 개발자 |
| 명령어 | 9 | `/prd`, `/implement`, `/auto-commit`, `/backend`, `/devops`, `/stt`, `/llm`, `/add-feature`, `/component-scaffold` |
| 스킬 | 29 | 디자인 스타일, 상태 관리, 테스팅, 인증, 네비게이션, SEO 등 |
| 디자인 스타일 | 12+ | Editorial, Brutalist, Glassmorphism, Swiss Minimal, Bento Grid 등 |
| 훅 | 4 | 위험 명령 차단, 포맷팅 알림, 패턴 준수 확인 |

---

## 설치

```bash
# 1단계 — 마켓플레이스 소스 추가 (최초 1회)
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# 2단계 — 플러그인 설치
/install wigtn-coding
```

<details>
<summary>수동 설치 (대안)</summary>

```bash
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn
mkdir -p ~/.claude/plugins
ln -s ~/.claude-plugins/wigtn/plugins/wigtn-coding ~/.claude/plugins/

# 업데이트
git -C ~/.claude-plugins/wigtn pull
```

</details>

---

## 파이프라인

아이디어에서 커밋된 코드까지, 4단계 핵심 워크플로우:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   /prd "OAuth 기반 사용자 인증"                                   │
│   ├── PRD.md (구조화된 요구사항)                                   │
│   └── PLAN_{feature}.md (단계별 작업 계획)                         │
│                         ↓                                       │
│   digging (4-에이전트 병렬 분석)                                   │
│   ├── 완전성 — 빠진 요구사항이 있는가?                               │
│   ├── 실현가능성 — 실제로 구현 가능한가?                              │
│   ├── 보안 — 취약점은 없는가?                                      │
│   └── 일관성 — 요구사항끼리 모순은 없는가?                            │
│                         ↓                                       │
│   /implement --parallel                                         │
│   ├── DESIGN 단계 (3 에이전트 병렬)                                │
│   │   ├── PRD 탐색 + 품질 검증                                    │
│   │   ├── 아키텍처 결정 (MSA vs 모놀리스)                           │
│   │   └── 프로젝트 분석 + 갭 분석                                   │
│   ├── 사용자 승인 체크포인트                                        │
│   └── BUILD 단계 (팀 기반 병렬)                                    │
│       ├── 백엔드 팀  → backend-architect 에이전트                   │
│       ├── 프론트엔드 팀 → frontend-developer 에이전트               │
│       ├── AI 팀       → ai-agent (필요 시)                        │
│       └── 운영 팀      → devops 설정 (필요 시)                     │
│                         ↓                                       │
│   /auto-commit                                                  │
│   ├── 3-에이전트 병렬 코드 리뷰                                     │
│   ├── 품질 게이트 (점수 80+ = 자동 커밋)                            │
│   ├── 보안 제로 톨러런스 검사                                       │
│   └── 커밋 + 푸시                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 품질 게이트

| 점수 | 동작 |
|------|------|
| 80+ | 자동 커밋 |
| 60-79 | 자동 수정 후 재시도 |
| < 60 | 커밋 차단 |
| 보안 치명적 | 강제 FAIL (59점으로 제한) |

### 병렬 처리 속도 향상

| 단계 | 순차 처리 | 병렬 처리 | 속도 향상 |
|------|----------|----------|----------|
| digging | 4개 카테고리 순차 | 4 에이전트 병렬 | **4배** |
| DESIGN | 4단계 순차 | 3 에이전트 병렬 | **3배** |
| BUILD | 작업 순차 | 팀 기반 병렬 | **2-3배** |
| 리뷰 | 단일 리뷰어 | 3 에이전트 병렬 | **3배** |
| **전체 파이프라인** | **~20분** | **~6분** | **~3배** |

---

## 명령어

### 핵심 워크플로우

| 명령어 | 설명 |
|--------|------|
| `/prd <기능>` | 기능 아이디어로부터 PRD + 단계별 작업 계획 생성 |
| `/implement <기능>` | 자동 병렬 모드 감지로 설계 + 빌드 |
| `/implement --parallel` | 팀 기반 병렬 빌드 강제 실행 |
| `/auto-commit` | 병렬 품질 리뷰 + 안전 검증 + 자동 커밋 |

### 도메인별 명령어

| 명령어 | 설명 |
|--------|------|
| `/backend <작업>` | 백엔드 아키텍처 개선 및 기술 설계 |
| `/devops <작업>` | Docker, CI/CD, Kubernetes, 클라우드 배포 설정 |
| `/stt` | WhisperX 기반 음성-텍스트 변환 통합 |
| `/llm` | LLM API 통합 (OpenAI, Anthropic) |

### 크로스 플랫폼 명령어

| 명령어 | 설명 |
|--------|------|
| `/add-feature <기능>` | 기능 추가 — Web (Next.js) 또는 Mobile (React Native) 자동 감지 |
| `/component-scaffold <이름>` | 컴포넌트 스캐폴딩 — `package.json`에서 플랫폼 자동 감지 |

> 플랫폼 감지: package.json에 `next` / `react-dom` = Web, `react-native` / `expo` = Mobile.

---

## 에이전트 (12개)

| 에이전트 | 역할 |
|---------|------|
| `architecture-decision` | PRD 분석 후 MSA vs 모놀리식 vs 모듈러 모놀리스 결정 |
| `code-formatter` | 다중 언어 포맷팅 및 린팅 자동화 |
| `parallel-build-coordinator` | 의존성 그래프 + 레벨 기반 병렬 BUILD |
| `team-build-coordinator` | 팀 기반 병렬 빌드: 백엔드 + 프론트엔드 + AI + 운영 |
| `parallel-review-coordinator` | 3-에이전트 병렬 코드 리뷰 + 점수 병합 |
| `parallel-digging-coordinator` | 4-에이전트 병렬 PRD 분석 + 결과 병합 |
| `frontend-developer` | React / Next.js 컴포넌트 및 페이지 생성 |
| `design-discovery` | VS (Verbalized Sampling) 기법 기반 스타일 추천 |
| `backend-architect` | 백엔드 패턴, API 설계, 데이터베이스 스키마 |
| `mobile-developer` | React Native / Expo 컴포넌트 및 화면 생성 |
| `mobile-design-discovery` | 모바일 전용 디자인 디스커버리 (HIG + Material Design) |
| `ai-agent` | STT 및 LLM 통합 패턴 |

---

## 스킬 (29개)

### 핵심 (3개)

| 스킬 | 설명 |
|------|------|
| `code-review` | 다중 레벨 코드 리뷰와 품질 점수 (0-100). 레벨 1-4: 빠른 린트부터 심층 아키텍처 분석까지 |
| `digging` | PRD 취약점 분석 — 구현 전에 빈틈, 리스크, 약점을 발견 |
| `shared-memory` | 팀 협업을 위한 에이전트 간 공유 컨텍스트 |

### 웹 — 프론트엔드 (11개)

| 스킬 | 설명 |
|------|------|
| `design-skill` | 12+ 디자인 스타일 가이드 — 안티패턴과 구현 체크리스트 포함 |
| `nextjs-app-router-patterns` | Next.js 16+ App Router, Server Components, 스트리밍, 병렬 라우트 |
| `tailwind-design-system` | Tailwind CSS 기반 디자인 토큰, 컴포넌트 라이브러리, 반응형 패턴 |
| `component-library` | 프로덕션 레디 접근성 UI 컴포넌트 (Radix UI + Tailwind) |
| `react-hooks` | 10+ 커스텀 훅: useLocalStorage, useDebounce, useMediaQuery 등 |
| `forms-validation` | React Hook Form + Zod — 타입 안전 폼과 자동 유효성 검사 |
| `api-integration` | fetch, Axios, TanStack Query, 에러 핸들링, 재시도 로직 |
| `frontend-authentication` | NextAuth.js, Clerk, JWT, OAuth, RBAC, 보호된 라우트 |
| `seo` | Next.js 메타데이터 API, 구조화된 데이터 (JSON-LD), 사이트맵, robots.txt |
| `data-visualization` | Recharts, Chart.js, D3 — 라인 차트, 바 차트, 대시보드 |
| `realtime-features` | WebSocket, SSE, 폴링 — 채팅, 알림, 협업 편집 |

### 백엔드 (2개)

| 스킬 | 설명 |
|------|------|
| `backend-patterns` | 아키텍처 패턴, 스택 선택, AI 서비스 패턴, 공통 패턴 |
| `devops-patterns` | Docker, CI/CD, Kubernetes, 클라우드 가이드, 모니터링, 보안 |

### 모바일 (9개)

| 스킬 | 설명 |
|------|------|
| `mobile-design-skill` | iOS HIG + Material Design 3, 크로스 플랫폼 패턴 |
| `navigation` | Expo Router, React Navigation — 탭, 스택, 드로어, 딥 링킹 |
| `native-modules` | 카메라, 알림, 위치, 파일 시스템, 생체 인증 |
| `rn-styling` | StyleSheet + react-native-size-matters, 플랫폼별 패턴, 다크 모드 |
| `mobile-authentication` | 생체 인증, 소셜 로그인, Firebase Auth, Supabase, 보안 토큰 저장 |
| `performance-optimization` | FlatList 튜닝, 메모리 관리, 번들 크기, Hermes 엔진 |
| `responsive-design` | 폰, 태블릿, 폴더블 — 적응형 레이아웃과 스케일링 전략 |
| `deep-linking` | Universal Links (iOS), App Links (Android), Expo Router 딥 링킹 |
| `app-store-optimization` | App Store / Play Store 메타데이터, 스크린샷, 키워드, A/B 테스팅 |

### AI (2개)

| 스킬 | 설명 |
|------|------|
| `stt` | WhisperX 기반 음성 전사 — 타임스탬프 및 다국어 지원 |
| `llm` | OpenAI + Anthropic API 패턴 — 채팅, 텍스트 분석, 구조화된 출력, 스트리밍 |

### 크로스 플랫폼 (2개)

| 스킬 | 설명 |
|------|------|
| `state-management` | Zustand, Jotai, Redux Toolkit, React Query — Web + Mobile 통합, MMKV 영속화 및 오프라인 지원 |
| `testing` | Jest, RTL, RNTL, Playwright (Web E2E), Detox/Maestro (Mobile E2E) — Web + Mobile 통합 |

---

## 디자인 스타일 (12+)

`design-skill`에는 전문적으로 작성된 12개의 스타일 가이드가 포함되어 있습니다. 각 스타일 가이드는 철학, 타이포그래피, 레이아웃, 색상, 컴포넌트, 모션, 안티패턴을 다룹니다.

| 스타일 | 분위기 |
|--------|--------|
| **Editorial** | 강렬한 세리프 타이포그래피의 매거진 스타일 레이아웃 |
| **Brutalist** | 날것의 대담함, 파격적 — 모든 규칙을 깨는 디자인 |
| **Glassmorphism** | 블러와 투명도를 활용한 젖빛 유리 효과 |
| **Swiss Minimal** | 깔끔한 그리드 기반 디자인, 타이포그래피 중심 |
| **Neomorphism** | 부드러운 인셋/아웃셋 그림자의 소프트 UI |
| **Bento Grid** | 모던 카드 기반 그리드 레이아웃 (Apple 스타일) |
| **Dark Mode First** | 처음부터 다크 인터페이스로 설계 |
| **Minimal Corporate** | 깔끔하고 전문적인 비즈니스 감성 |
| **Retro Pixel** | CRT 효과, 모노스페이스 폰트, 터미널 향수 |
| **Organic Shapes** | 블롭 도형, 자연스러운 곡선, 자연의 색감 |
| **Maximalist** | 대담한 타이포그래피, 강렬한 색상, 겹겹이 쌓인 복잡함 |
| **3D Immersive** | CSS 3D 변환, 패럴랙스, 깊이감 효과 |

`design-discovery` 에이전트가 VS (Verbalized Sampling) 기법을 사용하여 프로젝트에 가장 적합한 스타일을 추천합니다.

---

## 훅 (안전 & 품질)

| 훅 | 트리거 | 기능 |
|----|--------|------|
| 위험 명령 차단 | `Bash` PreToolUse | `rm -rf /`, `git push --force`, `DROP TABLE` 등 차단 |
| 파이프라인 완료 | Stop 이벤트 | 푸시 전 변경사항 검토 알림 |
| 프론트엔드 포맷팅 | `Write\|Edit` PostToolUse | `.tsx`, `.jsx`, `.css` 파일에 prettier/eslint 실행 알림 |
| 백엔드 패턴 준수 | `Write\|Edit` PostToolUse | `.ts`, `.py`, `.go` 파일에 에러 핸들링, 입력 검증, 로깅 확인 알림 |

---

## 시나리오

### 시나리오 1: 풀스택 SaaS 앱을 처음부터

> "팀 협업 기능이 있는 프로젝트 관리 도구를 만들고 싶어"

```bash
# 1단계 — 요구사항 정의
/prd 칸반 보드와 팀 협업이 있는 프로젝트 관리 도구

# 2단계 — 계획 검토 및 정제 (digging 자동 실행)
# 4-에이전트 병렬 분석으로 빈틈 발견: "누락: 실시간 동기화, 역할 권한"

# 3단계 — 병렬로 모든 것을 빌드
/implement --parallel project-management
# 백엔드 팀: API 엔드포인트, Prisma 스키마, 인증 미들웨어
# 프론트엔드 팀: 칸반 보드, 팀 뷰, 대시보드
# 운영 팀: Dockerfile, GitHub Actions CI/CD

# 4단계 — 품질 검증 및 커밋
/auto-commit
# 3명의 리뷰어 점수: 87/100 → 자동 커밋
```

### 시나리오 2: 기존 앱에 기능 추가

> "Next.js 앱에 다크 모드를 추가해줘"

```bash
/add-feature 시스템 설정 감지 및 영구 토글이 있는 다크 모드
# 자동 감지: Next.js (Web) → Tailwind 다크 모드 패턴 사용
# 생성: ThemeProvider, 토글 컴포넌트, CSS 변수, localStorage 영속화
```

### 시나리오 3: 모바일 앱 개발

> "React Native로 피트니스 트래킹 앱을 만들어줘"

```bash
/prd 운동 기록, 진행 차트, Apple Health 동기화가 있는 피트니스 트래커

/implement fitness-tracker
# 아키텍처: Expo Router + Zustand + MMKV + React Query
# 모바일 특화: 생체 인증, 햅틱 피드백, 오프라인 동기화
# 생성: 화면, 컴포넌트, 네비게이션, 네이티브 모듈 통합
```

### 시나리오 4: 백엔드 API 개선

> "API가 느린데 데이터베이스 쿼리를 최적화해줘"

```bash
/backend 사용자 대시보드의 데이터베이스 쿼리 최적화 — 현재 응답시간 3초
# 분석: N+1 쿼리, 누락된 인덱스, 즉시 로딩 기회
# 구현: 쿼리 최적화, 캐싱 레이어, 커넥션 풀링
```

### 시나리오 5: 디자인 주도 랜딩 페이지

> "AI 스타트업 랜딩 페이지를 만들어줘"

```bash
/component-scaffold LandingPage
# design-discovery 에이전트 활성화 → 브랜드 성격에 대해 질문
# 추천: Glassmorphism (모던, 신뢰감) 또는 Editorial (권위, 명확함)
# 생성: Hero, Features, Pricing, CTA 섹션 — 선택한 스타일 적용
```

### 시나리오 6: DevOps 파이프라인 구성

> "모노레포에 Docker와 CI/CD를 설정해줘"

```bash
/devops pnpm 모노레포를 위한 Docker 멀티스테이지 빌드 + GitHub Actions CI/CD
# 생성: Dockerfile, docker-compose.yml, .github/workflows/ci.yml
# 포함: 캐싱, 테스트 스테이지, Vercel/Railway 배포
```

### 시나리오 7: AI 기능 통합

> "앱에 음성 명령 기능을 추가해줘"

```bash
/stt
# 생성: WhisperX 통합, 오디오 녹음, 전사 API
# 포함: 다국어 지원, 타임스탬프, 스트리밍 전사

/llm
# 생성: OpenAI/Anthropic API 통합, 프롬프트 관리
# 포함: 스트리밍 응답, JSON 모드, 에러 핸들링, 토큰 카운팅
```

### 시나리오 8: 크로스 플랫폼 컴포넌트

> "프로젝트에 SearchBar 컴포넌트를 만들어줘"

```bash
/component-scaffold SearchBar
# package.json에서 플랫폼 자동 감지:
#   - Next.js 프로젝트 → Tailwind + RTL 테스트 + Storybook이 포함된 React 컴포넌트
#   - Expo 프로젝트 → StyleSheet + 스케일링 + RNTL 테스트가 포함된 RN 컴포넌트
```

---

## 플러그인 구조

```
plugins/wigtn-coding/
├── .claude-plugin/
│   └── plugin.json           # 플러그인 메타데이터 (12 에이전트, 9 명령어, 29 스킬)
├── agents/                   # 12개 에이전트 정의
│   ├── architecture-decision.md
│   ├── code-formatter.md
│   ├── parallel-build-coordinator.md
│   ├── team-build-coordinator.md
│   ├── parallel-review-coordinator.md
│   ├── parallel-digging-coordinator.md
│   ├── frontend-developer.md
│   ├── design-discovery.md
│   ├── backend-architect.md
│   ├── mobile-developer.md
│   ├── mobile-design-discovery.md
│   └── ai-agent.md
├── commands/                 # 9개 사용자 실행 명령어
│   ├── prd.md
│   ├── implement.md
│   ├── auto-commit.md
│   ├── backend.md
│   ├── devops.md
│   ├── stt.md
│   ├── llm.md
│   ├── add-feature.md
│   └── component-scaffold.md
├── skills/                   # 29개 스킬 + 참조 파일
│   ├── code-review/          # 다중 레벨 리뷰 (levels/)
│   ├── digging/
│   ├── shared-memory/
│   ├── design-skill/         # 12개 스타일 가이드 (styles/), 공통 패턴
│   ├── nextjs-app-router-patterns/
│   ├── tailwind-design-system/
│   ├── component-library/
│   ├── react-hooks/
│   ├── forms-validation/
│   ├── api-integration/
│   ├── frontend-authentication/   # 웹 인증 (NextAuth, Clerk, JWT)
│   ├── seo/
│   ├── data-visualization/
│   ├── realtime-features/
│   ├── backend-patterns/     # 아키텍처 참조 (references/)
│   ├── devops-patterns/      # DevOps 참조 (references/)
│   ├── mobile-design-skill/  # iOS HIG + Material Design (patterns/)
│   ├── navigation/
│   ├── native-modules/
│   ├── rn-styling/
│   ├── mobile-authentication/    # 모바일 인증 (생체인증, 소셜 로그인)
│   ├── performance-optimization/
│   ├── responsive-design/
│   ├── deep-linking/
│   ├── app-store-optimization/
│   ├── state-management/     # 통합 Web + Mobile (patterns/)
│   ├── testing/              # 통합 Web + Mobile
│   ├── stt/
│   └── llm/
└── hooks/
    └── hooks.json            # 4개 훅 (안전 + 품질)
```

---

## 기술 스택

| 도메인 | 기술 |
|--------|------|
| **프론트엔드** | React 19, Next.js 16+, Tailwind CSS, Radix UI, React Hook Form, Zod |
| **백엔드** | NestJS, Express, Fastify, FastAPI, Prisma, TypeORM, Drizzle |
| **모바일** | React Native 0.73+, Expo SDK 52+, Expo Router, React Navigation |
| **데이터베이스** | PostgreSQL, MySQL, MongoDB, SQLite |
| **상태 관리** | Zustand, Jotai, Redux Toolkit, React Query, MMKV |
| **테스팅** | Jest, RTL, RNTL, Playwright, Detox, Maestro, MSW |
| **DevOps** | Docker, Kubernetes, GitHub Actions, Vercel, Railway |
| **AI** | WhisperX (STT), OpenAI GPT, Anthropic Claude |
| **디자인** | 12+ 스타일 시스템, VS 기반 스타일 디스커버리, HIG, Material Design 3 |

---

## 기여하기

1. 레포지토리를 **포크**합니다
2. 기능 브랜치를 **생성**합니다 (`git checkout -b feature/amazing-skill`)
3. 변경사항을 **커밋**합니다 (`git commit -m 'feat: Add amazing skill'`)
4. 브랜치에 **푸시**합니다 (`git push origin feature/amazing-skill`)
5. **Pull Request**를 생성합니다

---

## 라이선스

이 프로젝트는 **MIT 라이선스** 하에 배포됩니다 — 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

<div align="center">

**Made with Claude Code by [WIGTN Crew](https://github.com/wigtn)**

</div>
