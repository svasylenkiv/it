# 🔹 4. Конфіги та Секрети

**⏱️ Час: 1-2 дні**

## 📚 Теорія

### ConfigMap
**ConfigMap** - це ресурс Kubernetes для зберігання конфігураційних даних:
- **Нечутливі дані** - налаштування, URL, порти
- **Ключ-значення** або файли конфігурації
- **Можна використовувати** як змінні середовища або монтувати як файли

### Secret
**Secret** - це ресурс для зберігання чутливих даних:
- **Чутливі дані** - паролі, токени, ключі
- **Base64 кодування** - автоматичне кодування/декодування
- **Типи Secret** - Opaque, TLS, Docker-registry

### Способи використання

#### 1. Environment Variables
- Через `env` в Pod
- Через `envFrom` для всіх ключів

#### 2. Volume Mounts
- Монтування як файли
- Створення конфігураційних файлів

## 🛠️ Практика

### Крок 1: Створення ConfigMap

Створи файл `configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  labels:
    app: myapp
data:
  # Прості ключ-значення
  APP_NAME: "My Application"
  APP_VERSION: "1.0.0"
  LOG_LEVEL: "INFO"
  
  # Конфігураційний файл
  appsettings.json: |
    {
      "ConnectionStrings": {
        "DefaultConnection": "Server=localhost;Database=myapp;Trusted_Connection=true;"
      },
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft": "Warning"
        }
      },
      "AllowedHosts": "*"
    }
  
  # Nginx конфігурація
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
        
        location /api {
            proxy_pass http://api-service:8080;
        }
    }
```

### Крок 2: Створення Secret

Створи файл `secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  labels:
    app: myapp
type: Opaque
data:
  # Base64 encoded values
  # echo -n "mysecretpassword" | base64
  DB_PASSWORD: bXlzZWNyZXRwYXNzd29yZA==
  
  # echo -n "myapikey123" | base64
  API_KEY: bXlhcGlrZXkxMjM=
  
  # echo -n "jwtsecretkey" | base64
  JWT_SECRET: and0c2VjcmV0a2V5
  
  # Connection string
  CONNECTION_STRING: U2VydmVyPWRiLmV4YW1wbGUuY29tO0RhdGFiYXNlPW15YXBwO1VzZXIgSWQ9dXNlcjtQYXNzd29yZD1wYXNzd29yZA==
```

### Крок 3: Створення Pod з використанням ConfigMap та Secret

Створи файл `pod-with-config.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-config
  labels:
    app: myapp
spec:
  containers:
  - name: app
    image: nginx:alpine
    
    # Environment variables з ConfigMap
    env:
    - name: APP_NAME
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_NAME
    - name: APP_VERSION
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_VERSION
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
    
    # Environment variables з Secret
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: DB_PASSWORD
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: API_KEY
    
    # Використання всіх ключів з ConfigMap
    envFrom:
    - configMapRef:
        name: app-config
    
    ports:
    - containerPort: 80
    
    # Монтування ConfigMap як файл
    volumeMounts:
    - name: config-volume
      mountPath: /etc/app/config
    - name: nginx-config
      mountPath: /etc/nginx/conf.d/default.conf
      subPath: nginx.conf
    - name: secrets-volume
      mountPath: /etc/app/secrets
      readOnly: true
  
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
      - key: appsettings.json
        path: appsettings.json
  - name: nginx-config
    configMap:
      name: app-config
      items:
      - key: nginx.conf
        path: nginx.conf
  - name: secrets-volume
    secret:
      secretName: app-secrets
```

### Крок 4: Застосування ресурсів

```bash
# Застосування ConfigMap
kubectl apply -f configmap.yaml

# Застосування Secret
kubectl apply -f secret.yaml

# Застосування Pod
kubectl apply -f pod-with-config.yaml

# Перевірка статусу
kubectl get configmaps
kubectl get secrets
kubectl get pods
```

### Крок 5: Перевірка конфігурації

```bash
# Перегляд ConfigMap
kubectl describe configmap app-config

# Перегляд Secret
kubectl describe secret app-secrets

# Перевірка environment variables в Pod
kubectl exec -it app-with-config -- env | grep -E "(APP_|LOG_|DB_|API_)"

# Перевірка монтованих файлів
kubectl exec -it app-with-config -- ls -la /etc/app/config/
kubectl exec -it app-with-config -- cat /etc/app/config/appsettings.json
kubectl exec -it app-with-config -- cat /etc/nginx/conf.d/default.conf
```

### Крок 6: Оновлення ConfigMap

```bash
# Оновлення ConfigMap
kubectl patch configmap app-config --patch '{"data":{"LOG_LEVEL":"DEBUG"}}'

# Або редагування
kubectl edit configmap app-config

# Перезапуск Pod для застосування змін
kubectl delete pod app-with-config
kubectl apply -f pod-with-config.yaml
```

### Крок 7: Створення Secret з файлу

Створи файл `database.key`:
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
-----END PRIVATE KEY-----
```

```bash
# Створення Secret з файлу
kubectl create secret generic db-key-secret --from-file=database.key

# Створення Secret з кількох файлів
kubectl create secret generic app-secrets --from-file=./secrets/
```

### Крок 8: Використання в Deployment

Створи файл `deployment-with-config.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:v1
        ports:
        - containerPort: 80
        
        # Environment variables
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DB_PASSWORD
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_NAME
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        
        # Resource limits
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        
        # Volume mounts
        volumeMounts:
        - name: config-volume
          mountPath: /etc/app/config
        - name: secrets-volume
          mountPath: /etc/app/secrets
          readOnly: true
      
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: secrets-volume
        secret:
          secretName: app-secrets
```

### Крок 9: Практичний приклад - .NET API з конфігурацією

Створи файл `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=${DB_HOST};Database=${DB_NAME};User Id=${DB_USER};Password=${DB_PASSWORD};"
  },
  "Logging": {
    "LogLevel": {
      "Default": "${LOG_LEVEL}",
      "Microsoft": "Warning"
    }
  },
  "ApiSettings": {
    "ApiKey": "${API_KEY}",
    "JwtSecret": "${JWT_SECRET}"
  }
}
```

Створи файл `dotnet-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dotnet-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dotnet-api
  template:
    metadata:
      labels:
        app: dotnet-api
    spec:
      containers:
      - name: api
        image: mydotnetapi:v1
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          value: "postgres-service"
        - name: DB_NAME
          value: "myapp"
        - name: DB_USER
          value: "postgres"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DB_PASSWORD
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: LOG_LEVEL
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: API_KEY
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: JWT_SECRET
```

## 📝 Завдання для практики

1. **Створи різні типи конфігурації:**
   - ConfigMap для різних середовищ (dev/staging/prod)
   - Secret для різних типів даних (паролі, ключі, сертифікати)

2. **Налаштуй монтування файлів:**
   - Конфігураційні файли додатку
   - SSL сертифікати
   - Ключі авторизації

3. **Створи Secret для різних провайдерів:**
   - Docker registry credentials
   - TLS сертифікати
   - SSH ключі

4. **Налаштуй оновлення конфігурації:**
   - Автоматичне оновлення ConfigMap
   - Перезапуск Pod-ів при зміні конфігурації
   - Versioning конфігурацій

## 🔍 Перевірка знань

- [ ] Розумію різницю між ConfigMap та Secret
- [ ] Можу створити ConfigMap з різними типами даних
- [ ] Можу створити Secret для чутливих даних
- [ ] Налаштував використання конфігурації в Pod
- [ ] Можу монтувати конфігурацію як файли та змінні

## 📚 Додаткові ресурси

- [Kubernetes ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Managing Secrets](https://kubernetes.io/docs/tasks/configmap-secret/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Зберігання (Storage)](../05-storage/README.md) 