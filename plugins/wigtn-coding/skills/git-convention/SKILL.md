---
name: git-convention
description: Git 컨벤션 자동 적용. 브랜치 생성, 커밋 메시지 작성, PR 생성, 병합 시 팀 표준(Conventional Commits, 브랜치 전략, PR 템플릿)을 자동으로 적용합니다.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Git Convention — 자동 적용 스킬

Git 작업 시 팀 컨벤션을 **자동으로 적용**합니다. 사용자가 일일이 규칙을 확인할 필요 없이, 이 스킬이 올바른 형식을 보장합니다.

---

## 실행 모드

사용자 요청에 따라 아래 모드를 자동 판별하여 실행합니다.

### 1. 브랜치 생성

사용자가 브랜치 생성을 요청하면:

1. 작업 유형 판별 → `feature/*` 또는 `hotfix/*`
2. 네이밍 규칙 자동 적용: `<type>/<short-description>` (소문자, kebab-case)
3. 올바른 기준 브랜치에서 분기
   - `feature/*` → `dev`에서 분기
   - `hotfix/*` → `main`에서 분기
4. 브랜치 생성 실행

```bash
# 예시: 사용자가 "로그인 기능 개발할게" 라고 하면
git checkout dev && git pull origin dev
git checkout -b feature/login-api
```

**금지**: `feature/test`, `fix/tmp` 같은 의미 없는 이름

### 2. 커밋

사용자가 커밋을 요청하면:

1. `git diff --staged` 분석으로 변경 내용 파악
2. Conventional Commits 형식으로 메시지 자동 생성
3. 사용자 확인 후 커밋 실행

**커밋 메시지 형식:**
```
<type>(<scope>): <summary>
```

| Type | 용도 |
|------|------|
| `feat` | 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 동작 변경 없는 구조 개선 |
| `docs` | 문서 변경 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드/설정/유지보수 |
| `ci` | CI/CD 설정 변경 |

**규칙:**
- 한 커밋 = 하나의 논리적 변경
- `WIP`, `final`, `test` 같은 의미 없는 메시지 금지
- scope는 변경된 모듈/폴더 기준으로 자동 추출

### 3. PR 생성

사용자가 PR을 요청하면:

1. 현재 브랜치와 커밋 히스토리 분석
2. 병합 대상 자동 결정:
   - `feature/*` → `dev` (Squash Merge 권장)
   - `hotfix/*` → `main` (Merge Commit 권장)
   - `dev` → `main` (Merge Commit, 릴리즈)
3. PR 템플릿 자동 작성:

```markdown
## 목적
- {변경 이유 자동 추출}

## 변경 내용
- {커밋 히스토리 기반 요약}

## 영향 범위
- {변경된 파일/모듈 기반 분석}

## 테스트
- [ ] 단위 테스트 통과
- [ ] 로컬 검증 완료

## 배포/롤백
- 문제 발생 시 PR revert
```

4. `gh pr create` 실행

### 4. Hotfix 절차

사용자가 운영 긴급 수정을 요청하면:

1. `main`에서 `hotfix/*` 브랜치 자동 생성
2. 수정 완료 후 커밋 (Conventional Commits 적용)
3. `hotfix/*` → `main` PR 생성
4. **병합 후 자동 안내**: `main` → `dev` 역반영 PR 필요함을 알림

---

## 자동 검증 체크리스트

모든 Git 작업 시 아래 항목을 자동 확인합니다:

- [ ] 브랜치명이 `<type>/<description>` 형식인가
- [ ] 커밋 메시지가 `<type>(<scope>): <summary>` 형식인가
- [ ] `main`, `dev`에 직접 push하려는 것은 아닌가
- [ ] PR 크기가 적절한가 (300~500줄 권장)
- [ ] hotfix 후 `dev` 역반영이 필요한가

위반 사항 발견 시 사용자에게 경고하고 올바른 형식을 제안합니다.

---

## 상세 레퍼런스

전체 규칙(GitOps, 보호 브랜치, 태깅, 운영 체크리스트 등):

- [전체 Git Convention 문서](../../../docs/skills/git_convention.md)
