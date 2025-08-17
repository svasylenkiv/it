# 4. Конфіги та Секрети ⏱️ 1–2 дні

**ConfigMap** — зберігання конфігів.  
**Secret** — паролі, токени, credentials.  
Використання в Pod-ах через env або volume.

👉 **Практика**: Винеси connection string до Secret.

## 1. Що таке ConfigMap і Secret

| Ресурс | Для чого | Особливості |
|--------|----------|-------------|
| **ConfigMap** | Зберігання звичайних конфігів (рядки, файли) | Дані зберігаються в plain text |
| **Secret** | Зберігання чутливих даних (паролі, ключі, токени, connection string) | Дані base64-encoded, але все одно читаються у кластері — не шифрування, а обфускація |

### 📌 Рекомендація:

- **Загальнодоступні конфіги** — у ConfigMap
- **Паролі, ключі, connection strings** — у Secret

## 2. Створюємо Secret з connection string

### Варіант 1 — одразу в YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-connection-secret
type: Opaque
data:
  connection-string: cG9zdGdyZXNxbDovL3VzZXI6cGFzc3dvcmRAMTIzLjAuMC4xOjU0MzIvbXlkYg==
```

Тут `connection-string` — це base64 від:
```
postgresql://user:password@123.0.0.1:5432/mydb
```

**Отримати base64:**
```bash
echo -n "postgresql://user:password@123.0.0.1:5432/mydb" | base64
```

### Варіант 2 — через команду kubectl

```bash
kubectl create secret generic db-connection-secret \
  --from-literal=connection-string="postgresql://user:password@123.0.0.1:5432/mydb"
```

## 3. Використання Secret у Pod через env

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi-deployment
spec:
  replicas: 1
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
        image: myregistry/myapi:latest
        ports:
        - containerPort: 80
        env:
        - name: CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: db-connection-secret
              key: connection-string
```

## 4. Використання Secret як volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-volume-demo
spec:
  containers:
  - name: demo
    image: nginx
    volumeMounts:
    - name: secret-vol
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secret-vol
    secret:
      secretName: db-connection-secret
```

Тоді в контейнері буде файл `/etc/secrets/connection-string` з потрібним значенням.

## 5. Перевірка

```bash
kubectl get secret db-connection-secret -o yaml
kubectl describe secret db-connection-secret
```

Значення виводяться у base64 — для читання:

```bash
kubectl get secret db-connection-secret -o jsonpath="{.data.connection-string}" | base64 --decode
```

---

## Повний приклад з .NET API

Готовий працюючий приклад .NET API, який читає connection string з Secret, інші несекретні налаштування — з ConfigMap.

**Отримаєш:**
- мінімальний .NET 8 API з підключенням до PostgreSQL
- Dockerfile для збірки образу
- Kubernetes маніфести: Namespace, Secret, ConfigMap, Deployment, Service
- команди перевірки

### 0) Структура папок

```
k8s-secrets-configmap-demo/
├─ src/
│  └─ MyApi/
│     ├─ MyApi.csproj
│     ├─ Program.cs
│     └─ appsettings.json            # опційно, для локалу
├─ Dockerfile
└─ k8s/
   ├─ 00-namespace.yaml
   ├─ 10-secret.yaml
   ├─ 20-configmap.yaml
   ├─ 30-deployment.yaml
   └─ 40-service.yaml
```

### 1) .NET API

**`src/MyApi/MyApi.csproj`**
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Npgsql" Version="8.0.3" />
    <PackageReference Include="Microsoft.Extensions.Diagnostics.HealthChecks" Version="8.0.0" />
  </ItemGroup>
</Project>
```

**`src/MyApi/Program.cs`**
```csharp
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// Читаємо налаштування з ENV (із Secret/ConfigMap)
var connString = Environment.GetEnvironmentVariable("CONNECTION_STRING");
var appName = Environment.GetEnvironmentVariable("APP_NAME") ?? "MyApi";

// Перевірка: якщо рядок підключення не переданий — кидаємо явну помилку на старті
if (string.IsNullOrWhiteSpace(connString))
{
    throw new InvalidOperationException("CONNECTION_STRING is not set. Provide it via Kubernetes Secret.");
}

// Реєструємо пул підключень Npgsql
builder.Services.AddNpgsqlDataSource(connString);

// Health-check: проста перевірка БД
builder.Services.AddHealthChecks()
    .AddNpgSql(connString, name: "postgres");

var app = builder.Build();

app.MapGet("/", () => new { message = $"Hello from {appName}!", time = DateTimeOffset.UtcNow });

app.MapGet("/db/now", async (NpgsqlDataSource ds) =>
{
    await using var cmd = ds.CreateCommand("select now(), version()");
    await using var reader = await cmd.ExecuteReaderAsync();
    await reader.ReadAsync();
    return Results.Ok(new {
        now = reader.GetFieldValue<DateTime>(0),
        version = reader.GetString(1)
    });
});

app.MapHealthChecks("/healthz");     // liveness/readiness можна вказати на цей ендпоінт

app.Run();
```

**(опційно) `src/MyApi/appsettings.json`**
```json
{
  "Logging": { 
    "LogLevel": { 
      "Default": "Information", 
      "Microsoft.AspNetCore": "Warning" 
    } 
  } 
}
```

### 2) Dockerfile (корінь проєкту)

Замінюй `myrepo/myapi:demo` на свій реєстр/тег.

```dockerfile
# build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ./src/MyApi ./MyApi
RUN dotnet restore ./MyApi/MyApi.csproj
RUN dotnet publish ./MyApi/MyApi.csproj -c Release -o /out

# run
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out ./
# ASP.NET всередині контейнера слухає 8080, далі ми пробросимо на Service:80
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "MyApi.dll"]
```

**Збірка й пуш:**
```bash
# у корені (де Dockerfile)
docker build -t myrepo/myapi:demo .
docker push myrepo/myapi:demo
```

### 3) Kubernetes маніфести

Використовуємо namespace `apps-dev`. Застосовуй у такій послідовності.

**`k8s/00-namespace.yaml`**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: apps-dev
```

**`k8s/10-secret.yaml`** — Secret з connection string

**ПРИКЛАД**: заміни значення на своє. Тут можна ВІДРАЗУ plaintext — kubectl перетворить у base64.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-connection-secret
  namespace: apps-dev
type: Opaque
stringData:
  connection-string: "Host=postgres.example.internal;Port=5432;Database=mydb;Username=myuser;Password=mypassword;SSL Mode=Disable"
```

**Альтернатива CLI (без yaml):**
```bash
kubectl create secret generic db-connection-secret \
  --from-literal=connection-string="Host=...;Port=5432;Database=...;Username=...;Password=...;SSL Mode=Disable" \
  -n apps-dev
```

**`k8s/20-configmap.yaml`** — ConfigMap з не чутливими параметрами
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapi-config
  namespace: apps-dev
data:
  APP_NAME: "MyApi (dev)"
  # приклад додаткових опцій
  LOG_LEVEL__Default: "Information"
```

**`k8s/30-deployment.yaml`** — Deployment: читаємо Secret/ConfigMap в env
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapi-deployment
  namespace: apps-dev
spec:
  replicas: 1
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
        image: myrepo/myapi:demo
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        env:
        # Secret -> env
        - name: CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: db-connection-secret
              key: connection-string
        # ConfigMap -> env
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: myapi-config
              key: APP_NAME
        # Приклад лівнес/редінес (один і той же ендпоінт)
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
```

**`k8s/40-service.yaml`** — Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapi-svc
  namespace: apps-dev
spec:
  type: ClusterIP
  selector:
    app: myapi
  ports:
  - name: http
    port: 80
    targetPort: 8080
```

### 4) Застосування маніфестів і перевірка

```bash
# створюємо namespace
kubectl apply -f k8s/00-namespace.yaml

# secret + configmap
kubectl apply -f k8s/10-secret.yaml
kubectl apply -f k8s/20-configmap.yaml

# деплой + сервіс
kubectl apply -f k8s/30-deployment.yaml
kubectl apply -f k8s/40-service.yaml

# стан
kubectl get pods -n apps-dev
kubectl logs deploy/myapi-deployment -n apps-dev

# локальний доступ (без Ingress поки що):
kubectl port-forward -n apps-dev svc/myapi-svc 8080:80
```

**У браузері/CLI:**
- `http://localhost:8080/` → Hello from MyApi (dev)!
- `http://localhost:8080/db/now` → now + version() з БД
- `http://localhost:8080/healthz` → 200 OK

### 5) Оновлення секретів/конфігів без простою

**змінити Secret/ConfigMap:**
```bash
kubectl apply -f k8s/10-secret.yaml
kubectl apply -f k8s/20-configmap.yaml
```

**перезапустити поди, щоб підтягнули нові значення env (найпростіше):**
```bash
kubectl rollout restart deploy/myapi-deployment -n apps-dev
```

> **Примітка**: env змінні зчитуються на старті контейнера; якщо монтуєш як файл — можна зробити hot-reload у самому застосунку

### 6) Поради по безпеці Secret

- **У продакшені** використовуйте Encryption at Rest для Secret-ів (KMS/Cloud KMS на керованих кластерах або EncryptionConfiguration для kube-apiserver).
- **Обмежуйте доступ RBAC**: хто може читати secrets у namespace.
- **Розглянь external secrets** (External Secrets Operator / SOPS) для інтеграції з AWS Secrets Manager / Azure Key Vault / HashiCorp Vault.

---

**Хочеш** — зроблю варіант з Ingress + myapi.local (TLS через cert-manager) або додам PostgreSQL у кластері з PVC (Days 10–11), щоб мати повністю самодостатній стенд.