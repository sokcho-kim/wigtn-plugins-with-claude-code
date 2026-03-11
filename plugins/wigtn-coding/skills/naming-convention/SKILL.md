---
name: naming-convention
description: 네이밍 컨벤션 자동 적용. GitHub 레포 생성, 프로젝트 초기화 시 네이밍 템플릿을 자동 적용하고 기존 이름의 컨벤션 위반을 검증/수정합니다.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Naming Convention — 자동 적용 스킬

레포지토리/프로젝트 네이밍 시 컨벤션을 **자동으로 적용**합니다. 사용자가 규칙을 외울 필요 없이, 이 스킬이 올바른 이름을 생성하고 검증합니다.

---

## 실행 모드

### 1. 레포 이름 생성

사용자가 새 레포/프로젝트를 만들 때:

1. 사용자 설명에서 도메인, 역할, 실행 형태를 파악
2. 템플릿에 맞춰 이름 자동 생성
3. 체크리스트 검증 후 제안

**템플릿:**
```
<domain>-<component>-<type>(-<lang>)
```

| 슬롯 | 필수 | 설명 |
|------|------|------|
| `domain` | 필수 | 비즈니스 도메인/제품명 |
| `component` | 선택 | 세부 기능/역할 |
| `type` | 필수 | 아키텍처 유형 (아래 허용 목록) |
| `lang` | 선택 | 언어 (polyglot일 때만) |

**Type 자동 판별 플로우:**
```
HTTP 요청 처리?
├── Yes → 외부 노출? → Yes: api / No: service
└── No → 주기적 실행? → Yes: worker
     └── No → 터미널 실행? → Yes: cli
          └── No → 브라우저? → Yes: web
               └── No → import용? → Yes: lib
                    └── No → 문서? → Yes: docs
                         └── No → 인프라? → Yes: infra → No: data
```

**허용 Type 목록:** `api`, `service`, `worker`, `web`, `mobile`, `lib`, `sdk`, `cli`, `infra`, `docs`, `data`

**실행 예시:**
```
사용자: "RAG 기반 검색 API 만들건데 Python이야"
→ 자동 생성: rag-search-api-python
  - domain=rag, component=search, type=api, lang=python
```

### 2. 기존 이름 검증

사용자가 기존 레포/프로젝트 이름을 검증 요청하면:

1. 형식 검사 실행
2. 위반 사항 목록 출력
3. 수정안 제안

**자동 검증 체크리스트:**

#### 형식 검사
- [ ] lowercase — 대문자 없음
- [ ] kebab-case — 단어 구분은 하이픈만
- [ ] 20자 이내 (최대 30자)
- [ ] 영문/숫자만 — 한글, 공백, 특수문자 없음

#### 금지 패턴 검사
- [ ] 버전 접두사 없음 (`v2-`, `v3-`)
- [ ] 조직명 중복 없음 (org에서 이미 구분)
- [ ] 중복 단어 없음 (`server-backend` 등)
- [ ] 암호 같은 약어 없음 (`acro`, `prc`, `ods`)

#### 템플릿 검사
- [ ] domain이 명확한가
- [ ] type이 허용 목록에 있는가
- [ ] lang이 정말 필요한가 (polyglot일 때만)

**검증 결과 출력 형식:**
```
## 네이밍 검증 결과

| 항목 | 결과 | 상세 |
|------|------|------|
| 형식 | PASS/FAIL | ... |
| 금지 패턴 | PASS/FAIL | ... |
| 템플릿 | PASS/FAIL | ... |

### 위반 사항
- ❌ {위반 내용}

### 수정 제안
- 현재: `cginside-v2-acro-batch`
- 수정안: `bill-collector-worker`
- 이유: 버전 접두사 제거, 약어를 명확한 도메인명으로 변경
```

### 3. 일괄 검증

사용자가 여러 레포를 한번에 검증 요청하면:

1. GitHub org의 레포 목록 조회 (`gh repo list`)
2. 전체 레포에 대해 검증 실행
3. 위반 레포 목록 + 수정안 일괄 출력

---

## 빠른 결정 가이드

```
Q1: 뭘 다루나요?
→ 의안 = bill-*, 법령 = law-*, RAG/LLM = rag-*, 제품 = {product}-*

Q2: 어떤 형태로 실행되나요?
→ HTTP 서버 = *-api / *-service, 배치 = *-worker, 웹 UI = *-web
→ CLI = *-cli, 라이브러리 = lib-*, 문서 = docs-*, 인프라 = infra-*

Q3: 세부 역할? (선택)
→ 수집 = *-collector-*, 인덱싱 = *-indexer-*, 관리 = *-admin-*

Q4: 언어 구분 필요? (선택)
→ 다중 언어 = *-python / *-ts, 단일 언어 = 생략
```

---

## 상세 레퍼런스

전체 가이드(체크리스트, 예시 모음 등):

- [전체 Naming Convention 문서](references/full-convention.md)
