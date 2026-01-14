# Monitoring Setup

Monitoring and logging setup patterns.

## Logging

### Structured Logging

**JSON Format:**
```typescript
logger.info({
  level: 'info',
  message: 'User logged in',
  userId: user.id,
  timestamp: new Date().toISOString(),
  requestId: req.id
});
```

**Log Collection:**
```yaml
# docker-compose.yml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Log Aggregation

**Loki (Grafana):**
```yaml
# loki-config.yaml
auth_enabled: false
server:
  http_listen_port: 3100
schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
```

**ELK Stack:**
```yaml
# elasticsearch, logstash, kibana
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
```

## Metrics

### Prometheus

**Configuration:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'backend-api'
    static_configs:
      - targets: ['api:3000']
    metrics_path: /metrics
```

**Application Metrics:**
```typescript
import { Counter, Histogram } from 'prom-client';

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});
```

### Grafana Dashboards

**Dashboard Configuration:**
```json
{
  "dashboard": {
    "title": "Backend API Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
          }
        ]
      }
    ]
  }
}
```

## Error Tracking

### Sentry

**Configuration:**
```typescript
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});
```

**K8s ConfigMap:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  SENTRY_DSN: "${SENTRY_DSN}"
```

## Health Checks

### Application Health

**Endpoint:**
```typescript
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks: {
      database: await checkDatabase(),
      redis: await checkRedis()
    }
  });
});
```

**K8s Probe:**
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3

livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 15
  periodSeconds: 20
  failureThreshold: 3
```

## Alerting

### Alertmanager

**Configuration:**
```yaml
# alertmanager.yml
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'web.hook'
receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://slack:5001/'
```

**Alert Rules:**
```yaml
# alerts.yml
groups:
  - name: backend
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        annotations:
          summary: "High error rate detected"
```

## APM (Application Performance Monitoring)

### OpenTelemetry

**Configuration:**
```typescript
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const sdk = new NodeSDK({
  instrumentations: [getNodeAutoInstrumentations()],
  traceExporter: new OTLPTraceExporter({
    url: 'http://jaeger:4318/v1/traces',
  }),
});

sdk.start();
```

### Jaeger

**Deployment:**
```yaml
# jaeger.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  template:
    spec:
      containers:
        - name: jaeger
          image: jaegertracing/all-in-one:latest
          ports:
            - containerPort: 16686  # UI
            - containerPort: 4318   # OTLP
```

## Infrastructure Monitoring

### Node Exporter

**K8s DaemonSet:**
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  template:
    spec:
      containers:
        - name: node-exporter
          image: prom/node-exporter:latest
          ports:
            - containerPort: 9100
```

### cAdvisor

**Container Metrics:**
```yaml
# Included in Kubelet
# Collected by Prometheus
scrape_configs:
  - job_name: 'cadvisor'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: replace
        source_labels: [__address__]
        regex: (.+)
        target_label: __address__
        replacement: $1:4194
```

## Custom Metrics

### Business Metrics

**Example:**
```typescript
const ordersTotal = new Counter({
  name: 'orders_total',
  help: 'Total number of orders',
  labelNames: ['status']
});

const revenue = new Counter({
  name: 'revenue_total',
  help: 'Total revenue',
  labelNames: ['currency']
});
```

## Log Retention

### Retention Policy

**Loki:**
```yaml
limits_config:
  retention_period: 720h  # 30 days
  max_query_length: 720h
```

**ELK:**
```yaml
# Index Lifecycle Management
PUT _ilm/policy/log-policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "50GB",
            "max_age": "7d"
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

## Best Practices

### Do's
- Structured logging (JSON)
- Clear metric labels
- Health check required
- Appropriate alert thresholds
- Log retention policy

### Don'ts
- Logging sensitive information
- Excessive metrics
- Alert spam
- Unlimited log retention
