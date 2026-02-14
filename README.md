<div align="center">

[English](README.md) | [한국어](README.ko.md)

# WIGTN Coding

**From Idea to Deploy, Zero Friction**

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

## What is WIGTN Coding?

**WIGTN Coding** is a single, unified Claude Code plugin that takes you from a rough idea to a deployed product with zero friction. One plugin — no prefixes needed.

```
"I want to build a SaaS dashboard with user auth"
  → /prd        (requirements)
  → digging     (analysis)
  → /implement  (parallel build)
  → /auto-commit (quality gate + commit)
```

**12 agents**, **9 commands**, **29 skills**, **12+ design styles** — all working together with team-based parallel execution for 3-5x speedup.

---

## At a Glance

| What | Count | Highlights |
|------|-------|------------|
| Agents | 12 | Parallel coordinators, architecture decisions, specialized developers |
| Commands | 9 | `/prd`, `/implement`, `/auto-commit`, `/backend`, `/devops`, `/stt`, `/llm`, `/add-feature`, `/component-scaffold` |
| Skills | 29 | Design styles, state management, testing, auth, navigation, SEO, etc. |
| Design Styles | 12+ | Editorial, Brutalist, Glassmorphism, Swiss Minimal, Bento Grid, and more |
| Hooks | 4 | Dangerous command blocking, formatting reminders, pattern compliance |

---

## Installation

```bash
# Step 1 — Add marketplace source (first time only)
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# Step 2 — Install plugin
/install wigtn-coding
```

<details>
<summary>Manual install (alternative)</summary>

```bash
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn
mkdir -p ~/.claude/plugins
ln -s ~/.claude-plugins/wigtn/plugins/wigtn-coding ~/.claude/plugins/

# Update
git -C ~/.claude-plugins/wigtn pull
```

</details>

---

## The Pipeline

The core workflow is a 4-step pipeline that goes from idea to committed code:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   /prd "user authentication with OAuth"                         │
│   ├── PRD.md (structured requirements)                          │
│   └── PLAN_{feature}.md (phased task plan)                      │
│                         ↓                                       │
│   digging (4-agent parallel analysis)                           │
│   ├── Completeness — missing requirements?                      │
│   ├── Feasibility — can we actually build this?                 │
│   ├── Security — any vulnerabilities?                           │
│   └── Consistency — do requirements contradict?                 │
│                         ↓                                       │
│   /implement --parallel                                         │
│   ├── DESIGN Phase (3 agents parallel)                          │
│   │   ├── PRD search + quality gate                             │
│   │   ├── Architecture decision (MSA vs Monolith)               │
│   │   └── Project analysis + gap analysis                       │
│   ├── User approval checkpoint                                  │
│   └── BUILD Phase (team-based parallel)                         │
│       ├── Backend team  → backend-architect agent               │
│       ├── Frontend team → frontend-developer agent              │
│       ├── AI team       → ai-agent (when needed)                │
│       └── Ops team      → devops setup (when needed)            │
│                         ↓                                       │
│   /auto-commit                                                  │
│   ├── 3-agent parallel code review                              │
│   ├── Quality Gate (score 80+ = auto-commit)                    │
│   ├── Security zero-tolerance check                             │
│   └── Commit + push                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Quality Gate

| Score | Action |
|-------|--------|
| 80+ | Auto-commit |
| 60-79 | Auto-fix then retry |
| < 60 | Block commit |
| Security Critical | Force FAIL (capped at 59) |

### Parallel Speedup

| Stage | Sequential | Parallel | Speedup |
|-------|-----------|----------|---------|
| digging | 4 categories serial | 4 agents parallel | **4x** |
| DESIGN | 4 steps serial | 3 agents parallel | **3x** |
| BUILD | tasks serial | team-based parallel | **2-3x** |
| Review | single reviewer | 3 agents parallel | **3x** |
| **Full Pipeline** | **~20 min** | **~6 min** | **~3x** |

---

## Commands

### Core Workflow

| Command | Description |
|---------|-------------|
| `/prd <feature>` | Generate PRD + phased task plan from a feature idea |
| `/implement <feature>` | Design + build with automatic parallel mode detection |
| `/implement --parallel` | Force parallel team-based build |
| `/auto-commit` | Parallel quality review + safety gate + auto-commit |

### Domain-Specific

| Command | Description |
|---------|-------------|
| `/backend <task>` | Backend architecture enhancement and technical planning |
| `/devops <task>` | Docker, CI/CD, Kubernetes, cloud deployment setup |
| `/stt` | Speech-to-Text integration with WhisperX |
| `/llm` | LLM API integration (OpenAI, Anthropic) |

### Cross-Platform

| Command | Description |
|---------|-------------|
| `/add-feature <feature>` | Add a feature — auto-detects Web (Next.js) or Mobile (React Native) |
| `/component-scaffold <Name>` | Scaffold a component — auto-detects platform from `package.json` |

> Platform detection: `next` / `react-dom` in package.json = Web, `react-native` / `expo` = Mobile.

---

## Agents (12)

| Agent | Role |
|-------|------|
| `architecture-decision` | Analyzes PRD to decide MSA vs Monolithic vs Modular Monolith |
| `code-formatter` | Multi-language formatting and linting automation |
| `parallel-build-coordinator` | Dependency graph + level-based parallel BUILD |
| `team-build-coordinator` | Team-based parallel build: Backend + Frontend + AI + Ops |
| `parallel-review-coordinator` | 3-agent parallel code review with score merge |
| `parallel-digging-coordinator` | 4-agent parallel PRD analysis with result merge |
| `frontend-developer` | React / Next.js component and page generation |
| `design-discovery` | VS (Verbalized Sampling) style recommendation |
| `backend-architect` | Backend patterns, API design, database schema |
| `mobile-developer` | React Native / Expo component and screen generation |
| `mobile-design-discovery` | Mobile-specific design discovery (HIG + Material Design) |
| `ai-agent` | STT and LLM integration patterns |

---

## Skills (29)

### Core (3)

| Skill | Description |
|-------|-------------|
| `code-review` | Multi-level code review with quality scoring (0-100). Levels 1-4 from quick lint to deep architecture analysis |
| `digging` | PRD vulnerability analysis — finds gaps, risks, and weaknesses before implementation |
| `shared-memory` | Cross-agent shared context for team coordination |

### Web — Frontend (11)

| Skill | Description |
|-------|-------------|
| `design-skill` | 12+ design style guides with anti-patterns and implementation checklists |
| `nextjs-app-router-patterns` | Next.js 16+ App Router, Server Components, streaming, parallel routes |
| `tailwind-design-system` | Design tokens, component libraries, responsive patterns with Tailwind CSS |
| `component-library` | Production-ready accessible UI components (Radix UI + Tailwind) |
| `react-hooks` | 10+ custom hooks: useLocalStorage, useDebounce, useMediaQuery, etc. |
| `forms-validation` | React Hook Form + Zod — type-safe forms with automatic validation |
| `api-integration` | fetch, Axios, TanStack Query, error handling, retry logic |
| `frontend-authentication` | NextAuth.js, Clerk, custom JWT, OAuth, RBAC, protected routes |
| `seo` | Next.js metadata API, structured data (JSON-LD), sitemaps, robots.txt |
| `data-visualization` | Recharts, Chart.js, D3 — line charts, bar charts, dashboards |
| `realtime-features` | WebSocket, SSE, polling — chat, notifications, collaborative editing |

### Backend (2)

| Skill | Description |
|-------|-------------|
| `backend-patterns` | Architecture patterns, stack selection, AI service patterns, common patterns |
| `devops-patterns` | Docker, CI/CD, Kubernetes, cloud guides, monitoring, security |

### Mobile (9)

| Skill | Description |
|-------|-------------|
| `mobile-design-skill` | iOS HIG + Material Design 3, cross-platform patterns |
| `navigation` | Expo Router, React Navigation — tabs, stacks, drawers, deep linking |
| `native-modules` | Camera, notifications, location, file system, biometrics |
| `rn-styling` | StyleSheet + react-native-size-matters, platform-specific patterns, dark mode |
| `mobile-authentication` | Biometrics, social login, Firebase Auth, Supabase, secure token storage |
| `performance-optimization` | FlatList tuning, memory management, bundle size, Hermes engine |
| `responsive-design` | Phones, tablets, foldables — adaptive layouts and scaling strategies |
| `deep-linking` | Universal Links (iOS), App Links (Android), Expo Router deep linking |
| `app-store-optimization` | App Store / Play Store metadata, screenshots, keywords, A/B testing |

### AI (2)

| Skill | Description |
|-------|-------------|
| `stt` | WhisperX-powered transcription with timestamps and multi-language support |
| `llm` | OpenAI + Anthropic API patterns — chat, text analysis, structured output, streaming |

### Cross-Platform (2)

| Skill | Description |
|-------|-------------|
| `state-management` | Zustand, Jotai, Redux Toolkit, React Query — unified Web + Mobile with MMKV persistence and offline support |
| `testing` | Jest, RTL, RNTL, Playwright (Web E2E), Detox/Maestro (Mobile E2E) — unified Web + Mobile |

---

## Design Styles (12+)

The `design-skill` includes 12 professionally crafted style guides. Each style guide covers philosophy, typography, layout, color, components, motion, and anti-patterns.

| Style | Vibe |
|-------|------|
| **Editorial** | Magazine-inspired layouts with strong serif typography |
| **Brutalist** | Raw, bold, unconventional — breaks all the rules |
| **Glassmorphism** | Frosted glass effects with blur and transparency |
| **Swiss Minimal** | Clean grid-based design, typography-focused |
| **Neomorphism** | Soft UI with subtle inset/outset shadows |
| **Bento Grid** | Modern card-based grid layouts (Apple-inspired) |
| **Dark Mode First** | Designed for dark interfaces from the ground up |
| **Minimal Corporate** | Clean, professional business aesthetic |
| **Retro Pixel** | CRT effects, monospace fonts, terminal nostalgia |
| **Organic Shapes** | Blob shapes, natural curves, earthy tones |
| **Maximalist** | Bold typography, intense colors, layered complexity |
| **3D Immersive** | CSS 3D transforms, parallax, depth effects |

The `design-discovery` agent uses VS (Verbalized Sampling) technique to recommend the best style for your project context.

---

## Hooks (Safety & Quality)

| Hook | Trigger | What It Does |
|------|---------|-------------|
| Dangerous Command Blocker | `Bash` PreToolUse | Blocks `rm -rf /`, `git push --force`, `DROP TABLE`, etc. |
| Pipeline Completion | Stop event | Reminds you to review changes before pushing |
| Frontend Formatting | `Write\|Edit` PostToolUse | Reminds to run prettier/eslint on `.tsx`, `.jsx`, `.css` files |
| Backend Pattern Compliance | `Write\|Edit` PostToolUse | Reminds to verify error handling, input validation, logging on `.ts`, `.py`, `.go` files |

---

## Scenarios

### Scenario 1: Full-Stack SaaS App from Scratch

> "I want to build a project management tool with team collaboration"

```bash
# Step 1 — Define requirements
/prd project management tool with kanban boards and team collaboration

# Step 2 — Review and refine the plan (runs digging automatically)
# 4-agent parallel analysis catches gaps: "Missing: real-time sync, role permissions"

# Step 3 — Build everything in parallel
/implement --parallel project-management
# Backend team: API endpoints, Prisma schema, auth middleware
# Frontend team: Kanban board, team views, dashboard
# Ops team: Dockerfile, GitHub Actions CI/CD

# Step 4 — Quality check and commit
/auto-commit
# 3 reviewers score: 87/100 → Auto-commit
```

### Scenario 2: Add a Feature to an Existing App

> "Add dark mode to my Next.js app"

```bash
/add-feature dark mode with system preference detection and persistent toggle
# Auto-detects: Next.js (Web) → uses Tailwind dark mode patterns
# Creates: ThemeProvider, toggle component, CSS variables, localStorage persistence
```

### Scenario 3: Mobile App Development

> "Build a fitness tracking app with React Native"

```bash
/prd fitness tracker with workout logging, progress charts, and Apple Health sync

/implement fitness-tracker
# Architecture: Expo Router + Zustand + MMKV + React Query
# Mobile-specific: biometric auth, haptic feedback, offline sync
# Generates: screens, components, navigation, native module integration
```

### Scenario 4: Backend API Enhancement

> "My API is slow. Help me optimize the database queries."

```bash
/backend optimize database queries for user dashboard — currently 3s response time
# Analyzes: N+1 queries, missing indexes, eager loading opportunities
# Implements: query optimization, caching layer, connection pooling
```

### Scenario 5: Design-Driven Landing Page

> "Create a landing page for my AI startup"

```bash
/component-scaffold LandingPage
# design-discovery agent activates → asks about brand personality
# Recommends: Glassmorphism (modern, trust) or Editorial (authority, clarity)
# Generates: Hero, Features, Pricing, CTA sections with chosen style
```

### Scenario 6: DevOps Pipeline Setup

> "Set up Docker and CI/CD for my monorepo"

```bash
/devops Docker multi-stage build + GitHub Actions CI/CD for pnpm monorepo
# Generates: Dockerfile, docker-compose.yml, .github/workflows/ci.yml
# Includes: caching, test stage, deployment to Vercel/Railway
```

### Scenario 7: AI Feature Integration

> "Add voice commands to my app"

```bash
/stt
# Generates: WhisperX integration, audio recording, transcription API
# Includes: multi-language support, timestamps, streaming transcription

/llm
# Generates: OpenAI/Anthropic API integration, prompt management
# Includes: streaming responses, JSON mode, error handling, token counting
```

### Scenario 8: Cross-Platform Component

> "Create a SearchBar component for my project"

```bash
/component-scaffold SearchBar
# Auto-detects platform from package.json:
#   - Next.js project → React component with Tailwind, RTL tests, Storybook
#   - Expo project → RN component with StyleSheet, scaling, RNTL tests
```

---

## Plugin Structure

```
plugins/wigtn-coding/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata (12 agents, 9 commands, 29 skills)
├── agents/                   # 12 agent definitions
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
├── commands/                 # 9 user-invocable commands
│   ├── prd.md
│   ├── implement.md
│   ├── auto-commit.md
│   ├── backend.md
│   ├── devops.md
│   ├── stt.md
│   ├── llm.md
│   ├── add-feature.md
│   └── component-scaffold.md
├── skills/                   # 29 skills with reference files
│   ├── code-review/          # Multi-level review (levels/)
│   ├── digging/
│   ├── shared-memory/
│   ├── design-skill/         # 12 style guides (styles/), common patterns
│   ├── nextjs-app-router-patterns/
│   ├── tailwind-design-system/
│   ├── component-library/
│   ├── react-hooks/
│   ├── forms-validation/
│   ├── api-integration/
│   ├── frontend-authentication/   # Web auth (NextAuth, Clerk, JWT)
│   ├── seo/
│   ├── data-visualization/
│   ├── realtime-features/
│   ├── backend-patterns/     # Architecture references (references/)
│   ├── devops-patterns/      # DevOps references (references/)
│   ├── mobile-design-skill/  # iOS HIG + Material Design (patterns/)
│   ├── navigation/
│   ├── native-modules/
│   ├── rn-styling/
│   ├── mobile-authentication/    # Mobile auth (biometrics, social login)
│   ├── performance-optimization/
│   ├── responsive-design/
│   ├── deep-linking/
│   ├── app-store-optimization/
│   ├── state-management/     # Unified Web + Mobile (patterns/)
│   ├── testing/              # Unified Web + Mobile
│   ├── stt/
│   └── llm/
└── hooks/
    └── hooks.json            # 4 hooks (safety + quality)
```

---

## Tech Stack Coverage

| Domain | Technologies |
|--------|-------------|
| **Frontend** | React 19, Next.js 16+, Tailwind CSS, Radix UI, React Hook Form, Zod |
| **Backend** | NestJS, Express, Fastify, FastAPI, Prisma, TypeORM, Drizzle |
| **Mobile** | React Native 0.73+, Expo SDK 52+, Expo Router, React Navigation |
| **Database** | PostgreSQL, MySQL, MongoDB, SQLite |
| **State** | Zustand, Jotai, Redux Toolkit, React Query, MMKV |
| **Testing** | Jest, RTL, RNTL, Playwright, Detox, Maestro, MSW |
| **DevOps** | Docker, Kubernetes, GitHub Actions, Vercel, Railway |
| **AI** | WhisperX (STT), OpenAI GPT, Anthropic Claude |
| **Design** | 12+ style systems, VS-based style discovery, HIG, Material Design 3 |

---

## Contributing

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/amazing-skill`)
3. **Commit** your changes (`git commit -m 'feat: Add amazing skill'`)
4. **Push** to the branch (`git push origin feature/amazing-skill`)
5. **Open** a Pull Request

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with Claude Code by [WIGTN Crew](https://github.com/wigtn)**

</div>
