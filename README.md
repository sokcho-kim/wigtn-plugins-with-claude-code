# wigtn Plugins for Claude Code

A collection of development workflow plugins for Claude Code.

## Plugins

| Plugin | Description |
|--------|-------------|
| **auto-commit** | Analyze changes and auto-commit with intelligent message generation |
| **prd** | Generate structured PRD documents from vague feature requests |
| **implement** | Implement features based on PRD specifications immediately |

## Installation

### Option 1: Marketplace (Recommended)

```bash
# Add this marketplace to Claude Code
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code

# Install plugins you want
/plugin install auto-commit
/plugin install prd
/plugin install implement
```

### Option 2: CLI Installation

```bash
# Install with scope
claude plugin install auto-commit@wigtn-plugins --scope user      # Global (default)
claude plugin install auto-commit@wigtn-plugins --scope project   # Shared with team
claude plugin install auto-commit@wigtn-plugins --scope local     # Local only (gitignored)
```

### Option 3: Manual Installation (Symlink)

```bash
# 1. Clone to a global location
git clone https://github.com/wigtn/wigtn-plugins-with-claude-code.git ~/.claude-plugins/wigtn

# 2. Create symlinks to Claude's skills directory
mkdir -p ~/.claude/skills
ln -s ~/.claude-plugins/wigtn/plugins/auto-commit/skills/auto-commit ~/.claude/skills/
ln -s ~/.claude-plugins/wigtn/plugins/prd/skills/prd ~/.claude/skills/
ln -s ~/.claude-plugins/wigtn/plugins/implement/skills/implement ~/.claude/skills/

# Update plugins
git -C ~/.claude-plugins/wigtn pull
```

## Usage

### auto-commit

```bash
/auto-commit                      # Auto-generate commit message and push
/auto-commit --no-push            # Commit only, no push
/auto-commit --message "message"  # Manual commit message
```

### prd

```bash
/prd user-authentication          # Generate PRD for a feature
/prd plugin-marketplace --detail=full
```

### implement

```bash
/implement user-authentication    # Implement by feature name
/implement FR-006                 # Implement by requirement ID
```

## Installation Scopes

| Scope | Settings File | Use Case |
|-------|---------------|----------|
| `user` | `~/.claude/settings.json` | Personal plugins across all projects (default) |
| `project` | `.claude/settings.json` | Team plugins shared via version control |
| `local` | `.claude/settings.local.json` | Project-specific plugins, gitignored |

## Plugin Structure

```
wigtn-plugins-with-claude-code/
├── .claude-plugin/
│   ├── plugin.json              # Marketplace metadata
│   └── marketplace.json         # Plugin registry
└── plugins/
    └── <plugin-name>/
        ├── .claude-plugin/
        │   └── plugin.json      # Plugin metadata
        ├── skills/
        │   └── <skill-name>/
        │       └── SKILL.md     # Skill definition
        └── README.md
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-plugin`)
3. Commit your changes (`git commit -m 'feat: Add amazing plugin'`)
4. Push to the branch (`git push origin feature/amazing-plugin`)
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details.
