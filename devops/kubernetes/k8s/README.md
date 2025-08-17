# 🚀 Kubernetes: Повний курс з нуля до Production

Це комплексний курс для вивчення Kubernetes з нуля до рівня production-ready DevOps інженера.

## 📚 Структура курсу

### 🔹 1. [Базові поняття Kubernetes](01-basic-concepts/README.md)
**⏱️ Час: 1-2 дні**
- Що таке Kubernetes (K8s)
- Основні об'єкти: Pod, Node, Cluster
- Архітектура компонентів
- Declarative model
- **Практика:** Встановлення Minikube, створення першого Pod

### 🔹 2. [Deployment і Service](02-deployment-service/README.md)
**⏱️ Час: 2-3 дні**
- Deployment: масштабування та оновлення
- Service: типи та налаштування
- **Практика:** Задеплой .NET/Node.js API, налаштування Service

### 🔹 3. [Ingress-контролер](03-ingress-controller/README.md)
**⏱️ Час: 2-3 дні**
- Що таке Ingress
- Маршрутизація на основі домену
- TLS/HTTPS + Cert-Manager
- **Практика:** Доступ через myapi.local з TLS

### 🔹 4. [Конфіги та Секрети](04-configs-secrets/README.md)
**⏱️ Час: 1-2 дні**
- ConfigMap для зберігання конфігів
- Secret для паролів та токенів
- **Практика:** Винесення connection string до Secret

### 🔹 5. [Зберігання (Storage)](05-storage/README.md)
**⏱️ Час: 2-3 дні**
- PersistentVolume та PersistentVolumeClaim
- StorageClass та StatefulSet
- **Практика:** Задеплой PostgreSQL з PVC

### 🔹 6. [Health checks](06-health-checks/README.md)
**⏱️ Час: 1-2 дні**
- Readiness Probe та Liveness Probe
- Startup Probe
- **Практика:** Додавання health checks до API

### 🔹 7. [Автоматичне масштабування (HPA)](07-hpa/README.md)
**⏱️ Час: 1-2 дні**
- Horizontal Pod Autoscaler
- Метрики CPU та Memory
- **Практика:** Автоскейл API під навантаженням

### 🔹 8. [Namespaces та доступи (RBAC)](08-namespaces-rbac/README.md)
**⏱️ Час: 1-2 дні**
- Відокремлення середовищ
- Користувачі, ролі, привілеї
- **Практика:** Створення Namespace та обмеження доступу

### 🔹 9. [Helm](09-helm/README.md)
**⏱️ Час: 2-3 дні**
- Шаблони Helm
- Створення власних чартів
- **Практика:** Helm-чарт для API з БД

### 🔹 10. [CI/CD](10-ci-cd/README.md)
**⏱️ Час: 2-3 дні**
- GitHub Actions / GitLab CI
- Build → Push → Deploy
- **Практика:** CI/CD пайплайн з автоматичним розгортанням

### 🔹 11. [Моніторинг і логування](11-monitoring-logging/README.md)
**⏱️ Час: 2-3 дні**
- Prometheus + Grafana
- EFK Stack (Elasticsearch + Fluentd + Kibana)
- **Практика:** Базовий моніторинг та логування

### 🔹 12. [Розгортання в хмарі](12-cloud-deployment/README.md)
**⏱️ Час: 3-4 дні**
- AWS EKS, Azure AKS, GCP GKE
- Kubectl + Cloud CLI
- **Практика:** Задеплой API в хмарі

## 🎯 Загальний час навчання: 25-35 днів

## 🚀 Швидкий старт

### 1. Встановлення необхідних інструментів
```bash
# Kubernetes CLI
kubectl version --client

# Minikube для локального кластера
minikube version

# Helm для пакетного менеджера
helm version

# Docker для контейнерів
docker --version
```

### 2. Запуск першого кластера
```bash
# Запуск Minikube
minikube start

# Перевірка статусу
kubectl cluster-info

# Запуск dashboard
minikube dashboard
```

### 3. Перший додаток
```bash
# Створення першого Pod
kubectl run nginx --image=nginx:alpine

# Перевірка статусу
kubectl get pods

# Доступ до додатку
kubectl port-forward nginx 8080:80
```

## 📋 Рекомендації по навчанню

### ✅ Найкращі практики
- **Вчи з практикою** - не лише теорією
- **Пиши всі манифести сам** - не копіюй всліпу
- **Веди Git-репозиторій** - з усім YAML/Helm кодом
- **Працюй з реальними проектами** - створюй власні додатки

### 📚 Ресурси для навчання
- [Kubernetes.io](https://kubernetes.io/) - офіційна документація
- [Play with Kubernetes](https://labs.play-with-k8s.com/) - інтерактивна лабораторія
- [Kubernetes Tutorials](https://kubernetes.io/docs/tutorials/) - офіційні туторіали

### 🎓 Курси та сертифікати
- **CKAD** - Certified Kubernetes Application Developer
- **CKA** - Certified Kubernetes Administrator
- **CKS** - Certified Kubernetes Security Specialist

## 🔧 Інструменти та технології

### Основні
- **Kubernetes** - оркестрація контейнерів
- **Docker** - контейнеризація
- **Helm** - пакетний менеджер
- **kubectl** - CLI для Kubernetes

### CI/CD
- **GitHub Actions** - автоматизація
- **GitLab CI** - безперервна інтеграція
- **ArgoCD** - GitOps

### Моніторинг
- **Prometheus** - збір метрик
- **Grafana** - візуалізація
- **EFK Stack** - логування

### Хмарні платформи
- **AWS EKS** - Amazon
- **Azure AKS** - Microsoft
- **GCP GKE** - Google

## 🎯 Цілі навчання

Після завершення курсу ви зможете:

- ✅ **Розуміти архітектуру Kubernetes**
- ✅ **Створювати та керувати ресурсами**
- ✅ **Налаштовувати networking та security**
- ✅ **Використовувати Helm для розгортання**
- ✅ **Будувати CI/CD пайплайни**
- ✅ **Моніторити та логувати додатки**
- ✅ **Розгортати в хмарі**

## 🚀 Почати навчання

1. **Почніть з [Розділу 1](01-basic-concepts/README.md)**
2. **Виконуйте всі практичні завдання**
3. **Створюйте власні проекти**
4. **Практикуйтесь щодня**

## 🤝 Підтримка

Якщо у вас є питання або потрібна допомога:
- Створюйте Issues в репозиторії
- Додавайте Pull Requests з покращеннями
- Діліться своїм досвідом

---

**🎉 Успіхів у вивченні Kubernetes!**

*Пам'ятайте: найкращий спосіб вивчити Kubernetes - це практика, практика і ще раз практика!* 