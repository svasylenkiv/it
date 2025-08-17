# 🔹 3. Ingress-контролер

**⏱️ Час: 2-3 дні**

## 📚 Теорія

### Що таке Ingress?
**Ingress** - це ресурс Kubernetes, який забезпечує:
- **Маршрутизацію на основі HTTP/HTTPS** - направлення запитів до різних сервісів
- **Віртуальні хости** - обслуговування кількох доменів
- **SSL/TLS термінацію** - обробка HTTPS з'єднань
- **Load balancing** - розподіл навантаження між сервісами

### Ingress Controller
**Ingress Controller** - це Pod, який обробляє Ingress правила:
- **NGINX Ingress Controller** - найпопулярніший
- **Traefik** - легкий та швидкий
- **HAProxy** - для високих навантажень
- **Istio Gateway** - для service mesh

### Типи маршрутизації

#### 1. Path-based routing
- Різні шляхи → різні сервіси
- `/api` → API сервіс
- `/web` → Web сервіс

#### 2. Host-based routing
- Різні домени → різні сервіси
- `api.example.com` → API сервіс
- `web.example.com` → Web сервіс

## 🛠️ Практика

### Крок 1: Встановлення NGINX Ingress Controller

#### Для Minikube:
```bash
# Включення Ingress addon
minikube addons enable ingress

# Перевірка статусу
kubectl get pods -n ingress-nginx
```

#### Для інших кластерів:
```bash
# Встановлення через Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

### Крок 2: Створення тестових сервісів

Створи файл `test-services.yaml`:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-app
  labels:
    app: api-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-app
  template:
    metadata:
      labels:
        app: api-app
    spec:
      containers:
      - name: api-app
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: api-app-service
spec:
  selector:
    app: api-app
  ports:
  - port: 80
    targetPort: 80
```

### Крок 3: Створення Ingress

Створи файл `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: myapi.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-app-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-app-service
            port:
              number: 80
  - host: myweb.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

### Крок 4: Застосування ресурсів

```bash
# Застосування сервісів
kubectl apply -f test-services.yaml

# Застосування Ingress
kubectl apply -f ingress.yaml

# Перевірка статусу
kubectl get ingress
kubectl get services
kubectl get pods
```

### Крок 5: Налаштування hosts файлу

#### Windows:
```bash
# Відкрий Notepad як Administrator
notepad C:\Windows\System32\drivers\etc\hosts

# Додай рядки:
127.0.0.1 myapi.local
127.0.0.1 myweb.local
```

#### macOS/Linux:
```bash
# Відкрий hosts файл
sudo nano /etc/hosts

# Додай рядки:
127.0.0.1 myapi.local
127.0.0.1 myweb.local
```

### Крок 6: Тестування Ingress

```bash
# Отримання IP адреси Minikube
minikube ip

# Тестування через curl
curl -H "Host: myapi.local" http://$(minikube ip)/
curl -H "Host: myweb.local" http://$(minikube ip)/

# Або через браузер
# http://myapi.local
# http://myweb.local
```

### Крок 7: Налаштування TLS/HTTPS

#### Встановлення cert-manager:
```bash
# Встановлення через Helm
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

#### Створення ClusterIssuer:
Створи файл `cluster-issuer.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

#### Оновлення Ingress з TLS:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress-tls
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - myapi.local
    - myweb.local
    secretName: my-tls-secret
  rules:
  - host: myapi.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-app-service
            port:
              number: 80
  - host: myweb.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

### Крок 8: Розширені налаштування Ingress

#### Rate limiting:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress-advanced
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  # ... правила ...
```

#### CORS:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress-cors
  annotations:
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
spec:
  # ... правила ...
```

## 📝 Завдання для практики

1. **Створи різні типи маршрутизації:**
   - Path-based routing (`/api/v1`, `/api/v2`)
   - Host-based routing (`dev.example.com`, `prod.example.com`)

2. **Налаштуй SSL/TLS:**
   - Встанови cert-manager
   - Створи самопідписані сертифікати
   - Налаштуй автоматичне оновлення

3. **Досліди різні Ingress контролери:**
   - NGINX vs Traefik
   - Порівняй продуктивність та функціональність

4. **Створи Blue-Green deployment через Ingress:**
   - Два різних сервіси
   - Перемикання між ними через Ingress

## 🔍 Перевірка знань

- [ ] Розумію призначення Ingress та Ingress Controller
- [ ] Можу створити Ingress з різними правилами маршрутизації
- [ ] Налаштував TLS/HTTPS з cert-manager
- [ ] Можу налаштувати hosts файл для локального тестування
- [ ] Розумію різні типи маршрутизації

## 📚 Додаткові ресурси

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager Documentation](https://cert-manager.io/docs/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Конфіги та Секрети](../04-configs-secrets/README.md) 