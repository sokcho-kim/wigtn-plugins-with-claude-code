<div align="center">

[English](README.md) | [한국어](README.ko.md)

# WIGTN Claude Code Plugin Tools

**Boost your AI-powered development capabilities with Claude Code**

*Vibe Coding for Rapid Project Creation*

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
- **Design-First Approach**: 12+ professional design styles for unique UI/UX
- **Full-Stack Ready**: Complete Next.js solutions with database, auth, and API
- **Quality Assurance**: Built-in code review and automatic formatting

---

## Plugins

### 1. public-commands

> **Core Development Workflow Plugin**

The essential plugin that powers your entire development lifecycle with intelligent automation.

#### Workflow Pipeline

```
/prd → digging → /implement → /auto-commit
  ↓       ↓          ↓            ↓
 PRD   Analyze    Code It     Quality Gate
```

#### Commands

| Command | Description |
|---------|-------------|
| `/prd <feature>` | Generate structured PRD from vague feature requests |
| `/implement <feature>` | Implement features based on PRD specifications |
| `/auto-commit` | Quality-gated auto-commit with intelligent message generation |

#### Skills & Agent

| Type | Name | Description |
|------|------|-------------|
| Skill | `code-review` | Code quality scoring (0-100) with detailed feedback |
| Skill | `digging` | PRD vulnerability analysis and risk identification |
| Agent | `code-formatter` | Multi-language formatting and linting automation |

#### Quality Gate System

| Score | Grade | Action |
|-------|-------|--------|
| 80+ | A/B | ✅ Auto-commit |
| 60-79 | C/D | ⚠️ Auto-fix then retry |
| < 60 | F | ❌ Block commit |

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

### 3. fullstack-nextjs

> **Complete Full-Stack Next.js Solution** `v1.1.0`

Everything you need for building production-ready full-stack applications.

#### Tech Stack

- **Next.js 15+** with App Router
- **React 19** with Server Components
- **Prisma ORM** for database management
- **NextAuth** for authentication
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Vitest & Playwright** for testing

#### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/component` | Create React components | `/component LoginForm --form` |
| `/page` | Generate Next.js pages | `/page products/[id] --dynamic` |
| `/api` | Create API routes | `/api posts --crud` |
| `/model` | Define Prisma models | `/model Post --fields "title:String"` |
| `/action` | Create Server Actions | `/action createUser` |
| `/hook` | Generate custom hooks | `/hook useAuth` |
| `/feature` | Full feature scaffolding | `/feature blog --crud` |
| `/test` | Generate test files | `/test LoginForm` |

<details>
<summary><strong>View all 12 skills</strong></summary>

| Category | Skills |
|----------|--------|
| Frontend | `react-patterns`, `nextjs-app-router`, `tailwind`, `frontend-design` |
| Backend | `api-routes`, `server-actions`, `database-prisma`, `auth-patterns`, `error-handling` |
| Shared | `typescript`, `testing`, `form-validation` |

</details>

---

## Coming Soon

Two additional plugins are currently in development:

| Plugin | Status | Description |
|--------|--------|-------------|
| 🔜 TBD | In Development | Coming soon |
| 🔜 TBD | Planning | Coming soon |

*Stay tuned for updates!*

---

## Installation

### Option 1: Marketplace (Recommended)

```bash
# Add marketplace to Claude Code
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# Install plugins
/plugin install public-commands
/plugin install frontend-development
/plugin install fullstack-nextjs
```

### Option 2: CLI Installation

```bash
# Install with scope
claude plugin install public-commands@wigtn-plugins --scope user      # Global (default)
claude plugin install frontend-development@wigtn-plugins --scope project   # Team shared
claude plugin install fullstack-nextjs@wigtn-plugins --scope local     # Local only
```

### Option 3: Manual Installation (Symlink)

```bash
# 1. Clone repository
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn

# 2. Create symlinks
mkdir -p ~/.claude/plugins
ln -s ~/.claude-plugins/wigtn/plugins/public-commands ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/frontend-development ~/.claude/plugins/
ln -s ~/.claude-plugins/wigtn/plugins/fullstack-nextjs ~/.claude/plugins/

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

### Complete Development Workflow

```bash
# 1. Generate PRD from your idea
/prd user-authentication

# 2. Analyze and improve the plan (optional)
# The 'digging' skill will identify gaps and risks

# 3. Implement the feature
/implement user-authentication

# 4. Auto-commit with quality check
/auto-commit
```

### Frontend Development

```bash
# Scaffold a component with design style
/component-scaffold Dashboard --style=bento-grid

# Generate form component
/component-scaffold ContactForm --style=glassmorphism
```

### Full-Stack Development

```bash
# Create complete CRUD feature
/feature blog --crud --auth

# This generates:
# - Prisma model
# - API routes
# - Server actions
# - Pages & components
# - Types & hooks
```

---

## Plugin Structure

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/
│   └── plugin.json              # Marketplace metadata
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
│   │   └── skills/              # 13 skills
│   └── fullstack-nextjs/
│       ├── agents/
│       ├── commands/            # 8 commands
│       └── skills/              # 12 skills
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
