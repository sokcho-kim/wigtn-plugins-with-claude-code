# Team Convention Plugin

기존 프로젝트 설정을 검토하고, 누락된 컨벤션만 보완합니다.

## 🎯 역할

프레임워크(Next.js, NestJS 등)로 생성한 프로젝트는 이미 ESLint가 있습니다.
이 플러그인은 **기존 설정을 유지**하고 **누락된 부분만 추가**합니다.

## 프레임워크별 기본 포함 여부

| 설정       | CRA | Next.js | NestJS | Vite |
| ---------- | --- | ------- | ------ | ---- |
| ESLint     | ✅  | ✅      | ✅     | ✅   |
| Prettier   | ❌  | ❌      | ✅     | ❌   |
| husky      | ❌  | ❌      | ❌     | ❌   |
| commitlint | ❌  | ❌      | ❌     | ❌   |
| PR 템플릿  | ❌  | ❌      | ❌     | ❌   |

**→ 대부분 husky, commitlint, PR 템플릿은 직접 추가해야 함**

## 사용법

```
/convention
"컨벤션 검토해줘", "husky 설정해줘", "PR 템플릿 만들어줘"
```

## 사용 예시

```
User: /convention

Claude:
1. "현재 설정:
   • ESLint: ✅ 있음 (next/core-web-vitals)
   • husky: ❌ 없음
   💡 추천: husky, commitlint 추가"

2. "[1] 추천 전체 / [2] Git 규칙만 / ..."

User: 1

Claude:
3. 파일 생성 (기존 ESLint 유지)
4. npm install 명령어 안내
```

## 주요 특징

- **기존 설정 유지**: 프레임워크가 만든 ESLint 등은 수정하지 않음
- **누락된 부분만 추가**: husky, commitlint, PR 템플릿 등
- **선택적 추가**: 필요한 것만 골라서 추가 가능
