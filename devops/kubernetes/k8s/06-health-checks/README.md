# 🔹 6. Health checks

**⏱️ Час: 1-2 дні**

## 📚 Теорія

### Health Checks в Kubernetes
**Health Checks** - це механізм для перевірки стану додатку:
- **Readiness Probe** - чи готовий Pod приймати трафік
- **Liveness Probe** - чи живий Pod
- **Startup Probe** - чи завершився запуск Pod

### Типи Probe

#### 1. Readiness Probe
- **Призначення** - визначає чи готовий Pod обслуговувати запити
- **Результат** - Pod видаляється з Service endpoints якщо не готовий
- **Використання** - для поступового розгортання та оновлення

#### 2. Liveness Probe
- **Призначення** - визначає чи працює Pod коректно
- **Результат** - Pod перезапускається якщо не відповідає
- **Використання** - для автоматичного відновлення злабаних Pod-ів

#### 3. Startup Probe
- **Призначення** - визначає чи завершився запуск додатку
- **Результат** - блокує інші probe до завершення запуску
- **Використання** - для повільно запускаючихся додатків

### Методи Probe

#### HTTP GET
- Перевірка HTTP endpoint
- Найпопулярніший для web додатків

#### TCP Socket
- Перевірка TCP з'єднання
- Для додатків без HTTP API

#### Exec
- Виконання команди в контейнері
- Для складних перевірок

## 🛠️ Практика

### Крок 1: Створення простого API з health checks

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
  "name": "health-check-api",
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

let isHealthy = true;
let isReady = false;

// Middleware для логування
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoints
app.get('/health', (req, res) => {
  if (isHealthy) {
    res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
  } else {
    res.status(503).json({ status: 'unhealthy', timestamp: new Date().toISOString() });
  }
});

app.get('/ready', (req, res) => {
  if (isReady) {
    res.status(200).json({ status: 'ready', timestamp: new Date().toISOString() });
  } else {
    res.status(503).json({ status: 'not ready', timestamp: new Date().toISOString() });
  }
});

app.get('/startup', (req, res) => {
  res.status(200).json({ status: 'started', timestamp: new Date().toISOString() });
});

// API endpoints
app.get('/', (req, res) => {
  res.json({ message: 'Health Check API', timestamp: new Date().toISOString() });
});

app.get('/api/data', (req, res) => {
  res.json({ data: 'Some data', timestamp: new Date().toISOString() });
});

// Endpoint для симуляції проблем
app.post('/health/toggle', (req, res) => {
  isHealthy = !isHealthy;
  res.json({ isHealthy, timestamp: new Date().toISOString() });
});

app.post('/ready/toggle', (req, res) => {
  isReady = !isReady;
  res.json({ isReady, timestamp: new Date().toISOString() });
});

// Симуляція повільного запуску
setTimeout(() => {
  isReady = true;
  console.log('Application is now ready');
}, 10000);

// Симуляція періодичних проблем
setInterval(() => {
  if (Math.random() < 0.1) { // 10% шанс проблем
    isHealthy = false;
    console.log('Application became unhealthy');
    setTimeout(() => {
      isHealthy = true;
      console.log('Application recovered');
    }, 5000);
  }
}, 30000);

app.listen(port, () => {
  console.log(`Health Check API listening at http://localhost:${port}`);
});
```

### Крок 2: Збірка та публікація образу

```bash
# Збірка образу
docker build -t health-check-api:v1 .

# Тестування локально
docker run -p 3000:3000 health-check-api:v1

# Публікація в реєстр (заміни на свій)
docker tag health-check-api:v1 your-registry/health-check-api:v1
docker push your-registry/health-check-api:v1
```

### Крок 3: Створення Deployment з health checks

Створи файл `deployment-with-health.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: health-check-api
  labels:
    app: health-check-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: health-check-api
  template:
    metadata:
      labels:
        app: health-check-api
    spec:
      containers:
      - name: api
        image: health-check-api:v1
        ports:
        - containerPort: 3000
        
        # Startup Probe - перевіряє чи завершився запуск
        startupProbe:
          httpGet:
            path: /startup
            port: 3000
          failureThreshold: 30
          periodSeconds: 10
        
        # Readiness Probe - перевіряє чи готовий Pod приймати трафік
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        
        # Liveness Probe - перевіряє чи живий Pod
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        
        # Resource limits
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
```

### Крок 4: Створення Service

Створи файл `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: health-check-service
  labels:
    app: health-check-api
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 3000
    protocol: TCP
  selector:
    app: health-check-api
```

### Крок 5: Застосування ресурсів

```bash
# Застосування Deployment
kubectl apply -f deployment-with-health.yaml

# Застосування Service
kubectl apply -f service.yaml

# Перевірка статусу
kubectl get deployments
kubectl get pods
kubectl get services
```

### Крок 6: Спостерігання за health checks

```bash
# Перегляд деталей Pod
kubectl describe pod -l app=health-check-api

# Логи Pod
kubectl logs -l app=health-check-api -f

# Перегляд events
kubectl get events --sort-by='.lastTimestamp'

# Перевірка endpoints
kubectl get endpoints health-check-service
```

### Крок 7: Тестування health checks

```bash
# Доступ до API
kubectl port-forward service/health-check-service 8080:80

# Тестування health endpoints
curl http://localhost:8080/health
curl http://localhost:8080/ready
curl http://localhost:8080/startup

# Симуляція проблем
curl -X POST http://localhost:8080/health/toggle
curl -X POST http://localhost:8080/ready/toggle

# Перевірка змін
curl http://localhost:8080/health
curl http://localhost:8080/ready
```

### Крок 8: Різні типи health checks

#### TCP Socket Probe:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tcp-health-check
spec:
  template:
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
        
        # TCP Socket Probe
        livenessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          tcpSocket:
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

#### Exec Probe:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: exec-health-check
spec:
  template:
    spec:
      containers:
      - name: app
        image: postgres:13
        ports:
        - containerPort: 5432
        
        # Exec Probe для PostgreSQL
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - postgres
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - postgres
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Крок 9: Розширені налаштування

#### HTTP Probe з заголовками:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
    httpHeaders:
    - name: Custom-Header
      value: health-check
    - name: Authorization
      value: Bearer token123
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1
```

#### Grpc Probe (для gRPC додатків):
```yaml
livenessProbe:
  grpc:
    port: 9090
    service: grpc.health.v1.Health
  initialDelaySeconds: 30
  periodSeconds: 10
```

### Крок 10: Моніторинг та логування

Створи файл `monitoring-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitoring-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitoring
  template:
    metadata:
      labels:
        app: monitoring
    spec:
      containers:
      - name: monitoring
        image: curlimages/curl:latest
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            echo "=== Health Check $(date) ==="
            
            # Перевірка health
            echo "Health:"
            curl -s http://health-check-service/health || echo "FAILED"
            
            # Перевірка ready
            echo "Ready:"
            curl -s http://health-check-service/ready || echo "FAILED"
            
            # Перевірка endpoints
            echo "Endpoints:"
            kubectl get endpoints health-check-service || echo "FAILED"
            
            echo "========================"
            sleep 30
          done
```

## 📝 Завдання для практики

1. **Створи різні типи health checks:**
   - HTTP для web API
   - TCP для баз даних
   - Exec для складних перевірок

2. **Налаштуй різні сценарії:**
   - Повільно запускаючийся додаток
   - Додаток з періодичними проблемами
   - Додаток з залежностями

3. **Створи систему моніторингу:**
   - Автоматичні алерти при проблемах
   - Логування всіх health check результатів
   - Dashboard для відстеження стану

4. **Оптимізуй health checks:**
   - Налаштуй оптимальні таймаути
   - Зменши навантаження на кластер
   - Покращи швидкість виявлення проблем

## 🔍 Перевірка знань

- [ ] Розумію різницю між Readiness, Liveness та Startup Probe
- [ ] Можу налаштувати HTTP, TCP та Exec health checks
- [ ] Налаштував health checks для API з різними сценаріями
- [ ] Можу моніторити та тестувати health checks
- [ ] Розумію як health checks впливають на Service endpoints

## 📚 Додаткові ресурси

- [Kubernetes Health Checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Автоматичне масштабування (HPA)](../07-hpa/README.md) 