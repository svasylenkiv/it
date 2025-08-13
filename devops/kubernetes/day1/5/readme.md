# 🚀 Налаштування Ingress для TodoAPI

> Налаштовуємо Ingress Controller для доступу до TodoAPI через домен myapi.local

---

## 📋 Передумови

У тебе вже має бути створено з минулого кроку:

- **Deployment** → `todoapi-deployment`
- **Service** → `todoapi-service`

Для Ingress краще, щоб Service був ClusterIP (за замовчуванням). Якщо ти робив type: NodePort, просто онови сервіс:

```bash
# Швидко перепризначимо на ClusterIP (або просто перевстанови yaml без type:)
kubectl patch svc todoapi-service -p '{"spec":{"type":"ClusterIP"}}'
kubectl get svc todoapi-service
```

---

## 1️⃣ Встановлюємо Ingress Controller

### Варіант A — Minikube (рекомендую)

```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
# чекаємо, поки контролер стане Ready (STATUS=Running, READY=1/1 або 2/2)
```

### Варіант B — Docker Desktop Kubernetes (якщо ти без Minikube)

Можеш поставити NGINX Ingress Controller через Helm:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
kubectl get pods -n ingress-nginx
```

---

## 2️⃣ Створюємо Ingress-ресурс (HTTP)

### 📄 todoapi-ingress.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todoapi-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: myapi.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: todoapi-service
                port:
                  number: 80
```

**Застосовуємо:**

```bash
kubectl apply -f todoapi-ingress.yaml
kubectl describe ingress todoapi-ingress
```

---

## 3️⃣ Прописуємо hosts і тестуємо

### Отримай IP Ingress (для Minikube це IP VM):

```bash
minikube ip
```

### Відкрий C:\Windows\System32\drivers\etc\hosts від адміна і додай рядок:

```
<IP_з_minikube_ip>   myapi.local
```

### Перевір:

```bash
curl http://myapi.local
# або в браузері відкрий http://myapi.local — має бути Swagger UI TodoAPI
```

**Тестування API:**

```bash
# Отримати список todos
curl http://myapi.local/todos

# Додати новий todo
curl -X POST http://myapi.local/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Kubernetes","isComplete":false}'

# Swagger UI
curl http://myapi.local/swagger
```

---

## 4️⃣ Додаємо TLS (локальний сертифікат)

### Найзручніший шлях локально — mkcert (ставить локальний Root CA, і браузер довіряє):

```bash
choco install mkcert
mkcert -install
mkcert myapi.local
# згенерує два файли в поточній папці: myapi.local.pem і myapi.local-key.pem
```

### Створюємо TLS Secret у кластері:

```bash
kubectl create secret tls myapi-tls \
  --cert="myapi.local.pem" \
  --key="myapi.local-key.pem"
kubectl get secret myapi-tls
```

### Оновлюємо Ingress на HTTPS:

**📄 todoapi-ingress-tls.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todoapi-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
    - hosts:
        - myapi.local
      secretName: myapi-tls
  rules:
    - host: myapi.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: todoapi-service
                port:
                  number: 80
```

**Застосуй:**

```bash
kubectl apply -f todoapi-ingress-tls.yaml
```

### Тест:

```bash
curl https://myapi.local -k
# У браузері відкрий https://myapi.local (має бути "безпечне" з'єднання завдяки mkcert)
```

---

## 5️⃣ Типові перевірки, якщо щось не відкривається

```bash
# Ingress Controller
kubectl get pods -n ingress-nginx — контролер має бути Running.

# Ingress
kubectl describe ingress todoapi-ingress — дивись Events (помилки у назві сервісу/порту).

# Service
kubectl get svc todoapi-service -o wide — сервіс існує й слухає 80.

# Endpoints
kubectl get endpoints todoapi-service — є Endpoints (тобто Pod-и живі).

# Pods
kubectl get pods -l app=todoapi — Pod-и Running/Ready.
```

**Перевір hosts** — `ping myapi.local` має резолвитись у IP minikube.

Якщо Docker Desktop: перевір, що Ingress Controller інстальований у `ingress-nginx`.

---

## 6️⃣ Прибирання (коли захочеш)

```bash
kubectl delete -f todoapi-ingress.yaml --ignore-not-found
kubectl delete -f todoapi-ingress-tls.yaml --ignore-not-found
kubectl delete secret myapi-tls --ignore-not-found
# (опційно) повернути сервіс у NodePort або видалити:
# kubectl delete -f todoapi-deployment-service.yaml
```

---

## 🎯 Що ми досягли

- ✅ Налаштували Ingress Controller для TodoAPI
- ✅ Створили доступ через домен `myapi.local`
- ✅ Додали TLS шифрування
- ✅ Можемо тестувати API через красивий домен

---

<div align="center">

**🎉 Вітаємо! Ти успішно налаштував Ingress для TodoAPI! 🎉**

</div>