# Налаштування Nginx з Ingress та TLS

Робимо доступ до нашого Nginx через домен `myapi.local` з Ingress і далі — додаємо TLS.

## 1) Передумови

У тебе вже має бути створено з минулого кроку:

- **Deployment** → `nginx-deployment`
- **Service** → `nginx-deployment-service`

Для Ingress краще, щоб Service був ClusterIP (за замовчуванням). Якщо ти робив `type: NodePort`, просто онови сервіс:

```powershell
# Швидко перепризначимо на ClusterIP (або просто перевстанови yaml без type:)
kubectl patch svc nginx-deployment-service -p '{"spec":{"type":"ClusterIP"}}'
kubectl get svc nginx-deployment-service
```

## 2) Встановлюємо Ingress Controller

### Варіант A — Minikube (рекомендую)

```powershell
minikube addons enable ingress
kubectl get pods -n ingress-nginx
# чекаємо, поки контролер стане Ready (STATUS=Running, READY=1/1 або 2/2)
```

### Варіант B — Docker Desktop Kubernetes (якщо ти без Minikube)

Можеш поставити NGINX Ingress Controller через Helm:

```powershell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace
kubectl get pods -n ingress-nginx
```

## 3) Створюємо Ingress-ресурс (HTTP)

📄 **nginx-ingress.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
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
                name: nginx-deployment-service
                port:
                  number: 80
```

Застосовуємо:

```powershell
kubectl apply -f nginx-ingress.yaml
kubectl describe ingress nginx-ingress
```

## 4) Прописуємо hosts і тестуємо

Отримай IP Ingress (для Minikube це IP VM):

```powershell
minikube ip
```

Відкрий `C:\Windows\System32\drivers\etc\hosts` від адміна і додай рядок:

```lua
<IP_з_minikube_ip>   myapi.local
```

Перевір:

```powershell
curl http://myapi.local
# або в браузері відкрий http://myapi.local — має бути стартова сторінка Nginx
```

## 5) Додаємо TLS (локальний сертифікат)

Найзручніший шлях локально — `mkcert` (ставить локальний Root CA, і браузер довіряє):

```powershell
choco install mkcert
mkcert -install
mkcert myapi.local
# згенерує два файли в поточній папці: myapi.local.pem і myapi.local-key.pem
```

Створюємо TLS Secret у кластері:

```powershell
kubectl create secret tls myapi-tls \
  --cert="myapi.local.pem" \
  --key="myapi.local-key.pem"
kubectl get secret myapi-tls
```

Оновлюємо Ingress на HTTPS:

📄 **nginx-ingress-tls.yaml**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
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
                name: nginx-deployment-service
                port:
                  number: 80
```

Застосуй:

```powershell
kubectl apply -f nginx-ingress-tls.yaml
```

Тест:

```powershell
curl https://myapi.local -k
# У браузері відкрий https://myapi.local (має бути "безпечне" з'єднання завдяки mkcert)
```

## 6) Типові перевірки, якщо щось не відкривається

- `kubectl get pods -n ingress-nginx` — контролер має бути Running.
- `kubectl describe ingress nginx-ingress` — дивись Events (помилки у назві сервісу/порту).
- `kubectl get svc nginx-deployment-service -o wide` — сервіс існує й слухає 80.
- `kubectl get endpoints nginx-deployment-service` — є Endpoints (тобто Pod-и живі).
- `kubectl get pods -l app=nginx` — Pod-и Running/Ready.

Перевір hosts — `ping myapi.local` має резолвитись у IP minikube.

Якщо Docker Desktop: перевір, що Ingress Controller інстальований у `ingress-nginx`.

## 7) Прибирання (коли захочеш)

```powershell
kubectl delete -f nginx-ingress.yaml --ignore-not-found
kubectl delete -f nginx-ingress-tls.yaml --ignore-not-found
kubectl delete secret myapi-tls --ignore-not-found
# (опційно) повернути сервіс у NodePort або видалити:
# kubectl delete -f nginx-deployment-service.yaml
```