# 🔹 1. Базові поняття Kubernetes

**⏱️ Час: 1-2 дні**

## 📚 Теорія

### Що таке Kubernetes (K8s)?
Kubernetes - це система оркестрації контейнерів, яка автоматизує розгортання, масштабування та управління контейнеризованими додатками.

### Основні об'єкти

#### Pod – найменша одиниця
- **Pod** - найменша розрахункова одиниця в Kubernetes
- Може містити один або кілька контейнерів
- Всі контейнери в Pod мають спільну мережу та storage

#### Node – фізичний або віртуальний сервер
- **Node** - машина (фізична або віртуальна), де запускаються Pod-и
- Кожен Node має kubelet для управління Pod-ами
- Node може бути master (control plane) або worker

#### Cluster – набір Node-ів
- **Cluster** - набір Node-ів, які працюють разом
- Має один або кілька master Node-ів та worker Node-ів
- Централізоване управління через API Server

### Архітектура компонентів

#### Control Plane (Master Node):
- **kube-apiserver** - API для всіх операцій
- **etcd** - база даних конфігурації кластера
- **kube-scheduler** - планування Pod-ів на Node-ах
- **kube-controller-manager** - керування різними контролерами

#### Worker Node:
- **kubelet** - агент на кожному Node
- **kube-proxy** - мережевий проксі
- **Container Runtime** - Docker, containerd, тощо

### Declarative Model
- Описуємо бажаний стан системи в YAML файлах
- Kubernetes автоматично приводить систему до цього стану
- Принцип: "Опиши що хочеш, а не як це зробити"

## 🛠️ Практика

### Крок 1: Встановлення Minikube

#### Windows:
```bash
# Завантаж та встанови Minikube
winget install minikube
```

```bash
# Або через Chocolatey
choco install minikube
```

```bash
# Або через Scoop
scoop install minikube
```

#### macOS:
```bash
# За допомогою Homebrew
brew install minikube
```

#### Linux:
```bash
# Завантаж та встанови
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
```

```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Крок 2: Запуск Minikube

```bash
# Запуск кластера
minikube start
```

```bash
# Перевірка статусу
minikube status
```

```bash
# Включення dashboard (опціонально)
minikube dashboard
```

#### Зупинка Minikube

```bash
# Зупинка кластера (зберігає стан і налаштування)
minikube stop
```

```bash
# Пауза/відновлення (щоб зменшити використання ресурсів)
minikube pause
```

```bash
minikube unpause
```

```bash
# Повне видалення кластера і всіх даних (обережно!)
minikube delete --all
```

### Крок 3: Встановлення kubectl

```bash
# Windows (через winget)
winget install -e --id Kubernetes.kubectl
```


# macOS
```bash
brew install kubectl
```

# Linux
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### Крок 4: Створення першого Pod

Створи файл `first-pod.yaml`:

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

### Крок 5: Застосування манифесту

```bash
# Застосування манифесту
kubectl apply -f first-pod.yaml
```

```bash
# Перевірка статусу Pod
kubectl get pods
```

```bash
# Детальна інформація про Pod
kubectl describe pod nginx-pod
```

```bash
# Логи Pod
kubectl logs nginx-pod
```

```bash
# Доступ до Pod через порт
kubectl port-forward nginx-pod 8080:80
```

### Крок 6: Базові команди kubectl

```bash
# Перегляд ресурсів
kubectl get pods
```

```bash
kubectl get nodes
```

```bash
kubectl get services
```

```bash
# Детальна інформація
kubectl describe pod <pod-name>
```

```bash
kubectl describe node <node-name>
```

```bash
# Логи
kubectl logs <pod-name>
```

```bash
# Виконання команд в Pod
kubectl exec -it <pod-name> -- /bin/bash
```

```bash
# Видалення ресурсу
kubectl delete pod <pod-name>
```

## 📝 Завдання для практики

1. **Створи Pod з різними контейнерами:**
   - Nginx + Redis в одному Pod
   - Використай різні порти

2. **Досліди життєвий цикл Pod:**
   - Створи Pod
   - Видали Pod
   - Спостерігай за станами

3. **Працюй з labels та selectors:**
   - Додай різні labels до Pod
   - Використай selectors для пошуку

## 🔍 Перевірка знань

- [ ] Розумію що таке Pod, Node, Cluster
- [ ] Можу описати архітектуру Kubernetes
- [ ] Встановив Minikube та kubectl
- [ ] Створив перший Pod
- [ ] Використовую базові команди kubectl

## 📚 Додаткові ресурси

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes.io Tutorials](https://kubernetes.io/docs/tutorials/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Deployment і Service](../02-deployment-service/README.md) 