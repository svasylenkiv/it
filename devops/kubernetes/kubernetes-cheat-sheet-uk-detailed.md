# Kubernetes Cheat Sheet з поясненнями 🇺🇦

## 📚 Основні концепції Kubernetes

### Що таке Kubernetes?
Kubernetes (K8s) - це система оркестрації контейнерів, яка автоматизує розгортання, масштабування та управління додатками в контейнерах.

### Основні компоненти:
- **Pod** - найменша одиниця розгортання, може містити один або кілька контейнерів
- **Node** - фізична або віртуальна машина, де запускаються поди
- **Cluster** - набір нод, які працюють разом
- **Namespace** - логічне розділення ресурсів у кластері (як папки в файловій системі)

---

## 🗂️ Namespace (Простір імен)

### Що це таке?
Namespace - це механізм для логічного розділення ресурсів у кластері. Це як створення окремих "відділів" у вашому кластері.

### Навіщо потрібен?
- **Ізоляція** - різні команди/проекти не конфліктують між собою
- **Безпека** - обмеження доступу до ресурсів
- **Організація** - логічне групування ресурсів
- **Квоти** - обмеження ресурсів для різних namespace

### Приклади використання:
```bash
# Створення namespace для розробки
kubectl create namespace development

# Створення namespace для продакшену
kubectl create namespace production

# Створення namespace для тестування
kubectl create namespace testing
```

---

## 📋 Основний синтаксис

```bash
kubectl [команда] [ТИП] [ІМ'Я] [флаги]
```

**Приклади:**
- `kubectl get pods` - отримати список всіх подів
- `kubectl describe pod my-pod` - детальна інформація про под
- `kubectl delete deployment my-app` - видалити deployment

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

#### Поди (контейнери)
**Що це:** Поди - це найменші одиниці розгортання в Kubernetes. Кожен под може містити один або кілька контейнерів.

```bash
# Базовий список подів
kubectl get pods

# Розширена інформація (включає IP адреси та ноди)
kubectl get pods -o wide

# Фільтрація за лейблами
kubectl get pods -l app=myapp
```

#### Сервіси
**Що це:** Сервіси забезпечують мережевий доступ до подів. Вони створюють стабільну IP адресу та DNS ім'я.

```bash
# Список сервісів
kubectl get services
kubectl get svc

# Детальна інформація про сервіс
kubectl describe service my-service
```

#### Deployment
**Що це:** Deployment забезпечує декларативне оновлення подів. Він дозволяє легко масштабувати та оновлювати додатки.

```bash
# Список deployment
kubectl get deployments
kubectl get deploy

# Детальна інформація про deployment
kubectl describe deployment my-deployment
```

#### ConfigMaps та Secrets
**ConfigMap** - зберігає конфігураційні дані (не секретні)
**Secret** - зберігає секретні дані (паролі, токени)

```bash
# ConfigMaps
kubectl get configmaps

# Secrets
kubectl get secrets
```

#### PersistentVolumes та PersistentVolumeClaims
**Що це:** Механізм для збереження даних між перезапусками подів.

```bash
# PersistentVolumes
kubectl get pv

# PersistentVolumeClaims
kubectl get pvc
```

#### Nodes (вузли кластера)
**Що це:** Фізичні або віртуальні машини, де запускаються поди.

```bash
# Список нод
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

#### Створення з файлу YAML
```bash
# Створення з одного файлу
kubectl apply -f deployment.yaml

# Створення з директорії (всі YAML файли)
kubectl apply -f k8s/

# Створення з stdin (вставка YAML прямо в термінал)
kubectl apply -f -
```

#### Створення namespace
```bash
# Створення namespace
kubectl create namespace my-namespace

# Переключення на namespace
kubectl config set-context --current --namespace=my-namespace
```

#### Створення ConfigMap
**Навіщо:** Зберігати конфігураційні дані (налаштування додатку, змінні середовища)

```bash
# З файлу
kubectl create configmap my-config --from-file=config.properties

# З літеральних значень
kubectl create configmap my-config --from-literal=key=value
```

#### Створення Secret
**Навіщо:** Зберігати секретні дані (паролі, API ключі, сертифікати)

```bash
# З файлу
kubectl create secret generic my-secret --from-file=secret.txt

# З літеральних значень
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

# Оновлення через edit (відкриває редактор)
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

#### Перегляд логів
**Навіщо:** Для діагностики проблем, моніторингу роботи додатку

```bash
# Базові логи поду
kubectl logs <pod-name>

# Слідкування за логами (як tail -f)
kubectl logs <pod-name> -f

# Логи конкретного контейнера (якщо в поді кілька контейнерів)
kubectl logs <pod-name> -c <container-name>

# Логи за останні 10 хвилин
kubectl logs <pod-name> --since=10m
```

#### Підключення до поду
**Навіщо:** Для відладки, перевірки файлів, виконання команд всередині контейнера

```bash
# Підключення до поду з bash
kubectl exec -it <pod-name> -- /bin/bash

# Підключення до конкретного контейнера
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh

# Виконання команди без підключення
kubectl exec <pod-name> -- ls /app
```

#### Копіювання файлів
**Навіщо:** Для експорту логів, конфігурацій, або завантаження файлів

```bash
# Копіювання з поду на локальну машину
kubectl cp <pod-name>:/path/to/file ./local-file

# Копіювання з локальної машини в под
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

#### Rollout
**Що це:** Процес оновлення deployment (заміна старих подів на нові)

```bash
# Статус поточного rollout
kubectl rollout status deployment <deployment-name>

# Історія rollout (які версії були розгорнуті)
kubectl rollout history deployment <deployment-name>

# Відкат до попередньої версії
kubectl rollout undo deployment <deployment-name>

# Відкат до конкретної версії
kubectl rollout undo deployment <deployment-name> --to-revision=2
```

### Ресурси та використання
```bash
# Використання CPU та пам'яті подів
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

#### Типи сервісів:
- **ClusterIP** - внутрішній доступ (за замовчуванням)
- **NodePort** - доступ через порт ноди
- **LoadBalancer** - зовнішній балансувальник навантаження

```bash
# Створення сервісу
kubectl expose deployment myapp --port=80 --target-port=8080

# Порт-форвардинг для доступу до сервісу
kubectl port-forward service/myapp 8080:80

# Порт-форвардинг до поду
kubectl port-forward pod/myapp-pod 8080:80
```

### Ingress
**Що це:** Правила для маршрутизації HTTP/HTTPS трафіку до сервісів

```bash
# Перегляд Ingress
kubectl get ingress
kubectl describe ingress <ingress-name>
```

---

## 🔐 Безпека та авторизація

### RBAC (Role-Based Access Control)
**Що це:** Система контролю доступу на основі ролей

#### Ролі:
- **Role** - дозволи в межах namespace
- **ClusterRole** - дозволи в межах всього кластера

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
**Що це:** Облікові записи для подів, які дозволяють їм взаємодіяти з API сервером

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

#### Генерація YAML
**Навіщо:** Для створення шаблонів конфігурації

```bash
# Генерація YAML без створення
kubectl run myapp --image=nginx --dry-run=client -o yaml > deployment.yaml

# Генерація YAML для сервісу
kubectl expose deployment myapp --port=80 --dry-run=client -o yaml > service.yaml

# Валідація YAML файлу
kubectl apply -f deployment.yaml --dry-run=client
```

#### Експорт конфігурації
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
  namespace: production  # Вказуємо namespace
spec:
  replicas: 3  # Кількість копій поду
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
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: production
spec:
  selector:
    app: myapp  # Вибирає поди з лейблом app=myapp
  ports:
  - port: 80        # Порт сервісу
    targetPort: 80  # Порт контейнера
  type: ClusterIP   # Тип сервісу
```

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
  namespace: production
data:
  config.properties: |
    database.url=jdbc:mysql://localhost:3306/mydb
    app.name=MyApplication
  environment: production
```

### Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    team: backend
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

# Швидкий відкат до попередньої версії
kubectl rollout undo deployment myapp
```

---

## 🔄 Типові сценарії роботи

### 1. Розгортання нового додатку
```bash
# 1. Створення namespace
kubectl create namespace myapp

# 2. Створення ConfigMap
kubectl create configmap myapp-config --from-file=config.properties -n myapp

# 3. Створення Secret
kubectl create secret generic myapp-secret --from-literal=password=secret123 -n myapp

# 4. Розгортання додатку
kubectl apply -f deployment.yaml -n myapp

# 5. Створення сервісу
kubectl apply -f service.yaml -n myapp

# 6. Перевірка статусу
kubectl get all -n myapp
```

### 2. Оновлення додатку
```bash
# 1. Оновлення image
kubectl set image deployment/myapp myapp=nginx:1.20 -n myapp

# 2. Перевірка статусу rollout
kubectl rollout status deployment/myapp -n myapp

# 3. Перегляд історії
kubectl rollout history deployment/myapp -n myapp
```

### 3. Відладка проблем
```bash
# 1. Перегляд статусу подів
kubectl get pods -n myapp

# 2. Перегляд логів
kubectl logs <pod-name> -n myapp

# 3. Підключення до поду
kubectl exec -it <pod-name> -n myapp -- /bin/bash

# 4. Перегляд подій
kubectl get events -n myapp --sort-by=.metadata.creationTimestamp
```

---

## 📚 Корисні посилання

- [Офіційна документація Kubernetes](https://kubernetes.io/docs/)
- [Kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Kubernetes Cheat Sheet (англ.)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)

---

## 💡 Поради для початківців

1. **Завжди вказуйте namespace** - використовуйте `-n` флаг або встановіть namespace за замовчуванням
2. **Використовуйте лейбли** - для організації та фільтрації ресурсів
3. **Перевіряйте статус** - завжди перевіряйте `kubectl get pods` після розгортання
4. **Дивіться логи** - перша діагностика проблем через `kubectl logs`
5. **Використовуйте dry-run** - для тестування команд без реальних змін

---

*Цей cheat sheet містить детальні пояснення концепцій та найбільш поширені команди Kubernetes. Для детальної інформації дивіться офіційну документацію.* 