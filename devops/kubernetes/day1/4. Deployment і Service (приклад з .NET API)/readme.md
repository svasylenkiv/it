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
- [7️⃣ Зупинка сервісу](#-зупинка-сервісу)
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

### 🔧 Покращений варіант Dockerfile (рекомендований)

> **Примітка:** Назва файлу `TodoApi.dll` може не співпадати з реальною назвою проекту. 
> Краще використовувати `*.dll` для автоматичного пошуку DLL файлу:

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
# Автоматично знаходить DLL файл проекту
ENTRYPOINT ["dotnet", "*.dll"]
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
kubectl get endpoints todoapi-service
```

> Якщо `endpoints` порожній — Pod-и ще не готові або не співпав селектор `app: todoapi`.

---

## 6️⃣ Доступ до API

```powershell
minikube service todoapi-service --url
```

- Перейди за виданою URL. Якщо на корені `/` 404 — відкрий свій реальний маршрут (наприклад, `/swagger`, `/api/todos` тощо).
- Перевірити швидко:

```powershell
curl $(minikube service todoapi-service --url)/swagger
```

---

## 7️⃣ Зупинка сервісу

### 🛑 Зупинка Deployment

```powershell
kubectl delete deployment todoapi-deployment
```

### 🛑 Зупинка Service

```powershell
kubectl delete service todoapi-service
```

### 🛑 Або все разом

```powershell
kubectl delete -f todoapi-deployment.yaml
kubectl delete -f todoapi-service.yaml
```

### 🔍 Перевірка, що все зупинено

```powershell
kubectl get deployments
kubectl get pods
kubectl get services
```

### 🔧 Масштабування API

```powershell
kubectl scale deployment todoapi-deployment --replicas=5
```

---

## ✅ Що ми зробили на цьому етапі

- ✅ Навчилися деплоїти .NET API в Kubernetes
- ✅ Зробили доступ через Service (NodePort)
- ✅ Можемо масштабувати API

---

<div align="center">

**🎉 Вітаємо! Ти успішно розгорнув .NET API в Kubernetes! 🎉**

</div>