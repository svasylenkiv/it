# 🚀 Deployment і Service (приклад з .NET API)

> Ми розгорнемо простий ASP.NET Core Web API (hello world), зробимо Deployment і Service.

---

## 📋 Зміст

- [1️⃣ Підготовка Docker-образу](#-підготовка-docker-образу)
- [2️⃣ Deployment для API](#-deployment-для-api)
- [3️⃣ Service для доступу](#-service-для-доступу)
- [4️⃣ Застосування в Kubernetes](#-застосування-в-kubernetes)
- [5️⃣ Перевірка](#-перевірка)
- [6️⃣ Доступ до API](#-доступ-до-api)
- [✅ Що ми зробили](#-що-ми-зробили)

---

## 1️⃣ Підготовка Docker-образу

> Якщо у тебе вже є готовий .NET API — просто збери образ і залий у Docker Hub (або інший реєстр).

### 📄 Приклад Dockerfile

```dockerfile
# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

# Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish --no-restore

# Final
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "TodoApi.dll"]

```

### 🔨 Збірка і пуш у Docker Hub

```powershell
docker login
cd app
docker build -t <твій_логін>/todoapi:1.0 .
docker push <твій_логін>/todoapi:1.0
```

### 🏷️ Якщо образ вже зібраний локально — лише тег і пуш

```powershell
docker login
docker images
docker tag <локальна_назва_або_ID_образу> <твій_логін>/todoapi:1.0
docker push <твій_логін>/todoapi:1.0
```

---

## 2️⃣ Deployment для API

### 📄 todoapi-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todoapi-deployment
  labels:
    app: todoapi
spec:
  replicas: 2
  selector:
    matchLabels:
      app: todoapi
  template:
    metadata:
      labels:
        app: todoapi
    spec:
      containers:
        - name: todoapi
          image: <твій_логін>/todoapi:1.0
          ports:
            - containerPort: 80
```

---

## 3️⃣ Service для доступу

### 📄 todoapi-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: todoapi-service
spec:
  selector:
    app: todoapi
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
```

---

## 4️⃣ Застосування в Kubernetes

```powershell
kubectl apply -f todoapi-deployment.yaml
kubectl apply -f todoapi-service.yaml
```

---

## 5️⃣ Перевірка

```powershell
kubectl get deployments
kubectl get pods
kubectl get svc todoapi-service
```

---

## 6️⃣ Доступ до API

```powershell
minikube service todoapi-service
```

> Відкриється браузер, і ти побачиш відповідь API (наприклад, "Hello World").

---

## ✅ Що ми зробили на цьому етапі

- ✅ Навчилися деплоїти .NET API в Kubernetes
- ✅ Зробили доступ через Service (NodePort)
- ✅ Можемо масштабувати API

### 🔧 Масштабування API

```powershell
kubectl scale deployment todoapi-deployment --replicas=5
```

---

<div align="center">

**🎉 Вітаємо! Ти успішно розгорнув .NET API в Kubernetes! 🎉**

</div>