---
name: git-guide
description: 팀 Git 워크플로우 스타일(Git Flow, GitHub Flow, Trunk Based)을 선택하고 해당 스타일에 맞게 안내합니다. Trigger on "/git", "브랜치 전략", "워크플로우", "깃 어떻게".
model: sonnet
allowed-tools: ["Bash", "Read", "Write"]
---

# Git Workflow Guide

## Trigger

- `/git`, `/깃`
- "브랜치 전략", "워크플로우"
- "기능 개발 어떻게", "머지 어떻게", "배포 어떻게"

## Protocol

1. `.git-workflow` 파일을 확인하라
2. 파일이 없으면 워크플로우 스타일을 선택하게 하라:
   - [1] Git Flow
   - [2] GitHub Flow
   - [3] Trunk Based
3. 선택 시 해당 스타일의 **장점, 단점, 적합한 팀**을 반드시 설명하라
4. 선택한 스타일을 `.git-workflow` 파일에 저장하라
5. 이후 모든 Git 관련 안내는 **선택한 스타일에 맞게** 제공하라

## 스타일별 핵심 차이

**Git Flow:**

- 브랜치: main, develop, feature/_, release/_, hotfix/\*
- 기능 개발: develop → feature → develop
- 배포: develop → release → main
- 적합: 정기 릴리즈, QA 있는 팀, 대규모 팀

**GitHub Flow:**

- 브랜치: main, feature/\*
- 기능 개발: main → feature → PR → main
- 배포: main이 곧 배포
- 적합: 수시 배포, 소규모 팀, SaaS

**Trunk Based:**

- 브랜치: main (+ 매우 짧은 feature)
- 기능 개발: main → 짧은 브랜치 → 바로 main
- 배포: main이 곧 배포
- 적합: CI/CD 완전 자동화, 시니어 팀

## Rules

1. 안내 전에 반드시 워크플로우 스타일을 확인하라
2. 스타일 선택 시 장단점을 반드시 설명하라
3. 모든 Git 안내는 선택한 스타일의 프로세스에 맞게 제공하라
4. 스타일이 없으면 먼저 선택하게 하라
