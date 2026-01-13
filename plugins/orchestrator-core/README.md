# orchestrator-core

Central coordinator for multi-plugin orchestration in Claude Code.

## Features

- **Plugin Discovery**: Dynamically detect installed stack/skill plugins
- **Parallel Execution**: Run independent agents concurrently
- **Ownership Enforcement**: Prevent agents from modifying files outside their domain
- **Conflict Prevention**: Detect and block conflicting operations
- **Duplicate Prevention**: Identify and skip redundant work
- **Lock Management**: Acquire/release locks during execution

## Usage

```
/orchestrate <task-description>
```

## 8-Phase Execution Protocol

1. Plugin Discovery - Scan installed plugins
2. Task Analysis - Analyze requirements and determine agents
3. Dependency Graph - Build execution order
4. Ownership Registry - Map file paths to agent owners
5. Lock Management - Acquire resource locks
6. Conflict Detection - Check for file/type/config conflicts
7. Duplicate Detection - Identify redundant operations
8. Agent Dispatch - Execute agents (sequential/parallel)

## Installation

```bash
claude /install wigtn/wigtn-plugins-with-claude-code/plugins/orchestrator-core
```
