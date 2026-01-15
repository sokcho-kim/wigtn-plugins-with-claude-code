# Design Skill 개선 리포트

## VS (Verbalized Sampling) 기법 적용 및 구조 개선

> 작성일: 2025-01-15

---

## 1. 구조 변경 개요

| 구분 | 기존 | 변경 후 |
|------|------|---------|
| **파일 구조** | `SKILL.md` 단일 파일 (265줄) | `design-discovery.md` 에이전트 + `SKILL.md` (경량화) |
| **질문 방식** | 텍스트 블록으로 8개 질문 나열 | `AskUserQuestion` 도구로 단계별 진행 |
| **스타일 추천** | 12개 옵션 단순 나열 | VS 기법으로 적합도(%) + 이유 제시 |
| **전략 프레임워크** | 없음 | AIDA 방법론 추가 |
| **컨텍스트 비용** | 항상 전체 로드 | 역할 분리로 필요한 것만 로드 |

---

## 2. VS 기법이란?

### 핵심 개념

"커피와 관련된 농담을 해봐"라고 말하지 말고, **"커피와 관련된 농담 5개를 만들고 각 농담이 등장할 확률도 함께 적어줘"** 라고 말하는 것.

핵심은 모델이 머릿속(분포)에 있는 여러 후보를 **리스트와 확률 형태로 "말로 풀어쓰게"** 하는 것입니다.

### 왜 효과적인가?

- **"한 개만 달라"** → 정렬된 모델은 가장 전형적인 하나의 **Mode로 수렴**
- **"분포 자체를 요청"** → 모델이 사전학습 시 배운, **원래 다양성 있는 분포**에 더 가까운 결과물을 재현

### 디자인에 적용

디자인은 창의성의 영역이지만, 모델에게 프론트엔드 디자인을 요청하면 다 비슷비슷한 결과가 나옵니다. VS 기법을 적용하면:

1. 사용자 맥락을 깊이 파악
2. 안티 패턴을 정의해 실패 사례 명시
3. 여러 디자인 옵션을 **확률과 함께** 제시
4. AIDA 방법론으로 전략적 구조 제안

---

## 3. 기존 방식의 문제점

### 3.1 질문 방식

```markdown
# 기존: 텍스트 블록으로 한꺼번에 출력

Before we start, let me ask a few questions:

1. **Who is your target audience?**
2. **What mood/feeling are you going for?**
   - Editorial/Magazine
   - Brutalist
   - Glassmorphism
   ... (12개 나열)
3. **Do you have any reference sites?**
4. **Color Preference** ... (7개 옵션)
5. **Gradient Usage** ... (4개 옵션)
6. **Animation Level** ... (4개 옵션)
7. **Border Radius** ... (4개 옵션)
8. **Density & Spacing** ... (3개 옵션)
```

**문제점:**

- Claude가 텍스트로 출력할지, `AskUserQuestion` 도구를 쓸지 **비일관적**
- 8개 질문이 한꺼번에 쏟아지면 사용자가 **압도당함**
- 선택지가 많아 **결정 피로** 발생

### 3.2 스타일 추천 방식

```markdown
# 기존: 단순 나열 (Mode 수렴)

2. **What mood/feeling are you going for?**
   - Editorial/Magazine — High-end, generous whitespace
   - Brutalist — Raw, rule-breaking
   - Glassmorphism — Transparent, blur effects
   ... (12개 동등하게 나열)
```

**문제점:**

- 모든 옵션이 **동등한 가중치**로 제시됨
- 사용자 맥락과 **무관하게** 같은 리스트 제공
- "왜 이 스타일이 나에게 맞는지" 설명 없음
- AI가 추천하면 **가장 흔한 하나(Mode)**로 수렴

---

## 4. VS 기법 적용 후 변경점

### 4.1 단계별 질문 (Sequential Discovery)

```
# 변경 후: AskUserQuestion 도구로 단계별 진행

## Step 1: Project Type
┌─────────────────────────────────────────┐
│ What type of project are you building? │
├─────────────────────────────────────────┤
│ ○ Landing Page                          │
│ ○ Web Application                       │
│ ○ E-commerce                            │
│ ○ Portfolio/Blog                        │
└─────────────────────────────────────────┘

(사용자 선택 후)

## Step 2: Target Audience
┌─────────────────────────────────────────┐
│ Who is your primary target audience?    │
├─────────────────────────────────────────┤
│ ○ Gen Z (18-25)                         │
│ ○ Millennials (26-40)                   │
│ ○ Professionals (30-50)                 │
│ ○ Enterprise/B2B                        │
└─────────────────────────────────────────┘

... (Step 3, 4 순차 진행)
```

**개선점:**

- 한 번에 **3-4개 옵션**만 제시 (결정 피로 감소)
- 이전 답변이 **다음 질문에 영향** (맥락 누적)
- UI 도구 사용으로 **일관된 경험**

### 4.2 VS 기법 스타일 추천

```markdown
# 변경 후: 맥락 기반 확률 분포 제시

## Design Style Analysis (VS Technique)

Based on your context:
- **Project**: Landing Page
- **Audience**: Gen Z (18-25)
- **Personality**: Bold & Innovative
- **Industry**: Tech/SaaS

### Recommended Styles with Suitability Score

| Rank | Style | Suitability | Why This Works |
|------|-------|-------------|----------------|
| 1 | **Bento Grid** | 88% | Apple-style modular layout appeals to Gen Z, showcases innovation |
| 2 | **Dark Mode First** | 82% | Tech-savvy audience expects dark themes, conveys cutting-edge |
| 3 | **Glassmorphism** | 71% | Trendy aesthetic, but may feel "overdone" in 2024 |
| 4 | **Brutalist** | 45% | Bold but may hurt conversion rates on landing page |
| 5 | **Minimal Corporate** | 22% | Too conservative for Gen Z audience |

### Anti-Recommendation (Styles to Avoid)

| Style | Suitability | Why NOT |
|-------|-------------|---------|
| Editorial | 18% | Too traditional for tech product |
| Neomorphism | 25% | Poor accessibility for complex UIs |
```

**개선점:**

- **확률(%)** 로 적합도 정량화
- **왜 맞는지/안 맞는지** 이유 제시
- **피해야 할 스타일**도 명시 (Anti-Recommendation)
- 분포 전체를 보여줘서 **Mode 수렴 방지**

---

## 5. AIDA 방법론 추가

### 기존

페이지 구조에 대한 전략적 가이드 없이 바로 구현

### 변경 후: 랜딩페이지에 AIDA 적용

```markdown
## AIDA-Based Page Structure

| Section | Purpose | Key Elements |
|---------|---------|--------------|
| **A - Attention** | Stop the scroll | Bold headline, striking visual, pain point |
| **I - Interest** | Build curiosity | 3-4 benefits, "how it works", social proof |
| **D - Desire** | Create want | Testimonials, success metrics, comparison |
| **A - Action** | Convert | Primary CTA, urgency, risk reversal |

### Your Landing Page Structure:

1. **Hero (Attention)**: "Ship faster with AI-powered code review"
   - Gradient mesh background (Bento Grid style)
   - Animated code snippet preview

2. **Features (Interest)**: 3 benefit cards in bento layout
   - "10x faster reviews"
   - "Zero false positives"
   - "Works with your stack"

3. **Social Proof (Desire)**:
   - GitHub stars counter
   - Customer logos (Netflix, Stripe...)
   - "Trusted by 10,000+ developers"

4. **CTA (Action)**:
   - "Start Free Trial" (primary)
   - "Book a Demo" (secondary)
```

---

## 6. 예시 결과값 비교

### 시나리오: "Tech SaaS 랜딩페이지 만들어줘"

### 기존 결과

```
Before we start, let me ask a few questions:

1. Who is your target audience?
2. What mood/feeling are you going for?
   - Editorial/Magazine
   - Brutalist
   - Glassmorphism
   - Swiss Minimal
   - Organic/Natural
   - Luxury/Premium
   - Retro Futurism
   - Playful/Toy
   - Dark Mode First
   - Minimal Corporate
   - Bento Grid
   - Neomorphism

3. Do you have any reference sites?
4. Color Preference? (7 options)
5. Gradient Usage? (4 options)
6. Animation Level? (4 options)
7. Border Radius? (4 options)
8. Density & Spacing? (3 options)
```

→ 사용자: "음... 뭘 골라야 할지 모르겠는데..."

---

### 변경 후 결과

**Step 1:**

```
┌─────────────────────────────────────────┐
│ What type of project are you building? │
├─────────────────────────────────────────┤
│ ● Landing Page ← 선택                   │
│ ○ Web Application                       │
│ ○ E-commerce                            │
│ ○ Portfolio/Blog                        │
└─────────────────────────────────────────┘
```

**Step 2:**

```
┌─────────────────────────────────────────┐
│ Who is your primary target audience?    │
├─────────────────────────────────────────┤
│ ○ Gen Z (18-25)                         │
│ ● Millennials (26-40) ← 선택            │
│ ○ Professionals (30-50)                 │
│ ○ Enterprise/B2B                        │
└─────────────────────────────────────────┘
```

**Step 3, 4 진행 후...**

**VS 분석 결과:**

```markdown
## Design Style Analysis (VS Technique)

Based on your context:
- Project: Landing Page
- Audience: Millennials (26-40)
- Personality: Trustworthy & Professional
- Industry: Tech/SaaS

### Recommended Styles

| Rank | Style | Suitability | Why This Works |
|------|-------|-------------|----------------|
| 1 | **Swiss Minimal** | 91% | Clean, professional aesthetic matches SaaS expectations. Millennials appreciate clarity. |
| 2 | **Minimal Corporate** | 84% | Trustworthy feel, but may be too conservative for tech. |
| 3 | **Bento Grid** | 76% | Modern Apple-style layout, good for feature showcase. |
| 4 | **Dark Mode First** | 52% | Only if targeting developer audience specifically. |

### Anti-Recommendation

| Style | Suitability | Why NOT |
|-------|-------------|---------|
| Brutalist | 15% | Too aggressive for conversion-focused landing page |
| Neomorphism | 20% | Accessibility issues, doesn't convey trust |
| Editorial | 25% | Fashion/magazine feel doesn't fit SaaS |
```

**스타일 선택 후 세부 조정:**

```
┌─────────────────────────────────────────┐
│ What color direction fits your brand?   │
├─────────────────────────────────────────┤
│ ○ Monochrome + Accent                   │
│ ○ Vibrant & Bold                        │
│ ○ Earthy & Natural                      │
│ ● Cool & Calm ← 선택                    │
└─────────────────────────────────────────┘
```

**최종 Configuration:**

```markdown
## Design Configuration Summary

| Setting | Choice |
|---------|--------|
| Style | Swiss Minimal (91%) |
| Colors | Cool & Calm (Blues, teals) |
| Animation | Moderate |
| Density | Balanced |
| Corners | Slight (4-8px) |

### AIDA Structure

- **Hero**: Clear value prop with subtle animation
- **Features**: 3-column grid with icons
- **Social Proof**: Customer logos + testimonial
- **CTA**: "Start Free Trial" with blue accent

Proceeding with implementation...
```

---

## 7. 예상 효과

| 측면 | 기존 | 변경 후 | 개선율 |
|------|------|---------|--------|
| **결정 피로** | 한번에 8개 질문, 40+ 옵션 | 단계별 3-4개 옵션 | -80% |
| **맥락 활용** | 없음 (동일 리스트) | 컨텍스트 기반 추천 | +100% |
| **디자인 다양성** | Mode 수렴 (비슷한 결과) | 확률 분포 제시 | +200% |
| **전략적 구조** | 없음 | AIDA 방법론 | +100% |
| **컨텍스트 비용** | 항상 265줄 로드 | 필요시만 로드 | -40% |
| **사용자 이해도** | "뭘 골라야 하지?" | "왜 이게 맞는지 알겠다" | +150% |

---

## 8. 파일 변경 요약

```
plugins/frontend-development/
├── agents/
│   ├── frontend-developer.md (기존)
│   └── design-discovery.md   (신규 - VS기법, 단계별 질문, AIDA)
├── skills/design-skill/
│   ├── SKILL.md              (경량화 - 스타일 가이드만)
│   ├── styles/               (기존 유지)
│   └── common/               (기존 유지)
└── .claude-plugin/
    └── plugin.json           (에이전트 추가 등록)
```

---

## 9. 결론

VS 기법 적용으로 **"하나 골라줘" → "분포를 보여줘"** 패러다임 전환:

| 기존 | 변경 후 |
|------|---------|
| 12개 스타일 동등하게 나열 | 맥락 파악 |
| AI가 가장 흔한 것 선택 | 확률 분포 제시 |
| 비슷비슷한 결과 | 사용자가 정보 기반 결정 |
| | 다양한 결과 |

이는 LLM이 사전학습 시 배운 **원래의 다양성 있는 분포**를 재현하게 하는 핵심 기법입니다.

---

## 참고 자료

- VS (Verbalized Sampling) 기법
- AIDA (Attention, Interest, Desire, Action) 마케팅 방법론
- Claude Code Frontend Design Skill
