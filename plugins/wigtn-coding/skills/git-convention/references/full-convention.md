# Git Convention 초안

---

cf. 브랜치 전략(**`main` / `dev` / `feature/*` / `hotfix/*`**)에 맞춰 작성

## 1. 목적

본 규칙은 팀의 소스코드 및 배포 구성을 일관되게 관리하기 위한 Git 운영 기준이다.

- 브랜치 전략 표준화
- PR/리뷰/병합 절차 통일
- GitOps 기반 배포 흐름 명확화
- 운영 안정성 및 변경 이력 추적성 확보

---

## 2. 기본 원칙

1. **Git이 단일 진실원천(Source of Truth)** 이다.
2. **직접 운영 반영 금지**
    - 운영 환경 변경은 반드시 Git 변경(PR/Merge)을 통해 수행한다.
3. **직접 커밋 금지**
    - `main`, `dev` 브랜치에 직접 push 하지 않는다. (예외: 저장소 관리자 긴급 조치)
4. **모든 변경은 PR 기반**
    - 기능/수정/핫픽스/운영 설정 변경 모두 Pull Request로 진행한다.
5. **작고 명확한 변경**
    - PR은 가능한 작게 나누고, 목적이 분명해야 한다.

---

## 3. 브랜치 전략

## 3.1 브랜치 종류 및 역할

### `main`

- **운영 기준 브랜치**
- 배포 가능한 안정 상태만 유지
- 운영 릴리즈 이력이 누적되는 기준선
- GitHub 기본 브랜치(Default Branch)로 설정 권장

### `dev`

- **개발 통합 브랜치**
- 기능 브랜치를 병합하여 통합 테스트 수행
- 개발 환경 자동 배포의 기준 브랜치

### `feature/*`

- 신규 기능 개발 브랜치
- `dev`에서 분기하고 `dev`로 병합

예시:

- `feature/login-api`
- `feature/user-profile-edit`
- `feature/123-payment-retry`

### `hotfix/*`

- 운영 이슈 긴급 수정 브랜치
- `main`에서 분기하고 **`main` + `dev` 모두 반영**
- 운영 장애/치명적 버그 대응 전용

예시:

- `hotfix/token-expiry-bug`
- `hotfix/502-nginx-timeout`

---

## 3.2 브랜치 생성 기준

- 신규 기능/개선 → `feature/*` (`dev`에서 분기)
- 운영 긴급 수정 → `hotfix/*` (`main`에서 분기)
- 문서만 수정해도 가능하면 작업 브랜치 사용 (`docs/*`는 선택)

---

## 3.3 브랜치 네이밍 규칙

형식:

- `<type>/<short-description>`
- 필요 시 이슈 번호 포함: `<type>/<issue-number>-<short-description>`

규칙:

- 소문자 사용
- 단어 구분은
- 의미 없는 이름 금지 (`feature/test`, `fix/tmp` 금지)

예시:

- `feature/142-user-search`
- `feature/oauth-google-login`
- `hotfix/payment-duplicate-charge`

---

## 4. 병합(Merge) 규칙

## 4.1 기본 병합 흐름

### 기능 개발

`feature/*` → `dev`

### 운영 릴리즈

`dev` → `main` (릴리즈 PR)

### 운영 긴급 수정

`hotfix/*` → `main`

이후 반드시 **역반영(back-merge)**:

- `main` → `dev` (또는 동일 변경 PR)

> **중요:** `hotfix`가 `main`에만 반영되고 `dev`에 누락되면 이후 릴리즈 시 재발 가능성이 높다.
> 

---

## 4.2 병합 방식

권장:

- **Squash Merge** (기능 브랜치 → `dev`)
    - 히스토리 단순화
- **Merge Commit** (`dev` → `main`, `hotfix` → `main`)
    - 릴리즈/핫픽스 단위 추적 용이

팀 정책 예시:

- `feature/*` PR: **Squash merge**
- 릴리즈 PR (`dev`→`main`): **Merge commit**
- `hotfix/*` PR: **Merge commit**

---

## 5. PR(Pull Request) 규칙

## 5.1 PR 생성 필수 항목

모든 PR에는 아래 내용을 포함한다.

- 변경 목적 (왜 필요한가)
- 변경 내용 요약 (무엇이 바뀌는가)
- 영향 범위 (API/DB/배포/운영 영향)
- 테스트 방법 및 결과
- 롤백 방법 (운영 반영 시)

예시 템플릿:

```markdown
## 목적
- 로그인 토큰 재발급 로직 오류 수정

## 변경 내용
- refresh token 만료 시간 계산 로직 수정
- 단위 테스트 추가

## 영향 범위
- 인증 API
- 기존 세션 유지 로직

## 테스트
- [x] 단위 테스트 통과
- [x] 로컬 재현/검증 완료

## 배포/롤백
- 배포 후 auth 서버 로그 확인
- 문제 발생 시 PR revert
```

---

## 5.2 PR 크기 기준

권장:

- 1 PR = 1 목적
- 리뷰 가능한 크기 유지 (가능하면 300~500줄 내외)
- 리팩터링 + 기능 추가 혼합 금지 (분리 권장)

---

## 5.3 리뷰 승인 기준

- 최소 **1명 승인** (권장 2명)
- 운영 영향/DB 변경/인프라 변경 포함 시 **담당자 추가 승인**
- CI 실패 상태에서는 병합 금지

---

## 6. 보호 브랜치(Branch Protection) 규칙

`main`, `dev`에 보호 정책 적용 권장

### `main`

- direct push 금지
- PR 필수
- 승인 필수
- CI 통과 필수
- force push 금지
- branch deletion 금지

### `dev`

- direct push 금지
- PR 필수
- CI 통과 필수
- force push 금지

---

## 7. 커밋 메시지 규칙 (권장: Conventional Commits)

형식:

```
<type>(<scope>): <summary>
```

예시:

- `feat(auth): add refresh token rotation`
- `fix(api): handle null user id`
- `hotfix(payment): prevent duplicate charge`
- `refactor(user): split service layer`
- `docs(readme): update local setup`
- `chore(ci): cache gradle dependencies`

### 자주 쓰는 type

- `feat`: 기능 추가
- `fix`: 버그 수정
- `refactor`: 동작 변경 없는 구조 개선
- `docs`: 문서 변경
- `test`: 테스트 추가/수정
- `chore`: 빌드/설정/기타 유지보수
- `ci`: CI/CD 설정 변경

규칙:

- 한 커밋에는 하나의 논리적 변경만 담는다
- `WIP`, `final`, `test` 같은 의미 없는 커밋 메시지 금지

---

## 8. 버전 태깅(Release Tag) 규칙

운영 배포 시 `main`에 태그를 생성한다.

형식(권장):

- `vMAJOR.MINOR.PATCH`
- 예: `v1.4.2`

예시 기준:

- `MAJOR`: 호환성 깨지는 변경
- `MINOR`: 기능 추가
- `PATCH`: 버그 수정

운영 이슈 추적을 위해 태그/릴리즈 노트를 남긴다.

---

# 9. GitOps 운영 규칙 (중요)

> 아래 규칙은 **애플리케이션 코드 저장소**와 **GitOps(배포 manifest) 저장소**를 함께 운영할 때의 기준이다.
> 

## 9.1 저장소 역할 분리 (권장)

### A. 애플리케이션 저장소 (App Repo)

- 소스코드, 테스트 코드, Dockerfile, CI 설정
- 브랜치 전략: `main`, `dev`, `feature/*`, `hotfix/*`

### B. GitOps 저장소 (Ops/Manifest Repo)

- Kubernetes manifests / Helm values / Kustomize overlays
- 배포 환경별 설정 (`dev`, `stg`, `prod`)
- Argo CD / Flux가 감시하는 배포 기준 저장소

> 가능하면 **App Repo와 GitOps Repo를 분리**한다.
> 
> 
> (코드 변경과 배포 승격(promote)을 분리하여 통제/감사/롤백이 쉬워짐)
> 

---

## 9.2 환경 관리 방식 (브랜치가 아닌 디렉터리 권장)

GitOps 저장소에서는 환경을 브랜치로 나누기보다 **디렉터리/overlay**로 관리하는 것을 권장한다.

예시:

```
gitops-repo/
  apps/
    my-service/
      base/
      overlays/
        dev/
        stg/
        prod/
```

이유:

- 환경 간 diff 확인이 쉬움
- PR 리뷰가 명확함
- 브랜치 드리프트 방지

---

## 9.3 배포 흐름 (권장 시나리오)

### 개발 반영

1. 개발자가 `feature/*` → `dev` PR 병합
2. CI가 이미지 빌드 및 레지스트리 푸시 (`image: my-service:<sha>`)
3. GitOps 저장소의 `dev` overlay 이미지 태그를 업데이트하는 PR 생성/병합
4. Argo CD/Flux가 `dev` 환경 자동 동기화

### 운영 릴리즈

1. `dev` → `main` 릴리즈 PR 병합
2. 태그 생성 (`v1.4.2`)
3. CI가 운영용 이미지 빌드/푸시 (immutable tag 권장: `v1.4.2`, sha)
4. GitOps 저장소의 `prod` overlay 이미지 태그를 PR로 승격
5. 승인 후 병합 → Argo CD/Flux가 운영 배포

---

## 9.4 GitOps 절대 규칙

1. **클러스터에 수동 적용 금지**
    - `kubectl apply -f ...` 직접 반영 금지 (긴급상황 예외 시 사후 Git 반영 필수)
2. **운영 변경은 Git PR로만**
    - replica 수, image tag, env 변수, ingress 설정 등 모두 Git으로 변경
3. **태그는 immutable 사용**
    - `latest` 사용 금지 (운영/스테이징)
    - sha 태그 또는 버전 태그 사용
4. **롤백도 Git으로**
    - 이전 커밋 revert 또는 이전 태그로 되돌리는 PR 생성

---

## 9.5 환경 승격(Promotion) 규칙

- `dev` → `stg` → `prod`는 **동일 이미지 태그**를 승격하는 방식으로 진행
- 운영에서 검증되지 않은 새 빌드를 즉시 `prod`에 반영하지 않는다
- 환경마다 다른 값은 설정값(values/overlay)로만 분리하고, 애플리케이션 코드 자체는 동일 버전을 사용

예시:

- dev 검증 완료 이미지: `my-service:v1.4.2`
- stg/prod도 같은 `v1.4.2`를 사용 (재빌드 금지)

---

## 9.6 Drift(실제 환경과 Git 불일치) 처리 규칙

- Argo/Flux drift 감지 시:
    1. 수동 변경 여부 확인
    2. 수동 변경이면 원복하거나 Git에 반영
    3. 재발 방지를 위해 직접 접근 권한/절차 점검

---

# 10. Hotfix 운영 절차 (운영 장애 대응)

## 10.1 절차

1. `main`에서 `hotfix/*` 브랜치 생성
2. 수정 및 테스트
3. `hotfix/*` → `main` PR 생성 (긴급 리뷰)
4. 병합 후 운영 배포
5. **반드시 `main` 변경사항을 `dev`에 역반영**
    - `main` → `dev` PR 생성 또는 cherry-pick PR
6. GitOps 저장소 `prod` overlay 이미지/설정 업데이트 및 배포
7. 필요 시 `dev`/`stg`도 동일 변경 반영 확인

---

## 10.2 Hotfix 커밋/PR 표기 권장

- 브랜치: `hotfix/<issue>`
- 커밋: `hotfix(scope): ...` 또는 `fix(scope): ...`
- PR 제목 예시:
    - `[HOTFIX] Prevent duplicate payment retry`
    - `[HOTFIX] auth token expiry null check`

---

# 11. 금지 사항

- `main`, `dev` direct push
- `force push` (특히 공유 브랜치)
- `latest` 태그 운영 사용
- CI 실패 상태 병합
- 리뷰 없이 운영 반영
- 핫픽스 후 `dev` 역반영 누락
- 운영 수동 변경 후 Git 미반영

---

# 12. 예시 워크플로우

## 기능 개발

```bash
# dev 기준 분기
git checkout dev
git pull origin dev
git checkout -b feature/user-search

# 개발/커밋
git commit -m "feat(user): add user search API"

# 원격 푸시 후 PR 생성 (feature/user-search -> dev)
git push origin feature/user-search
```

## 운영 핫픽스

```bash
# main 기준 분기
git checkout main
git pull origin main
git checkout -b hotfix/payment-duplicate-charge

# 수정/테스트 후 커밋
git commit -m "fix(payment): prevent duplicate charge on retry"

# PR 생성 (hotfix/* -> main), 병합 후 운영 반영
git push origin hotfix/payment-duplicate-charge
```

이후 필수:

- `main` → `dev` 역반영 PR 생성

---

# 13. 권장 PR 제목 규칙 (선택)

형식:

- `[FEAT] 사용자 검색 API 추가`
- `[FIX] 로그인 실패 시 null 처리`
- `[HOTFIX] 결제 중복 청구 방지`
- `[RELEASE] dev -> main (v1.4.2)`

---

# 14. 운영 체크리스트 (릴리즈/핫픽스 공통)

- [ ]  CI 통과
- [ ]  리뷰 승인 완료
- [ ]  변경 영향 범위 확인 (DB/API/인프라)
- [ ]  롤백 방법 확인
- [ ]  GitOps manifest PR 반영 확인
- [ ]  배포 후 모니터링 확인 (로그/메트릭/알람)
- [ ]  핫픽스 시 `dev` 역반영 완료

---

## 15. 최종 요약

- **개발 통합은 `dev`**
- **운영 기준은 `main`**
- **기능은 `feature/*`**
- **운영 긴급 수정은 `hotfix/*`**
- **배포는 GitOps 저장소 PR로 관리**
- **운영 수동 변경 금지, 롤백도 Git으로 수행**