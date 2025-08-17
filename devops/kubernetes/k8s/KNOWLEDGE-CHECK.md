# ✅ Перевірка знань Kubernetes

## 🎯 Загальна структура

Кожен розділ має чек-лист для перевірки знань. Відмічайте галочки по мірі проходження матеріалу.

---

## 🔹 Розділ 1: Базові поняття Kubernetes

### Теоретичні знання
- [ ] Розумію що таке Kubernetes та його призначення
- [ ] Можу описати архітектуру кластера
- [ ] Розумію різницю між Pod, Node та Cluster
- [ ] Знаю основні компоненти Control Plane
- [ ] Розумію принцип declarative model

### Практичні навички
- [ ] Встановив Minikube та kubectl
- [ ] Можу запустити локальний кластер
- [ ] Створив перший Pod
- [ ] Використовую базові команди kubectl
- [ ] Можу переглядати ресурси кластера

### Перевірка
```bash
# Тест 1: Створення Pod
kubectl run test-pod --image=nginx:alpine

# Тест 2: Перегляд ресурсів
kubectl get all

# Тест 3: Опис Pod
kubectl describe pod test-pod

# Тест 4: Логи Pod
kubectl logs test-pod

# Тест 5: Видалення Pod
kubectl delete pod test-pod
```

---

## 🔹 Розділ 2: Deployment і Service

### Теоретичні знання
- [ ] Розумію призначення Deployment
- [ ] Знаю різниці між Deployment та Pod
- [ ] Розумію типи Service (ClusterIP, NodePort, LoadBalancer)
- [ ] Знаю як працює load balancing
- [ ] Розумію принцип rolling updates

### Практичні навички
- [ ] Створив Deployment з кількома репліками
- [ ] Налаштував різні типи Service
- [ ] Задеплоїв .NET/Node.js API
- [ ] Можу масштабувати Deployment
- [ ] Можу оновлювати Deployment

### Перевірка
```bash
# Тест 1: Створення Deployment
kubectl create deployment nginx --image=nginx:alpine

# Тест 2: Масштабування
kubectl scale deployment nginx --replicas=3

# Тест 3: Створення Service
kubectl expose deployment nginx --port=80 --target-port=80

# Тест 4: Оновлення образу
kubectl set image deployment/nginx nginx=nginx:latest

# Тест 5: Перегляд статусу
kubectl rollout status deployment/nginx
```

---

## 🔹 Розділ 3: Ingress-контролер

### Теоретичні знання
- [ ] Розумію призначення Ingress
- [ ] Знаю різниці між Ingress та Service
- [ ] Розумію типи маршрутизації (path-based, host-based)
- [ ] Знаю як працює TLS/HTTPS
- [ ] Розумію роль Ingress Controller

### Практичні навички
- [ ] Встановив NGINX Ingress Controller
- [ ] Створив Ingress з різними правилами
- [ ] Налаштував TLS/HTTPS з cert-manager
- [ ] Можу налаштувати hosts файл
- [ ] Тестую Ingress маршрутизацію

### Перевірка
```bash
# Тест 1: Перевірка Ingress Controller
kubectl get pods -n ingress-nginx

# Тест 2: Створення Ingress
kubectl apply -f ingress.yaml

# Тест 3: Перевірка Ingress
kubectl get ingress

# Тест 4: Тестування маршрутизації
curl -H "Host: myapi.local" http://localhost/

# Тест 5: Перевірка TLS
curl -k https://myapi.local
```

---

## 🔹 Розділ 4: Конфіги та Секрети

### Теоретичні знання
- [ ] Розумію різницю між ConfigMap та Secret
- [ ] Знаю способи використання конфігурації
- [ ] Розумію принципи безпеки Secret
- [ ] Знаю як монтувати конфігурацію
- [ ] Розумію життєвий цикл конфігурації

### Практичні навички
- [ ] Створив ConfigMap з різними типами даних
- [ ] Створив Secret для чутливих даних
- [ ] Налаштував використання в Pod
- [ ] Можу монтувати як файли та змінні
- [ ] Можу оновлювати конфігурацію

### Перевірка
```bash
# Тест 1: Створення ConfigMap
kubectl create configmap app-config --from-literal=APP_NAME=MyApp

# Тест 2: Створення Secret
kubectl create secret generic app-secret --from-literal=DB_PASSWORD=secret123

# Тест 3: Перегляд ресурсів
kubectl get configmap app-config -o yaml
kubectl get secret app-secret -o yaml

# Тест 4: Використання в Pod
kubectl apply -f pod-with-config.yaml

# Тест 5: Перевірка конфігурації
kubectl exec -it <pod-name> -- env | grep APP_
```

---

## 🔹 Розділ 5: Зберігання (Storage)

### Теоретичні знання
- [ ] Розумію різницю між PV, PVC та StorageClass
- [ ] Знаю типи зберігання та access modes
- [ ] Розумію призначення StatefulSet
- [ ] Знаю як працює динамічне provision
- [ ] Розумію принципи backup та recovery

### Практичні навички
- [ ] Створив StorageClass
- [ ] Створив PVC та PV
- [ ] Налаштував StatefulSet з PostgreSQL
- [ ] Можу розширити зберігання
- [ ] Створив систему backup

### Перевірка
```bash
# Тест 1: Створення StorageClass
kubectl apply -f storage-class.yaml

# Тест 2: Створення PVC
kubectl apply -f pvc.yaml

# Тест 3: Перегляд зберігання
kubectl get pvc
kubectl get pv

# Тест 4: Створення StatefulSet
kubectl apply -f postgres-statefulset.yaml

# Тест 5: Перевірка зберігання
kubectl exec -it postgres-0 -- ls -la /var/lib/postgresql/data
```

---

## 🔹 Розділ 6: Health checks

### Теоретичні знання
- [ ] Розумію різницю між Readiness, Liveness та Startup Probe
- [ ] Знаю методи Probe (HTTP, TCP, Exec)
- [ ] Розумію параметри та налаштування
- [ ] Знаю як health checks впливають на Service
- [ ] Розумію принципи автоматичного відновлення

### Практичні навички
- [ ] Налаштував health checks для API
- [ ] Створив різні типи Probe
- [ ] Можу моніторити health status
- [ ] Налаштував автоматичне відновлення
- [ ] Тестую різні сценарії

### Перевірка
```bash
# Тест 1: Створення Pod з health checks
kubectl apply -f pod-with-health.yaml

# Тест 2: Перегляд health checks
kubectl describe pod <pod-name>

# Тест 3: Тестування health endpoints
curl http://localhost:8080/health
curl http://localhost:8080/ready

# Тест 4: Симуляція проблем
curl -X POST http://localhost:8080/health/toggle

# Тест 5: Перевірка відновлення
kubectl get pods -w
```

---

## 🔹 Розділ 7: Автоматичне масштабування (HPA)

### Теоретичні знання
- [ ] Розумію принцип роботи HPA
- [ ] Знаю типи метрик для масштабування
- [ ] Розумію параметри масштабування
- [ ] Знаю як налаштувати поведінку
- [ ] Розумію принципи стабілізації

### Практичні навички
- [ ] Встановив Metrics Server
- [ ] Створив HPA на основі CPU/Memory
- [ ] Налаштував автоматичне масштабування
- [ ] Можу тестувати під навантаженням
- [ ] Можу моніторити HPA

### Перевірка
```bash
# Тест 1: Перевірка Metrics Server
kubectl top pods
kubectl top nodes

# Тест 2: Створення HPA
kubectl apply -f hpa.yaml

# Тест 3: Перегляд HPA
kubectl get hpa
kubectl describe hpa <name>

# Тест 4: Тестування масштабування
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://service-name; done"

# Тест 5: Перегляд масштабування
kubectl get pods -w
```

---

## 🔹 Розділ 8: Namespaces та доступи (RBAC)

### Теоретичні знання
- [ ] Розумію призначення Namespaces
- [ ] Знаю принципи RBAC
- [ ] Розумію різниці між Role та ClusterRole
- [ ] Знаю як налаштувати права доступу
- [ ] Розумію принципи безпеки

### Практичні навички
- [ ] Створив Namespaces з Resource Quotas
- [ ] Налаштував різні ролі та права
- [ ] Створив Service Accounts
- [ ] Можу тестувати доступ
- [ ] Налаштував безпеку кластера

### Перевірка
```bash
# Тест 1: Створення Namespace
kubectl create namespace test-namespace

# Тест 2: Створення Resource Quota
kubectl apply -f resource-quota.yaml

# Тест 3: Створення Role та RoleBinding
kubectl apply -f rbac.yaml

# Тест 4: Тестування доступу
kubectl auth can-i create pods --namespace test-namespace

# Тест 5: Перегляд прав
kubectl get roles,rolebindings -n test-namespace
```

---

## 🔹 Розділ 9: Helm

### Теоретичні знання
- [ ] Розумію призначення Helm
- [ ] Знаю концепції Chart, Release, Repository
- [ ] Розумію структуру Helm чарту
- [ ] Знаю як працюють шаблони
- [ ] Розумію принципи залежностей

### Практичні навички
- [ ] Встановив Helm
- [ ] Створив власний чарт
- [ ] Налаштував залежності
- [ ] Можу встановлювати та керувати чартами
- [ ] Можу створювати репозиторії

### Перевірка
```bash
# Тест 1: Перевірка Helm
helm version
helm repo list

# Тест 2: Створення чарту
helm create my-chart

# Тест 3: Тестування чарту
helm lint my-chart
helm template my-chart

# Тест 4: Встановлення чарту
helm install my-release ./my-chart

# Тест 5: Керування release
helm list
helm status my-release
helm upgrade my-release ./my-chart
```

---

## 🔹 Розділ 10: CI/CD

### Теоретичні знання
- [ ] Розумію принципи CI/CD
- [ ] Знаю компоненти pipeline
- [ ] Розумію GitOps принципи
- [ ] Знаю як автоматизувати розгортання
- [ ] Розумію принципи безпеки

### Практичні навички
- [ ] Створив GitHub Actions або GitLab CI pipeline
- [ ] Налаштував автоматичне розгортання
- [ ] Інтегрував з Kubernetes
- [ ] Налаштував GitOps з ArgoCD
- [ ] Можу керувати різними середовищами

### Перевірка
```bash
# Тест 1: Перевірка pipeline
# Запустіть pipeline та перевірте статус

# Тест 2: Автоматичне розгортання
# Зробіть зміну в коді та перевірте розгортання

# Тест 3: Перевірка в кластері
kubectl get pods -l app=myapp
kubectl get deployments

# Тест 4: GitOps синхронізація
# Зробіть зміну в Git та перевірте синхронізацію

# Тест 5: Rollback
# Перевірте можливість відкату змін
```

---

## 🔹 Розділ 11: Моніторинг і логування

### Теоретичні знання
- [ ] Розумію принципи моніторингу
- [ ] Знаю компоненти Prometheus + Grafana
- [ ] Розумію принципи логування
- [ ] Знаю як налаштувати алерти
- [ ] Розумію принципи observability

### Практичні навички
- [ ] Встановив Prometheus + Grafana
- [ ] Налаштував збір метрик
- [ ] Створив dashboard
- [ ] Налаштував алерти
- [ ] Налаштував EFK Stack

### Перевірка
```bash
# Тест 1: Перевірка Prometheus
kubectl get pods -n monitoring | grep prometheus

# Тест 2: Доступ до Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Тест 3: Перевірка метрик
curl http://localhost:9090/api/v1/query?query=up

# Тест 4: Перевірка алертів
kubectl get prometheusrules -n monitoring

# Тест 5: Перевірка логування
kubectl get pods -n logging
```

---

## 🔹 Розділ 12: Розгортання в хмарі

### Теоретичні знання
- [ ] Розумію різниці між managed та self-hosted рішеннями
- [ ] Знаю особливості AWS EKS, Azure AKS, GCP GKE
- [ ] Розумію принципи хмарної безпеки
- [ ] Знаю як інтегрувати з хмарними сервісами
- [ ] Розумію принципи масштабування

### Практичні навички
- [ ] Створив кластер в хмарі
- [ ] Налаштував kubectl для хмарного кластера
- [ ] Розгорнув додаток в хмарі
- [ ] Налаштував CI/CD для хмари
- [ ] Можу керувати хмарним кластером

### Перевірка
```bash
# Тест 1: Перевірка підключення
kubectl cluster-info

# Тест 2: Перегляд nodes
kubectl get nodes

# Тест 3: Розгортання додатку
kubectl apply -f k8s/

# Тест 4: Перевірка доступності
kubectl get ingress
curl -H "Host: myapp.example.com" https://<load-balancer-ip>

# Тест 5: Масштабування
kubectl scale deployment myapp --replicas=5
```

---

## 🎯 Фінальна перевірка

### Загальні знання
- [ ] Можу пояснити архітектуру Kubernetes
- [ ] Розумію принципи роботи всіх компонентів
- [ ] Можу створити production-ready кластер
- [ ] Розумію принципи безпеки та моніторингу
- [ ] Можу автоматизувати розгортання

### Практичні навички
- [ ] Створив повний CI/CD pipeline
- [ ] Розгорнув додаток в хмарі
- [ ] Налаштував моніторинг та логування
- [ ] Створив Helm чарти
- [ ] Налаштував безпеку кластера

### Portfolio проекти
- [ ] Простий web додаток
- [ ] API з базою даних
- [ ] Мікросервісна архітектура
- [ ] Production-ready кластер

---

## 🏆 Рівні майстерності

### 🥉 Початківець (0-4 розділи)
- Базове розуміння Kubernetes
- Можете створити прості додатки
- Знаєте основні команди kubectl

### 🥈 Середній рівень (5-8 розділи)
- Глибоке розуміння концепцій
- Можете створити складні додатки
- Знаєте безпеку та масштабування

### 🥇 Просунутий рівень (9-12 розділи)
- Повне розуміння Kubernetes
- Можете створити production кластер
- Знаєте CI/CD та GitOps

### 🏅 Експерт (Всі розділи + додаткові знання)
- Експертне знання Kubernetes
- Можете архітектувати складні системи
- Готові до сертифікації

---

**🎯 Мета: Досягти рівня "Просунутий" або "Експерт"!**

*Регулярно перевіряйте свої знання та практикуйтесь.* 