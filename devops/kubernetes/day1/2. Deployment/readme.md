# Kubernetes Deployment для Nginx

Зробимо Deployment для Nginx, щоб ти вже вмів масштабувати та оновлювати додатки в Kubernetes.

## 1️⃣ Що таке Deployment?

Deployment — це об'єкт Kubernetes, який керує ReplicaSet, а ReplicaSet створює потрібну кількість Pod-ів.

Завдяки Deployment ти можеш:

- Масштабувати додаток (наприклад, з 1 до 5 копій)
- Оновлювати версії контейнерів без даунтайму (Rolling Update)
- Повертатися до попередньої версії (Rollback)

## 2️⃣ YAML-файл для Deployment

📄 **nginx-deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2   # Кількість Pod-ів
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
          image: nginx:1.27
          ports:
            - containerPort: 80
```

## 3️⃣ Створення Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

## 4️⃣ Перевірка створення

```bash
kubectl get deployments
kubectl get pods
```

## 5️⃣ Доступ до Deployment через Service

📄 **nginx-deployment-service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-deployment-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
```

Створюємо сервіс:

```bash
kubectl apply -f nginx-deployment-service.yaml
```

## 6️⃣ Відкрити сайт

```bash
minikube service nginx-deployment-service
```

## 7️⃣ Масштабування

```bash
kubectl scale deployment nginx-deployment --replicas=5
kubectl get pods
```

## 8️⃣ Оновлення версії образу

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.28
kubectl rollout status deployment/nginx-deployment
```

### Перевірка версії образу після оновлення

#### 1️⃣ Подивитися через kubectl describe

```bash
kubectl describe deployment nginx-deployment
```

У блоці Containers побачиш:

```yaml
Containers:
  nginx:
    Image: nginx:1.28
```

#### 2️⃣ Подивитися через kubectl get у широкому форматі

```bash
kubectl get deployment nginx-deployment -o wide
```

Це покаже ім'я образу у полі IMAGE.

#### 3️⃣ Подивитися тільки ім'я образу (чистий вивід)

```bash
kubectl get deployment nginx-deployment -o=jsonpath='{.spec.template.spec.containers[0].image}'
```

Результат:

```makefile
nginx:1.28
```

#### 4️⃣ Подивитися, що реально запущено в подах

```bash
kubectl get pods -l app=nginx -o=jsonpath='{.items[*].spec.containers[*].image}'
```

Це корисно, щоб переконатися, що всі поди вже оновилися на нову версію.

💡 **Порада**: Після оновлення завжди перевіряй версію образу в подах, а не лише в деплойменті, щоб переконатися, що rollout дійсно завершився успішно.

## 9️⃣ Rollback (повернення до попередньої версії)

```bash
kubectl rollout undo deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment
```

## 🔧 Додаткові можливості

### Подивитися історію ревізій:

```bash
kubectl rollout history deployment/nginx-deployment
```

### Відкотитися до конкретної ревізії:

```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

💡 **Порада**: Після undo завжди корисно перевірити:

```bash
kubectl get deployment nginx-deployment -o=jsonpath='{.spec.template.spec.containers[0].image}'
```

щоб переконатися, що версія образу змінилася на потрібну.

## 📝 Корисні примітки

- **Якщо деплоймент paused**, спершу розпаузь: `kubectl rollout resume deployment/nginx-deployment`

- **Можна відкотитись до конкретної ревізії**: `kubectl rollout undo deployment/nginx-deployment --to-revision=2`

- **Якщо оновлення «зависло»**, глянь причини: `kubectl describe deployment nginx-deployment` і `kubectl get events --sort-by=.lastTimestamp`

## 🚀 Однорядкові команди для зручності

### Форматований вивід версій образів у всіх подах:

```bash
kubectl get pods -l app=nginx \
  -o=custom-columns="POD_NAME:.metadata.name,IMAGE:.spec.containers[*].image"
```

📌 **Вивід буде приблизно такий:**

```
POD_NAME                     IMAGE
nginx-deployment-7f5d6c9f7f-abcde   nginx:1.28
nginx-deployment-7f5d6c9f7f-fghij   nginx:1.28
```

### Одночасно показати і deployment, і pod-и:

```bash
echo "Deployment image:" \
&& kubectl get deploy nginx-deployment -o=jsonpath='{.spec.template.spec.containers[0].image}'; echo \
&& echo "Pods images:" \
&& kubectl get pods -l app=nginx -o=custom-columns="POD_NAME:.metadata.name,IMAGE:.spec.containers[*].image"
```

💡 **Перевага**: Ти побачиш і те, що записано в деплойменті, і те, що реально крутиться в подах.

## 1️⃣0️⃣ Видалення

```bash
kubectl delete -f nginx-deployment.yaml
kubectl delete -f nginx-deployment-service.yaml
```

## ✅ Що ти навчився

- Працювати з Deployment і ReplicaSet
- Масштабувати додаток
- Оновлювати додаток без даунтайму
- Робити rollback

