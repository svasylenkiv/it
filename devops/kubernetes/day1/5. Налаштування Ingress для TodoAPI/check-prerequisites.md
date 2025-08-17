# ✅ Перевірка передумов для Ingress

## 🔍 Перевірка, що TodoAPI розгорнуто

### 1. Перевірка Deployment

```bash
kubectl get deployment todoapi-deployment
```

**Очікуваний результат:**
```
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
todoapi-deployment    2/2     2            2           5m
```

### 2. Перевірка Pods

```bash
kubectl get pods -l app=todoapi
```

**Очікуваний результат:**
```
NAME                                   READY   STATUS    RESTARTS   AGE
todoapi-deployment-7d8f9c8f9c-abc12   1/1     Running   0          5m
todoapi-deployment-7d8f9c8f9c-def34   1/1     Running   0          5m
```

### 3. Перевірка Service

```bash
kubectl get svc todoapi-service
```

**Очікуваний результат:**
```
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
todoapi-service   ClusterIP   10.96.123.45   <none>        80/TCP    5m
```

### 4. Перевірка Endpoints

```bash
kubectl get endpoints todoapi-service
```

**Очікуваний результат:**
```
NAME              ENDPOINTS                         AGE
todoapi-service   10.244.0.5:80,10.244.0.6:80     5m
```

## 🚨 Якщо щось не так

### Deployment не готовий

```bash
# Детальна інформація про Deployment
kubectl describe deployment todoapi-deployment

# Логи Pod-ів
kubectl logs -l app=todoapi
```

### Service не має Endpoints

```bash
# Перевірка селекторів
kubectl get svc todoapi-service -o yaml

# Перевірка labels на Pod-ах
kubectl get pods -l app=todoapi --show-labels
```

### Pod-и не запускаються

```bash
# Опис Pod-а
kubectl describe pod <pod-name>

# Логи контейнера
kubectl logs <pod-name>
```

## 🔧 Швидке виправлення

### Якщо Service має неправильний тип

```bash
# Змінити на ClusterIP
kubectl patch svc todoapi-service -p '{"spec":{"type":"ClusterIP"}}'
```

### Якщо Pod-и не готові

```bash
# Перезапустити Deployment
kubectl rollout restart deployment todoapi-deployment

# Дочекатися готовності
kubectl rollout status deployment todoapi-deployment
```

## ✅ Готовність до Ingress

**Перед створенням Ingress переконайся, що:**

- [ ] Deployment `todoapi-deployment` має статус `READY: 2/2`
- [ ] Pod-и мають статус `Running`
- [ ] Service `todoapi-service` має тип `ClusterIP`
- [ ] Endpoints не порожній
- [ ] TodoAPI відповідає на запити (можна протестувати через NodePort)

### Тест TodoAPI через NodePort (якщо ще не ClusterIP)

```bash
# Отримати URL для тестування
minikube service todoapi-service --url

# Тест API
curl $(minikube service todoapi-service --url)/todos
curl $(minikube service todoapi-service --url)/swagger
``` 