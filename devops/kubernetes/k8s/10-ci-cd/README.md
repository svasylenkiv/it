# 🔹 10. CI/CD

**⏱️ Час: 2-3 дні**

## 📚 Теорія

### CI/CD в Kubernetes
**CI/CD** (Continuous Integration/Continuous Deployment) - це автоматизація процесу розробки:
- **CI** - автоматична збірка та тестування коду
- **CD** - автоматичне розгортання в різні середовища
- **GitOps** - управління інфраструктурою через Git

### Основні компоненти

#### 1. Source Control
- **Git репозиторій** - зберігання коду та конфігурацій
- **Branching strategy** - стратегія гілок (GitFlow, GitHub Flow)
- **Pull Requests** - код ревью та автоматичні перевірки

#### 2. Build Pipeline
- **Docker build** - створення контейнерних образів
- **Image registry** - зберігання образів (Docker Hub, ECR, ACR)
- **Security scanning** - перевірка безпеки образів

#### 3. Deployment Pipeline
- **Kubernetes manifests** - YAML файли для розгортання
- **Helm charts** - шаблони для розгортання
- **Environment promotion** - переміщення між середовищами

## 🛠️ Практика

### Крок 1: Налаштування GitHub Actions

Створи файл `.github/workflows/ci-cd.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Job для збірки та тестування
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Run linting
      run: npm run lint
    
    - name: Build application
      run: npm run build
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  # Job для розгортання в development
  deploy-dev:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: development
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'latest'
    
    - name: Configure kubectl
      run: |
        echo "${{ secrets.KUBE_CONFIG_DEV }}" | base64 -d > kubeconfig
        export KUBECONFIG=kubeconfig
    
    - name: Deploy to development
      run: |
        # Оновлення образу в deployment
        kubectl set image deployment/myapp myapp=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} -n development
        
        # Перевірка статусу
        kubectl rollout status deployment/myapp -n development
        
        # Перевірка health checks
        kubectl wait --for=condition=ready pod -l app=myapp -n development --timeout=300s

  # Job для розгортання в staging
  deploy-staging:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: staging
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'latest'
    
    - name: Configure kubectl
      run: |
        echo "${{ secrets.KUBE_CONFIG_STAGING }}" | base64 -d > kubeconfig
        export KUBECONFIG=kubeconfig
    
    - name: Deploy to staging
      run: |
        # Оновлення образу в deployment
        kubectl set image deployment/myapp myapp=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} -n staging
        
        # Перевірка статусу
        kubectl rollout status deployment/myapp -n staging
        
        # Перевірка health checks
        kubectl wait --for=condition=ready pod -l app=myapp -n staging --timeout=300s

  # Job для production deployment (manual trigger)
  deploy-production:
    needs: build-and-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'latest'
    
    - name: Configure kubectl
      run: |
        echo "${{ secrets.KUBE_CONFIG_PROD }}" | base64 -d > kubeconfig
        export KUBECONFIG=kubeconfig
    
    - name: Deploy to production
      run: |
        # Оновлення образу в deployment
        kubectl set image deployment/myapp myapp=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} -n production
        
        # Перевірка статусу
        kubectl rollout status deployment/myapp -n production
        
        # Перевірка health checks
        kubectl wait --for=condition=ready pod -l app=myapp -n production --timeout=300s
```

### Крок 2: Налаштування GitLab CI

Створи файл `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - deploy-dev
  - deploy-staging
  - deploy-production

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  REGISTRY: $CI_REGISTRY
  IMAGE_NAME: $CI_PROJECT_PATH

# Build stage
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA .
    - docker build -t $REGISTRY/$IMAGE_NAME:$CI_COMMIT_REF_SLUG .
    - docker push $REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA
    - docker push $REGISTRY/$IMAGE_NAME:$CI_COMMIT_REF_SLUG
  only:
    - main
    - develop

# Test stage
test:
  stage: test
  image: node:18
  before_script:
    - npm ci
  script:
    - npm run lint
    - npm run test
    - npm run build
  artifacts:
    reports:
      junit: junit.xml
    paths:
      - coverage/
  only:
    - main
    - develop
    - merge_requests

# Deploy to development
deploy-dev:
  stage: deploy-dev
  image: bitnami/kubectl:latest
  before_script:
    - echo "$KUBE_CONFIG_DEV" | base64 -d > kubeconfig
    - export KUBECONFIG=kubeconfig
  script:
    - kubectl set image deployment/myapp myapp=$REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA -n development
    - kubectl rollout status deployment/myapp -n development
    - kubectl wait --for=condition=ready pod -l app=myapp -n development --timeout=300s
  environment:
    name: development
    url: https://dev.example.com
  only:
    - develop
  when: manual

# Deploy to staging
deploy-staging:
  stage: deploy-staging
  image: bitnami/kubectl:latest
  before_script:
    - echo "$KUBE_CONFIG_STAGING" | base64 -d > kubeconfig
    - export KUBECONFIG=kubeconfig
  script:
    - kubectl set image deployment/myapp myapp=$REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA -n staging
    - kubectl rollout status deployment/myapp -n staging
    - kubectl wait --for=condition=ready pod -l app=myapp -n staging --timeout=300s
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - main
  when: manual

# Deploy to production
deploy-production:
  stage: deploy-production
  image: bitnami/kubectl:latest
  before_script:
    - echo "$KUBE_CONFIG_PROD" | base64 -d > kubeconfig
    - export KUBECONFIG=kubeconfig
  script:
    - kubectl set image deployment/myapp myapp=$REGISTRY/$IMAGE_NAME:$CI_COMMIT_SHA -n production
    - kubectl rollout status deployment/myapp -n production
    - kubectl wait --for=condition=ready pod -l app=myapp -n production --timeout=300s
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual
```

### Крок 3: Створення Kubernetes manifests

Створи файл `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: ghcr.io/yourusername/myapp:latest
        ports:
        - containerPort: 3000
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        
        # Resource limits
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        
        # Environment variables
        env:
        - name: NODE_ENV
          value: "production"
        - name: APP_VERSION
          valueFrom:
            fieldRef:
              fieldPath: metadata.labels['app.kubernetes.io/version']
        
        # Volume mounts
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
      
      volumes:
      - name: config-volume
        configMap:
          name: myapp-config
```

Створи файл `k8s/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  labels:
    app: myapp
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
  selector:
    app: myapp
```

Створи файл `k8s/ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  labels:
    app: myapp
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

### Крок 4: Створення Helm chart для CI/CD

Створи файл `helm/values-dev.yaml`:

```yaml
# Development environment values
replicaCount: 2

image:
  repository: ghcr.io/yourusername/myapp
  tag: "develop"
  pullPolicy: Always

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: dev.myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70

app:
  environment: "development"
  debug: true
```

Створи файл `helm/values-staging.yaml`:

```yaml
# Staging environment values
replicaCount: 3

image:
  repository: ghcr.io/yourusername/myapp
  tag: "main"
  pullPolicy: Always

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: staging.myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

app:
  environment: "staging"
  debug: false
```

Створи файл `helm/values-prod.yaml`:

```yaml
# Production environment values
replicaCount: 5

image:
  repository: ghcr.io/yourusername/myapp
  tag: "main"
  pullPolicy: Always

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70

app:
  environment: "production"
  debug: false
```

### Крок 5: Налаштування автоматичного розгортання

#### Створення скрипта для розгортання:
Створи файл `scripts/deploy.sh`:

```bash
#!/bin/bash

set -e

# Параметри
ENVIRONMENT=$1
IMAGE_TAG=$2
NAMESPACE=$3

if [ -z "$ENVIRONMENT" ] || [ -z "$IMAGE_TAG" ] || [ -z "$NAMESPACE" ]; then
    echo "Usage: $0 <environment> <image-tag> <namespace>"
    echo "Example: $0 dev v1.0.0 development"
    exit 1
fi

echo "Deploying to $ENVIRONMENT environment..."

# Перевірка наявності kubectl
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed"
    exit 1
fi

# Перевірка підключення до кластера
if ! kubectl cluster-info &> /dev/null; then
    echo "Cannot connect to Kubernetes cluster"
    exit 1
fi

# Створення namespace якщо не існує
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Оновлення образу в deployment
kubectl set image deployment/myapp myapp=ghcr.io/yourusername/myapp:$IMAGE_TAG -n $NAMESPACE

# Очікування готовності deployment
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/myapp -n $NAMESPACE --timeout=300s

# Перевірка health checks
echo "Checking health status..."
kubectl wait --for=condition=ready pod -l app=myapp -n $NAMESPACE --timeout=300s

# Перевірка статусу
echo "Deployment status:"
kubectl get pods -n $NAMESPACE -l app=myapp
kubectl get services -n $NAMESPACE -l app=myapp
kubectl get ingress -n $NAMESPACE -l app=myapp

echo "Deployment to $ENVIRONMENT completed successfully!"
```

#### Створення скрипта для rollback:
Створи файл `scripts/rollback.sh`:

```bash
#!/bin/bash

set -e

# Параметри
NAMESPACE=$1
REVISION=$2

if [ -z "$NAMESPACE" ] || [ -z "$REVISION" ]; then
    echo "Usage: $0 <namespace> <revision>"
    echo "Example: $0 production 2"
    exit 1
fi

echo "Rolling back deployment in $NAMESPACE to revision $REVISION..."

# Перевірка наявності kubectl
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed"
    exit 1
fi

# Перевірка підключення до кластера
if ! kubectl cluster-info &> /dev/null; then
    echo "Cannot connect to Kubernetes cluster"
    exit 1
fi

# Rollback deployment
kubectl rollout undo deployment/myapp -n $NAMESPACE --to-revision=$REVISION

# Очікування завершення rollback
echo "Waiting for rollback to complete..."
kubectl rollout status deployment/myapp -n $NAMESPACE --timeout=300s

# Перевірка статусу
echo "Rollback completed. Current status:"
kubectl get pods -n $NAMESPACE -l app=myapp
kubectl rollout history deployment/myapp -n $NAMESPACE

echo "Rollback to revision $REVISION completed successfully!"
```

### Крок 6: Налаштування моніторингу та алертів

#### Створення PrometheusRule для алертів:
Створи файл `k8s/monitoring/prometheus-rules.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: deployment-alerts
  namespace: monitoring
  labels:
    prometheus: kube-prometheus
    role: alert-rules
spec:
  groups:
  - name: deployment.rules
    rules:
    - alert: DeploymentFailed
      expr: kube_deployment_status_replicas_unavailable > 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Deployment {{ $labels.deployment }} has failed"
        description: "Deployment {{ $labels.deployment }} in namespace {{ $labels.namespace }} has {{ $value }} unavailable replicas"
    
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
        description: "CPU usage is above 80% on {{ $labels.instance }}"
    
    - alert: HighMemoryUsage
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.instance }}"
        description: "Memory usage is above 85% on {{ $labels.instance }}"
```

#### Створення Grafana Dashboard:
Створи файл `k8s/monitoring/grafana-dashboard.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: deployment-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  deployment-dashboard.json: |
    {
      "dashboard": {
        "title": "Deployment Monitoring",
        "panels": [
          {
            "title": "Pod Count",
            "type": "stat",
            "targets": [
              {
                "expr": "kube_deployment_status_replicas{deployment=\"myapp\"}"
              }
            ]
          },
          {
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(container_cpu_usage_seconds_total{pod=~\"myapp.*\"}[5m])"
              }
            ]
          },
          {
            "title": "Memory Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(container_memory_usage_bytes{pod=~\"myapp.*\"}[5m])"
              }
            ]
          }
        ]
      }
    }
```

### Крок 7: Налаштування GitOps з ArgoCD

#### Встановлення ArgoCD:
```bash
# Встановлення ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Отримання паролю адміністратора
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

#### Створення Application для GitOps:
Створи файл `k8s/argocd/application.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-argocd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourusername/myapp-repo
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
  revisionHistoryLimit: 10
```

## 📝 Завдання для практики

1. **Створи повний CI/CD pipeline:**
   - GitHub Actions або GitLab CI
   - Автоматична збірка та тестування
   - Автоматичне розгортання в різні середовища

2. **Налаштуй GitOps:**
   - ArgoCD для автоматичного розгортання
   - Git-based конфігурація
   - Автоматичне синхронізація

3. **Створи систему моніторингу:**
   - Prometheus та Grafana
   - Алерти та нотифікації
   - Dashboard для відстеження

4. **Оптимізуй pipeline:**
   - Кешування та швидкість
   - Безпека та валідація
   - Rollback та disaster recovery

## 🔍 Перевірка знань

- [ ] Розумію принципи CI/CD в Kubernetes
- [ ] Можу створити GitHub Actions або GitLab CI pipeline
- [ ] Налаштував автоматичне розгортання в різні середовища
- [ ] Можу використовувати Helm для розгортання
- [ ] Розумію GitOps та ArgoCD

## 📚 Додаткові ресурси

- [GitHub Actions](https://docs.github.com/en/actions)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [ArgoCD](https://argoproj.github.io/argo-cd/)
- [GitOps](https://www.gitops.tech/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Моніторинг і логування](../11-monitoring-logging/README.md) 