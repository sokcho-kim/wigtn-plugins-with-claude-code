# PRD Plugin

모호한 기능 요청을 구조화된 PRD(Product Requirements Document) 문서로 변환합니다.

## Installation

```bash
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code
/plugin install prd
```

## Usage

```bash
# 기본 사용
/prd user-authentication

# 상세 모드
/prd plugin-marketplace --detail=full
```

## Features

- **자동 컨텍스트 분석**: 프로젝트 구조, 기존 코드, 기술 스택 자동 파악
- **구조화된 템플릿**: 10개 섹션의 상세 PRD 템플릿
- **MoSCoW 우선순위**: P0~P3 우선순위 체계
- **INVEST 기준**: 사용자 스토리 품질 검증

## PRD Structure

1. Overview (문제 정의, 목표, 범위)
2. User Stories (사용자 스토리, 수용 기준)
3. Functional Requirements (기능 요구사항)
4. Non-Functional Requirements (성능, 보안, 신뢰성)
5. UI/UX Specification (와이어프레임, 사용자 흐름)
6. Technical Design (API, DB 스키마)
7. Implementation Phases (구현 단계)
8. Success Metrics (성공 지표)
9. Risks & Mitigations (위험 및 대응)
10. Open Questions (미해결 질문)

## Output Location

PRD 파일은 다음 우선순위로 저장됩니다:
1. `prd/[feature-name].md`
2. `docs/prd/[feature-name].md`
3. `[feature-name]-prd.md`

## License

MIT
