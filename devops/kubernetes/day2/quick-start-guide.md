# 🚀 Швидкий старт Kubernetes - Початківцям

## ⚡ За 30 хвилин у вас буде робочий Kubernetes кластер!

### 📋 Що ви зробите
1. ✅ Встановите Kubernetes середовище
2. ✅ Створите перший Pod
3. ✅ Задеплоїте додаток
4. ✅ Створите Service
5. ✅ Отримаєте доступ через браузер

---

## 🛠️ Крок 1: Встановлення середовища

### Варіант A: Docker Desktop (Найпростіший)
```bash
# 1. Завантажте Docker Desktop
# https://www.docker.com/products/docker-desktop/

# 2. Увімкніть Kubernetes в налаштуваннях
# Settings → Kubernetes → Enable Kubernetes

# 3. Перевірте встановлення
kubectl version --client
kubectl cluster-info
```

### Варіант B: Minikube
```bash
# Windows (з Chocolatey)
choco install minikube

# macOS (з Homebrew)
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Запуск
minikube start --driver=docker
```

### Варіант C: Kind
```bash
# Windows (з Chocolatey)
choco install kind

# macOS (з Homebrew)
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Створення кластеру
kind create cluster
```

---

## 🚀 Крок 2: Перший Pod

### Створення файлу
```bash
# Створіть папку для проекту
mkdir my-first-k8s
cd my-first-k8s

# Створіть файл nginx-pod.yaml
```

### nginx-pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

### Застосування
```bash
# Створення Pod
kubectl apply -f nginx-pod.yaml

# Перевірка статусу
kubectl get pods
kubectl get pods -o wide

# Детальна інформація
kubectl describe pod nginx-pod
```

---

## 🌐 Крок 3: Створення Service

### Створення файлу
```bash
# Створіть файл nginx-service.yaml
```

### nginx-service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30000
```

### Застосування
```bash
# Створення Service
kubectl apply -f nginx-service.yaml

# Перевірка Service
kubectl get services
kubectl describe service nginx-service
```

---

## 🔍 Крок 4: Доступ до додатку

### Перевірка статусу
```bash
# Перевірте, що все працює
kubectl get pods
kubectl get services
kubectl get endpoints
```

### Доступ через браузер

#### Docker Desktop
```bash
# Відкрийте браузер і перейдіть на:
http://localhost:30000
```

#### Minikube
```bash
# Отримання URL
minikube service nginx-service --url

# Або відкрийте в браузері
minikube service nginx-service
```

#### Kind
```bash
# Отримання IP ноди
kubectl get nodes -o wide

# Доступ через IP:30000
# Наприклад: http://172.18.0.2:30000
```

---

## 📊 Крок 5: Базові команди

### Перегляд ресурсів
```bash
# Pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels

# Services
kubectl get services
kubectl get svc

# Всі ресурси
kubectl get all
kubectl get all --all-namespaces
```

### Логи та дебаг
```bash
# Логи Pod
kubectl logs nginx-pod
kubectl logs -f nginx-pod

# Виконання команд в Pod
kubectl exec -it nginx-pod -- /bin/bash
kubectl exec nginx-pod -- nginx -v

# Опис ресурсу
kubectl describe pod nginx-pod
kubectl describe service nginx-service
```

### Видалення ресурсів
```bash
# Видалення конкретного ресурсу
kubectl delete pod nginx-pod
kubectl delete service nginx-service

# Видалення за файлом
kubectl delete -f nginx-pod.yaml
kubectl delete -f nginx-service.yaml

# Видалення всіх ресурсів
kubectl delete all --all
```

---

## 🎯 Крок 6: Перший Deployment

### Створення файлу
```bash
# Створіть файл nginx-deployment.yaml
```

### nginx-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

### Застосування
```bash
# Створення Deployment
kubectl apply -f nginx-deployment.yaml

# Перевірка
kubectl get deployments
kubectl get pods -l app=nginx

# Масштабування
kubectl scale deployment nginx-deployment --replicas=5
```

---

## 🔧 Крок 7: Оновлення додатку

### Rolling Update
```bash
# Оновлення образу
kubectl set image deployment/nginx-deployment nginx=nginx:1.21

# Моніторинг оновлення
kubectl rollout status deployment/nginx-deployment

# Історія оновлень
kubectl rollout history deployment/nginx-deployment

# Відкат до попередньої версії
kubectl rollout undo deployment/nginx-deployment
```

---

## 📱 Крок 8: Перевірка в браузері

### Створення Service для Deployment
```yaml
# nginx-deployment-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-deployment-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001
```

```bash
# Застосування
kubectl apply -f nginx-deployment-service.yaml

# Доступ через браузер
# http://localhost:30001
```

---

## 🎉 Вітаємо! Ви створили перший Kubernetes кластер!

### ✅ Що ви зробили
- Встановили Kubernetes середовище
- Створили Pod з nginx
- Налаштували Service для доступу
- Створили Deployment з масштабуванням
- Зробили rolling update

### 🚀 Наступні кроки
1. **Вивчіть основний план**: [kubernetes-learning-plan.md](kubernetes-learning-plan.md)
2. **Практикуйтеся з прикладами**: [kubernetes-practical-examples.md](kubernetes-practical-examples.md)
3. **Досліджуйте ресурси**: [kubernetes-resources.md](kubernetes-resources.md)

---

## 🆘 Вирішення проблем

### Проблема: Pod не запускається
```bash
# Перевірте статус
kubectl get pods
kubectl describe pod <pod-name>

# Перевірте логи
kubectl logs <pod-name>
```

### Проблема: Service не доступний
```bash
# Перевірте Service
kubectl get services
kubectl describe service <service-name>

# Перевірте Endpoints
kubectl get endpoints
```

### Проблема: Немає доступу з браузера
```bash
# Перевірте NodePort
kubectl get services -o wide

# Перевірте, що Pod працює
kubectl get pods -l app=nginx
```

---

## 📚 Корисні команди для початківців

### 🔍 Дослідження кластера
```bash
# Інформація про кластер
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Перегляд всіх ресурсів
kubectl get all
kubectl get all --all-namespaces
```

### 📊 Моніторинг
```bash
# Статус ресурсів
kubectl get pods -w
kubectl get services -w

# Детальна інформація
kubectl describe node <node-name>
kubectl describe namespace <namespace-name>
```

### 🧹 Очищення
```bash
# Видалення всіх ресурсів
kubectl delete all --all

# Видалення за мітками
kubectl delete pods -l app=nginx
kubectl delete services -l app=nginx
```

---

## 🎯 Готові до наступного кроку?

**Тепер у вас є робочий Kubernetes кластер!** 

Перейдіть до [основного плану навчання](kubernetes-learning-plan.md) та продовжуйте вивчення більш складних концепцій:

- 🔹 Deployment та Service (продовження)
- 🔹 Ingress-контролер
- 🔹 ConfigMaps та Secrets
- 🔹 Storage та StatefulSets
- 🔹 Health Checks та HPA
- 🔹 RBAC та Namespaces
- 🔹 Helm Charts
- 🔹 CI/CD пайплайни
- 🔹 Моніторинг та логування
- 🔹 Хмарне розгортання

**Успіхів у вивченні Kubernetes! 🚀** 