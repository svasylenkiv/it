# Kubernetes Cheat Sheet 🇺🇦

## 📋 Основний синтаксис

```bash
kubectl [команда] [ТИП] [ІМ'Я] [флаги]
```

---

## 🔍 Перегляд ресурсів

### Отримання інформації про кластер
```bash
# Перевірка версії kubectl та підключення до кластера
kubectl version
kubectl cluster-info

# Перегляд всіх namespace
kubectl get namespaces
kubectl get ns

# Перегляд ресурсів у поточному namespace
kubectl get all
```

### Отримання списку ресурсів
```bash
# Поди (контейнери)
kubectl get pods
kubectl get pods -o wide
kubectl get pods -l app=myapp

# Сервіси
kubectl get services
kubectl get svc

# Deployment
kubectl get deployments
kubectl get deploy

# ConfigMaps та Secrets
kubectl get configmaps
kubectl get secrets

# PersistentVolumes та PersistentVolumeClaims
kubectl get pv
kubectl get pvc

# Nodes (вузли кластера)
kubectl get nodes
kubectl get nodes -o wide
```

### Детальна інформація про ресурси
```bash
# Детальний опис поду
kubectl describe pod <pod-name>
kubectl describe pod <pod-name> -n <namespace>

# Детальний опис сервісу
kubectl describe service <service-name>

# Детальний опис deployment
kubectl describe deployment <deployment-name>

# Детальний опис ноди
kubectl describe node <node-name>
```

---

## 🚀 Створення та управління ресурсами

### Створення ресурсів
```bash
# Створення з файлу YAML
kubectl apply -f deployment.yaml
kubectl apply -f k8s/

# Створення з stdin
kubectl apply -f -

# Створення namespace
kubectl create namespace my-namespace

# Створення ConfigMap
kubectl create configmap my-config --from-file=config.properties
kubectl create configmap my-config --from-literal=key=value

# Створення Secret
kubectl create secret generic my-secret --from-file=secret.txt
kubectl create secret generic my-secret --from-literal=username=admin
```

### Оновлення ресурсів
```bash
# Оновлення з файлу
kubectl apply -f deployment.yaml

# Оновлення image в deployment
kubectl set image deployment/myapp myapp=nginx:1.19

# Масштабування deployment
kubectl scale deployment myapp --replicas=3

# Оновлення через edit
kubectl edit deployment myapp
```

### Видалення ресурсів
```bash
# Видалення конкретного ресурсу
kubectl delete pod <pod-name>
kubectl delete service <service-name>
kubectl delete deployment <deployment-name>

# Видалення всіх ресурсів з файлу
kubectl delete -f deployment.yaml

# Видалення всіх подів у namespace
kubectl delete pods --all -n <namespace>

# Видалення namespace (видаляє всі ресурси в ньому)
kubectl delete namespace <namespace>
```

---

## 🔧 Робота з подами

### Логи та відладка
```bash
# Перегляд логів поду
kubectl logs <pod-name>
kubectl logs <pod-name> -f  # слідкування за логами
kubectl logs <pod-name> -c <container-name>  # для конкретного контейнера

# Підключення до поду
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh

# Копіювання файлів
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

### Перезапуск подів
```bash
# Перезапуск deployment (створює нові поди)
kubectl rollout restart deployment <deployment-name>

# Перезапуск конкретного поду
kubectl delete pod <pod-name>
```

---

## 📊 Моніторинг та аналіз

### Статус розгортання
```bash
# Статус rollout
kubectl rollout status deployment <deployment-name>

# Історія rollout
kubectl rollout history deployment <deployment-name>

# Відкат до попередньої версії
kubectl rollout undo deployment <deployment-name>
kubectl rollout undo deployment <deployment-name> --to-revision=2
```

### Ресурси та використання
```bash
# Використання ресурсів подів
kubectl top pods
kubectl top pods -n <namespace>

# Використання ресурсів нод
kubectl top nodes

# Детальна інформація про ресурси
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[*].resources.requests.cpu,MEMORY:.spec.containers[*].resources.requests.memory
```

---

## 🌐 Мережеві ресурси

### Сервіси
```bash
# Створення сервісу
kubectl expose deployment myapp --port=80 --target-port=8080

# Порт-форвардинг для доступу до сервісу
kubectl port-forward service/myapp 8080:80

# Порт-форвардинг до поду
kubectl port-forward pod/myapp-pod 8080:80
```

### Ingress
```bash
# Перегляд Ingress
kubectl get ingress
kubectl describe ingress <ingress-name>
```

---

## 🔐 Безпека та авторизація

### RBAC (Role-Based Access Control)
```bash
# Перегляд ролей
kubectl get roles
kubectl get clusterroles

# Перегляд RoleBindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Детальна інформація про ролі
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>
```

### Service Accounts
```bash
# Перегляд Service Accounts
kubectl get serviceaccounts
kubectl get sa

# Створення Service Account
kubectl create serviceaccount my-service-account
```

---

## 📁 Робота з файлами

### YAML файли
```bash
# Генерація YAML без створення
kubectl run myapp --image=nginx --dry-run=client -o yaml > deployment.yaml

# Генерація YAML для сервісу
kubectl expose deployment myapp --port=80 --dry-run=client -o yaml > service.yaml

# Валідація YAML файлу
kubectl apply -f deployment.yaml --dry-run=client
```

### Експорт конфігурації
```bash
# Експорт поточного стану
kubectl get deployment myapp -o yaml > exported-deployment.yaml

# Експорт без серверних полів
kubectl get deployment myapp -o yaml --export > clean-deployment.yaml
```

---

## 🎯 Корисні флаги та опції

### Фільтрація та форматування
```bash
# Фільтрація за лейблами
kubectl get pods -l app=myapp,env=production

# Виключення лейблів
kubectl get pods -l '!app'

# Сортування
kubectl get pods --sort-by=.metadata.creationTimestamp

# Формати виводу
kubectl get pods -o wide
kubectl get pods -o json
kubectl get pods -o yaml
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
```

### Namespace
```bash
# Встановлення namespace за замовчуванням
kubectl config set-context --current --namespace=my-namespace

# Перегляд ресурсів у всіх namespace
kubectl get pods --all-namespaces
kubectl get pods -A
```

---

## 🛠️ Корисні команди для відладки

### Перевірка стану кластера
```bash
# Перевірка компонентів кластера
kubectl get componentstatuses
kubectl get cs

# Перевірка API ресурсів
kubectl api-resources

# Перевірка API версій
kubectl api-versions
```

### Перевірка конфігурації
```bash
# Перевірка конфігурації kubectl
kubectl config view

# Перевірка поточного контексту
kubectl config current-context

# Перелік всіх контекстів
kubectl config get-contexts
```

---

## 📝 Приклади YAML файлів

### Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
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
        image: nginx:1.19
        ports:
        - containerPort: 80
```

### Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  config.properties: |
    database.url=jdbc:mysql://localhost:3306/mydb
    app.name=MyApplication
```

---

## 🚨 Швидкі команди для аварійних ситуацій

```bash
# Швидке масштабування до 0 (зупинка всіх подів)
kubectl scale deployment myapp --replicas=0

# Швидке масштабування до 1
kubectl scale deployment myapp --replicas=1

# Видалення всіх подів у namespace
kubectl delete pods --all -n <namespace>

# Перезапуск всіх deployment у namespace
kubectl rollout restart deployment --all -n <namespace>
```

---

## 📚 Корисні посилання

- [Офіційна документація Kubernetes](https://kubernetes.io/docs/)
- [Kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Kubernetes Cheat Sheet (англ.)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

*Цей cheat sheet містить найбільш поширені команди Kubernetes. Для детальної інформації дивіться офіційну документацію.* 