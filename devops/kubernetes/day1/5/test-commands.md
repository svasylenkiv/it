# 🧪 Команди для тестування TodoAPI через Ingress

## 📋 Перевірка стану

```bash
# Перевірка Ingress Controller
kubectl get pods -n ingress-nginx

# Перевірка Ingress
kubectl get ingress
kubectl describe ingress todoapi-ingress

# Перевірка Service
kubectl get svc todoapi-service

# Перевірка Pods
kubectl get pods -l app=todoapi
```

## 🌐 Тестування HTTP

```bash
# Отримати IP minikube
minikube ip

# Тест основного endpoint
curl http://myapi.local

# Тест Swagger UI
curl http://myapi.local/swagger

# Тест API endpoints
curl http://myapi.local/todos
curl http://myapi.local/todos/1
```

## 🔒 Тестування HTTPS

```bash
# Тест з TLS (ігноруємо сертифікат для тестування)
curl https://myapi.local -k

# Тест API через HTTPS
curl https://myapi.local/todos -k
curl https://myapi.local/swagger -k
```

## 📝 Тестування CRUD операцій

```bash
# Створити новий todo
curl -X POST http://myapi.local/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Kubernetes","isComplete":false}'

# Отримати всі todos
curl http://myapi.local/todos

# Отримати конкретний todo (заміни {id} на реальний ID)
curl http://myapi.local/todos/1

# Оновити todo
curl -X PUT http://myapi.local/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Kubernetes - Updated","isComplete":true}'

# Видалити todo
curl -X DELETE http://myapi.local/todos/1
```

## 🐛 Діагностика проблем

```bash
# Логи Ingress Controller
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Логи TodoAPI
kubectl logs -l app=todoapi

# Опис Ingress з подіями
kubectl describe ingress todoapi-ingress

# Перевірка endpoints
kubectl get endpoints todoapi-service
```

## 🧹 Очищення

```bash
# Видалити Ingress
kubectl delete -f todoapi-ingress.yaml --ignore-not-found
kubectl delete -f todoapi-ingress-tls.yaml --ignore-not-found

# Видалити TLS Secret
kubectl delete secret myapi-tls --ignore-not-found

# Перевірити, що все видалено
kubectl get ingress
kubectl get secret
``` 