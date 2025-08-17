# 🔹 2. Deployment і Service

**⏱️ Час: 2-3 дні**

## 📚 Теорія

### Deployment
**Deployment** - це ресурс Kubernetes, який забезпечує:
- **Масштабування** - збільшення/зменшення кількості Pod-ів
- **Оновлення** - безперервне розгортання нових версій
- **Rollback** - повернення до попередньої версії
- **Відмовостійкість** - автоматичне відновлення Pod-ів при збоях

### Service
**Service** - забезпечує стабільну точку доступу до набору Pod-ів:
- **Стабільна IP адреса** - не змінюється при перезапуску Pod-ів
- **Load balancing** - розподіл навантаження між Pod-ами
- **Service discovery** - автоматичне знаходження Pod-ів

#### Типи Service:

##### 1. ClusterIP (за замовчуванням)
- Доступ тільки всередині кластера
- Використовується для внутрішнього зв'язку між сервісами

##### 2. NodePort
- Відкриває порт на кожному Node
- Доступ ззовні кластера через `<node-ip>:<nodeport>`

##### 3. LoadBalancer
- Автоматично створює зовнішній Load Balancer
- Доступ ззовні кластера через публічну IP

## 🛠️ Практика

### Крок 1: Створення простого .NET API

Створи файл `Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["SimpleApi.csproj", "./"]
RUN dotnet restore "SimpleApi.csproj"
COPY . .
RUN dotnet build "SimpleApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SimpleApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
```

Створи файл `SimpleApi.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net7.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

Створи файл `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Hello from .NET API!");
app.MapGet("/health", () => "Healthy");
app.MapGet("/api/version", () => "v1.0.0");

app.Run();
```

### Крок 2: Збірка та публікація образу

```bash
# Збірка образу
docker build -t myapi:v1 .

# Тестування локально
docker run -p 8080:80 myapi:v1

# Публікація в реєстр (заміни на свій)
docker tag myapi:v1 your-registry/myapi:v1
docker push your-registry/myapi:v1
```

### Крок 3: Створення Deployment

Створи файл `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi-deployment
  labels:
    app: myapi
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapi
  template:
    metadata:
      labels:
        app: myapi
    spec:
      containers:
      - name: myapi
        image: myapi:v1
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Крок 4: Створення Service

Створи файл `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapi-service
  labels:
    app: myapi
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: myapi
```

### Крок 5: Застосування ресурсів

```bash
# Застосування Deployment
kubectl apply -f deployment.yaml

# Застосування Service
kubectl apply -f service.yaml

# Перевірка статусу
kubectl get deployments
kubectl get pods
kubectl get services
```

### Крок 6: Тестування Service

```bash
# Доступ до API через Service
kubectl port-forward service/myapi-service 8080:80

# Тестування в браузері або через curl
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/api/version
```

### Крок 7: Масштабування Deployment

```bash
# Збільшення кількості реплік
kubectl scale deployment myapi-deployment --replicas=5

# Перевірка
kubectl get pods

# Зменшення кількості реплік
kubectl scale deployment myapi-deployment --replicas=2
```

### Крок 8: Оновлення Deployment

```bash
# Оновлення образу
kubectl set image deployment/myapi-deployment myapi=myapi:v2

# Перевірка статусу оновлення
kubectl rollout status deployment/myapi-deployment

# Історія оновлень
kubectl rollout history deployment/myapi-deployment

# Rollback до попередньої версії
kubectl rollout undo deployment/myapi-deployment
```

### Крок 9: Різні типи Service

#### NodePort Service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapi-nodeport
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: myapi
```

#### LoadBalancer Service (для хмарних провайдерів):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapi-loadbalancer
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: myapi
```

## 📝 Завдання для практики

1. **Створи Node.js API замість .NET:**
   - Простий Express.js сервер
   - Docker образ
   - Deployment та Service

2. **Досліди різні стратегії оновлення:**
   - RollingUpdate (за замовчуванням)
   - Recreate
   - Blue-Green deployment

3. **Налаштуй LoadBalancer:**
   - Використай Minikube tunnel для LoadBalancer
   - Тестуй доступ ззовні кластера

4. **Масштабування під навантаженням:**
   - Створи скрипт для генерації навантаження
   - Спостерігай за поведінкою Pod-ів

## 🔍 Перевірка знань

- [ ] Розумію різницю між Deployment та Service
- [ ] Можу створити Deployment з кількома репліками
- [ ] Налаштував різні типи Service
- [ ] Задеплоїв .NET/Node.js API
- [ ] Можу масштабувати та оновлювати Deployment

## 📚 Додаткові ресурси

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Ingress-контролер](../03-ingress-controller/README.md) 