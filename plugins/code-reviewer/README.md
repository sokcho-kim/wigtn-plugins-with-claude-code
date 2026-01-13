# Code Reviewer

구현 완료된 코드를 분석하여 엣지케이스, 보안 취약점, 성능 이슈 등 우려사항을 주석으로 표시합니다.

## 사용법

```
/review                    # 최근 수정 파일 리뷰
/review src/api/           # 특정 디렉토리 리뷰
/review src/auth.ts        # 특정 파일 리뷰
코드 리뷰해줘              # 자연어로 요청
```

## 주석 태그

| 태그        | 용도             | 긴급도 |
| ----------- | ---------------- | ------ |
| `SECURITY:` | 보안 취약점      | 🔴     |
| `FIXME:`    | 버그 가능성      | 🔴     |
| `WARNING:`  | 주의 필요        | 🟠     |
| `TODO:`     | 미완성/추후 개선 | 🟡     |
| `PERF:`     | 성능 이슈        | 🟡     |
| `HACK:`     | 임시 해결책      | 🟡     |
| `NOTE:`     | 설명/컨텍스트    | 🟢     |

## 검토 관점

- 🔒 **보안**: SQL Injection, XSS, 인증/인가, 민감정보 노출
- ⚡ **성능**: N+1 쿼리, 메모리 누수, 캐싱, 리렌더링
- 🐛 **엣지케이스**: null 처리, 에러 핸들링, 동시성
- 🔧 **유지보수**: 매직넘버, 중복코드, 타입 안전성

## 예시

**Before:**

```typescript
const user = await db.user.findUnique({ where: { email } });
if (user.password === password) {
  return { token: generateToken(user) };
}
```

**After:**

```typescript
const user = await db.user.findUnique({ where: { email } });
// FIXME: user가 null일 경우 크래시
// - if (!user) return { error: "Not found" } 추가 필요

// SECURITY: 평문 비밀번호 비교
// - bcrypt.compare() 사용 권장
if (user.password === password) {
  return { token: generateToken(user) };
}
```

## 출력 예시

```
┌─────────────────────────────────────────────────────┐
│ 📋 Code Review Summary                              │
├─────────────────────────────────────────────────────┤
│ 🔴 Critical: 2개                                    │
│   • auth.ts:15 - SECURITY: 비밀번호 평문 비교       │
│   • api.ts:8 - FIXME: 입력 검증 없음               │
│                                                     │
│ 🟡 Warning: 3개                                     │
│   • list.tsx:22 - PERF: N+1 쿼리                   │
│   • form.tsx:45 - TODO: 에러 메시지 개선           │
└─────────────────────────────────────────────────────┘
```

## 특징

- 🧠 **Opus 모델** 사용으로 깊이 있는 분석
- 📝 **구체적 해결책** 제시
- 🎯 **긴급도 분류**로 우선순위 파악
- ✅ **긍정적 피드백**도 포함 (좋은 패턴 인정)
