# public-commands

> **Core Development Workflow Plugin** `v1.1.0`

A core plugin that provides a frictionless development workflow from idea to deployment, now with **Agent Teams parallel execution** for 3-5x speedup.

---

## Overview

`public-commands` supports the entire development lifecycle from PRD generation to implementation, quality inspection, and automatic commits. It is designed to achieve maximum results with minimal input, aligned with the Vibe Coding philosophy.

**v0.2.0 Highlight**: Agent Teams parallel execution across the entire pipeline — digging (4x), DESIGN (3x), BUILD (2-3x), review (3x).

### Workflow Pipeline

```
Sequential (v0.1.0):
┌─────────────────────────────────────────────────────────────┐
│   /prd  ──▶  digging  ──▶  /implement  ──▶  /auto-commit   │
│     │          │              │                │            │
│     ▼          ▼              ▼                ▼            │
│   PRD      Analysis       Code            Quality Check     │
│   Generation (serial)   Implementation      + Commit        │
└─────────────────────────────────────────────────────────────┘

Parallel (v0.2.0):
┌─────────────────────────────────────────────────────────────┐
│   /prd  ──▶  digging(4x) ──▶ /implement  ──▶ /auto-commit  │
│     │          │                │                │          │
│     ▼          ▼                ▼                ▼          │
│   PRD     4 agents          DESIGN(3x)      3 agents       │
│   Gen     parallel          BUILD(2-3x)     parallel       │
│           analysis          Cross-Plugin    review          │
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

| Type | Name | Description | New |
|------|------|-------------|-----|
| Command | `/prd` | Automatic PRD document generation | |
| Command | `/implement` | PRD-based feature implementation with parallel support | |
| Command | `/auto-commit` | Quality gate + automatic commit with parallel review | |
| Skill | `code-review` | Code quality score evaluation (0-100), parallel review mode | |
| Skill | `digging` | PRD vulnerability analysis, 4-agent parallel analysis | |
| Agent | `architecture-decision` | MSA vs Monolithic architecture decision | |
| Agent | `code-formatter` | Multi-language formatting automation | |
| Agent | `parallel-build-coordinator` | BUILD Phase dependency graph + level-based parallel | v0.2.0 |
| Agent | `parallel-review-coordinator` | 3-agent parallel code review + score merge | v0.2.0 |
| Agent | `parallel-digging-coordinator` | 4-agent parallel PRD analysis + result merge | v0.2.0 |

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

Implements features defined in the PRD. Separated into two phases: **DESIGN** and **BUILD**, both supporting parallel execution.

```bash
/implement user authentication          # Auto-detect parallel mode
/implement --parallel user authentication    # Force parallel mode
/implement --sequential user authentication  # Force sequential mode
/implement --full-stack user authentication  # Cross-Plugin parallel
/implement FR-006                        # By feature ID
```

**Vibe Coder Friendly Triggers:**
- "Write the code", "Develop it"
- "Build it now", "Start it"
- "Just make it"

#### Two-Phase Approach (with Parallel Support)

```
┌─────────────────────────────────────────────────────────────┐
│                    /implement Workflow                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │     DESIGN      │  ─ Confirm ─▶│     BUILD       │       │
│  │   (3x parallel) │    (Y/n)     │  (2-3x parallel)│       │
│  └─────────────────┘              └─────────────────┘       │
│                                                             │
│  Sequential:                   Sequential:                  │
│  Step0→1→2→3→4→5→6             Phase by Phase               │
│                                                             │
│  Parallel:                     Parallel:                    │
│  ┌─Agent A─┐                   Level 1: [Schema][Config]    │
│  │PRD + QG │                        ↓                       │
│  ├─Agent B─┤  → Merge → Plan   Level 2: [BE][FE][Svc]      │
│  │Architect│                        ↓                       │
│  ├─Agent C─┤                   Level 3: [Tests]             │
│  │Proj+Gap │                                                │
│  └─────────┘                                                │
│                                                             │
│  Cross-Plugin (--full-stack):                               │
│  ┌─Track 1─┐ ┌─Track 2─┐ ┌─Track 3─┐                      │
│  │backend- │ │frontend-│ │mobile-  │                       │
│  │architect│ │developer│ │developer│                       │
│  └─────────┘ └─────────┘ └─────────┘                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### DESIGN Phase

| Step | Description | Parallel Agent |
|------|-------------|---------------|
| 0 | PRD Quality Gate Check | Agent A |
| 1 | PRD Search | Agent A |
| 2 | Architecture Decision (`architecture-decision` agent) | Agent B |
| 3 | Project State Analysis | Agent C |
| 4 | Gap Analysis | Agent C |
| 5 | Implementation Plan Creation (merge results) | - |
| 6 | User Confirmation (CHECKPOINT) | - |

#### BUILD Phase (parallel-build-coordinator)

| Level | Tasks | Execution |
|-------|-------|-----------|
| 1 | Schema, Config | Parallel (no dependencies) |
| 2 | Backend, Frontend, Services | Parallel (Level 1 complete) |
| 3 | Tests | Parallel (Level 2 complete) |
| 4 | Integration / E2E | Sequential (all complete) |

#### User Confirmation Options

```
Proceed with this plan?

→ "Proceed (Recommended)" : Start implementation immediately
→ "Detailed Review" : Detailed file-by-file analysis with digging skill
→ "Needs Modification" : Modify the plan
→ "Cancel" : Cancel implementation
```

---

### /auto-commit

Analyzes changes, runs parallel quality checks, and automatically commits.

```bash
/auto-commit                          # Parallel review + auto message + push
/auto-commit --no-push                # Commit only, no push
/auto-commit --no-review              # Skip quality check (emergency hotfixes)
/auto-commit --no-parallel-review     # Force sequential review
```

**Vibe Coder Friendly Triggers:**
- "Commit it", "Auto commit"
- "git push", "Push to git"

#### Parallel Quality Gate System

```
                    ┌─────────────────┐
                    │ Collect Changes │
                    └────────┬────────┘
                             │
              files >= 3? ───┼─── files < 3?
              │              │              │
              ▼              │              ▼
     ┌─────────────────┐    │    ┌─────────────────┐
     │ Parallel Review │    │    │ Sequential      │
     │ (3 agents)      │    │    │ Review          │
     │                 │    │    │                 │
     │ A: Read+Main/40 │    │    │ 5 categories    │
     │ B: Perf+Test/40 │    │    │ sequential      │
     │ C: BP+Sec/20    │    │    │                 │
     └────────┬────────┘    │    └────────┬────────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
                    ┌────────┴────────┐
                    │  Score Merge    │
                    │  + Security     │
                    │  Override       │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
        ┌─────────┐    ┌─────────┐    ┌─────────┐
        │ ≥80pts  │    │ 60-79pts│    │ <60pts  │
        │  PASS   │    │  WARN   │    │  FAIL   │
        └────┬────┘    └────┬────┘    └────┬────┘
             │              │              │
             │              ▼              │
             │    ┌─────────────────┐      │
             │    │ code-formatter  │      │
             │    └────────┬────────┘      │
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
| Security Critical | - | Force FAIL (score capped at 59) |

---

## Skills

### code-review

Provides file/function-level code review and quality scoring system. **Supports parallel review mode** with 3 specialized agents.

**Evaluation Categories (20 points each):**

| Category | Evaluation Criteria | Parallel Agent |
|----------|---------------------|---------------|
| Readability | Naming conventions, comments, code structure | Agent A |
| Maintainability | Modularity, coupling, extensibility | Agent A |
| Performance | Algorithm efficiency, resource usage | Agent B |
| Testability | Test ease, dependency injection | Agent B |
| Best Practices | Language conventions, design patterns, security | Agent C |

**Parallel Review Mode** (auto-activated for 3+ changed files):
- Agent A: Readability (20) + Maintainability (20) = /40
- Agent B: Performance (20) + Testability (20) = /40
- Agent C: Best Practices (20) + Security Flag = /20
- Score Merge: Sum + Security Override (Critical -> force 59)
- Timeout: 60s per agent, fallback to 15/20 default

**Review Levels:**

| Level | Name | Description |
|-------|------|-------------|
| 1 | Quick | Lint-level checks |
| 2 | Standard | Standard quality review (default for /auto-commit) |
| 3 | Deep | Senior-level analysis with parallel Phase 2,3,5 (2x speedup) |
| 4 | Architecture | System design review with parallel Phase 2,3,5 (2x speedup) |

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

Analyzes vulnerabilities, omissions, and risks in PRD documents. **Supports 4-agent parallel analysis** for 4x speedup.

**Analysis Categories (fully independent, parallel-safe):**

| Category | Check Items | Parallel Agent |
|----------|-------------|---------------|
| Completeness | FR/NFR coverage, edge cases, error handling | Agent A |
| Feasibility | Tech stack fit, complexity, dependency risk | Agent B |
| Security | OWASP, auth/authz, data protection, input validation | Agent C |
| Consistency | Terminology, conflicts, priority, dependency cycles | Agent D |

**Parallel Mode** (auto-activated for PRD with 3+ sections and 500+ chars):
- 4 agents run completely independently (no shared state)
- Results merged with deduplication (same section + same issue)
- Severity ordering: Critical -> Major -> Minor
- Quality Gate: Critical 0 = PASS, 1+ = BLOCKED

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

---

### parallel-build-coordinator `v0.2.0`

Orchestrates BUILD Phase tasks across multiple agents for maximum parallelism while respecting dependency constraints.

**Key Features:**
- Dependency graph construction (Schema -> Backend -> Frontend -> Test)
- Level-based parallel execution (same level = parallel, next level = wait)
- File-level lock management (same file -> same agent)
- Graceful degradation (failed task -> sequential fallback, others continue)

**Dependency Priority:**

| Level | Task Types | Execution |
|-------|-----------|-----------|
| 0 | Config, Environment | Parallel |
| 1 | Schema (DB, Prisma) | Parallel (after Level 0) |
| 2 | Backend + Frontend | Parallel (after Level 1) |
| 3 | Tests | Parallel (after Level 2) |

---

### parallel-review-coordinator `v0.2.0`

Distributes code review across 3 category-specialized agents and merges results.

**Agent Distribution:**

| Agent | Categories | Points |
|-------|-----------|--------|
| A | Readability + Maintainability | /40 |
| B | Performance + Testability | /40 |
| C | Best Practices + Security Flag | /20 + security |

**Score Merge:**
- Sum all scores -> /100
- Security Critical -> force score to 59 (FAIL)
- Timeout (60s) -> conservative default (15/20)
- File distribution for 10+ files (domain-based round robin)

---

### parallel-digging-coordinator `v0.2.0`

Distributes PRD analysis across 4 independent agents for 4x speedup.

**Agent Distribution:**

| Agent | Category | Independence |
|-------|----------|-------------|
| A | Completeness | Input-only shared, no state |
| B | Feasibility | Input-only shared, no state |
| C | Security & Risk | Input-only shared, no state |
| D | Consistency | Input-only shared, no state |

**Result Merge:**
- Collect all issues from 4 agents
- Deduplicate (same section + same issue -> merge, keep higher severity)
- Sort by severity: Critical -> Major -> Minor
- Quality Gate: Critical 0 = PASS, 1+ = BLOCKED

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

### 2. Analyze PRD (auto-parallel: 4x speedup)

```bash
# 4 agents analyze in parallel
"Review the PRD"
```

### 3. Implement Feature (auto-parallel)

```bash
# Auto-detects parallel mode
/implement user authentication

# Force parallel
/implement --parallel user authentication

# Full-stack parallel (Backend + Frontend simultaneously)
/implement --full-stack user authentication
```

Or:
```
"Build it now"
```

### 4. Quality Check + Commit (parallel review: 3x speedup)

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
  ├── (calls) parallel-digging-coordinator (auto, 3+ sections)
  └── (output) Analysis Report, Improved PRD

/implement
  ├── (input) PRD Document
  ├── (calls) architecture-decision agent
  ├── (calls) parallel-build-coordinator (auto, 3+ files)
  ├── (calls) digging skill (for detailed review)
  ├── (calls) backend-architect (--full-stack)
  ├── (calls) frontend-developer (--full-stack)
  ├── (calls) mobile-developer (--full-stack, optional)
  └── (output) Implemented Code

/auto-commit
  ├── (calls) code-review skill
  ├── (calls) parallel-review-coordinator (auto, 3+ files)
  ├── (calls) code-formatter agent (for 60-79 score)
  └── (output) Commit + Push
```

---

## Parallel Execution Summary

| Component | Sequential | Parallel | Speedup | Auto-Activate |
|-----------|-----------|----------|---------|--------------|
| digging | 4 categories serial | 4 agents parallel | **4x** | PRD 3+ sections |
| DESIGN Phase | Steps 0-4 serial | 3 agents parallel | **3x** | Files 3+ |
| BUILD Phase | Tasks serial | Level-based parallel | **2-3x** | Tasks 3+ |
| Cross-Plugin | Plugins serial | Backend+Frontend parallel | **2x** | `--full-stack` |
| Quality Review | Single reviewer | 3 agents parallel | **3x** | Files 3+ |
| Deep Review (L3) | 5 phases serial | Phase 2,3,5 parallel | **2x** | Always |
| Arch Review (L4) | 5 phases serial | Phase 2,3,5 parallel | **2x** | Always |

**Error Handling:**

| Failure | Recovery | User Impact |
|---------|----------|------------|
| Agent Timeout (60s) | Conservative default (15/20) | Slight score variance |
| Single Agent Error | Reassign or sequential fallback | Category may be incomplete |
| File Conflict | File-level locks prevent; later wins if detected | None (prevented) |
| Full Parallel Failure | Complete sequential fallback | Speed only, same results |
| Security Critical | Immediate FAIL, score capped at 59 | Commit blocked |

> For detailed documentation, see [Agent Teams Parallel Execution Guide](../../docs/agent-teams-parallel-execution.md)

---

## Examples

### Full Workflow (Parallel Mode)

```bash
# 1. Generate PRD
User: "I want to build a payment feature"
-> /prd executed -> docs/prd/payment.md created

# 2. Analyze PRD (4 agents parallel)
User: "Review the PRD"
-> parallel-digging-coordinator: 4 agents
-> Agent A (Completeness): 3.2s
-> Agent B (Feasibility): 4.1s
-> Agent C (Security): 3.8s
-> Agent D (Consistency): 2.5s
-> Total: 4.1s (sequential estimate: 13.6s, speedup: 3.3x)
-> 2 Critical, 3 Major issues found
-> Quality Gate: BLOCKED

# 3. Fix Critical issues, re-analyze
-> Quality Gate: PASS

# 4. Implement (parallel mode auto-detected)
User: "Build it now"
-> DESIGN Phase (3 agents parallel, 3.5s)
   Agent A: PRD + QG -> PASS
   Agent B: Architecture -> Modular Monolith (85%)
   Agent C: Project + Gap -> 5 new files, 2 modifications
-> User confirmation: "Proceed"
-> BUILD Phase (level-based parallel, 10.1s)
   Level 1: [schema][config] parallel (1.8s)
   Level 2: [backend-1][backend-2][frontend] parallel (5.1s)
   Level 3: [test] (3.2s)
-> Total: 13.6s (sequential estimate: 27.4s, speedup: 2.0x)

# 5. Commit (parallel review)
User: "Commit it"
-> parallel-review-coordinator: 3 agents
   Agent A (Read+Main): 34/40 (4.2s)
   Agent B (Perf+Test): 32/40 (5.1s)
   Agent C (BP+Sec): 17/20 + OK (3.8s)
-> Total: 83/100 (5.1s, sequential: 15.3s, speedup: 3.0x)
-> Grade: B -> PASS
-> Commit + Push completed
```

### Quality Gate Flow

```bash
# Case 1: High Quality Code (parallel)
/auto-commit
-> 3 agents parallel review: 88/100
-> Commit immediately

# Case 2: Needs Improvement
/auto-commit
-> 3 agents parallel review: 72/100
-> code-formatter auto executed
-> Re-evaluation: 84/100
-> Commit

# Case 3: Quality Failure
/auto-commit
-> 3 agents parallel review: 55/100
-> Commit blocked
-> Manual fix items provided

# Case 4: Security Critical
/auto-commit
-> Agent C: Security Critical detected!
-> Score forced to 59/100 (was 85)
-> Commit blocked
-> Security vulnerability details provided
```

---

## License

MIT License - see [LICENSE](../../LICENSE)
