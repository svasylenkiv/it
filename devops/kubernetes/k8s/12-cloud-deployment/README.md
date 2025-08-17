# 🔹 12. Розгортання в хмарі

**⏱️ Час: 3-4 дні**

## 📚 Теорія

### Хмарні Kubernetes сервіси
**Managed Kubernetes** - це готові рішення від хмарних провайдерів:
- **AWS EKS** - Elastic Kubernetes Service
- **Azure AKS** - Azure Kubernetes Service
- **GCP GKE** - Google Kubernetes Engine

### Переваги managed рішень
- **Автоматичне оновлення** - безпека та стабільність
- **Масштабування** - автоматичне збільшення ресурсів
- **Інтеграція** - з іншими хмарними сервісами

## 🛠️ Практика

### Крок 1: AWS EKS

#### Встановлення AWS CLI та eksctl:
```bash
# AWS CLI
aws --version

# eksctl
eksctl version

# Створення кластера EKS
eksctl create cluster \
  --name my-cluster \
  --region us-west-2 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4
```

#### Налаштування kubectl:
```bash
aws eks update-kubeconfig --name my-cluster --region us-west-2
kubectl get nodes
```

### Крок 2: Azure AKS

#### Встановлення Azure CLI:
```bash
# Azure CLI
az version

# Створення кластера AKS
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Налаштування kubectl
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

### Крок 3: GCP GKE

#### Встановлення gcloud CLI:
```bash
# gcloud CLI
gcloud version

# Створення кластера GKE
gcloud container clusters create my-gke-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# Налаштування kubectl
gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a
```

### Крок 4: Розгортання додатку

```bash
# Застосування manifests
kubectl apply -f k8s/

# Перевірка статусу
kubectl get all
kubectl get ingress
```

### Крок 5: Налаштування Load Balancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-loadbalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: myapp
```

## 📝 Завдання для практики

1. **Створи кластер в хмарі:**
   - AWS EKS, Azure AKS або GCP GKE
   - Налаштуй networking та security
   - Підключи kubectl

2. **Розгортай додаток:**
   - Використай Helm charts
   - Налаштуй Load Balancer
   - Перевір доступність

3. **Налаштуй CI/CD:**
   - Підключи до хмарного кластера
   - Автоматичне розгортання
   - Моніторинг та логування

## 🔍 Перевірка знань

- [ ] Розумію різницю між managed та self-hosted рішеннями
- [ ] Створив кластер в хмарі
- [ ] Розгорнув додаток
- [ ] Налаштував CI/CD pipeline

## 📚 Додаткові ресурси

- [AWS EKS](https://aws.amazon.com/eks/)
- [Azure AKS](https://azure.microsoft.com/services/kubernetes-service/)
- [GCP GKE](https://cloud.google.com/kubernetes-engine)

## 🎉 Вітаємо!

Ви завершили повний курс Kubernetes! Тепер ви маєте:
- Глибоке розуміння Kubernetes
- Практичний досвід роботи
- Навички розгортання в production
- Знання сучасних DevOps практик

Продовжуйте практику та досліджуйте нові можливості! 