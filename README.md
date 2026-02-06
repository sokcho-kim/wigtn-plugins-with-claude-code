<div align="center">

[English](README.md) | [한국어](README.ko.md)

# WIGTN Claude Code Plugin Tools

**From Idea to Deploy, No Friction**

![Ship Fast](https://img.shields.io/badge/🚀_Ship-Fast-FF6B6B?style=for-the-badge)
![One Command](https://img.shields.io/badge/One_Command-Full_Feature-5A67D8?style=for-the-badge)
![No Boilerplate](https://img.shields.io/badge/No-Boilerplate-00D4AA?style=for-the-badge)

[![GitHub Stars](https://img.shields.io/github/stars/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![Contributors](https://img.shields.io/github/contributors/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/graphs/contributors)
[![Last Commit](https://img.shields.io/github/last-commit/wigtn/wigtn-plugins-with-claude-code?style=flat-square)](https://github.com/wigtn/wigtn-plugins-with-claude-code/commits/main)

</div>

---

## Overview

**WIGTN Claude Code Plugin Tools** is a collection of plugins designed to maximize AI-powered development capabilities with Claude Code. Our goal is to enable **Vibe Coding** — a seamless development experience where you can go from idea to production with minimal friction.

### Key Features

- **End-to-End Workflow**: From PRD generation to implementation and auto-commit
- **Agent Teams Parallel Execution** `v0.2.0`: 3-5x speedup across the entire pipeline
- **Design-First Approach**: 12+ professional design styles for unique UI/UX
- **Backend & DevOps**: Complete backend architecture with CI/CD pipelines
- **AI Integration**: STT and LLM capabilities for intelligent applications
- **Quality Assurance**: Built-in code review and automatic formatting

---

## Plugins

### 1. public-commands

> **Core Development Workflow Plugin** `v1.1.0`

The essential plugin that powers your entire development lifecycle with intelligent automation and **Agent Teams parallel execution**.

#### Workflow Pipeline

```
Sequential:
  /prd → digging → /implement → /auto-commit

Parallel (v0.2.0):
  /prd → digging(4x) → /implement(3x DESIGN + 2-3x BUILD) → /auto-commit(3x)
```

#### 1-Click Complete Workflow

Generate PRD -> Auto-create Task Plan -> Phase-based Implementation -> Quality-gated Commit

```
┌─────────────────────────────────────────────────────────────┐
│  /prd                                                       │
│  ├── PRD.md (Requirements)                                  │
│  └── PLAN_{feature}.md (Task Plan with Phases)              │
│                     ↓                                       │
│  digging (4 agents parallel: 4x speedup)                    │
│  └── Completeness + Feasibility + Security + Consistency    │
│                     ↓                                       │
│  /implement --parallel                                      │
│  ├── DESIGN (3 agents parallel: 3x speedup)                 │
│  ├── BUILD (level-based parallel: 2-3x speedup)             │
│  └── --full-stack: Cross-Plugin parallel (Backend+Frontend) │
│                     ↓                                       │
│  /auto-commit                                               │
│  ├── Parallel Review (3 agents: 3x speedup)                 │
│  ├── Quality Gate (Score 80+)                               │
│  ├── Security Zero-Tolerance                                │
│  └── Commit + Push                                          │
└─────────────────────────────────────────────────────────────┘
```

#### Commands

| Command | Description |
|---------|-------------|
| `/prd <feature>` | Generate PRD + Task Plan (PLAN_{feature}.md) |
| `/implement <feature>` | Phase-based implementation with parallel support |
| `/implement --parallel` | Force parallel mode (auto-detected by default) |
| `/implement --full-stack` | Cross-Plugin parallel (Backend + Frontend + Mobile) |
| `/auto-commit` | Parallel Quality Gate + Safety Guard + Auto-commit |

#### Skills & Agents

| Type | Name | Description |
|------|------|-------------|
| Skill | `code-review` | Code quality scoring (0-100) with parallel review mode |
| Skill | `digging` | PRD vulnerability analysis with 4-agent parallel analysis |
| Agent | `architecture-decision` | MSA vs Monolithic architecture decision |
| Agent | `code-formatter` | Multi-language formatting and linting automation |
| Agent | `parallel-build-coordinator` | BUILD Phase dependency graph + level-based parallel |
| Agent | `parallel-review-coordinator` | 3-agent parallel code review + score merge |
| Agent | `parallel-digging-coordinator` | 4-agent parallel PRD analysis + result merge |

#### Quality Gate System

| Score | Grade | Action |
|-------|-------|--------|
| 80+ | A/B | Auto-commit |
| 60-79 | C/D | Auto-fix then retry |
| < 60 | F | Block commit |
| Security Critical | - | Force FAIL (score capped at 59) |

#### Parallel Speedup Summary

| Component | Sequential | Parallel | Speedup |
|-----------|-----------|----------|---------|
| digging | 4 categories serial | 4 agents parallel | **4x** |
| /implement DESIGN | 4 steps serial | 3 agents parallel | **3x** |
| /implement BUILD | Tasks serial | Level-based parallel | **2-3x** |
| /auto-commit review | Single reviewer | 3 agents parallel | **3x** |
| **Full Pipeline** | **15-20 min** | **5-7 min** | **~3x** |

> See [Agent Teams Parallel Execution Guide](docs/agent-teams-parallel-execution.md) for detailed documentation.

---

### 2. frontend-development

> **Professional Frontend Development Solution** `v1.1.0`

Complete frontend development toolkit with 12+ design styles to create unique, non-generic AI designs.

#### Highlights

- **12+ Design Styles**: Editorial, Brutalist, Glassmorphism, Swiss Minimal, Neomorphism, Bento Grid, and more
- **Next.js 16 & React 19** support
- **State Management**: Zustand, Jotai, Valtio patterns
- **13 Specialized Skills** for comprehensive frontend development

#### Command

| Command | Description |
|---------|-------------|
| `/component-scaffold` | Generate responsive components with TypeScript, tests, and Storybook |

#### Design Styles

| Style | Description |
|-------|-------------|
| Editorial | Magazine-inspired layouts with strong typography |
| Brutalist | Raw, bold, unconventional designs |
| Glassmorphism | Frosted glass effects with blur and transparency |
| Swiss Minimal | Clean, grid-based, typography-focused |
| Neomorphism | Soft UI with subtle shadows |
| Bento Grid | Modern grid-based card layouts |
| Dark Mode First | Optimized for dark interfaces |
| Minimal Corporate | Clean professional business look |

<details>
<summary><strong>View all 13 skills</strong></summary>

| Category | Skills |
|----------|--------|
| Design | `design-skill`, `tailwind-design-system` |
| React | `react-state-management`, `react-hooks`, `component-library` |
| Next.js | `nextjs-app-router-patterns` |
| Features | `api-integration`, `authentication`, `forms-validation`, `realtime-features` |
| Quality | `frontend-test`, `seo`, `data-visualization` |

</details>

---

### 3. backend-development

> **Backend Architecture & DevOps Solution** `v2.0.0`

Complete backend development toolkit with beginner-friendly architecture guides and DevOps automation.

#### Highlights

- **Beginner Friendly**: Step-by-step guides with clear explanations
- **Full Stack**: NestJS, Prisma, PostgreSQL, JWT
- **DevOps Ready**: Docker, Kubernetes, CI/CD pipelines
- **Safe by Design**: Auto-detection prevents overwrites

#### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/backend` | Backend enhancement and architecture improvement | `/backend Improve real-time chat performance` |
| `/devops` | CI/CD and deployment infrastructure setup | `/devops Docker + CI/CD` |

#### Tech Stack

| Category | Options |
|----------|---------|
| Framework | NestJS, Express, Fastify, FastAPI |
| Database | PostgreSQL, MySQL, MongoDB, SQLite |
| ORM | Prisma, TypeORM, Drizzle |
| DevOps | Docker, Kubernetes, GitHub Actions |

<details>
<summary><strong>View all skills</strong></summary>

| Category | Skills |
|----------|--------|
| Backend Patterns | `backend-patterns` - Architecture patterns, common patterns, AI service patterns, frontend interactions, stack selection |
| DevOps Patterns | `devops-patterns` - CI/CD, cloud guides, Docker, Kubernetes, monitoring, security |
| DevOps Setup | `devops-setup` - Docker setup guides |

</details>

---

### 4. mobile-development

> **Complete Mobile Development Solution** `v1.0.0`

Build production-ready React Native applications with Expo and React Native CLI support.

#### Highlights

- **React Native CLI & Expo**: Full support for both development approaches
- **Design Systems**: iOS HIG, Material Design 3, VS-based design discovery
- **11 Specialized Skills**: Navigation, authentication, native modules, testing, and more
- **Performance Focused**: FlatList optimization, memory management, startup time

#### Commands

| Command | Description |
|---------|-------------|
| `/component-scaffold` | Generate complete RN component with types, tests |
| `/add-feature` | Add new feature with proper architecture |

#### Tech Stack

| Category | Support |
|----------|---------|
| Frameworks | Expo SDK 52+, React Native 0.73+ |
| Navigation | Expo Router, React Navigation v6 |
| State | Zustand + MMKV, React Query |
| Styling | StyleSheet + react-native-size-matters |

<details>
<summary><strong>View all 11 skills</strong></summary>

| Category | Skills |
|----------|--------|
| Design | `mobile-design`, `rn-styling`, `responsive-design` |
| Navigation | `navigation`, `deep-linking` |
| Data | `mobile-state-management`, `mobile-authentication` |
| Native | `native-modules` |
| Quality | `mobile-testing`, `mobile-performance`, `app-store-optimization` |

</details>

---

### 5. ai-development

> **AI Integration for STT and LLM** `v1.0.0`

Seamlessly integrate Speech-to-Text and Large Language Model capabilities into your projects.

#### Features

- **STT (Speech-to-Text)**: WhisperX-powered transcription with multi-language support
- **LLM Integration**: OpenAI (GPT) and Anthropic (Claude) support
- **Streaming**: Real-time streaming responses
- **JSON Mode**: Structured JSON output generation

#### Skills

| Skill | Description |
|-------|-------------|
| `stt` | Audio transcription with timestamps and language detection |
| `llm` | Text generation, summarization, and structured responses |

#### Supported Providers

| Provider | Models |
|----------|--------|
| OpenAI | GPT-4, GPT-4o-mini |
| Anthropic | Claude Sonnet |

---

## Installation

### Option 1: Marketplace (Recommended)

```bash
# Add marketplace to Claude Code
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# Install plugins
/plugin install public-commands
/plugin install frontend-development
/plugin install backend-development
/plugin install mobile-development
/plugin install ai-development
```

### Option 2: CLI Installation

```bash
# Install with scope
claude plugin install public-commands@wigtn-plugins --scope user      # Global (default)
claude plugin install frontend-development@wigtn-plugins --scope project   # Team shared
claude plugin install backend-development@wigtn-plugins --scope local     # Local only
```

### Option 3: Manual Installation (Symlink)

```bash
# 1. Clone repository
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn

# 2. Create symlinks
mkdir -p ~/.claude/plugins
ln -s ~/.claude-plugins/wigtn/plugins/public-commands ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/frontend-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/backend-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/mobile-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/ai-development ~/.claude/plugins/

# Update plugins
git -C ~/.claude-plugins/wigtn pull
```

### Installation Scopes

| Scope | Settings File | Use Case |
|-------|---------------|----------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects |
| `project` | `.claude/settings.json` | Team plugins via version control |
| `local` | `.claude/settings.local.json` | Local only, gitignored |

---

## Quick Start

### Complete Development Workflow (1-Click Complete)

```bash
# 1. Generate PRD + Task Plan from your idea
/prd user-authentication
# Creates: docs/prd/user-authentication.md
#          docs/todo_plan/PLAN_user-authentication.md

# 2. Analyze and improve the plan (auto-parallel: 4x speedup)
# The 'digging' skill runs 4 agents in parallel

# 3. Implement with parallel execution (auto-detected)
/implement user-authentication
# DESIGN (3 agents parallel) → BUILD (level-based parallel)

# 3-alt. Full-stack parallel (Backend + Frontend simultaneously)
/implement --full-stack user-authentication

# 4. Auto-commit with parallel review (3x speedup)
/auto-commit
# Parallel Review → Quality Gate → Safety Guard → Commit + Push
```

### Frontend Development

```bash
# Scaffold a component with design style
/component-scaffold Dashboard --style=bento-grid

# Generate form component
/component-scaffold ContactForm --style=glassmorphism
```

### Backend Development

```bash
# Backend enhancement and architecture improvement
/backend 실시간 채팅 성능 개선

# Setup CI/CD and deployment
/devops Docker + CI/CD
```

---

## Plugin Structure

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/
│   ├── plugin.json              # Marketplace metadata (v0.2.0)
│   └── marketplace.json         # Marketplace registry
├── docs/
│   └── agent-teams-parallel-execution.md  # Parallel execution guide
├── plugins/
│   ├── public-commands/
│   │   ├── agents/              # 5 agents (3 new parallel coordinators)
│   │   ├── commands/            # 3 commands
│   │   └── skills/              # 2 skills
│   ├── frontend-development/
│   │   ├── agents/
│   │   ├── commands/
│   │   └── skills/              # 13 skills
│   ├── backend-development/
│   │   ├── agents/
│   │   ├── commands/            # 2 commands
│   │   └── skills/              # 3 skills
│   ├── mobile-development/
│   │   ├── agents/              # 2 agents
│   │   ├── commands/            # 2 commands
│   │   └── skills/              # 11 skills
│   └── ai-development/
│       ├── agents/
│       └── skills/              # 2 skills
├── README.md
├── README.ko.md
└── LICENSE
```

---

## Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/amazing-plugin`)
3. **Commit** your changes (`git commit -m 'feat: Add amazing plugin'`)
4. **Push** to the branch (`git push origin feature/amazing-plugin`)
5. **Open** a Pull Request

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by [WIGTN Crew](https://github.com/wigtn)**

</div>
