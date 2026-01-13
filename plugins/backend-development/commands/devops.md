---
description: CI/CD, 컨테이너화, 배포 설정을 단계별로 안내합니다. Trigger on "/devops", "CI/CD 만들어줘", "도커 설정해줘", "배포 설정해줘", or when user needs DevOps configuration.
---

# DevOps

CI/CD, 컨테이너화, 배포 설정을 단계별로 안내합니다.

## Usage

```bash
/devops [options]
```

## Parameters

- `--docker`: Docker 설정만
- `--ci`: CI/CD 파이프라인만
- `--k8s`: Kubernetes 매니페스트만
- `--monitoring`: 모니터링 설정만
- `--quick`: 빠른 시작 (Docker + GitHub Actions)

## Protocol

### Phase 0: 상태 확인 (필수)

```
┌─────────────────────────────────────────────┐
│ 📊 Project Status                           │
├─────────────────────────────────────────────┤
│ Type        : [Node.js / Python / Go / ...] │
│ Container   : [없음 / Dockerfile 있음]       │
│ CI/CD       : [없음 / GitHub Actions / ...]   │
│ Cloud       : [없음 / AWS / GCP / Azure]     │
│ Monitoring  : [없음 / Prometheus / ...]      │
├─────────────────────────────────────────────┤
│ 💡 Recommendation: [다음 단계 제안]          │
└─────────────────────────────────────────────┘
```

### Phase 1: 요구사항 분석

프로젝트 타입, 배포 규모, 기술 요구사항 파악

### Phase 2: 인프라 스택 선정

```
선택해주세요:
1. 추천 스택 ⭐ → Docker + Kubernetes + GitHub Actions
2. 간단하게 시작 → Docker Compose (로컬/단일 서버)
3. 서버리스 → Vercel / Railway / Render
4. 클라우드 네이티브 → AWS ECS / GCP Cloud Run
5. 직접 선택
```

### Phase 3: 컨테이너화 (--docker)

Dockerfile, .dockerignore, docker-compose.yml 생성

### Phase 4: CI/CD (--ci)

GitHub Actions 워크플로우 생성

### Phase 5: Kubernetes (--k8s)

Deployment, Service, Ingress 매니페스트 생성

### Phase 6: 모니터링 (--monitoring)

Prometheus, Grafana 설정 생성

## Output Files

### Docker (--docker)

```
Dockerfile
.dockerignore
docker-compose.yml
docker-compose.prod.yml
```

### CI/CD (--ci)

```
.github/
└── workflows/
    ├── ci.yml          # 테스트, 린트
    ├── deploy.yml      # 배포
    └── release.yml     # 릴리즈 (선택)
```

### Kubernetes (--k8s)

```
k8s/
├── deployment.yaml
├── service.yaml
├── ingress.yaml
├── configmap.yaml
└── secrets.yaml
```

### Monitoring (--monitoring)

```
monitoring/
├── prometheus.yml
├── grafana/
│   └── dashboards/
│       └── app.json
└── alertmanager.yml
```

## Templates

### Dockerfile (NestJS)

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### GitHub Actions CI

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run build
```

## Examples

### 빠른 시작

```
입력: /devops --quick

결과:
- Dockerfile (멀티스테이지 빌드)
- .dockerignore
- docker-compose.yml (로컬 개발용)
- .github/workflows/ci.yml
```

### Docker만

```
입력: /devops --docker

결과:
- Dockerfile
- .dockerignore
- docker-compose.yml
- docker-compose.prod.yml
```

### 전체 설정

```
입력: /devops

Phase 0: 상태 확인
Phase 1-2: 요구사항 분석, 스택 선정
Phase 3-6: 선택한 항목 순차 생성
```

## Skill Reference

> 📚 이 Command는 `devops-architect` 스킬의 전체 플로우(Phase 0-7)를 실행합니다.
> 상세 프로토콜: [skills/devops-architect/skills/SKILL.md](../skills/devops-architect/skills/SKILL.md)

## Integration Points

| 연결 대상               | 역할                         |
| ----------------------- | ---------------------------- |
| `devops-architect` 스킬 | Phase 0-7 전체 플로우 실행   |
| `/backend` 명령어       | 백엔드가 없는 경우 먼저 실행 |
| `/auto-commit` 명령어   | 설정 완료 후 커밋            |

## Next Step

DevOps 설정 완료 후:

```
💡 인프라 설정이 완료되었습니다!

다음 단계:
  1. docker build -t myapp .
  2. docker-compose up -d
  3. git push origin main (CI/CD 트리거)
  4. `/auto-commit`으로 커밋
```

## Rules

1. **상태 확인 필수**: 모든 작업 전 Phase 0 실행
2. **중복 방지**: 기존 설정 존재 시 확인
3. **보안 우선**: 민감한 정보는 secrets로 분리
4. **멀티스테이지 빌드**: Docker 이미지 크기 최적화
5. **선택권 제공**: 강요하지 말고 옵션 제시

## $ARGUMENTS
