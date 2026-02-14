# Cloud Provider Reference

Deployment patterns and integration guides by cloud provider.

## AWS (EKS)

### ECR Push

```bash
# ECR login
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_URL

# Image tag & push
docker tag app:latest $ECR_URL/app:latest
docker push $ECR_URL/app:latest
```

### EKS Deployment

```bash
# Configure kubeconfig
aws eks update-kubeconfig --name my-cluster --region $REGION

# Deploy
kubectl apply -f k8s/
```

### GitHub Actions (AWS)

```yaml
- name: Configure AWS
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ap-northeast-2

- name: Login to ECR
  uses: aws-actions/amazon-ecr-login@v2

- name: Deploy to EKS
  run: |
    aws eks update-kubeconfig --name my-cluster
    kubectl apply -f k8s/
```

## GCP (GKE)

### Artifact Registry Push

```bash
# Authentication
gcloud auth configure-docker $REGION-docker.pkg.dev

# Image tag & push
docker tag app:latest $REGION-docker.pkg.dev/$PROJECT/app:latest
docker push $REGION-docker.pkg.dev/$PROJECT/app:latest
```

### GKE Deployment

```bash
# Configure kubeconfig
gcloud container clusters get-credentials my-cluster --zone $ZONE

# Deploy
kubectl apply -f k8s/
```

### GitHub Actions (GCP)

```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v2
  with:
    credentials_json: ${{ secrets.GCP_SA_KEY }}

- name: Setup GCloud
  uses: google-github-actions/setup-gcloud@v2

- name: Deploy to GKE
  run: |
    gcloud container clusters get-credentials my-cluster --zone $ZONE
    kubectl apply -f k8s/
```

## Azure (AKS)

### ACR Push

```bash
# ACR login
az acr login --name $ACR_NAME

# Image tag & push
docker tag app:latest $ACR_NAME.azurecr.io/app:latest
docker push $ACR_NAME.azurecr.io/app:latest
```

### AKS Deployment

```bash
# Configure kubeconfig
az aks get-credentials --resource-group $RG --name my-cluster

# Deploy
kubectl apply -f k8s/
```

## Serverless

### Vercel

```bash
# Install CLI
npm i -g vercel

# Deploy
vercel --prod
```

**vercel.json:**
```json
{
  "version": 2,
  "builds": [
    { "src": "dist/main.js", "use": "@vercel/node" }
  ],
  "routes": [
    { "src": "/(.*)", "dest": "dist/main.js" }
  ]
}
```

### Railway

```bash
# Install CLI
npm i -g @railway/cli

# Login & deploy
railway login
railway up
```

**railway.toml:**
```toml
[build]
builder = "DOCKERFILE"
dockerfilePath = "Dockerfile"

[deploy]
healthcheckPath = "/health"
restartPolicyType = "ON_FAILURE"
```

### Fly.io

```bash
# Install CLI
curl -L https://fly.io/install.sh | sh

# Deploy
fly launch
fly deploy
```

**fly.toml:**
```toml
app = "my-app"
primary_region = "nrt"

[build]
  dockerfile = "Dockerfile"

[http_service]
  internal_port = 3000
  force_https = true

[[services.ports]]
  port = 443
  handlers = ["tls", "http"]
```

## Environment Variable Management

### Secrets Configuration

| Provider | Method |
|----------|------|
| AWS | Secrets Manager, Parameter Store |
| GCP | Secret Manager |
| Azure | Key Vault |
| Vercel | Dashboard → Settings → Environment |
| Railway | Dashboard → Variables |

## Additional Cloud Providers

### DigitalOcean

**App Platform:**
```yaml
# .do/app.yaml
name: backend-api
region: nyc
services:
  - name: api
    github:
      repo: myorg/backend
      branch: main
    run_command: npm start
    environment_slug: node-js
    instance_count: 3
    instance_size_slug: basic-xxs
```

**Kubernetes:**
```bash
# DOKS cluster
doctl kubernetes cluster kubeconfig save my-cluster
kubectl apply -f k8s/
```

### Render

**Service Configuration:**
```yaml
# render.yaml
services:
  - type: web
    name: backend-api
    env: node
    buildCommand: npm install && npm run build
    startCommand: npm start
    envVars:
      - key: DATABASE_URL
        sync: false
```

### Cloudflare Workers

**Deployment:**
```bash
# Wrangler CLI
npm install -g wrangler
wrangler login
wrangler deploy
```

**wrangler.toml:**
```toml
name = "backend-api"
compatibility_date = "2024-01-01"

[env.production]
routes = [
  { pattern = "api.example.com/*", zone_name = "example.com" }
]
```

## Multi-Cloud Patterns

### Cloud-Agnostic Setup

**Terraform:**
```hcl
# terraform/main.tf
provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project
}

# Resource definition
```

### Disaster Recovery

**Backup Strategy:**
- Multi-region deployment
- Automatic backup
- Recovery plan

## Cost Optimization

### Resource Right-sizing

**Monitoring-based:**
- Usage analysis
- Appropriate instance size
- Spot instance utilization

### Reserved Instances

**AWS:**
```bash
# Purchase reserved instances
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id offering-id
```

## Best Practices

### Do's
- Use cloud-native services
- Configure auto-scaling
- Consider multi-region
- Cost monitoring

### Don'ts
- Unnecessary resources
- Hardcoded configurations
- Missing security settings
