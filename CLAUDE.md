# WIGTN Claude Code Plugin Tools

## Project Overview

A collection of Claude Code plugins enabling AI-powered Vibe Coding: idea to production with minimal friction.

**Version**: 0.3.0
**License**: MIT
**Repository**: https://github.com/wigtn/wigtn-plugins-with-claude-code

## Architecture

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/           # Marketplace metadata
├── plugins/
│   ├── public-commands/      # Core workflow: /prd → digging → /implement → /auto-commit
│   ├── frontend-development/ # 13 skills, 12+ design styles, React/Next.js
│   ├── backend-development/  # Backend patterns, DevOps, CI/CD
│   ├── mobile-development/   # React Native, Expo, 11 skills
│   └── ai-development/       # STT (WhisperX), LLM integration
├── CLAUDE.md                 # This file
├── README.md                 # English docs
└── README.ko.md              # Korean docs
```

### Plugin Structure Convention

Each plugin follows this structure:

```
plugins/{plugin-name}/
├── plugin.json               # Plugin metadata (if exists)
├── agents/                   # Agent definitions (.md)
├── commands/                 # User-invocable commands (.md)
├── skills/                   # Skills with SKILL.md + reference files
└── hooks/                    # Hooks configuration (hooks.json)
```

## Pipeline Flow

```
/prd <feature>
  → PRD.md + PLAN_{feature}.md
    → digging (4-category parallel analysis)
      → /implement (DESIGN parallel → BUILD level-based parallel)
        → /auto-commit (3-agent parallel review → quality gate → commit)
```

### Quality Gate

- **80+**: Auto-commit (PASS)
- **60-79**: Auto-fix then retry (WARN)
- **< 60**: Block commit (FAIL)
- **Security Critical**: Force FAIL (score capped at 59)

## Conventions

### Skill Frontmatter

```yaml
---
name: skill-name
description: Brief description of the skill
disable-model-invocation: true    # Optional: for heavy skills (600+ lines)
allowed-tools: Read, Write, Edit  # Optional: restrict available tools
context: fork                     # Optional: run in isolated subagent
context-agent-type: general-purpose  # Optional: agent type for fork
---
```

### Command Frontmatter

```yaml
---
argument-hint: "<feature name>"   # Optional: autocomplete hint for $ARGUMENTS
---
```

### Hooks

Hooks are defined in `plugins/{plugin}/hooks/hooks.json` and follow the Claude Code hooks schema.

### Agent Teams

Coordinators support both instruction-based orchestration (default) and native Agent Teams mode when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is detected.

## Key Paths

| Path | Purpose |
|------|---------|
| `plugins/public-commands/skills/code-review/` | Multi-level code review |
| `plugins/public-commands/skills/digging/` | PRD analysis |
| `plugins/frontend-development/skills/design-skill/styles/` | 12 design style guides |
| `plugins/backend-development/skills/backend-patterns/references/` | Backend reference docs |
| `plugins/backend-development/skills/devops-patterns/references/` | DevOps reference docs |
| `plugins/public-commands/agents/parallel-*` | Parallel coordinators |

## Important Notes

- All skills and commands use Korean (한국어) for user-facing content
- Design style files follow a consistent pattern: philosophy, typography, layout, color, components, anti-patterns
- Parallel coordinators include sequential fallback for graceful degradation
- Hooks run asynchronously to avoid blocking the main workflow
