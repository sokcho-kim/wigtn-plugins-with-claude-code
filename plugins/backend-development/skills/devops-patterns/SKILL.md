---
name: devops-patterns
description: DevOps configuration patterns and references. Use when setting up Docker, CI/CD, Kubernetes, or deployment infrastructure. Provides templates and best practices for production deployment.
allowed-tools: Read, Write, Edit, Bash
---

# DevOps Patterns

배포 인프라 설정 시 참조할 수 있는 DevOps 패턴과 설정 레퍼런스입니다.

## Purpose

- **Docker 설정** - Dockerfile, docker-compose 패턴
- **CI/CD 설정** - GitHub Actions 워크플로우
- **K8s 설정** - Kubernetes 매니페스트 패턴
- **클라우드 배포** - AWS, GCP, Vercel 가이드

## Reference Documents

Available references:

!`ls references/`

| 문서 | 용도 |
|------|------|
| [dockerfiles.md](references/dockerfiles.md) | 스택별 Dockerfile 템플릿 |
| [kubernetes.md](references/kubernetes.md) | K8s 매니페스트 패턴 |
| [ci-cd.md](references/ci-cd.md) | GitHub Actions 워크플로우 |
| [cloud-guides.md](references/cloud-guides.md) | 클라우드 배포 가이드 |
| [security-patterns.md](references/security-patterns.md) | 보안 설정 패턴 |
| [monitoring-setup.md](references/monitoring-setup.md) | 모니터링 구성 가이드 |

## Quick Reference

### Deployment Presets

| 프리셋 | 구성 | 적합한 상황 |
|--------|------|------------|
| `quick` | Docker + GitHub Actions | MVP, 빠른 시작 |
| `standard` | + Redis + K8s | 중규모 서비스 |
| `enterprise` | + ArgoCD + Prometheus | 대규모 서비스 |
| `serverless` | Vercel / Railway / Fly.io | 관리형 선호 |

### Output by Preset

| 프리셋 | 생성 파일 |
|--------|----------|
| `quick` | Dockerfile, docker-compose.yml, ci.yml |
| `standard` | + docker-compose.prod.yml, k8s/*, deploy.yml |
| `enterprise` | + hpa.yaml, monitoring/, argocd/ |

### Environment Configuration

**Development:**
- docker-compose.yml (로컬 개발)
- Hot reload 지원
- Debug 포트 노출

**Staging:**
- docker-compose.staging.yml
- 프로덕션과 유사한 환경
- 테스트 데이터

**Production:**
- k8s/ (Kubernetes 매니페스트)
- Secrets 관리 (외부)
- 모니터링 설정

### Docker Compose Example

```yaml
# Development
services:
  app:
    volumes:
      - .:/app  # Hot reload
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
      - "9229:9229"  # Debug
```

```yaml
# Production (K8s)
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### Deployment Strategies

| 전략 | 설명 | 사용 시점 |
|------|------|----------|
| Rolling | 점진적 배포 | 기본값 |
| Blue-Green | 전체 전환 | 빠른 롤백 필요 |
| Canary | 일부에 새 버전 | 리스크 최소화 |

### Security Principles

- **최소 권한 원칙** - 필요한 권한만 부여
- **심층 방어** - 다중 보안 레이어
- **외부 시크릿 관리** - 환경변수/Secrets Manager
- **정기 보안 업데이트**

### Monitoring Components

| 컴포넌트 | 역할 |
|----------|------|
| Prometheus | 메트릭 수집 |
| Grafana | 대시보드 |
| Loki / ELK | 로그 집계 |
| Sentry | 에러 트래킹 |
| Alertmanager | 알림 |

### Rollback Commands

```bash
# 즉시 롤백
kubectl rollout undo deployment/backend-api

# 특정 버전으로 롤백
kubectl rollout undo deployment/backend-api --to-revision=2

# 롤백 히스토리
kubectl rollout history deployment/backend-api
```

## Best Practices

### Do's
- Multi-stage 빌드
- Non-root 사용자
- Health check 필수
- 환경별 설정 분리
- 외부 시크릿 관리
- 구조화된 로깅
- 모니터링 설정

### Don'ts
- 민감정보 하드코딩
- 기존 설정 덮어쓰기
- 보안 설정 생략
- 단일 레플리카 프로덕션

## Usage

배포 설정 시 필요한 패턴을 레퍼런스 문서에서 찾아 참조합니다.

**예시: Docker + CI/CD 설정**
1. `dockerfiles.md` → 스택에 맞는 Dockerfile 템플릿
2. `ci-cd.md` → GitHub Actions 워크플로우
3. `security-patterns.md` → 보안 설정 확인

**예시: K8s 배포 설정**
1. `kubernetes.md` → Deployment, Service 매니페스트
2. `monitoring-setup.md` → Prometheus + Grafana 설정
3. `cloud-guides.md` → 클라우드별 K8s 설정

## Integration

`backend-architect` 에이전트가 인프라 결정 시 이 스킬의 레퍼런스를 참조합니다.

```
인프라 설정 요청
    ↓
backend-architect 에이전트
    ↓ (참조)
devops-patterns 스킬 레퍼런스
    ↓
적절한 설정 파일 생성
```
