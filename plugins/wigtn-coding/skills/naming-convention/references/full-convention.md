# 네이밍 컨벤션 표준화

---

# 기존 리포지토리 명 개선

---

## **github repo 네이밍 템플릿**

```markdown
<domain>-<component>-<type>(-<lang>)
```

### **슬롯별 가이드**

### **1. `<domain>` (필수) - 무엇을 다루는가?**

비즈니스 도메인 또는 제품명. 이름만 보고 "이게 뭐하는 프로젝트지?" 알 수 있어야 함.

| 좋은 예 | 나쁜 예 | 이유 |
| --- | --- | --- |
| `bill` | `acro` | "의안" vs 암호 같은 약어 |
| `law` | `v2s` | "법령" vs 버전 접두사 |
| `ihopper` | `cginside` | 제품명 vs 회사명 (org에서 이미 구분됨) |
| `apollo` | `ai` | 프로젝트명 vs 너무 일반적 |
| `rag` | `server` | 기술/기능 vs 아키텍처 용어 |

**규칙:**

- 1-2 단어
- 팀 누구나 아는 용어
- 암호 같은 약어 금지 (`acro`, `prc`, `ods`)

### **2. `<component>` (선택) - 무슨 역할인가?**

도메인 내 세부 기능. 생략 가능하지만 명확성을 위해 권장.

| 좋은 예 | 나쁜 예 | 이유 |
| --- | --- | --- |
| `indexer` | `batch` | 구체적 역할 vs 너무 일반적 |
| `collector` | `job` | 구체적 역할 vs 너무 일반적 |
| `admin` | `backend` | 명확한 범위 vs 모호함 |
| `report` | `main` | 기능 명시 vs 의미 없음 |

**규칙:**

- 명사 사용
- 동사형 금지 (`get-`, `do-`, `process-`)
- 단일 책임을 나타내야 함

### **3. `<type>` (필수) - 어떤 종류인가?**

아키텍처 유형. **아래 목록에서만 선택** (임의 추가 금지).

| Type | 용도 | 언제 사용? |
| --- | --- | --- |
| `api` | REST/GraphQL 엔드포인트 | HTTP 요청 받아서 응답 반환 |
| `service` | 백엔드 서비스 | 비즈니스 로직 처리, 상시 구동 |
| `worker` | 배치/큐 처리 | 스케줄 또는 이벤트 기반 실행 |
| `web` | 프론트엔드 웹앱 | 브라우저에서 실행되는 UI |
| `mobile` | 모바일 앱 | iOS/Android 앱 |
| `lib` | 공용 라이브러리 | 다른 프로젝트에서 import |
| `sdk` | 외부 SDK | 외부 개발자용 클라이언트 |
| `cli` | CLI 도구 | 터미널에서 실행하는 도구 |
| `infra` | IaC, 인프라 설정 | Terraform, K8s manifests 등 |
| `docs` | 문서 | README, 가이드, 명세서 |
| `data` | 데이터셋, 스키마 | 데이터 파일, DDL 모음 |

**선택 가이드:**

```
HTTP 요청 처리?
├── Yes → 외부 노출?
│         ├── Yes → api
│         └── No → service
└── No → 주기적 실행?
          ├── Yes → worker
          └── No → 터미널에서 실행?
                    ├── Yes → cli
                    └── No → 브라우저에서 실행?
                              ├── Yes → web
                              └── No → 다른 프로젝트에서 import?
                                        ├── Yes → lib
                                        └── No → 문서만?
                                                  ├── Yes → docs
                                                  └── No → 인프라 설정?
                                                            ├── Yes → infra
                                                            └── No → data

```

### **4. `<lang>` (선택) - 언어 명시**

**같은 기능이 여러 언어로 구현된 경우에만** 사용. 단일 언어면 생략.

| 상황 | 네이밍 |
| --- | --- |
| Python RAG API만 있음 | `rag-api` |
| Python + TypeScript RAG API | `rag-api-python`, `rag-api-ts` |
| Java 레거시 코드 | `bill-collector-worker-java` |

---

## **체크리스트**

### **형식 검사**

- [ ]  **lowercase** - 대문자 없음
- [ ]  **kebab-case** - 단어 구분은 하이픈()만
- [ ]  **20자 이내** - 길어도 최대 30자
- [ ]  **영문/숫자** - 한글, 공백, 특수문자 없음

### **템플릿 검사**

- [ ]  **domain** - 비즈니스 도메인이 명확한가?
- [ ]  **type** - 허용 목록(api, service, worker, web, lib, cli, infra, docs, data)에 있는가?
- [ ]  **lang** - 정말 필요한가? (polyglot일 때만)

### **금지 패턴 검사**

- [ ]  **버전 접두사 없음** - `v2`, `v3` 금지 (브랜치/태그 사용)
- [ ]  **조직명 중복 없음** - `cginside-` 불필요 (org에서 이미 구분)
- [ ]  **중복 단어 없음** - `server-backend`, `batch-job` 등
- [ ]  **암호 같은 약어 없음** - `acro`, `prc`, `ods` 등

### **운영 검사**

- [ ]  **기존 레포와 중복 없음** - 비슷한 이름 검색
- [ ]  **용도가 명확함** - 이름만 보고 뭐하는 건지 알 수 있음

---

## **예시**

### **좋은 예시**

| 이름 | 분석 |
| --- | --- |
| `bill-indexer-worker` | domain=bill, component=indexer, type=worker |
| `rag-api-ts` | domain=rag, type=api, lang=ts |
| `ihopper-web` | domain=ihopper, type=web |
| `lib-common` | type=lib, component=common |
| `apollo-report-service` | domain=apollo, component=report, type=service |
| `infra-gcp` | type=infra, component=gcp |
| `data-medical-synonyms` | type=data, component=medical-synonyms |

### **나쁜 예시**

| 이름 | 문제 | 수정안 |
| --- | --- | --- |
| `cginside-v2-acro-batch` | 버전+약어+중복 | `bill-collector-worker` |
| `ai-rag-server-backend-ts` | 중복 단어 (server≈backend) | `rag-api-ts` |
| `ai-apollo-v2` | 버전 접두사 | `apollo-service` |
| `새 폴더` | 한글, 공백 | (삭제) |
| `data_filter` | snake_case | `data-filter-cli` |
| `aiServer` | camelCase | `inference-service` |

---

## **빠른 결정 가이드**

```
Q1: 뭘 다루나요?
→ 의안 관련 = bill-*
→ 법령 관련 = law-*
→ RAG/LLM = rag-*, llm-*
→ 제품 = ihopper-*, apollo-*

Q2: 어떤 형태로 실행되나요?
→ HTTP 서버 = *-api 또는 *-service
→ 배치/스케줄 = *-worker
→ 웹 UI = *-web
→ CLI 도구 = *-cli
→ 라이브러리 = lib-*
→ 문서 = docs-*
→ 인프라 코드 = infra-*

Q3: 세부 역할이 있나요? (선택)
→ 수집 = *-collector-*
→ 인덱싱 = *-indexer-*
→ 리포트 = *-report-*
→ 관리 = *-admin-*

Q4: 언어 구분 필요? (선택)
→ Python/TS 둘 다 = *-python, *-ts
→ 레거시 Java = *-java
→ 단일 언어 = 생략

```

---