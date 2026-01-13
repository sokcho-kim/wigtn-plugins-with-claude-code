# DevOps Architect Plugin

DevOps 경험이 없어도 올바른 인프라를 설계하고 구축할 수 있도록 도와주는 플러그인입니다.

## Installation

```bash
/plugin marketplace add wigtn/wigtn-plugins-with-claude-code
/plugin install devops-architect
```

## Usage

```bash
/devops                  # 대화형 가이드 시작
"CI/CD 만들어줘"          # 자연어로 요청
"도커 설정해줘"           # 컨테이너화 요청
"배포 설정해줘"           # 배포 전략 요청
```

## What It Does

프로젝트를 분석하고, 단계별로 DevOps 인프라를 설계합니다:

```
┌─────────────────────────────────────────────┐
│ 📋 요구사항 분석                              │
│   ↓                                         │
│ 🛠️ 인프라 스택 선정 (Docker, K8s, Cloud)    │
│   ↓                                         │
│ 🐳 컨테이너화 설계 (Dockerfile, Compose)     │
│   ↓                                         │
│ 🔄 CI/CD 설계 (GitHub Actions, 파이프라인)   │
│   ↓                                         │
│ 📊 모니터링/로깅 설계 (Prometheus, Grafana)   │
│   ↓                                         │
│ 🚀 배포 전략 (Blue-Green, Canary, Rolling)   │
│   ↓                                         │
│ ✅ 구현 (파일 생성, 설정 안내)                │
└─────────────────────────────────────────────┘
```

## Features

- **요구사항 기반 설계**: 프로젝트 타입과 규모에 맞는 인프라 추천
- **스택 추천**: 상황에 맞는 클라우드/컨테이너/CI/CD 비교 및 추천
- **컨테이너화**: Dockerfile, docker-compose.yml 자동 생성
- **CI/CD 파이프라인**: GitHub Actions, GitLab CI 등 설정
- **모니터링/로깅**: Prometheus, Grafana, ELK Stack 구성
- **보안 우선**: 기본 보안 설정 항상 포함
- **초보자 친화적**: 전문 용어 쉽게 설명

## Example

```
User: "Next.js 앱 배포 설정해줘"

Claude:
┌─────────────────────────────────────────────┐
│ 📊 Project Status                           │
├─────────────────────────────────────────────┤
│ Type        : Next.js                       │
│ Container   : Not found                     │
│ CI/CD       : Not found                     │
│ Cloud       : Not configured                 │
└─────────────────────────────────────────────┘

요구사항을 분석했어요:
• 트래픽: 중규모
• 데이터베이스: PostgreSQL
• 파일 저장: S3 필요

스택을 선택해주세요:
[추천 스택으로 바로 시작] [간단하게 시작] [서버리스]
```

## Supported Stacks

| 카테고리           | 옵션                                         |
| ------------------ | -------------------------------------------- |
| **클라우드**       | AWS, GCP, Azure, DigitalOcean, 자체 호스팅   |
| **컨테이너**       | Docker, Podman                               |
| **오케스트레이션** | Kubernetes, Docker Swarm, ECS, Cloud Run     |
| **CI/CD**          | GitHub Actions, GitLab CI, CircleCI, Jenkins |
| **모니터링**       | Prometheus + Grafana, Datadog, CloudWatch    |
| **로깅**           | ELK Stack, Loki, CloudWatch Logs             |
| **IaC**            | Terraform, Pulumi, Ansible                   |

### 빠른 시작 프리셋

| 프리셋            | 구성                                 |
| ----------------- | ------------------------------------ |
| 추천 ⭐           | Docker + Kubernetes + GitHub Actions |
| 간단하게 시작     | Docker Compose (로컬/단일 서버)      |
| 서버리스          | Vercel / Railway / Render            |
| 클라우드 네이티브 | AWS ECS / GCP Cloud Run              |

## Workflow

1. **상태 확인**: 기존 설정 자동 감지
2. **요구사항 분석**: 프로젝트 타입, 규모 파악
3. **스택 선정**: 클라우드, 컨테이너, CI/CD 선택
4. **컨테이너화**: Dockerfile, docker-compose.yml 생성
5. **CI/CD**: 파이프라인 설정 파일 생성
6. **모니터링**: 메트릭/로깅 설정
7. **배포 전략**: Blue-Green, Canary 등 선택
8. **구현**: 실제 파일 생성 및 안내

## Common Use Cases

- **웹 애플리케이션 배포**: Next.js, React, Vue 등
- **백엔드 API 배포**: NestJS, Express, FastAPI 등
- **마이크로서비스**: 여러 서비스 조합
- **데이터 파이프라인**: ETL, 스트리밍 처리
- **CI/CD 구축**: 자동화된 빌드/테스트/배포

## License

MIT
