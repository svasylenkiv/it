# 🛠️ Практичні приклади Kubernetes

## 📁 Структура проекту
```
my-kubernetes-project/
├── manifests/
│   ├── 01-basics/
│   ├── 02-deployments/
│   ├── 03-ingress/
│   ├── 04-configs/
│   ├── 05-storage/
│   ├── 06-health-checks/
│   ├── 07-hpa/
│   ├── 08-rbac/
│   ├── 09-helm/
│   └── 10-monitoring/
├── helm-charts/
├── scripts/
└── README.md
```

---

## 🔹 1. Базові команди

### Перевірка кластера
```bash
# Перевірка статусу кластера
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Перевірка версії
kubectl version --client
kubectl version --short
```

### Робота з Pod
```bash
# Створення Pod
kubectl run nginx-pod --image=nginx:latest --port=80

# Перегляд Pod
kubectl get pods
kubectl get pods -o wide
kubectl describe pod nginx-pod

# Логи Pod
kubectl logs nginx-pod
kubectl logs -f nginx-pod

# Виконання команд в Pod
kubectl exec -it nginx-pod -- /bin/bash
kubectl exec nginx-pod -- nginx -v

# Видалення Pod
kubectl delete pod nginx-pod
```

---

## 🔹 2. Deployment та Service

### Створення Deployment
```yaml
# manifests/02-deployments/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
  labels:
    app: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: your-api:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Створення Service
```yaml
# manifests/02-deployments/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
  labels:
    app: api
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
```

### Команди для роботи
```bash
# Застосування маніфестів
kubectl apply -f manifests/02-deployments/

# Перегляд ресурсів
kubectl get deployments
kubectl get services
kubectl get endpoints

# Масштабування
kubectl scale deployment api-deployment --replicas=5

# Оновлення образу
kubectl set image deployment/api-deployment api=your-api:v2.0.0

# Історія оновлень
kubectl rollout history deployment/api-deployment

# Відкат до попередньої версії
kubectl rollout undo deployment/api-deployment
```

---

## 🔹 3. Ingress та TLS

### Встановлення Nginx Ingress Controller
```bash
# Встановлення
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Перевірка статусу
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Створення Ingress
```yaml
# manifests/03-ingress/api-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapi.local
    secretName: api-tls-secret
  rules:
  - host: myapi.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

### Створення TLS Secret
```bash
# Генерація приватного ключа
openssl genrsa -out tls.key 2048

# Генерація сертифіката
openssl req -new -x509 -key tls.key -out tls.crt -days 365 -subj "/CN=myapi.local"

# Створення Secret
kubectl create secret tls api-tls-secret --key tls.key --cert tls.crt
```

---

## 🔹 4. ConfigMaps та Secrets

### Створення ConfigMap
```yaml
# manifests/04-configs/api-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  DATABASE_URL: "postgresql://localhost:5432/mydb"
  API_VERSION: "1.0.0"
  LOG_LEVEL: "INFO"
  MAX_CONNECTIONS: "100"
```

### Створення Secret
```yaml
# manifests/04-configs/api-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secret
type: Opaque
data:
  username: YWRtaW4=  # admin
  password: cGFzc3dvcmQ=  # password
  api-key: c2VjcmV0LWtleQ==  # secret-key
```

### Використання в Deployment
```yaml
# manifests/04-configs/api-deployment-with-config.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  # ... existing spec ...
  template:
    spec:
      containers:
      - name: api
        image: your-api:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: api-config
              key: DATABASE_URL
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-secret
              key: api-key
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
      volumes:
      - name: config-volume
        configMap:
          name: api-config
```

---

## 🔹 5. Storage та StatefulSet

### Створення StorageClass
```yaml
# manifests/05-storage/storage-class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

### Створення PersistentVolume
```yaml
# manifests/05-storage/postgres-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  hostPath:
    path: /mnt/data/postgres
```

### Створення StatefulSet
```yaml
# manifests/05-storage/postgres-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: mydb
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: local-storage
      resources:
        requests:
          storage: 10Gi
```

---

## 🔹 6. Health Checks

### Readiness та Liveness Probes
```yaml
# manifests/06-health-checks/api-deployment-health.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  # ... existing spec ...
  template:
    spec:
      containers:
      - name: api
        image: your-api:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /health/startup
            port: 8080
          failureThreshold: 30
          periodSeconds: 10
```

### Health Endpoints в API
```csharp
// .NET
app.MapGet("/health/live", () => Results.Ok("Alive"));
app.MapGet("/health/ready", () => 
{
    // Перевірка з'єднання з БД
    try
    {
        // db.Ping();
        return Results.Ok("Ready");
    }
    catch
    {
        return Results.ServiceUnavailable("Not Ready");
    }
});
app.MapGet("/health/startup", () => Results.Ok("Started"));
```

```javascript
// Node.js
app.get('/health/live', (req, res) => res.status(200).send('Alive'));
app.get('/health/ready', async (req, res) => {
    try {
        // await db.ping();
        res.status(200).send('Ready');
    } catch (error) {
        res.status(503).send('Not Ready');
    }
});
app.get('/health/startup', (req, res) => res.status(200).send('Started'));
```

---

## 🔹 7. Horizontal Pod Autoscaler

### Встановлення metrics-server
```bash
# Встановлення
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Перевірка
kubectl get pods -n kube-system | grep metrics-server
```

### Створення HPA
```yaml
# manifests/07-hpa/api-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-deployment
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### Тестування HPA
```bash
# Створення навантаження
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://api-service; done"

# Моніторинг HPA
kubectl get hpa
kubectl describe hpa api-hpa

# Перегляд метрик
kubectl top pods
kubectl top nodes
```

---

## 🔹 8. RBAC та Namespaces

### Створення Namespace
```yaml
# manifests/08-rbac/development-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    environment: dev
    team: developers
```

### Створення ServiceAccount
```yaml
# manifests/08-rbac/developer-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: developer-sa
  namespace: development
```

### Створення Role
```yaml
# manifests/08-rbac/developer-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "create", "update", "delete"]
```

### Створення RoleBinding
```yaml
# manifests/08-rbac/developer-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: ServiceAccount
  name: developer-sa
  namespace: development
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

---

## 🔹 9. Helm Charts

### Створення Helm Chart
```bash
# Створення Chart
helm create my-api

# Структура Chart
my-api/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── NOTES.txt
└── charts/
```

### Chart.yaml
```yaml
# helm-charts/my-api/Chart.yaml
apiVersion: v2
name: my-api
description: A Helm chart for My API
type: application
version: 0.1.0
appVersion: "1.0.0"
```

### values.yaml
```yaml
# helm-charts/my-api/values.yaml
replicaCount: 3

image:
  repository: my-api
  tag: latest
  pullPolicy: IfNotPresent

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  hosts:
    - host: myapi.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: my-api-tls
      hosts:
        - myapi.local

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Встановлення та оновлення Chart
```bash
# Встановлення
helm install my-api ./helm-charts/my-api

# Оновлення
helm upgrade my-api ./helm-charts/my-api

# Перегляд статусу
helm list
helm status my-api

# Видалення
helm uninstall my-api
```

---

## 🔹 10. CI/CD Pipeline

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to Kubernetes

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest

    - name: Deploy to Kubernetes
      run: |
        echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > kubeconfig.yaml
        export KUBECONFIG=kubeconfig.yaml
        
        # Update deployment image
        kubectl set image deployment/api-deployment api=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        
        # Wait for rollout
        kubectl rollout status deployment/api-deployment --timeout=300s
```

### GitLab CI
```yaml
# .gitlab-ci.yml
stages:
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  before_script:
    - echo "$KUBE_CONFIG" | base64 -d > kubeconfig.yaml
    - export KUBECONFIG=kubeconfig.yaml
  script:
    - kubectl set image deployment/api-deployment api=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - kubectl rollout status deployment/api-deployment --timeout=300s
  only:
    - main
```

---

## 🔹 11. Моніторинг та логування

### Prometheus + Grafana
```bash
# Встановлення через Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Встановлення
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Доступ до Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Логін: admin, Пароль: prom-operator
```

### EFK Stack
```bash
# Elasticsearch
kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/operator.yaml

# Fluentd
kubectl apply -f https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch.yaml

# Kibana
kubectl apply -f https://raw.githubusercontent.com/elastic/kibana/master/deploy/kubernetes/kibana.yaml
```

### Базові команди моніторингу
```bash
# Логи
kubectl logs -f deployment/api-deployment
kubectl logs -f deployment/api-deployment --tail=100

# Метрики
kubectl top pods
kubectl top nodes
kubectl top pods --containers

# Події
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.name=api-deployment

# Опис ресурсів
kubectl describe pod <pod-name>
kubectl describe deployment api-deployment
kubectl describe service api-service
```

---

## 🔹 12. Хмарне розгортання

### AWS EKS
```bash
# Встановлення eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Створення кластеру
eksctl create cluster \
  --name my-cluster \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Оновлення kubeconfig
aws eks update-kubeconfig --name my-cluster --region us-west-2

# Перевірка
kubectl get nodes
kubectl cluster-info
```

### Azure AKS
```bash
# Створення кластеру
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --node-vm-size Standard_DS2_v2

# Отримання credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# Перевірка
kubectl get nodes
kubectl cluster-info
```

### GCP GKE
```bash
# Створення кластеру
gcloud container clusters create my-gke-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type e2-medium \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# Отримання credentials
gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a

# Перевірка
kubectl get nodes
kubectl cluster-info
```

---

## 📝 Корисні скрипти

### Скрипт для швидкого створення середовища
```bash
#!/bin/bash
# scripts/setup-environment.sh

echo "🚀 Налаштування Kubernetes середовища..."

# Перевірка kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl не знайдено. Встановіть kubectl спочатку."
    exit 1
fi

# Перевірка кластера
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Кластер недоступний. Запустіть кластер спочатку."
    exit 1
fi

echo "✅ Кластер доступний"

# Створення namespace
kubectl create namespace development --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Встановлення Nginx Ingress Controller
echo "📦 Встановлення Nginx Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Встановлення metrics-server
echo "📊 Встановлення metrics-server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo "✅ Середовище налаштовано!"
echo "🌐 Namespaces:"
kubectl get namespaces
echo "🔧 Ingress Controller:"
kubectl get pods -n ingress-nginx
```

### Скрипт для моніторингу ресурсів
```bash
#!/bin/bash
# scripts/monitor-resources.sh

NAMESPACE=${1:-default}

echo "📊 Моніторинг ресурсів в namespace: $NAMESPACE"
echo "================================================"

echo "🔍 Pods:"
kubectl get pods -n $NAMESPACE

echo ""
echo "📈 Top Pods (CPU/Memory):"
kubectl top pods -n $NAMESPACE

echo ""
echo "🔗 Services:"
kubectl get services -n $NAMESPACE

echo ""
echo "🌐 Ingress:"
kubectl get ingress -n $NAMESPACE

echo ""
echo "💾 Persistent Volumes:"
kubectl get pv,pvc -n $NAMESPACE

echo ""
echo "📋 Events (останні 10):"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -10
```

---

## 🎯 Фінальний проект - Повна архітектура

### Структура проекту
```
production-app/
├── backend/
│   ├── Dockerfile
│   ├── src/
│   └── tests/
├── frontend/
│   ├── Dockerfile
│   ├── src/
│   └── package.json
├── infrastructure/
│   ├── kubernetes/
│   │   ├── namespaces/
│   │   ├── backend/
│   │   ├── frontend/
│   │   ├── database/
│   │   ├── monitoring/
│   │   └── ingress/
│   ├── helm-charts/
│   └── terraform/
├── ci-cd/
│   ├── .github/
│   └── .gitlab-ci.yml
└── README.md
```

### Команди для розгортання
```bash
# 1. Створення namespace
kubectl apply -f infrastructure/kubernetes/namespaces/

# 2. Розгортання бази даних
kubectl apply -f infrastructure/kubernetes/database/

# 3. Розгортання backend
kubectl apply -f infrastructure/kubernetes/backend/

# 4. Розгортання frontend
kubectl apply -f infrastructure/kubernetes/frontend/

# 5. Налаштування Ingress
kubectl apply -f infrastructure/kubernetes/ingress/

# 6. Розгортання моніторингу
kubectl apply -f infrastructure/kubernetes/monitoring/

# 7. Перевірка статусу
kubectl get all --all-namespaces
kubectl get ingress --all-namespaces
kubectl get pv,pvc --all-namespaces
```

Цей план дасть вам **повне розуміння Kubernetes** та **практичні навички** для роботи в production середовищі! 🚀 