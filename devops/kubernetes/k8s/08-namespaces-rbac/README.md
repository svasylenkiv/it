# 🔹 8. Namespaces та доступи (RBAC)

**⏱️ Час: 1-2 дні**

## 📚 Теорія

### Namespaces
**Namespace** - це механізм для логічного розділення ресурсів в кластері:
- **Ізоляція ресурсів** - різні команди/проекти не бачать один одного
- **Керування доступом** - різні ролі для різних namespace
- **Ресурсні квоти** - обмеження ресурсів на namespace

### RBAC (Role-Based Access Control)
**RBAC** - це система керування доступом на основі ролей:
- **Role** - набір дозволів для конкретного namespace
- **ClusterRole** - набір дозволів для всього кластера
- **RoleBinding** - зв'язування ролі з користувачем/групою
- **ClusterRoleBinding** - зв'язування ClusterRole з користувачем/групою

### Типи користувачів

#### 1. Service Account
- **Внутрішні користувачі** - для Pod-ів та сервісів
- **Автоматичне створення** - в кожному namespace
- **Токени** - для автентифікації API

#### 2. User Account
- **Зовнішні користувачі** - люди або зовнішні системи
- **Зовнішня автентифікація** - LDAP, OIDC, тощо

## 🛠️ Практика

### Крок 1: Створення Namespaces

Створи файл `namespaces.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    name: development
    environment: dev
---
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    name: staging
    environment: stg
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    name: production
    environment: prod
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    name: monitoring
    purpose: observability
```

### Крок 2: Створення Resource Quotas

Створи файл `resource-quotas.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
    services: "5"
    persistentvolumeclaims: "5"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: staging-quota
  namespace: staging
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
    pods: "20"
    services: "10"
    persistentvolumeclaims: "10"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: production
spec:
  hard:
    requests.cpu: "8"
    requests.memory: 8Gi
    limits.cpu: "16"
    limits.memory: 16Gi
    pods: "50"
    services: "20"
    persistentvolumeclaims: "20"
```

### Крок 3: Створення Service Accounts

Створи файл `service-accounts.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: development
  labels:
    app: myapp
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitoring-service-account
  namespace: monitoring
  labels:
    app: monitoring
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-service-account
  namespace: production
  labels:
    app: admin
```

### Крок 4: Створення Roles

Створи файл `roles.yaml`:

```yaml
# Role для розробників в development namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# Role для DevOps в staging namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: staging
  name: devops-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
# Role для адміністраторів в production namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: admin-role
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["networking.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["storage.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
```

### Крок 5: Створення ClusterRoles

Створи файл `cluster-roles.yaml`:

```yaml
# ClusterRole для перегляду ресурсів кластера
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-viewer
rules:
- apiGroups: [""]
  resources: ["nodes", "namespaces", "persistentvolumes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses", "networkpolicies"]
  verbs: ["get", "list", "watch"]
---
# ClusterRole для моніторингу
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "nodes"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list", "watch"]
---
# ClusterRole для адміністраторів кластера
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

### Крок 6: Створення RoleBindings

Створи файл `role-bindings.yaml`:

```yaml
# RoleBinding для розробників
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: development
- kind: User
  name: developer@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
---
# RoleBinding для DevOps
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devops-binding
  namespace: staging
subjects:
- kind: ServiceAccount
  name: monitoring-service-account
  namespace: monitoring
- kind: User
  name: devops@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: devops-role
  apiGroup: rbac.authorization.k8s.io
---
# RoleBinding для адміністраторів
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: admin-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: admin-service-account
  namespace: production
- kind: User
  name: admin@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: admin-role
  apiGroup: rbac.authorization.k8s.io
```

### Крок 7: Створення ClusterRoleBindings

Створи файл `cluster-role-bindings.yaml`:

```yaml
# ClusterRoleBinding для перегляду кластера
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-viewer-binding
subjects:
- kind: User
  name: viewer@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-viewer
  apiGroup: rbac.authorization.k8s.io
---
# ClusterRoleBinding для моніторингу
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitoring-binding
subjects:
- kind: ServiceAccount
  name: monitoring-service-account
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: monitoring-role
  apiGroup: rbac.authorization.k8s.io
---
# ClusterRoleBinding для адміністраторів кластера
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-binding
subjects:
- kind: User
  name: cluster-admin@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

### Крок 8: Застосування ресурсів

```bash
# Застосування Namespaces
kubectl apply -f namespaces.yaml

# Застосування Resource Quotas
kubectl apply -f resource-quotas.yaml

# Застосування Service Accounts
kubectl apply -f service-accounts.yaml

# Застосування Roles
kubectl apply -f roles.yaml

# Застосування ClusterRoles
kubectl apply -f cluster-roles.yaml

# Застосування RoleBindings
kubectl apply -f role-bindings.yaml

# Застосування ClusterRoleBindings
kubectl apply -f cluster-role-bindings.yaml

# Перевірка статусу
kubectl get namespaces
kubectl get resourcequota --all-namespaces
kubectl get serviceaccounts --all-namespaces
kubectl get roles --all-namespaces
kubectl get clusterroles
kubectl get rolebindings --all-namespaces
kubectl get clusterrolebindings
```

### Крок 9: Тестування RBAC

#### Тестування доступу розробника:
```bash
# Створення контексту для розробника
kubectl config set-context dev-context \
  --cluster=minikube \
  --user=developer@company.com \
  --namespace=development

# Переключення на контекст розробника
kubectl config use-context dev-context

# Тестування створення Pod в development namespace
kubectl run test-pod --image=nginx:alpine

# Тестування створення Pod в production namespace (має не вдатися)
kubectl run test-pod --image=nginx:alpine -n production
```

#### Тестування доступу адміністратора:
```bash
# Переключення на адміністративний контекст
kubectl config use-context minikube

# Тестування створення ресурсів в різних namespace
kubectl run admin-pod --image=nginx:alpine -n development
kubectl run admin-pod --image=nginx:alpine -n staging
kubectl run admin-pod --image=nginx:alpine -n production
```

### Крок 10: Створення Pod з Service Account

Створи файл `pod-with-sa.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: development
  labels:
    app: myapp
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: nginx:alpine
    ports:
    - containerPort: 80
    
    # Команда для тестування доступу
    command:
    - /bin/sh
    - -c
    - |
      echo "Testing RBAC access..."
      
      # Тестування доступу до Pod в development namespace
      kubectl get pods -n development
      
      # Тестування доступу до Pod в production namespace (має не вдатися)
      kubectl get pods -n production || echo "Access denied to production namespace"
      
      # Запуск nginx
      nginx -g "daemon off;"
```

### Крок 11: Моніторинг та аудит

#### Створення Pod Security Policies:
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-policy
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      - min: 1
        max: 65535
  readOnlyRootFilesystem: true
```

#### Створення Network Policies:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-access
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 80
```

## 📝 Завдання для практики

1. **Створи різні Namespaces з квотами:**
   - Development з обмеженими ресурсами
   - Staging з середніми ресурсами
   - Production з високими ресурсами

2. **Налаштуй різні ролі доступу:**
   - Read-only користувачі
   - Розробники з обмеженими правами
   - DevOps з розширеними правами
   - Адміністратори з повними правами

3. **Створи систему аудиту:**
   - Логування всіх дій користувачів
   - Алерти при порушенні політик
   - Регулярні звіти про доступ

4. **Налаштуй безпеку:**
   - Pod Security Policies
   - Network Policies
   - Resource Quotas
   - Limit Ranges

## 🔍 Перевірка знань

- [ ] Розумію призначення Namespaces та RBAC
- [ ] Можу створити Namespaces з Resource Quotas
- [ ] Налаштував різні ролі та права доступу
- [ ] Можу тестувати та моніторити RBAC
- [ ] Розумію принципи безпеки Kubernetes

## 📚 Додаткові ресурси

- [Kubernetes Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Helm](../09-helm/README.md) 