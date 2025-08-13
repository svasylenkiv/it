# 🚀 Детальний план вивчення Kubernetes (K8s)

## 📋 Загальна інформація
- **Загальний час**: 25-35 днів
- **Рівень**: Від початківця до середнього
- **Формат**: Теорія + Практика (70% практики, 30% теорії)

---

## 🔹 1. Базові поняття Kubernetes
**⏱️ Час**: 1-2 дні

### 📚 Теорія
- **Що таке Kubernetes (K8s)?**
  - Контейнер оркестратор
  - Автоматизація розгортання, масштабування та управління контейнерами
  - Відкрита платформа від Google

- **Основні об'єкти**:
  - **Pod** – найменша одиниця розгортання
  - **Node** – фізичний або віртуальний сервер
  - **Cluster** – набір Node-ів
  - **Namespace** – логічне розділення ресурсів

- **Архітектура**:
  - **Control Plane**: kube-apiserver, etcd, scheduler, controller-manager
  - **Worker Nodes**: kubelet, kube-proxy, container runtime

- **Declarative model**: YAML → desired state → reconciliation loop

### 🛠️ Практика
1. **Встановлення середовища**:
   ```bash
   # Варіант 1: Minikube
   minikube start --driver=docker
   
   # Варіант 2: Docker Desktop
   # Увімкнути Kubernetes в налаштуваннях
   
   # Варіант 3: Kind
   kind create cluster
   ```

2. **Перший Pod**:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: nginx-pod
   spec:
     containers:
     - name: nginx
       image: nginx:latest
       ports:
       - containerPort: 80
   ```

3. **Команди для практики**:
   ```bash
   kubectl apply -f nginx-pod.yaml
   kubectl get pods
   kubectl describe pod nginx-pod
   kubectl logs nginx-pod
   kubectl exec -it nginx-pod -- /bin/bash
   ```

---

## 🔹 2. Deployment і Service
**⏱️ Час**: 2-3 дні

### 📚 Теорія
- **Deployment**:
  - Управління репліками Pod-ів
  - Rolling updates та rollbacks
  - Стратегії розгортання (RollingUpdate, Recreate)

- **Service**:
  - **ClusterIP**: внутрішній доступ в кластері
  - **NodePort**: доступ через порт ноди
  - **LoadBalancer**: зовнішній балансувальник навантаження

### 🛠️ Практика
1. **Створення Deployment**:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: api-deployment
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: api
     template:
       metadata:
         labels:
           app: api
       spec:
         containers:
         - name: api
           image: your-api:latest
           ports:
           - containerPort: 8080
   ```

2. **Створення Service**:
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: api-service
   spec:
     type: ClusterIP
     selector:
       app: api
     ports:
     - port: 80
       targetPort: 8080
   ```

3. **Практичні завдання**:
   - Задеплой .NET/Node.js API
   - Створи Service для доступу
   - Перевір масштабування (kubectl scale deployment api-deployment --replicas=5)
   - Зроби rolling update

---

## 🔹 3. Ingress-контролер
**⏱️ Час**: 2-3 дні

### 📚 Теорія
- **Ingress**: правила для вхідного трафіку
- **Ingress Controller**: реалізація правил (nginx, traefik)
- **TLS/HTTPS**: захищений доступ
- **Cert-Manager**: автоматичне управління сертифікатами

### 🛠️ Практика
1. **Встановлення Ingress Controller**:
   ```bash
   # Nginx Ingress Controller
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
   ```

2. **Створення Ingress**:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: api-ingress
     annotations:
       nginx.ingress.kubernetes.io/rewrite-target: /
   spec:
     rules:
     - host: myapi.local
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: api-service
               port:
                 number: 80
   ```

3. **Налаштування hosts**:
   ```bash
   # Windows: C:\Windows\System32\drivers\etc\hosts
   # Linux/Mac: /etc/hosts
   127.0.0.1 myapi.local
   ```

4. **TLS з Cert-Manager**:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
   ```

---

## 🔹 4. Конфіги та Секрети
**⏱️ Час**: 1-2 дні

### 📚 Теорія
- **ConfigMap**: зберігання конфігурацій
- **Secret**: зберігання чутливих даних
- **Використання**: через env або volume

### 🛠️ Практика
1. **Створення ConfigMap**:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: api-config
   data:
     DATABASE_URL: "postgresql://localhost:5432/mydb"
     API_VERSION: "1.0.0"
   ```

2. **Створення Secret**:
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: api-secret
   type: Opaque
   data:
     username: YWRtaW4=  # base64 encoded
     password: cGFzc3dvcmQ=  # base64 encoded
   ```

3. **Використання в Pod**:
   ```yaml
   env:
   - name: DB_USER
     valueFrom:
       secretKeyRef:
         name: api-secret
         key: username
   - name: API_VERSION
     valueFrom:
       configMapKeyRef:
         name: api-config
         key: API_VERSION
   ```

---

## 🔹 5. Зберігання (Storage)
**⏱️ Час**: 2-3 дні

### 📚 Теорія
- **PersistentVolume (PV)**: фізичне зберігання
- **PersistentVolumeClaim (PVC)**: запит на зберігання
- **StorageClass**: динамічне створення PV
- **StatefulSet**: для державних додатків

### 🛠️ Практика
1. **Створення StorageClass**:
   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: local-storage
   provisioner: kubernetes.io/no-provisioner
   volumeBindingMode: WaitForFirstConsumer
   ```

2. **Створення PV**:
   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: postgres-pv
   spec:
     capacity:
       storage: 10Gi
     accessModes:
     - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     storageClassName: local-storage
     hostPath:
       path: /mnt/data
   ```

3. **Створення PVC**:
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: postgres-pvc
   spec:
     accessModes:
     - ReadWriteOnce
     storageClassName: local-storage
     resources:
       requests:
         storage: 10Gi
   ```

4. **StatefulSet для PostgreSQL**:
   ```yaml
   apiVersion: apps/v1
   kind: StatefulSet
   metadata:
     name: postgres
   spec:
     serviceName: postgres
     replicas: 1
     selector:
       matchLabels:
         app: postgres
     template:
       metadata:
         labels:
           app: postgres
       spec:
         containers:
         - name: postgres
           image: postgres:13
           env:
           - name: POSTGRES_DB
             value: mydb
           - name: POSTGRES_PASSWORD
             valueFrom:
               secretKeyRef:
                 name: postgres-secret
                 key: password
           volumeMounts:
           - name: postgres-storage
             mountPath: /var/lib/postgresql/data
     volumeClaimTemplates:
     - metadata:
         name: postgres-storage
       spec:
         accessModes: [ "ReadWriteOnce" ]
         storageClassName: local-storage
         resources:
           requests:
             storage: 10Gi
   ```

---

## 🔹 6. Health checks
**⏱️ Час**: 1-2 дні

### 📚 Теорія
- **Readiness Probe**: чи готовий pod обслуговувати запити
- **Liveness Probe**: чи живий pod
- **Startup Probe**: чи завершився запуск pod

### 🛠️ Практика
1. **Додавання health checks до API**:
   ```yaml
   livenessProbe:
     httpGet:
       path: /health/live
       port: 8080
     initialDelaySeconds: 30
     periodSeconds: 10
   readinessProbe:
     httpGet:
       path: /health/ready
       port: 8080
     initialDelaySeconds: 5
     periodSeconds: 5
   startupProbe:
     httpGet:
       path: /health/startup
       port: 8080
     failureThreshold: 30
     periodSeconds: 10
   ```

2. **Створення health endpoints в API**:
   ```csharp
   // .NET
   app.MapGet("/health/live", () => Results.Ok("Alive"));
   app.MapGet("/health/ready", () => Results.Ok("Ready"));
   app.MapGet("/health/startup", () => Results.Ok("Started"));
   ```

---

## 🔹 7. Автоматичне масштабування (HPA)
**⏱️ Час**: 1-2 дні

### 📚 Теорія
- **Horizontal Pod Autoscaler (HPA)**
- **Метрики**: CPU, Memory, Custom metrics
- **Алгоритм**: на основі середнього навантаження

### 🛠️ Практика
1. **Встановлення metrics-server**:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

2. **Створення HPA**:
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: api-hpa
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: api-deployment
     minReplicas: 1
     maxReplicas: 10
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 70
   ```

3. **Тестування автоскейлу**:
   ```bash
   # Створення навантаження
   kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://api-service; done"
   
   # Моніторинг HPA
   kubectl get hpa
   kubectl describe hpa api-hpa
   ```

---

## 🔹 8. Namespaces та доступи (RBAC)
**⏱️ Час**: 1-2 дні

### 📚 Теорія
- **Namespace**: логічне розділення ресурсів
- **RBAC**: Role-Based Access Control
- **ServiceAccount**: облікові записи для Pod-ів

### 🛠️ Практика
1. **Створення Namespace**:
   ```yaml
   apiVersion: v1
   kind: Namespace
   metadata:
     name: development
     labels:
       environment: dev
   ```

2. **Створення Role**:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     namespace: development
     name: developer-role
   rules:
   - apiGroups: [""]
     resources: ["pods", "services"]
     verbs: ["get", "list", "create", "update", "delete"]
   ```

3. **Створення RoleBinding**:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: developer-binding
     namespace: development
   subjects:
   - kind: ServiceAccount
     name: developer-sa
     namespace: development
   roleRef:
     kind: Role
     name: developer-role
     apiGroup: rbac.authorization.k8s.io
   ```

---

## 🔹 9. Helm
**⏱️ Час**: 2-3 дні

### 📚 Теорія
- **Helm**: менеджер пакетів для Kubernetes
- **Chart**: шаблон для розгортання додатків
- **Release**: інстанс Chart в кластері

### 🛠️ Практика
1. **Встановлення Helm**:
   ```bash
   # Windows
   choco install kubernetes-helm
   
   # Linux/Mac
   curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
   sudo mv linux-amd64/helm /usr/local/bin/helm
   ```

2. **Створення Helm Chart**:
   ```bash
   helm create my-api
   ```

3. **Структура Chart**:
   ```
   my-api/
   ├── Chart.yaml
   ├── values.yaml
   ├── templates/
   │   ├── deployment.yaml
   │   ├── service.yaml
   │   └── ingress.yaml
   └── charts/
   ```

4. **Встановлення готових Chart-ів**:
   ```bash
   # PostgreSQL
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm install postgres bitnami/postgresql
   
   # Nginx
   helm install nginx bitnami/nginx
   ```

5. **Створення власного Chart**:
   ```yaml
   # values.yaml
   replicaCount: 3
   image:
     repository: my-api
     tag: latest
   service:
     type: ClusterIP
     port: 80
   ```

---

## 🔹 10. CI/CD
**⏱️ Час**: 2-3 дні

### 📚 Теорія
- **CI/CD**: Continuous Integration/Continuous Deployment
- **GitOps**: Git як джерело істини
- **Rollback**: відкат до попередньої версії

### 🛠️ Практика
1. **GitHub Actions**:
   ```yaml
   name: Deploy to Kubernetes
   on:
     push:
       branches: [ main ]
   
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@v3
       
       - name: Build and push image
         run: |
           docker build -t my-api:${{ github.sha }} .
           docker push my-api:${{ github.sha }}
       
       - name: Deploy to Kubernetes
         run: |
           kubectl set image deployment/api-deployment api=my-api:${{ github.sha }}
   ```

2. **GitLab CI**:
   ```yaml
   stages:
   - build
   - deploy
   
   build:
     stage: build
     script:
       - docker build -t my-api:$CI_COMMIT_SHA .
       - docker push my-api:$CI_COMMIT_SHA
   
   deploy:
     stage: deploy
     script:
       - kubectl set image deployment/api-deployment api=my-api:$CI_COMMIT_SHA
   ```

3. **ArgoCD**:
   ```bash
   # Встановлення
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

---

## 🔹 11. Моніторинг і логування
**⏱️ Час**: 2-3 дні

### 📚 Теорія
- **Моніторинг**: Prometheus + Grafana
- **Логування**: EFK Stack (Elasticsearch + Fluentd + Kibana)
- **Трейсинг**: Jaeger, Zipkin

### 🛠️ Практика
1. **Prometheus + Grafana**:
   ```bash
   # Встановлення через Helm
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/kube-prometheus-stack
   ```

2. **EFK Stack**:
   ```bash
   # Elasticsearch
   kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/crds.yaml
   kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/operator.yaml
   
   # Fluentd
   kubectl apply -f https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch.yaml
   
   # Kibana
   kubectl apply -f https://raw.githubusercontent.com/elastic/kibana/master/deploy/kubernetes/kibana.yaml
   ```

3. **Базові команди моніторингу**:
   ```bash
   kubectl logs -f deployment/api-deployment
   kubectl top pods
   kubectl top nodes
   kubectl get events --sort-by='.lastTimestamp'
   ```

---

## 🔹 12. Розгортання в хмарі
**⏱️ Час**: 3-4 дні

### 📚 Теорія
- **AWS EKS**: Elastic Kubernetes Service
- **Azure AKS**: Azure Kubernetes Service
- **GCP GKE**: Google Kubernetes Engine
- **Cloud CLI**: aws, az, gcloud

### 🛠️ Практика
1. **AWS EKS**:
   ```bash
   # Встановлення AWS CLI
   aws configure
   
   # Створення кластеру
   eksctl create cluster --name my-cluster --region us-west-2 --nodegroup-name standard-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4
   
   # Оновлення kubeconfig
   aws eks update-kubeconfig --name my-cluster --region us-west-2
   ```

2. **Azure AKS**:
   ```bash
   # Встановлення Azure CLI
   az login
   
   # Створення кластеру
   az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
   
   # Отримання credentials
   az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
   ```

3. **GCP GKE**:
   ```bash
   # Встановлення Google Cloud CLI
   gcloud auth login
   
   # Створення кластеру
   gcloud container clusters create my-gke-cluster --zone us-central1-a --num-nodes 3
   
   # Отримання credentials
   gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a
   ```

---

## 📚 Ресурси для вивчення

### 🌐 Офіційна документація
- [kubernetes.io](https://kubernetes.io/) - офіційна документація
- [kubernetes.io/docs/tutorials/](https://kubernetes.io/docs/tutorials/) - туторіали

### 🎮 Інтерактивні платформи
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Kubernetes.io Interactive Tutorials](https://kubernetes.io/docs/tutorials/)

### 📖 Курси та навчальні матеріали
- **Udemy**: "Kubernetes for the Absolute Beginners"
- **YouTube**: "TechWorld with Nana" - Kubernetes курси
- **Coursera**: "Introduction to Kubernetes"

### 🛠️ Інструменти для практики
- **Minikube**: локальний кластер
- **Kind**: Kubernetes in Docker
- **Docker Desktop**: вбудований Kubernetes
- **Lens**: GUI для Kubernetes

---

## 📝 Рекомендації по вивченню

### ✅ Що робити
1. **Практикуватися щодня** - мінімум 2-3 години
2. **Вести Git-репозиторій** з усіма YAML/Helm файлами
3. **Писати маніфести самостійно**, не копіювати всліпу
4. **Створювати власні проекти** для закріплення знань
5. **Використовувати різні середовища** (локальне, хмарне)

### ❌ Чого уникати
1. **Вивчення тільки теорії** без практики
2. **Копіювання коду** без розуміння
3. **Пропуск базових концепцій** для переходу до складних тем
4. **Використання тільки GUI** без командного рядка

### 📊 Метрика прогресу
- **День 1-7**: Базові концепції + прості Pod/Deployment
- **День 8-14**: Services + Ingress + ConfigMaps
- **День 15-21**: Storage + Health Checks + HPA
- **День 22-28**: RBAC + Helm + CI/CD
- **День 29-35**: Моніторинг + Хмарне розгортання

---

## 🎯 Фінальний проект

Після завершення всіх модулів створіть **повноцінний додаток**:

1. **Backend API** (.NET/Node.js) з базою даних
2. **Frontend** (React/Vue) або **Web UI**
3. **База даних** (PostgreSQL) з персистентним зберіганням
4. **Ingress** з TLS сертифікатами
5. **Моніторинг** (Prometheus + Grafana)
6. **Логування** (EFK Stack)
7. **CI/CD пайплайн** з автоматичним розгортанням
8. **Автоскейлінг** на основі навантаження
9. **Розгортання в хмарі** (AWS EKS/Azure AKS/GCP GKE)

Цей проект стане вашим **портфоліо** та **демонстрацією навичок** Kubernetes!

---

**🚀 Успіхів у вивченні Kubernetes!** 