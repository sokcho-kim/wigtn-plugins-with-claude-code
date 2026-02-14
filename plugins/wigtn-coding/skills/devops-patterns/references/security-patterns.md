# Security Patterns

Security patterns for deployment environments.

## Container Security

### Non-root User

**Dockerfile:**
```dockerfile
# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser

USER appuser

# Change file ownership
COPY --chown=appuser:nodejs /app/dist ./dist
```

### Minimal Base Images

**Recommended:**
```dockerfile
# Alpine-based (lightweight)
FROM node:20-alpine

# Distroless (minimal privileges)
FROM gcr.io/distroless/nodejs20
```

### Image Scanning

**In CI/CD:**
```yaml
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ghcr.io/${{ github.repository }}
    format: 'sarif'
    output: 'trivy-results.sarif'
```

## Secrets Management

### Environment Variables

**docker-compose.yml:**
```yaml
services:
  app:
    env_file:
      - .env.production
    environment:
      - DATABASE_URL=${DATABASE_URL}
      # Secrets as environment variables
```

### Kubernetes Secrets

**secrets.yaml:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: backend-secrets
type: Opaque
stringData:
  DATABASE_URL: "${DATABASE_URL}"
  JWT_SECRET: "${JWT_SECRET}"
```

**Usage:**
```yaml
envFrom:
  - secretRef:
      name: backend-secrets
```

### External Secrets Manager

**AWS Secrets Manager:**
```typescript
import { SecretsManager } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManager({ region: 'ap-northeast-2' });
const secret = await client.getSecretValue({ SecretId: 'backend-secrets' });
```

**HashiCorp Vault:**
```yaml
# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: backend-secrets
spec:
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: backend-secrets
  data:
    - secretKey: DATABASE_URL
      remoteRef:
        key: backend/database
```

## Network Security

### Network Policies (K8s)

**network-policy.yaml:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 3000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: database
      ports:
        - protocol: TCP
          port: 5432
```

### Firewall Rules

**Docker:**
```yaml
# Expose only specific ports
ports:
  - "3000:3000"  # HTTP only
  # Debug port excluded in production
```

## Access Control

### RBAC (K8s)

**service-account.yaml:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: backend-role
rules:
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: backend-rolebinding
subjects:
  - kind: ServiceAccount
    name: backend-sa
roleRef:
  kind: Role
  name: backend-role
  apiGroup: rbac.authorization.k8s.io
```

## Image Security

### Multi-stage Build

**Security Benefits:**
- Exclude build tools
- Minimal layers
- Reduced vulnerabilities

```dockerfile
FROM node:20-alpine AS builder
# Include build tools

FROM node:20-alpine AS runner
# Include runtime only
```

### Base Image Updates

**Auto Updates:**
```yaml
# Dependabot
- package-ecosystem: "docker"
  directory: "/"
  schedule:
    interval: "weekly"
```

## Runtime Security

### Read-only Filesystem

**K8s:**
```yaml
securityContext:
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1001
volumes:
  - name: tmp
    emptyDir: {}
volumeMounts:
  - name: tmp
    mountPath: /tmp
```

### Resource Limits

**K8s:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Security Context

**K8s:**
```yaml
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE  # Only what's needed
```

## TLS/SSL

### Certificate Management

**cert-manager:**
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: backend-tls
spec:
  secretName: backend-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - api.example.com
```

### Ingress TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - api.example.com
      secretName: backend-tls
```

## Security Scanning

### SAST (Static Analysis)

**CI/CD:**
```yaml
- name: Security Scan
  uses: github/super-linter@v4
  env:
    DEFAULT_BRANCH: main
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Dependency Scanning

**npm audit:**
```yaml
- name: Audit dependencies
  run: npm audit --audit-level=moderate
```

**Snyk:**
```yaml
- name: Run Snyk
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Compliance

### Audit Logging

**K8s Audit:**
```yaml
# audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: Metadata
    resources:
      - group: ""
        resources: ["secrets"]
```

### Data Encryption

**At Rest:**
- Database encryption
- Volume encryption

**In Transit:**
- TLS/SSL
- mTLS (between services)

## Best Practices

### Do's
- Non-root user
- Least privilege principle
- External secrets management
- Regular security scans
- Network policies
- Resource limits

### Don'ts
- Hardcode secrets
- Use root privileges
- Expose unnecessary ports
- Vulnerable base images
