# 🚀 Практичні проекти Kubernetes

## 🎯 Загальна концепція

Кожен проект розроблений для закріплення знань конкретного розділу та створення portfolio робіт.

## 📁 Проект 1: Простий Web додаток

### Опис
Створення базового web додатку з використанням основних концепцій Kubernetes.

### Технології
- **Frontend:** HTML/CSS/JavaScript або React
- **Backend:** Node.js або Python Flask
- **База даних:** SQLite або PostgreSQL
- **Контейнеризація:** Docker
- **Kubernetes:** Pod, Service, Ingress

### Структура проекту
```
simple-web-app/
├── frontend/
│   ├── Dockerfile
│   ├── src/
│   └── package.json
├── backend/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── k8s/
│   ├── namespace.yaml
│   ├── frontend-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── README.md
```

### Завдання
1. **Створіть простий web додаток**
2. **Контейнеризуйте frontend та backend**
3. **Створіть Kubernetes manifests**
4. **Налаштуйте Ingress для доступу**
5. **Створіть Helm chart**

### Результат
- Web додаток доступний через `http://myapp.local`
- Автоматичне масштабування
- Health checks
- Логування та моніторинг

---

## 📁 Проект 2: API з базою даних

### Опис
Створення REST API з базою даних та повним набором Kubernetes ресурсів.

### Технології
- **API:** Node.js/Express або Python/FastAPI
- **База даних:** PostgreSQL
- **Кеш:** Redis
- **Моніторинг:** Prometheus + Grafana
- **Логування:** EFK Stack

### Структура проекту
```
api-with-db/
├── api/
│   ├── Dockerfile
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── database/
│   ├── init.sql
│   └── migrations/
├── k8s/
│   ├── namespace.yaml
│   ├── api-deployment.yaml
│   ├── postgres-statefulset.yaml
│   ├── redis-deployment.yaml
│   ├── services.yaml
│   ├── ingress.yaml
│   ├── configmaps.yaml
│   └── secrets.yaml
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   └── efk/
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── README.md
```

### Завдання
1. **Створіть REST API з CRUD операціями**
2. **Налаштуйте PostgreSQL з StatefulSet**
3. **Додайте Redis для кешування**
4. **Налаштуйте моніторинг та логування**
5. **Створіть Helm chart з залежностями**

### Результат
- API доступне через `https://api.example.com`
- База даних з персистентним зберіганням
- Автоматичне масштабування API
- Моніторинг всіх компонентів

---

## 📁 Проект 3: Мікросервісна архітектура

### Опис
Створення складної мікросервісної архітектури з кількома сервісами.

### Технології
- **API Gateway:** Kong або Istio
- **Сервіси:** User Service, Product Service, Order Service
- **База даних:** PostgreSQL, MongoDB
- **Кеш:** Redis Cluster
- **Message Queue:** RabbitMQ або Kafka
- **Service Mesh:** Istio (опціонально)

### Структура проекту
```
microservices/
├── api-gateway/
│   ├── Dockerfile
│   └── kong.yaml
├── services/
│   ├── user-service/
│   ├── product-service/
│   └── order-service/
├── databases/
│   ├── postgres/
│   ├── mongodb/
│   └── redis/
├── message-queue/
│   └── rabbitmq/
├── k8s/
│   ├── namespaces/
│   ├── deployments/
│   ├── services/
│   ├── ingress/
│   ├── configmaps/
│   └── secrets/
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   ├── jaeger/
│   └── kiali/
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── charts/
└── README.md
```

### Завдання
1. **Створіть 3 мікросервіси**
2. **Налаштуйте API Gateway**
3. **Інтегруйте різні бази даних**
4. **Налаштуйте message queue**
5. **Додайте distributed tracing**
6. **Створіть Helm chart для всієї архітектури**

### Результат
- Повнофункціональна мікросервісна архітектура
- Централізоване управління трафіком
- Моніторинг та трасування
- Автоматичне масштабування кожного сервісу

---

## 📁 Проект 4: Production-ready кластер

### Опис
Створення production-ready кластера з усіма необхідними компонентами.

### Технології
- **Кластер:** Minikube або хмарний кластер
- **Безпека:** RBAC, Network Policies, Pod Security Policies
- **Моніторинг:** Prometheus + Grafana + AlertManager
- **Логування:** EFK Stack
- **CI/CD:** ArgoCD + GitOps
- **Backup:** Velero
- **Security:** Falco, OPA Gatekeeper

### Структура проекту
```
production-cluster/
├── infrastructure/
│   ├── namespaces/
│   ├── rbac/
│   ├── network-policies/
│   └── security-policies/
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   ├── alertmanager/
│   └── dashboards/
├── logging/
│   ├── elasticsearch/
│   ├── fluentd/
│   └── kibana/
├── security/
│   ├── falco/
│   ├── opa-gatekeeper/
│   └── security-contexts/
├── backup/
│   └── velero/
├── gitops/
│   ├── argocd/
│   └── applications/
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── charts/
└── README.md
```

### Завдання
1. **Налаштуйте безпеку кластера**
2. **Створіть систему моніторингу**
3. **Налаштуйте централізоване логування**
4. **Імплементуйте GitOps**
5. **Налаштуйте backup та disaster recovery**
6. **Створіть документацію та runbooks**

### Результат
- Production-ready кластер
- Повна безпека та compliance
- Автоматичне розгортання через Git
- Моніторинг та алерти
- Backup та відновлення

---

## 🎯 Рекомендації по виконанню

### Поетапне виконання
1. **Почніть з простого проекту**
2. **Поступово ускладнюйте**
3. **Додавайте нові функції**
4. **Тестуйте та оптимізуйте**

### Git workflow
1. **Створіть репозиторій для кожного проекту**
2. **Використовуйте feature branches**
3. **Створюйте Pull Requests**
4. **Документуйте зміни**

### Portfolio
1. **Зберігайте всі проекти в GitHub**
2. **Створюйте детальну документацію**
3. **Додайте скріншоти та демо**
4. **Опишіть технічні рішення**

## 🚀 Запуск проектів

### Локальна розробка
```bash
# Запуск Minikube
minikube start

# Включення addons
minikube addons enable ingress
minikube addons enable metrics-server

# Перевірка статусу
kubectl cluster-info
```

### Хмарне розгортання
```bash
# AWS EKS
eksctl create cluster --name my-cluster --region us-west-2

# Azure AKS
az aks create --resource-group myResourceGroup --name myAKSCluster

# GCP GKE
gcloud container clusters create my-gke-cluster --zone us-central1-a
```

## 📚 Корисні ресурси

### Документація
- [Kubernetes.io](https://kubernetes.io/)
- [Helm.sh](https://helm.sh/)
- [Prometheus.io](https://prometheus.io/)

### Приклади
- [Kubernetes Examples](https://github.com/kubernetes/examples)
- [Helm Charts](https://github.com/helm/charts)
- [Istio Examples](https://github.com/istio/istio/tree/master/samples)

---

**🎯 Мета: Створити portfolio з 4 production-ready проектів!**

*Кожен проект - це крок до майстерності в Kubernetes.* 