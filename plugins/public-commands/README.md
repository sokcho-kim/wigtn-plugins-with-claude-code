# public-commands

> **Core Development Workflow Plugin**

A core plugin that provides a frictionless development workflow from idea to deployment.

---

## Overview

`public-commands` supports the entire development lifecycle from PRD generation to implementation, quality inspection, and automatic commits. It is designed to achieve maximum results with minimal input, aligned with the Vibe Coding philosophy.

### Workflow Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   /prd  ──▶  digging  ──▶  /implement  ──▶  /auto-commit   │
│     │          │              │                │            │
│     ▼          ▼              ▼                ▼            │
│   PRD      Vulnerability    Code          Quality Check     │
│   Generation  Analysis    Implementation    + Commit        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Installation

### Option 1: Marketplace

```bash
/plugin install public-commands@wigtn-plugins
```

### Option 2: Manual (Symlink)

```bash
ln -s /path/to/wigtn-plugins/plugins/public-commands ~/.claude/plugins/
```

---

## Components

| Type | Name | Description |
|------|------|-------------|
| Command | `/prd` | Automatic PRD document generation |
| Command | `/implement` | PRD-based feature implementation |
| Command | `/auto-commit` | Quality gate + automatic commit |
| Skill | `code-review` | Code quality score evaluation (0-100) |
| Skill | `digging` | PRD vulnerability analysis |
| Agent | `architecture-decision` | MSA vs Monolithic architecture decision |
| Agent | `code-formatter` | Multi-language formatting automation |

---

## Commands

### /prd

Transforms vague feature requests into structured PRD (Product Requirement Document).

```bash
/prd user authentication feature
/prd payment system
```

**Vibe Coder Friendly Triggers:**
- "I want to build something that ~"
- "Create ~ for me"
- "Write a specification"

**Output:**
- Functional Requirements (FR-XXX)
- Non-Functional Requirements (NFR-XXX)
- API Specification (detailed)
- Data Model
- Priority Definition

---

### /implement

Implements features defined in the PRD. Separated into two phases: **DESIGN** and **BUILD**.

```bash
/implement user authentication
/implement FR-006
```

**Vibe Coder Friendly Triggers:**
- "Write the code", "Develop it"
- "Build it now", "Start it"
- "Just make it"

#### Two-Phase Approach

```
┌─────────────────────────────────────────────────────────────┐
│                    /implement Workflow                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐                  ┌─────────────┐           │
│  │   DESIGN    │  ── Confirm ──▶ │   BUILD     │           │
│  │   (Design)  │     (Y/n)       │   (Impl)    │           │
│  └─────────────┘                  └─────────────┘           │
│                                                             │
│  • PRD Analysis        User         • Write Code            │
│  • Architecture        Approval     • Create Files          │
│    Decision            Required!    • Run Tests             │
│    (subagent)                       • Verify Build          │
│  • Implementation Plan                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### DESIGN Phase

| Step | Description |
|------|-------------|
| 1 | PRD Search |
| 2 | Architecture Decision (`architecture-decision` agent) |
| 3 | Project State Analysis |
| 4 | Gap Analysis |
| 5 | Implementation Plan Creation |
| 6 | User Confirmation (CHECKPOINT) |

#### User Confirmation Options

```
Proceed with this plan?

→ "Proceed (Recommended)" : Start implementation immediately
→ "Detailed Review" : Detailed file-by-file analysis with digging skill before proceeding
→ "Needs Modification" : Modify the plan
→ "Cancel" : Cancel implementation
```

---

### /auto-commit

Analyzes changes, runs quality checks, and automatically commits.

```bash
/auto-commit                      # Quality check + auto message + push
/auto-commit --no-push            # Commit only, no push
/auto-commit --no-review          # Skip quality check (for emergency hotfixes)
```

**Vibe Coder Friendly Triggers:**
- "Commit it", "Auto commit"
- "git push", "Push to git"

#### Quality Gate System

```
                    ┌─────────────────┐
                    │ Collect Changes │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  code-review    │
                    │ Quality Score   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌─────────┐    ┌─────────┐    ┌─────────┐
        │ ≥80pts  │    │ 60-79pts│    │ <60pts  │
        │  PASS   │    │  WARN   │    │  FAIL   │
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
             │              ▼              │
             │    ┌─────────────────┐      │
             │    │ code-formatter  │      │
             │    │ Auto Improvement│      │
             │    └────────┬────────┘      │
             │              │              │
             ▼              ▼              ▼
        ┌─────────────┐       ┌─────────────┐
        │   COMMIT    │       │    STOP     │
        │   & PUSH    │       │ Manual Fix  │
        └─────────────┘       └─────────────┘
```

| Score | Grade | Action |
|-------|-------|--------|
| 80+ | A/B | Commit immediately |
| 60-79 | C/D | Auto improvement then retry |
| < 60 | F | Commit blocked, manual fix required |

---

## Skills

### code-review

Provides file/function-level code review and quality scoring system.

**Evaluation Categories (20 points each):**

| Category | Evaluation Criteria |
|----------|---------------------|
| Readability | Naming conventions, comments, code structure |
| Maintainability | Modularity, coupling, extensibility |
| Performance | Algorithm efficiency, resource usage |
| Testability | Test ease, dependency injection |
| Best Practices | Language conventions, design patterns, security |

**Grading System:**

| Grade | Score | Description |
|-------|-------|-------------|
| A+ | 95-100 | Exemplary code |
| A | 90-94 | Excellent code |
| B+ | 85-89 | Good code |
| B | 80-84 | Acceptable code |
| C | 70-79 | Needs improvement |
| D | 60-69 | Has problems |
| F | < 60 | Rewrite recommended |

---

### digging

Analyzes vulnerabilities, omissions, and risks in PRD documents.

**Analysis Categories:**

| Category | Check Items |
|----------|-------------|
| Completeness | Missing functional/non-functional requirements, edge cases |
| Feasibility | Technology stack suitability, implementation complexity |
| Security | Authentication/authorization, data protection, input validation |
| Consistency | Terminology uniformity, requirement conflicts, priority |

**Severity Levels:**

| Level | Criteria | Action |
|-------|----------|--------|
| Critical | Security vulnerabilities, missing core features | Immediate fix required |
| Major | Quality degradation, causes rework | Fix recommended before implementation |
| Minor | Nice-to-have improvements | Optional fix |

---

## Agents

### architecture-decision

Determines the optimal architecture based on PRD analysis.

**Decision Criteria:**

| Evaluation Item | Monolithic | Modular Monolithic | MSA |
|-----------------|------------|-------------------|-----|
| Number of Domains | 1-2 | 3-4 | 5+ |
| Team Size | 1-3 | 3-10 | 10+ |
| Project Stage | MVP | Growth | Enterprise |
| Independent Deployment | X | Partial | O |

**Output:**
- Architecture Type + Confidence Score
- Recommended Technology Stack
- Folder Structure
- Cautions/Warnings

---

### code-formatter

Performs multi-language formatting and linting automation.

**Supported Languages/Tools:**

| Language | Formatter |
|----------|-----------|
| TypeScript/JavaScript | Prettier, ESLint |
| Python | Black, isort, Ruff |
| Go | gofmt, goimports |
| Rust | rustfmt |

**Auto Fixes:**
- Import organization
- Formatting standardization
- Lint error correction

---

## Quick Start

### 1. Generate PRD

```bash
/prd user authentication feature
```

Or in natural language:
```
"I want to build a login feature"
```

### 2. Analyze PRD (Optional)

```bash
# Vulnerability analysis with digging skill
"Review the PRD"
```

### 3. Implement Feature

```bash
/implement user authentication
```

Or:
```
"Build it now"
```

### 4. Quality Check + Commit

```bash
/auto-commit
```

Or:
```
"Commit it"
```

---

## Integration

### Component Dependencies

```
/prd
  └── (output) PRD Document

digging
  ├── (input) PRD Document
  └── (output) Analysis Report, Improved PRD

/implement
  ├── (input) PRD Document
  ├── (calls) architecture-decision agent
  ├── (calls) digging skill (for detailed review)
  └── (output) Implemented Code

/auto-commit
  ├── (calls) code-review skill
  ├── (calls) code-formatter agent (for 60-79 score)
  └── (output) Commit + Push
```

---

## Examples

### Full Workflow

```bash
# 1. Generate PRD
User: "I want to build a payment feature"
→ /prd executed → docs/prd/payment.md created

# 2. Analyze PRD
User: "Review the PRD"
→ digging executed → 2 Critical, 3 Major issues found

# 3. Implement after PRD modification
User: "Build it now"
→ /implement executed
→ architecture-decision: Modular Monolith recommended
→ User confirmation: "Proceed"
→ Code implementation completed

# 4. Commit
User: "Commit it"
→ /auto-commit executed
→ code-review: 85/100
→ Commit + Push completed
```

### Quality Gate Flow

```bash
# Case 1: High Quality Code
/auto-commit
→ code-review: 88/100
→ Commit immediately

# Case 2: Needs Improvement
/auto-commit
→ code-review: 72/100
→ code-formatter auto executed
→ Re-evaluation: 84/100
→ Commit

# Case 3: Quality Failure
/auto-commit
→ code-review: 55/100
→ Commit blocked
→ Manual fix items provided
```

---

## License

MIT License - see [LICENSE](../../LICENSE)
