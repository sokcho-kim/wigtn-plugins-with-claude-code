---
description: DevOps and deployment setup helper. Trigger on "/devops", "배포 설정", "인프라 설정", "CI/CD 설정", "Docker 설정", or when user needs deployment infrastructure configuration.
---

# /devops

DevOps 및 배포 설정 헬퍼. 개발 사이클 완료 후 프로덕션 배포를 위한 인프라 설정을 지원합니다.

## Purpose

- **배포 준비** - 개발 완료된 애플리케이션의 배포 인프라 구성
- **CI/CD 파이프라인** - GitHub Actions, GitLab CI 워크플로우 설정
- **프로덕션 인프라** - Docker, Kubernetes, 클라우드 배포 설정
- **운영 환경 구성** - 모니터링, 로깅, 보안 설정

## Usage

```bash
/devops Docker 설정              # Dockerfile + docker-compose
/devops CI/CD 파이프라인         # GitHub Actions 워크플로우
/devops Kubernetes 배포          # K8s 매니페스트 생성
/devops AWS 배포                 # AWS 인프라 설정
/devops                          # 대화형 모드
```

## When to Use

**개발 사이클 완료 후 사용:**

| 상황             | 예시                          |
| ---------------- | ----------------------------- |
| 배포 준비        | "개발 완료, 이제 배포하려면?" |
| 컨테이너화 설정  | "Dockerfile 만들어줘"         |
| CI/CD 파이프라인 | "GitHub Actions 설정해줘"     |
| 클라우드 배포    | "AWS에 배포하려면?"           |
| Kubernetes 설정  | "K8s 배포 구성해줘"           |
| 모니터링 설정    | "Prometheus + Grafana 설정"   |
| 프로덕션 보안    | "프로덕션 보안 설정"          |

## Protocol

### Phase 1: 요청 파악

사용자의 요청을 파악합니다:

- 어떤 인프라 설정이 필요한가?
- 현재 프로젝트 스택은?
- 배포 환경은? (로컬/스테이징/프로덕션)
- 클라우드 플랫폼 선호도는?

### Phase 2: 컨텍스트 수집

필요한 정보를 수집합니다:

- 현재 프로젝트 구조
- 사용 중인 스택 (언어, 프레임워크)
- 기존 배포 설정 여부
- 프로젝트 규모 및 요구사항

### Phase 3: 배포 전략 결정

스킬 레퍼런스를 참조하여 결정:

| 레퍼런스                                                 | 참조 시점                |
| -------------------------------------------------------- | ------------------------ |
| `skills/devops-patterns/references/dockerfiles.md`       | Docker 설정 시           |
| `skills/devops-patterns/references/ci-cd.md`             | CI/CD 파이프라인 설정 시 |
| `skills/devops-patterns/references/kubernetes.md`        | K8s 배포 시              |
| `skills/devops-patterns/references/cloud-guides.md`      | 클라우드 배포 시         |
| `skills/devops-patterns/references/security-patterns.md` | 보안 설정 시             |
| `skills/devops-patterns/references/monitoring-setup.md`  | 모니터링 설정 시         |

### Phase 4: 설정 제공

구체적인 배포 설정을 제공:

```
## 배포 전략
- [배포 방식 선택과 이유]
- [환경 구성]

## 생성 파일
1. [파일 1 및 용도]
2. [파일 2 및 용도]
...

## 주요 설정
- [설정 1]
- [설정 2]
- [보안 고려사항]
```

### Phase 5: 후속 지원

- 추가 질문에 답변
- 필요 시 더 상세한 설명 제공
- 실제 설정 파일 생성 지원

## Example Interaction

**User:** `/devops Docker 설정`

**Response:**

```
Docker 설정을 도와드리겠습니다.

먼저 몇 가지 확인이 필요합니다:
1. 사용 중인 스택은? (예: NestJS, Express, Python FastAPI)
2. 데이터베이스는? (PostgreSQL, MySQL 등)
3. 개발 환경만? 프로덕션도?
4. 멀티 스테이지 빌드 필요한가요?
```

**User:** "NestJS, PostgreSQL, 개발+프로덕션"

**Response:**

```
## 배포 전략
- Multi-stage 빌드 (빌드/실행 분리)
- Development: Hot reload 지원
- Production: 최적화된 이미지

## 생성 파일
1. Dockerfile (Multi-stage)
2. docker-compose.yml (Development)
3. docker-compose.prod.yml (Production)
4. .dockerignore

## 주요 설정
- Node.js 20 LTS 베이스 이미지
- Non-root 사용자 실행
- Health check 설정
- 환경변수 분리
- PostgreSQL 서비스 포함 (Development)

바로 파일을 생성할까요?
```

**User:** `/devops GitHub Actions CI/CD`

**Response:**

```
GitHub Actions CI/CD 파이프라인을 설정하겠습니다.

## 파이프라인 구성
- 테스트 실행 (모든 PR)
- 빌드 검증 (모든 PR)
- Docker 이미지 빌드 (main 브랜치)
- 배포 (main 브랜치, 선택적)

## 생성 파일
1. .github/workflows/ci.yml
2. .github/workflows/cd.yml (선택)

## 주요 기능
- 자동 테스트 실행
- 코드 품질 검사 (ESLint, Prettier)
- Docker 이미지 빌드 및 푸시
- 배포 자동화 (선택)

바로 파일을 생성할까요?
```

## Integration

이 커맨드는 **개발 사이클 완료 후** 사용합니다.

```
개발 사이클:
/prd → prd-reviewer → /implement → /auto-commit
                              ^^^^^^^^^^^^
                              개발 사이클 완료

사이클 완료 후:
/devops [배포 설정] → 인프라 구성 → 배포 준비
```

**사용 시점:**

- `/auto-commit` 완료 후
- 프로덕션 배포가 필요할 때
- CI/CD 파이프라인 설정이 필요할 때
- 인프라 구성이 필요할 때

## Agent Reference

> 이 커맨드는 `backend-architect` 에이전트를 호출합니다.
> 📚 상세 프로토콜: [agents/backend-architect.md](../agents/backend-architect.md)
>
> DevOps 관련 레퍼런스:
> 📚 [skills/devops-patterns/SKILL.md](../skills/devops-patterns/SKILL.md)

## $ARGUMENTS
