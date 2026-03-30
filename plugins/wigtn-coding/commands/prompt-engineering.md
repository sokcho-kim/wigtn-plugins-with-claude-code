---
description: |
  프롬프트 엔지니어링 원칙 적용. 프롬프트 작성/리뷰/개선 시 자동 적용.

  Trigger keywords:
  - Commands: "/prompt-engineering", "프롬프트 리뷰", "프롬프트 개선"

  - Natural language (바이브 코더 친화):
    - "프롬프트 만들어줘", "프롬프트 작성해줘"
    - "프롬프트 검수해줘", "프롬프트 고쳐줘"
    - "프롬프팅 원칙대로", "프롬프트 품질 점검"
    - "LLM 프롬프트 설계", "시스템 프롬프트 작성"
---

# Prompt Engineering Principles

프롬프트 엔지니어링 가이드 + Fastcampus 강의 + NAVER D2/배민 LLMOps 실전 + RegScan V4 프롬프트 경험을 종합한 원칙.

> 원칙 소스: `C:\Jimin\Prompt-Engineering-Guide` (가이드 + _learning 전체)

## 모드

이 스킬은 2가지 모드로 동작한다:

| 모드 | 트리거 | 동작 |
|------|--------|------|
| **작성** | 새 프롬프트 생성 요청 | 아래 원칙을 적용하여 프롬프트 작성 |
| **리뷰** | 기존 프롬프트 검수 요청 | 체크리스트 + 루브릭으로 진단 후 개선안 제시 |

---

## Part 1. 프롬프트 4구성요소 (필수)

모든 프롬프트는 아래 4요소를 명시적으로 구분하라.

| 요소 | 필수 | 설명 | 구분자 |
|------|------|------|--------|
| **Instruction** | O | 수행할 작업 지시 | 프롬프트 상단 배치 |
| **Context** | △ | 외부 정보, 배경 지식, 도메인 규칙 | `## Context` 또는 시스템 프롬프트 |
| **Input Data** | △ | 처리할 데이터 | `[FACT DATA]` 또는 `{변수}` |
| **Output Indicator** | O | 출력 형식, 스키마 | JSON 스키마, 예시 |

**구분자로 영역을 명확히 분리하라**: `###`, `---`, `[SECTION]` 등.

---

## Part 2. 핵심 설계 원칙

### 2-1. DO 중심으로 써라 (하지마라 < 해라)

```
BAD:  "날짜를 추정하지 마라. 허위 생성 금지."
GOOD: "날짜는 [FACT DATA]에 있는 값만 사용하라. 없으면 '데이터 부족'으로 표기하라."
```

"하지마라"는 모델이 무엇을 해야 하는지 알려주지 않는다. 원하는 행동을 명시하라.

### 2-2. 구체적으로 써라 (Specificity)

```
BAD:  "간결하게 요약해라"
GOOD: "3문장 이내, 40자/문장 이하, BLUF 톤으로 요약하라"
```

수치 제한, 관점 수, 문장 수, 글자 수를 명시하라.

### 2-3. Fact/Insight 분리

```
Python이 계산하는 것 (Fact): 날짜, 금액, 승인 상태, 경과일, 통계
LLM이 생성하는 것 (Insight): 분석, 해석, 맥락, 전망, 시사점
```

LLM에게 팩트 생성을 맡기면 hallucination이 발생한다. 팩트는 코드가 주입하고, LLM은 인사이트만 생성하게 하라.

### 2-4. 금지표현 대안표

프롬프트에 상투적 표현의 대안을 명시하라:

```
| 금지 (상투적)                | 대안 (구체적)                          |
|------------------------------|----------------------------------------|
| "~할 것으로 예상된다"        | 경과일·패턴 기반 구체적 해석           |
| "모니터링이 필요하다"        | 구체적 시기·대상·주기 명시             |
| "주목된다"                   | 구체적 이유 명시                       |
| "혁명적" / "획기적"          | 데이터(HR, CI, p-value)로 대체         |
| "유망한" / "기대되는"        | 임상 근거(반응률, 생존율) 인용         |
| "지속적인 관심이 필요하다"   | "약제팀은 X 시점에 Y를 확인해야 한다"  |
```

### 2-5. 생애주기별 분기

동일한 프롬프트로 모든 상태를 처리하지 마라. 상태별 분기를 명시하라:

```
[미허가 약물] → 허가 전 접근 경로 (KODC 긴급도입, EAP, 임상시험)
[허가 완료 + 비급여] → 비급여 처방 실무 (절차, 실손보험, 약가 협상)
[급여 등재 완료] → 처방 최적화 (적응증별 급여 기준, PA, DUR)
```

해당되지 않는 경로는 반드시 생략하라.

---

## Part 3. 기법 적용 기준

### 3-1. Few-Shot — 완전한 입출력 쌍

**규칙**: 톤/스타일 예시 ≠ Few-shot. 반드시 **실제 입력 → 실제 출력 전체**를 보여줘라.

```
BAD (톤 예시만):
  GOOD: "headline": "FDA, KRAS G12C 이중억제제 승인 완료"
  BAD:  "headline": "새로운 항암제가 승인될 예정입니다"

GOOD (완전한 입출력 쌍):
  입력: {"inn": "PEMBROLIZUMAB", "fda_status": "AP", "fda_date": "2014-09-04", ...}
  출력: {"headline": "...", "key_points": [...], "global_insight_text": "...", ...}
```

**Min et al. (2022) 핵심 발견**: 라벨 공간의 가시성과 포맷 일관성이 가장 중요. 무작위 라벨이라도 포맷만 맞으면 성능 향상.

**설계 팁**:
- 카테고리당 균형 잡힌 예시 (편향 방지)
- 경계 사례 포함 (모호한 입력)
- 예시 순서를 무작위로 (순서 편향 방지)
- 최소 2-3쌍, 복잡한 작업은 3쌍 이상

### 3-2. Chain-of-Thought — 추론 과정 시연

**규칙**: 규칙만 나열하지 마라. 실제 추론 과정을 예시로 보여줘라.

```
BAD (규칙만):
  - 승인일 < 오늘 → "승인 완료"
  - 승인일 > 오늘 → "승인 예정"

GOOD (추론 과정 시연):
  예시: fda_date=2025-03-28, 오늘=2026-03-30
  → 2025-03-28 < 2026-03-30
  → 과거
  → "2025-03-28 FDA 승인 완료"

  예시: fda_date=2026-09-15, 오늘=2026-03-30
  → 2026-09-15 > 2026-03-30
  → 미래
  → "2026-09-15 FDA 승인 예정"
```

**3가지 방법**:
1. Few-shot CoT: 예시에 추론 과정 포함
2. Zero-shot CoT: "단계별로 생각하라" 추가
3. Auto-CoT: 클러스터링으로 자동 예시 생성

**적용 기준**: 추론이 필요한 작업(날짜 비교, 분류, 판단)에는 반드시 CoT를 쓰라. 단순 변환/생성에는 불필요.

### 3-3. Prompt Chaining — 복잡한 작업 분할

**규칙**: 한 프롬프트에 5개 이상의 독립적 작업을 넣지 마라. 분할하라.

```
BAD (한 번에 전부):
  "3개 스트림 요약 읽기 + 교차 분석 + top 5 선정 + 리스크 + 기회 + 내일 주시"

GOOD (2단계):
  Step 1: "3개 스트림에서 교차 신호 추출 + top 5 선정"
  Step 2: "Step 1 결과로 executive summary + risk/opportunity 도출"
```

**장점**: 디버깅 용이, 실패 지점 특정 가능, 각 단계 품질 검증 가능.

### 3-4. Self-Consistency — 다중 경로 일관성

동일 프롬프트를 N회 실행하고, 가장 일관된 답을 선택. 산술/추론 작업에서 greedy decoding 대비 정확도 향상.

### 3-5. RAG / Generated Knowledge — 사실성 확보

- 외부 문서를 검색하여 컨텍스트로 주입 (RAG)
- 모델이 먼저 배경 지식을 생성한 뒤 최종 답변 (Generated Knowledge)
- **RegScan에서**: `_extract_drug_intel()`이 이 역할. 14필드로 자르면서 중요 정보가 잘리지 않도록 주의.

### 3-6. LLM-as-Judge — 품질 평가

| 패턴 | 설명 | 적용 |
|------|------|------|
| **Pointwise** | 단일 응답 1-5점 채점 | 브리핑 품질 평가 |
| **Pairwise** | 두 응답 비교 | A/B 프롬프트 비교 |
| **Reference-based** | 정답 대조 | 팩트 검증 |
| **Multi-criteria** | 다차원 평가 | 종합 루브릭 |

**편향 주의**: 장문 편향(긴 답 선호), 위치 편향(첫 번째 선호), 자기 선호(자기 출력 선호), 스타일 편향.

---

## Part 4. 테스트 & 품질 관리

### 4-1. 9가지 테스트 규칙 (Fastcampus Part 6)

1. 최소 **2개 버전** 비교 테스트
2. 버전에 **기능적 이름** 부여 (v1, v2 X → ner_validation_fewshot, ner_validation_cot)
3. 하위 카테고리까지 **세분화**하여 버전 관리
4. **목표 & 기대 성능** 문서화
5. **실제 사용자 데이터** 사용 (인위적 데이터 X)
6. **테스트 데이터셋** 구축 (JSONL)
7. 최소 **10회 이상** 생성
8. **3명 이상** 이해관계자 참여
9. **다양한 모델**에서 테스트

### 4-2. 루브릭 평가 (5점 척도, 총 25점)

| 기준 | 1점 | 3점 | 5점 |
|------|-----|-----|-----|
| **정확성** | 팩트 오류 다수 | 일부 부정확 | 팩트 완벽 |
| **일관성** | 매번 다른 결과 | 대체로 일관 | 항상 일관 |
| **유용성** | 실무 적용 불가 | 일부 유용 | 즉시 적용 가능 |
| **문법/스타일** | 어색하고 상투적 | 보통 | 기사체, 데이터 주어 |
| **모델 호환** | 특정 모델만 작동 | 2-3개 작동 | 주요 모델 전부 |

**기준**: 21/25 이상이면 프로덕션 투입 가능.

### 4-3. 정성 분석 3단계

1. **목표 확인**: 키워드 추출, 문장 구조 분석
2. **구조 분석**: 흐름 논리 평가
3. **효율 평가**: 길이 적정성, 컨텍스트 충분성

### 4-4. 정량 테스트

- N-generation (N>100): 패턴 분석
- 모델 간 비교: 동일 프롬프트로 GPT/Gemini/Claude 비교
- 비용 추적: 토큰 사용량, 모델별 단가 산출

---

## Part 5. 버전 관리

### 5-1. 시맨틱 버전닝 (Major.Minor.Patch)

| 변경 | 버전 업 | 예시 |
|------|---------|------|
| 새 기능 / 구조 변경 / 토큰 대폭 변경 | Major | 1.0 → 2.0 |
| 부분 수정 / 개선 | Minor | 1.0 → 1.1 |
| 오타 / 출력 버그 | Patch | 1.0.0 → 1.0.1 |

### 5-2. 프롬프트 파일 메타데이터

```yaml
name: stream_briefing_therapeutic
version: 2.0.0
description: "치료영역 스트림 Executive Briefing"
model: {name: gpt-5.2, temperature: 0.3, max_completion_tokens: 2500}
techniques: [few-shot, cot, fact-insight-separation, lifecycle-branching]
expected_behavior: "과거 약물 → '승인 완료', 미래 약물 → '승인 예정'"
change_log: "1.2.0에서 Few-shot 완전 입출력 추가, CoT 추론 시연 추가"
```

### 5-3. 네이밍 규칙

`{시스템명}-{시맨틱버전}` 형식:
- `drug-briefing-4.1.0`
- `stream-briefing-2.0.0`
- `ai-pipeline-reasoning-1.0.0`

---

## Part 6. 실행 체크리스트

프롬프트를 작성하거나 리뷰할 때 아래를 확인하라:

### 작성 시 체크리스트

- [ ] 4구성요소 (Instruction/Context/Input/Output) 구분자로 분리했는가?
- [ ] DO 중심 지시인가? ("하지마라" 수 < "해라" 수)
- [ ] Fact/Insight가 분리되어 있는가?
- [ ] Few-shot이 있다면 완전한 입출력 쌍인가?
- [ ] 추론이 필요한 작업에 CoT 과정이 시연되어 있는가?
- [ ] 5개 이상 독립 작업이 한 프롬프트에 있지 않은가?
- [ ] 금지표현 대안표가 있는가?
- [ ] 생애주기별 분기가 필요한 경우 명시되어 있는가?
- [ ] 출력 스키마가 구체적인가 (필드명, 타입, 길이 제한)?
- [ ] 시맨틱 버전이 부여되어 있는가?

### 리뷰 시 루브릭

위 4-2 루브릭으로 채점 후:
- 21점 이상: 프로덕션 OK
- 16-20점: 개선 후 재테스트
- 15점 이하: 재설계

---

## Part 7. 엔터프라이즈 참고 (선택)

### NAVER D2 — 코드에서 프롬프트 분리
- 프롬프트를 코드에 하드코딩하지 마라
- 버전 관리 도구(Vitess/Langfuse)에서 관리
- 배포 없이 프롬프트 변경 가능한 구조

### 배민 AI Platform 2.0 — LLMOps 4컴포넌트
- GenAI Studio (Langfuse): 프롬프트 버전 + Observability
- GenAI SDK (LiteLLM): 모델 통합 인터페이스 + Fallback
- GenAI API Gateway: OpenAI 호환 + Routing
- GenAI Labs: 실험 + Golden Dataset 평가

### 평가 메트릭 (Ragas/ARES)
- FAITHFULNESS: 생성 내용이 컨텍스트에 충실한가
- CONTEXT_PRECISION: 관련 컨텍스트가 상위에 있는가
- ANSWER_SEMANTIC_SIMILARITY: 정답과 의미적으로 유사한가

---

## 참고 자료

| 출처 | 경로 |
|------|------|
| Prompt Engineering Guide | `C:\Jimin\Prompt-Engineering-Guide\pages\` |
| 학습 노트 (01~08) | `C:\Jimin\Prompt-Engineering-Guide\_learning\guide\` |
| Fastcampus 분석 | `C:\Jimin\Prompt-Engineering-Guide\_learning\inspirations\from_sujin\fastcampus\` |
| NAVER D2 분석 | `C:\Jimin\Prompt-Engineering-Guide\_learning\inspirations\naver_d2\` |
| 배민 분석 | `C:\Jimin\Prompt-Engineering-Guide\_learning\inspirations\woowahan\` |
| 실험 시스템 | `C:\Jimin\Prompt-Engineering-Guide\_learning\experiments\` |
| RegScan V4 프롬프트 | `C:\Jimin\RegScan\output\briefings\snapshots\2026-02-25_v4\_prompts.txt` |
| RegScan 버전 체계 | `C:\Jimin\RegScan\docs\research\llm\prompt-versioning.md` |
