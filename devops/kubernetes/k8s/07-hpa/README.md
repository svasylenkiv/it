# 🔹 7. Автоматичне масштабування (HPA)

**⏱️ Час: 1-2 дні**

## 📚 Теорія

### Horizontal Pod Autoscaler (HPA)
**HPA** - це ресурс Kubernetes, який автоматично масштабує кількість Pod-ів:
- **На основі метрик** - CPU, пам'ять, custom метрики
- **Автоматичне масштабування** - збільшення/зменшення реплік
- **Гнучкість** - мінімальна та максимальна кількість Pod-ів

### Типи метрик для HPA

#### 1. Resource Metrics (CPU/Memory)
- **CPU utilization** - відсоток використання CPU
- **Memory utilization** - відсоток використання пам'яті
- **Вбудовані метрики** - доступні за замовчуванням

#### 2. Custom Metrics
- **Application-specific** - кількість запитів, черга повідомлень
- **External metrics** - зовнішні системи моніторингу
- **Object metrics** - метрики Kubernetes об'єктів

### Принцип роботи HPA

1. **Збір метрик** - HPA збирає метрики з Pod-ів
2. **Аналіз тренду** - порівнює поточні метрики з цільовими
3. **Розрахунок реплік** - визначає необхідну кількість Pod-ів
4. **Масштабування** - оновлює Deployment/StatefulSet

## 🛠️ Практика

### Крок 1: Встановлення Metrics Server

#### Для Minikube:
```bash
# Включення Metrics Server addon
minikube addons enable metrics-server

# Перевірка статусу
kubectl get pods -n kube-system | grep metrics-server
```

#### Для інших кластерів:
```bash
# Завантаження Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Перевірка статусу
kubectl get pods -n kube-system | grep metrics-server
```

### Крок 2: Створення тестового додатку з навантаженням

Створи файл `Dockerfile`:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

Створи файл `package.json`:

```json
{
  "name": "load-test-api",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

Створи файл `server.js`:

```javascript
const express = require('express');
const app = express();
const port = 3000;

// Middleware для парсингу JSON
app.use(express.json());

// Змінна для симуляції навантаження
let loadLevel = 0;

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API endpoint з симуляцією навантаження
app.get('/api/data', (req, res) => {
  // Симуляція обробки запиту
  const start = Date.now();
  
  // Симуляція CPU навантаження
  let result = 0;
  for (let i = 0; i < loadLevel * 1000000; i++) {
    result += Math.random();
  }
  
  const duration = Date.now() - start;
  
  res.json({
    data: `Processed data with load level ${loadLevel}`,
    result: result,
    duration: duration,
    timestamp: new Date().toISOString()
  });
});

// Endpoint для зміни рівня навантаження
app.post('/api/load', (req, res) => {
  const { level } = req.body;
  if (level >= 0 && level <= 10) {
    loadLevel = level;
    res.json({ 
      message: `Load level set to ${level}`,
      timestamp: new Date().toISOString()
    });
  } else {
    res.status(400).json({ 
      error: 'Load level must be between 0 and 10',
      timestamp: new Date().toISOString()
    });
  }
});

// Endpoint для отримання поточного рівня навантаження
app.get('/api/load', (req, res) => {
  res.json({ 
    loadLevel: loadLevel,
    timestamp: new Date().toISOString()
  });
});

// Endpoint для симуляції важких обчислень
app.post('/api/compute', (req, res) => {
  const { iterations } = req.body;
  const start = Date.now();
  
  let result = 0;
  for (let i = 0; i < iterations; i++) {
    result += Math.sqrt(i) * Math.sin(i);
  }
  
  const duration = Date.now() - start;
  
  res.json({
    result: result,
    iterations: iterations,
    duration: duration,
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`Load Test API listening at http://localhost:${port}`);
  console.log(`Current load level: ${loadLevel}`);
});
```

### Крок 3: Збірка та публікація образу

```bash
# Збірка образу
docker build -t load-test-api:v1 .

# Тестування локально
docker run -p 3000:3000 load-test-api:v1

# Публікація в реєстр (заміни на свій)
docker tag load-test-api:v1 your-registry/load-test-api:v1
docker push your-registry/load-test-api:v1
```

### Крок 4: Створення Deployment з resource limits

Створи файл `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-test-api
  labels:
    app: load-test-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: load-test-api
  template:
    metadata:
      labels:
        app: load-test-api
    spec:
      containers:
      - name: api
        image: load-test-api:v1
        ports:
        - containerPort: 3000
        
        # Resource limits для HPA
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Крок 5: Створення Service

Створи файл `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: load-test-service
  labels:
    app: load-test-api
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
  selector:
    app: load-test-api
```

### Крок 6: Створення HPA

Створи файл `hpa.yaml`:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: load-test-hpa
  labels:
    app: load-test-api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: load-test-api
  
  # Мінімальна та максимальна кількість реплік
  minReplicas: 2
  maxReplicas: 10
  
  # Метрики для масштабування
  metrics:
  # CPU utilization
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  
  # Memory utilization
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  
  # Поведінка масштабування
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
      - type: Pods
        value: 1
        periodSeconds: 60
      selectPolicy: Min
```

### Крок 7: Застосування ресурсів

```bash
# Застосування Deployment
kubectl apply -f deployment.yaml

# Застосування Service
kubectl apply -f service.yaml

# Застосування HPA
kubectl apply -f hpa.yaml

# Перевірка статусу
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get hpa
```

### Крок 8: Перевірка HPA

```bash
# Детальна інформація про HPA
kubectl describe hpa load-test-hpa

# Перегляд метрик
kubectl top pods
kubectl top nodes

# Перегляд HPA статусу
kubectl get hpa load-test-hpa -o yaml
```

### Крок 9: Тестування автоматичного масштабування

#### Створення навантаження:
```bash
# Доступ до API
kubectl port-forward service/load-test-service 8080:80

# Встановлення високого рівня навантаження
curl -X POST http://localhost:8080/api/load \
  -H "Content-Type: application/json" \
  -d '{"level": 8}'

# Створення важких обчислень
for i in {1..50}; do
  curl -X POST http://localhost:8080/api/compute \
    -H "Content-Type: application/json" \
    -d '{"iterations": 1000000}' &
done
wait

# Спостерігання за масштабуванням
watch kubectl get pods -l app=load-test-api
watch kubectl get hpa load-test-hpa
```

#### Скрипт для генерації навантаження:
Створи файл `load-test.sh`:

```bash
#!/bin/bash

API_URL="http://localhost:8080"
DURATION=300  # 5 хвилин
INTERVAL=1    # 1 секунда

echo "Starting load test for $DURATION seconds..."

# Встановлення високого навантаження
curl -s -X POST "$API_URL/api/load" \
  -H "Content-Type: application/json" \
  -d '{"level": 9}' > /dev/null

echo "Load level set to 9"

# Генерація навантаження
for ((i=1; i<=DURATION; i++)); do
  echo "Request $i/$DURATION"
  
  # Паралельні запити
  for j in {1..5}; do
    curl -s "$API_URL/api/compute" \
      -X POST \
      -H "Content-Type: application/json" \
      -d '{"iterations": 500000}' > /dev/null &
  done
  
  wait
  sleep $INTERVAL
done

echo "Load test completed!"
```

### Крок 10: Налаштування Custom Metrics

#### Встановлення Prometheus та Custom Metrics Adapter:
```bash
# Встановлення Prometheus через Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

#### Створення HPA з custom метриками:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: custom-metrics-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: load-test-api
  
  minReplicas: 2
  maxReplicas: 10
  
  metrics:
  # Custom метрика - кількість запитів в секунду
  - type: Object
    object:
      metric:
        name: requests-per-second
      describedObject:
        apiVersion: v1
        kind: Service
        name: load-test-service
      target:
        type: AverageValue
        averageValue: 100
```

### Крок 11: Моніторинг та логування

#### Створення Dashboard для HPA:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hpa-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "HPA Monitoring",
        "panels": [
          {
            "title": "Pod Count",
            "type": "stat",
            "targets": [
              {
                "expr": "kube_deployment_status_replicas{deployment=\"load-test-api\"}"
              }
            ]
          },
          {
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(container_cpu_usage_seconds_total{pod=~\"load-test-api.*\"}[5m])"
              }
            ]
          }
        ]
      }
    }
```

## 📝 Завдання для практики

1. **Створи різні типи HPA:**
   - На основі CPU та Memory
   - На основі custom метрик
   - На основі external метрик

2. **Налаштуй різні сценарії масштабування:**
   - Швидке масштабування вгору
   - Повільне масштабування вниз
   - Стабілізаційні вікна

3. **Створи систему моніторингу HPA:**
   - Dashboard для відстеження метрик
   - Алерти при проблемах масштабування
   - Логування всіх змін кількості реплік

4. **Оптимізуй HPA налаштування:**
   - Налаштуй оптимальні пороги
   - Зменши коливання кількості реплік
   - Покращи швидкість реакції на зміни

## 🔍 Перевірка знань

- [ ] Розумію принцип роботи HPA
- [ ] Можу налаштувати HPA на основі CPU та Memory
- [ ] Налаштував автоматичне масштабування API під навантаженням
- [ ] Можу моніторити та тестувати HPA
- [ ] Розумію як налаштувати custom метрики

## 📚 Додаткові ресурси

- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/concepts/workloads/controllers/horizontal-pod-autoscaler/)
- [Custom Metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Namespaces та доступи (RBAC)](../08-namespaces-rbac/README.md) 