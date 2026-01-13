# DevOps Stack Reference

DevOps 스택 선정 시 참고하는 상세 비교표입니다.

## 1. 클라우드 플랫폼

### Public Cloud

| Platform         | 장점                         | 단점                     | 추천 상황                    |
| ---------------- | ---------------------------- | ------------------------ | ---------------------------- |
| **AWS** ⭐       | 가장 큰 생태계, 서비스 다양  | 복잡함, 비용 관리 어려움 | 엔터프라이즈, 대규모         |
| **GCP**          | Kubernetes 네이티브, ML 강점 | 생태계 작음              | Kubernetes 중심, ML 프로젝트 |
| **Azure**        | Microsoft 통합, 엔터프라이즈 | 복잡함                   | Microsoft 스택 사용시        |
| **DigitalOcean** | 간단함, 가격 투명            | 기능 제한적              | 중소규모, 빠른 시작          |
| **Linode**       | 가격 경쟁력                  | 기능 제한적              | 소규모, 예산 제약            |

### 서버리스/관리형 플랫폼

| Platform    | 특징                         | 추천 상황           |
| ----------- | ---------------------------- | ------------------- |
| **Vercel**  | 프론트엔드 최적화, 자동 배포 | Next.js, React, Vue |
| **Railway** | 간단함, PostgreSQL 포함      | 빠른 프로토타입     |
| **Render**  | Heroku 대안, 무료 티어       | 중소규모 웹앱       |
| **Fly.io**  | Edge 배포, 글로벌            | 낮은 레이턴시 필요  |
| **Netlify** | 정적 사이트, JAMstack        | 정적 사이트, Gatsby |

---

## 2. 컨테이너 기술

| 기술           | 특징                  | 추천 상황                |
| -------------- | --------------------- | ------------------------ |
| **Docker** ⭐  | 표준, 생태계 큼       | 대부분의 경우            |
| **Podman**     | Rootless, Docker 호환 | 보안 중요, Rootless 필요 |
| **containerd** | 경량, Kubernetes 기본 | Kubernetes 사용시        |

---

## 3. 오케스트레이션

| 기술              | 특징                    | 추천 상황           |
| ----------------- | ----------------------- | ------------------- |
| **Kubernetes** ⭐ | 표준, 확장성, 생태계    | 프로덕션, 대규모    |
| **Docker Swarm**  | 간단함, Docker 네이티브 | 소규모, 간단한 설정 |
| **Nomad**         | 멀티 클라우드, 유연함   | 복잡한 워크로드     |
| **ECS/Fargate**   | AWS 관리형              | AWS 사용시, 간단함  |
| **Cloud Run**     | 서버리스 컨테이너       | GCP, 트래픽 변동 큼 |

---

## 4. CI/CD

### 클라우드 기반

| 플랫폼                | 특징                       | 추천 상황                |
| --------------------- | -------------------------- | ------------------------ |
| **GitHub Actions** ⭐ | GitHub 통합, 무료          | GitHub 사용시            |
| **GitLab CI**         | 통합 플랫폼, 강력함        | GitLab 사용시            |
| **CircleCI**          | 빠름, 병렬 실행            | 성능 중요                |
| **Jenkins**           | 자체 호스팅, 플러그인 많음 | 온프레미스, 커스터마이징 |

### 서버리스 CI/CD

| 플랫폼                 | 특징       |
| ---------------------- | ---------- |
| **AWS CodePipeline**   | AWS 통합   |
| **Google Cloud Build** | GCP 통합   |
| **Azure DevOps**       | Azure 통합 |

---

## 5. 모니터링

### 메트릭 수집

| 기술              | 특징              | 추천 상황                   |
| ----------------- | ----------------- | --------------------------- |
| **Prometheus** ⭐ | 오픈소스, 표준    | 대부분의 경우               |
| **Datadog**       | 올인원, 사용 편의 | 예산 있음, 빠른 설정        |
| **New Relic**     | APM 강점          | 애플리케이션 성능 분석      |
| **CloudWatch**    | AWS 통합          | AWS 사용시                  |
| **Grafana Cloud** | 관리형 Prometheus | Prometheus + 관리 필요 없음 |

### 시각화

| 기술                   | 특징                          |
| ---------------------- | ----------------------------- |
| **Grafana** ⭐         | Prometheus 표준, 커스터마이징 |
| **Datadog Dashboards** | Datadog 통합                  |
| **Kibana**             | ELK Stack 통합                |

---

## 6. 로깅

| 기술                | 특징                              | 추천 상황         |
| ------------------- | --------------------------------- | ----------------- |
| **ELK Stack** ⭐    | Elasticsearch + Logstash + Kibana | 대규모, 검색 필요 |
| **Loki**            | Grafana 통합, 경량                | Grafana 사용시    |
| **Fluentd**         | 로그 수집기, 유연함               | 다양한 소스       |
| **CloudWatch Logs** | AWS 통합                          | AWS 사용시        |
| **Splunk**          | 엔터프라이즈급                    | 대기업, 규정 준수 |

---

## 7. 인프라 as Code (IaC)

| 기술               | 특징                             | 추천 상황              |
| ------------------ | -------------------------------- | ---------------------- |
| **Terraform** ⭐   | 멀티 클라우드, 선언적            | 대부분의 경우          |
| **Pulumi**         | 코드로 작성 (TypeScript, Python) | 개발자 친화적          |
| **CloudFormation** | AWS 네이티브                     | AWS만 사용             |
| **Ansible**        | 설정 관리, 멱등성                | 서버 설정, 배포 자동화 |

---

## 8. 배포 전략

| 전략            | 설명                          | 추천 상황   |
| --------------- | ----------------------------- | ----------- |
| **Blue-Green**  | 새/기존 버전 동시 운영, 전환  | 무중단 필수 |
| **Canary**      | 소수 트래픽만 새 버전, 점진적 | 위험 최소화 |
| **Rolling**     | 하나씩 교체, 점진적 업데이트  | 일반적      |
| **Recreate**    | 중단 후 재생성                | 개발 환경   |
| **A/B Testing** | 트래픽 분할, 비교 테스트      | 기능 테스트 |

---

## 9. 보안

### Secrets 관리

| 기술                    | 특징             | 추천 상황         |
| ----------------------- | ---------------- | ----------------- |
| **HashiCorp Vault** ⭐  | 오픈소스, 강력함 | 자체 호스팅       |
| **AWS Secrets Manager** | AWS 통합         | AWS 사용시        |
| **GCP Secret Manager**  | GCP 통합         | GCP 사용시        |
| **Kubernetes Secrets**  | K8s 네이티브     | Kubernetes 사용시 |
| **1Password Secrets**   | 사용자 친화적    | 소규모 팀         |

### 컨테이너 보안

| 기술       | 용도                 |
| ---------- | -------------------- |
| **Trivy**  | 이미지 취약점 스캔   |
| **Snyk**   | 종합 보안 스캔       |
| **Falco**  | 런타임 보안 모니터링 |
| **Notary** | 이미지 서명          |

---

## 10. 네트워킹

| 기술            | 특징                      | 추천 상황          |
| --------------- | ------------------------- | ------------------ |
| **Nginx** ⭐    | 리버스 프록시, 로드밸런서 | 대부분의 경우      |
| **Traefik**     | 자동 인증서, K8s 통합     | Kubernetes, 자동화 |
| **HAProxy**     | 고성능 로드밸런서         | 고성능 필요        |
| **CloudFlare**  | CDN, DDoS 방어            | 글로벌 트래픽      |
| **AWS ALB/NLB** | AWS 로드밸런서            | AWS 사용시         |

---

## 11. 스토리지

| 기술              | 특징                 | 추천 상황     |
| ----------------- | -------------------- | ------------- |
| **AWS S3** ⭐     | 객체 스토리지 표준   | 대부분의 경우 |
| **Cloudflare R2** | S3 호환, egress 무료 | 트래픽 많음   |
| **GCS**           | GCP 통합             | GCP 사용시    |
| **MinIO**         | 셀프 호스팅 S3       | 온프레미스    |
| **EBS/EFS**       | 블록/파일 스토리지   | 컨테이너 볼륨 |

---

## 12. 스택 조합 추천

### 초보자 / 빠른 시작

```
Docker + Docker Compose + GitHub Actions
→ 로컬 개발, 간단한 배포
→ 나중에 클라우드로 전환 쉬움
```

### 일반 프로덕션

```
Docker + Kubernetes + GitHub Actions + Prometheus + Grafana
→ 대부분의 서비스에 적합
→ 확장성, 모니터링 포함
```

### 서버리스

```
Vercel / Railway / Render
→ 백엔드 코드 최소화
→ 자동 스케일링, 관리형
```

### AWS 네이티브

```
Docker + ECS/Fargate + CodePipeline + CloudWatch
→ AWS 생태계 통합
→ 관리형 서비스 활용
```

### GCP 네이티브

```
Docker + Cloud Run / GKE + Cloud Build + Cloud Monitoring
→ GCP 생태계 통합
→ Kubernetes 네이티브
```

### 엔터프라이즈

```
Kubernetes + Terraform + Prometheus + Grafana + Vault + ELK
→ 대기업 표준
→ 보안, 규정 준수
```

### 마이크로서비스

```
Kubernetes + Istio + Prometheus + Jaeger + ArgoCD
→ 서비스 메시, 분산 추적
→ GitOps 배포
```

---

## 13. 비용 비교 (월 예상)

| 스택                           | 소규모  | 중규모    | 대규모 |
| ------------------------------ | ------- | --------- | ------ |
| **Docker Compose (자체 서버)** | $10-50  | $100-500  | $1000+ |
| **Railway/Render**             | $5-20   | $50-200   | $500+  |
| **AWS ECS**                    | $20-100 | $200-1000 | $2000+ |
| **GCP Cloud Run**              | $10-50  | $100-500  | $1000+ |
| **Kubernetes (GKE)**           | $50-200 | $500-2000 | $5000+ |

> 참고: 실제 비용은 트래픽, 저장소, 네트워크 사용량에 따라 달라집니다.

---

## 14. 학습 곡선

| 기술               | 난이도   | 학습 시간 |
| ------------------ | -------- | --------- |
| **Docker**         | ⭐⭐     | 1-2주     |
| **Docker Compose** | ⭐       | 1-2일     |
| **Kubernetes**     | ⭐⭐⭐⭐ | 1-3개월   |
| **Terraform**      | ⭐⭐⭐   | 2-4주     |
| **Prometheus**     | ⭐⭐⭐   | 2-3주     |
| **GitHub Actions** | ⭐⭐     | 1주       |

---

## 15. 도구 체인 예시

### 최소 구성 (MVP)

```
GitHub → GitHub Actions → Docker Hub → 단일 서버 (Docker)
```

### 표준 구성

```
GitHub → GitHub Actions → ECR/GCR → Kubernetes → Prometheus + Grafana
```

### 엔터프라이즈 구성

```
GitLab → GitLab CI → Harbor → Kubernetes → Prometheus + Grafana + ELK + Vault + Istio
```
