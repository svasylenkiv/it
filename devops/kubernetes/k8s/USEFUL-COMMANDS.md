# 🛠️ Корисні команди Kubernetes

## 📋 Базові команди kubectl

### Перегляд ресурсів
```bash
# Всі ресурси в поточному namespace
kubectl get all

# Всі ресурси у всіх namespaces
kubectl get all --all-namespaces

# Конкретні ресурси
kubectl get pods,services,deployments
kubectl get pods -l app=myapp
kubectl get pods -o wide

# Детальна інформація
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe deployment <deployment-name>
```

### Робота з Pod
```bash
# Створення Pod
kubectl run nginx --image=nginx:alpine

# Видалення Pod
kubectl delete pod <pod-name>

# Перегляд логів
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # follow logs
kubectl logs --previous <pod-name>  # logs from previous container

# Exec в контейнер
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- /bin/sh

# Копіювання файлів
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

### Робота з Deployment
```bash
# Створення Deployment
kubectl create deployment nginx --image=nginx:alpine

# Масштабування
kubectl scale deployment <name> --replicas=5

# Оновлення образу
kubectl set image deployment/<name> <container>=<new-image>

# Перегляд статусу оновлення
kubectl rollout status deployment/<name>

# Історія оновлень
kubectl rollout history deployment/<name>

# Rollback
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=2

# Пауза/відновлення оновлення
kubectl rollout pause deployment/<name>
kubectl rollout resume deployment/<name>
```

### Робота з Service
```bash
# Створення Service
kubectl expose deployment <name> --port=80 --target-port=8080

# Port forwarding
kubectl port-forward service/<service-name> 8080:80
kubectl port-forward pod/<pod-name> 8080:80

# Перегляд endpoints
kubectl get endpoints <service-name>
```

### Робота з ConfigMap та Secret
```bash
# Створення ConfigMap
kubectl create configmap <name> --from-file=./config/
kubectl create configmap <name> --from-literal=key=value

# Створення Secret
kubectl create secret generic <name> --from-file=./secret/
kubectl create secret generic <name> --from-literal=username=admin

# Перегляд вмісту
kubectl get configmap <name> -o yaml
kubectl get secret <name> -o yaml
```

### Робота з Namespace
```bash
# Створення Namespace
kubectl create namespace <name>

# Переключення на Namespace
kubectl config set-context --current --namespace=<name>

# Всі ресурси в Namespace
kubectl get all -n <namespace>
```

## 🔍 Debug та діагностика

### Перегляд статусу
```bash
# Перегляд nodes
kubectl get nodes
kubectl describe node <node-name>
kubectl top nodes

# Перегляд pods
kubectl get pods
kubectl top pods
kubectl get pods -o wide

# Перегляд events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace>
```

### Перегляд ресурсів
```bash
# Використання ресурсів
kubectl top pods
kubectl top nodes

# Детальна інформація про ресурси
kubectl get resourcequota -n <namespace>
kubectl get limitrange -n <namespace>
```

### Перегляд конфігурації
```bash
# YAML вивід
kubectl get <resource> <name> -o yaml
kubectl get <resource> <name> -o json

# Dry run
kubectl apply -f <file> --dry-run=client
kubectl create deployment nginx --image=nginx:alpine --dry-run=client -o yaml
```

## 🚀 Helm команди

### Базові операції
```bash
# Встановлення чарту
helm install <release-name> <chart-name>

# Оновлення release
helm upgrade <release-name> <chart-name>

# Перегляд releases
helm list
helm list --all-namespaces

# Статус release
helm status <release-name>

# Історія release
helm history <release-name>

# Rollback
helm rollback <release-name> <revision>

# Видалення release
helm uninstall <release-name>
```

### Робота з репозиторіями
```bash
# Додавання репозиторію
helm repo add <name> <url>

# Оновлення репозиторіїв
helm repo update

# Перегляд репозиторіїв
helm repo list

# Пошук чартів
helm search repo <keyword>
helm search hub <keyword>
```

### Робота з чартами
```bash
# Створення чарту
helm create <chart-name>

# Тестування чарту
helm lint <chart-name>
helm template <chart-name>

# Пакетування чарту
helm package <chart-name>

# Встановлення з локального чарту
helm install <release-name> ./<chart-name>
```

## 🔧 Minikube команди

### Базові операції
```bash
# Запуск кластера
minikube start

# Зупинка кластера
minikube stop

# Видалення кластера
minikube delete

# Статус кластера
minikube status

# IP адреса кластера
minikube ip
```

### Addons
```bash
# Перегляд доступних addons
minikube addons list

# Включення addon
minikube addons enable <addon-name>

# Відключення addon
minikube addons disable <addon-name>

# Включення Ingress
minikube addons enable ingress

# Включення Metrics Server
minikube addons enable metrics-server
```

### Додаткові функції
```bash
# Запуск dashboard
minikube dashboard

# Відкриття сервісу
minikube service <service-name>

# SSH в node
minikube ssh

# Перегляд логів
minikube logs
```

## 📊 Моніторинг команди

### Prometheus та Grafana
```bash
# Встановлення через Helm
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Доступ до Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Доступ до Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

### Логування
```bash
# Перегляд логів з усіх pods
kubectl logs -l app=myapp

# Перегляд логів з конкретного часу
kubectl logs <pod-name> --since=1h

# Перегляд логів з попереднього контейнера
kubectl logs <pod-name> --previous

# Перегляд логів з кількох контейнерів
kubectl logs <pod-name> -c <container-name>
```

## 🔐 Безпека команди

### RBAC
```bash
# Перегляд ролей
kubectl get roles --all-namespaces
kubectl get clusterroles

# Перегляд role bindings
kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings

# Перегляд service accounts
kubectl get serviceaccounts --all-namespaces
```

### Network Policies
```bash
# Перегляд network policies
kubectl get networkpolicies --all-namespaces

# Створення network policy
kubectl apply -f network-policy.yaml
```

## 🚀 CI/CD команди

### GitHub Actions
```bash
# Перевірка статусу workflow
gh run list

# Перегляд логів workflow
gh run view <run-id>

# Перезапуск workflow
gh run rerun <run-id>
```

### GitLab CI
```bash
# Перегляд pipeline
gitlab-ci-lint

# Запуск pipeline
gitlab-ci-run
```

## 📝 Корисні аліаси

### Додайте в ~/.bashrc або ~/.zshrc
```bash
# Короткі команди
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
alias kp='kubectl port-forward'

# Namespace команди
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Helm аліаси
alias h='helm'
alias hi='helm install'
alias hu='helm upgrade'
alias hl='helm list'
alias hs='helm status'
```

## 🔧 Корисні скрипти

### Перегляд всіх ресурсів
```bash
#!/bin/bash
# all-resources.sh
NAMESPACE=${1:-default}
echo "Resources in namespace: $NAMESPACE"
echo "================================"
kubectl get all -n $NAMESPACE
echo ""
echo "ConfigMaps:"
kubectl get configmaps -n $NAMESPACE
echo ""
echo "Secrets:"
kubectl get secrets -n $NAMESPACE
echo ""
echo "Events:"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | head -10
```

### Очищення namespace
```bash
#!/bin/bash
# cleanup-namespace.sh
NAMESPACE=$1
if [ -z "$NAMESPACE" ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

echo "Cleaning up namespace: $NAMESPACE"
kubectl delete all --all -n $NAMESPACE
kubectl delete configmaps --all -n $NAMESPACE
kubectl delete secrets --all -n $NAMESPACE
kubectl delete pvc --all -n $NAMESPACE
echo "Namespace $NAMESPACE cleaned up"
```

### Перегляд ресурсів використання
```bash
#!/bin/bash
# resource-usage.sh
echo "Node Resource Usage:"
echo "==================="
kubectl top nodes
echo ""
echo "Pod Resource Usage:"
echo "=================="
kubectl top pods --all-namespaces | head -20
```

## 💡 Поради

### Продуктивність
- Використовуйте аліаси для часто використовуваних команд
- Використовуйте `-o wide` для додаткової інформації
- Використовуйте `--dry-run=client` для тестування змін
- Використовуйте `kubectl explain` для розуміння ресурсів

### Debug
- Завжди перевіряйте `kubectl describe` та `kubectl logs`
- Використовуйте `kubectl get events` для діагностики
- Перевіряйте resource limits та requests
- Використовуйте `kubectl top` для моніторингу ресурсів

### Безпека
- Використовуйте namespaces для ізоляції
- Налаштуйте RBAC для контролю доступу
- Використовуйте Network Policies
- Регулярно оновлюйте кластер

---

**💡 Порада: Створіть власні аліаси та скрипти для часто використовуваних операцій!**

*Це значно прискорить вашу роботу з Kubernetes.* 