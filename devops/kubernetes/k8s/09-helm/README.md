# 🔹 9. Helm

**⏱️ Час: 2-3 дні**

## 📚 Теорія

### Що таке Helm?
**Helm** - це менеджер пакетів для Kubernetes:
- **Шаблони** - перевикористання конфігурацій
- **Версіонування** - управління різними версіями додатків
- **Залежності** - автоматичне встановлення залежних чартів
- **Rollback** - повернення до попередніх версій

### Основні концепції

#### 1. Chart
- **Пакет Helm** - набір файлів, що описують додаток
- **Структура** - директорія з певною структурою файлів
- **Версіонування** - кожен chart має версію

#### 2. Release
- **Інстанс Chart** - конкретне розгортання chart в кластері
- **Унікальна назва** - кожен release має унікальну назву
- **Життєвий цикл** - створення, оновлення, видалення

#### 3. Repository
- **Сховище Chart** - місце зберігання та поширення chart
- **Публічні репозиторії** - Helm Hub, Artifact Hub
- **Приватні репозиторії** - власні сховища

## 🛠️ Практика

### Крок 1: Встановлення Helm

#### Windows:
```bash
# Завантаження через winget
winget install Helm.Helm

# Або через Chocolatey
choco install kubernetes-helm

# Або через Scoop
scoop install helm
```

#### macOS:
```bash
# За допомогою Homebrew
brew install helm
```

#### Linux:
```bash
# Завантаження та встановлення
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

### Крок 2: Перевірка встановлення

```bash
# Перевірка версії
helm version

# Перегляд доступних команд
helm help

# Перегляд налаштувань
helm env
```

### Крок 3: Додавання репозиторіїв

```bash
# Додавання офіційного репозиторію
helm repo add stable https://charts.helm.sh/stable

# Додавання Bitnami репозиторію
helm repo add bitnami https://charts.bitnami.com/bitnami

# Додавання Prometheus репозиторію
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Оновлення репозиторіїв
helm repo update

# Перегляд доступних репозиторіїв
helm repo list
```

### Крок 4: Пошук та встановлення готових чартів

```bash
# Пошук чартів
helm search repo nginx
helm search repo postgresql
helm search repo redis

# Перегляд деталей чарту
helm show chart bitnami/nginx
helm show values bitnami/nginx

# Встановлення простого чарту
helm install my-nginx bitnami/nginx \
  --namespace default \
  --create-namespace

# Перегляд встановлених release
helm list
helm list --all-namespaces
```

### Крок 5: Створення власного Helm чарту

```bash
# Створення нового чарту
helm create myapp-chart

# Перегляд структури чарту
tree myapp-chart
```

Структура створеного чарту:
```
myapp-chart/
├── Chart.yaml          # Метадані чарту
├── values.yaml         # Значення за замовчуванням
├── charts/             # Залежності
├── templates/          # Шаблони Kubernetes ресурсів
│   ├── _helpers.tpl    # Допоміжні функції
│   ├── deployment.yaml # Deployment шаблон
│   ├── service.yaml    # Service шаблон
│   ├── ingress.yaml    # Ingress шаблон
│   ├── NOTES.txt       # Інструкції після встановлення
│   └── tests/          # Тести чарту
└── .helmignore         # Файли для ігнорування
```

### Крок 6: Налаштування Chart.yaml

Відредагуй файл `Chart.yaml`:

```yaml
apiVersion: v2
name: myapp-chart
description: A Helm chart for My Application
type: application
version: 0.1.0
appVersion: "1.0.0"
keywords:
  - web
  - api
  - kubernetes
home: https://github.com/yourusername/myapp-chart
sources:
  - https://github.com/yourusername/myapp-chart
maintainers:
  - name: Your Name
    email: your.email@example.com
```

### Крок 7: Налаштування values.yaml

Відредагуй файл `values.yaml`:

```yaml
# Default values for myapp-chart
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}

# Додаткові налаштування
app:
  name: "My Application"
  version: "1.0.0"
  environment: "production"

database:
  enabled: false
  host: "localhost"
  port: 5432
  name: "myapp"
  user: "postgres"
```

### Крок 8: Створення шаблонів

#### Deployment шаблон (`templates/deployment.yaml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp-chart.fullname" . }}
  labels:
    {{- include "myapp-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "myapp-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "myapp-chart.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "myapp-chart.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          env:
            - name: APP_NAME
              value: {{ .Values.app.name | quote }}
            - name: APP_VERSION
              value: {{ .Values.app.version | quote }}
            - name: APP_ENVIRONMENT
              value: {{ .Values.app.environment | quote }}
            {{- if .Values.database.enabled }}
            - name: DB_HOST
              value: {{ .Values.database.host | quote }}
            - name: DB_PORT
              value: {{ .Values.database.port | quote }}
            - name: DB_NAME
              value: {{ .Values.database.name | quote }}
            - name: DB_USER
              value: {{ .Values.database.user | quote }}
            {{- end }}
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

#### Service шаблон (`templates/service.yaml`):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "myapp-chart.fullname" . }}
  labels:
    {{- include "myapp-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "myapp-chart.selectorLabels" . | nindent 4 }}
```

#### Ingress шаблон (`templates/ingress.yaml`):
```yaml
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "myapp-chart.fullname" . -}}
{{- $svcPort := .Values.service.port -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "myapp-chart.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- if .pathType }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              service:
                name: {{ $fullName }}
                port:
                  number: {{ $svcPort }}
          {{- end }}
    {{- end }}
{{- end }}
```

### Крок 9: Тестування чарту

```bash
# Перевірка синтаксису чарту
helm lint myapp-chart

# Тестування рендерингу шаблонів
helm template myapp-chart

# Тестування з конкретними значеннями
helm template myapp-chart --set replicaCount=3 --set app.environment=staging

# Сухий запуск (dry-run)
helm install myapp-release myapp-chart --dry-run --debug
```

### Крок 10: Встановлення чарту

```bash
# Встановлення чарту
helm install myapp-release myapp-chart \
  --namespace default \
  --create-namespace

# Встановлення з кастомними значеннями
helm install myapp-staging myapp-chart \
  --namespace staging \
  --create-namespace \
  --set replicaCount=2 \
  --set app.environment=staging \
  --set database.enabled=true

# Перегляд встановлених release
helm list
helm list --all-namespaces
```

### Крок 11: Оновлення та керування release

```bash
# Оновлення release
helm upgrade myapp-release myapp-chart \
  --set replicaCount=3

# Оновлення з файлом значень
helm upgrade myapp-release myapp-chart \
  -f custom-values.yaml

# Перегляд історії release
helm history myapp-release

# Rollback до попередньої версії
helm rollback myapp-release 1

# Перегляд статусу release
helm status myapp-release

# Видалення release
helm uninstall myapp-release
```

### Крок 12: Створення складного чарту з залежностями

#### Створення чарту для API з базою даних:
```bash
helm create api-with-db-chart
```

#### Додавання залежності PostgreSQL:
```bash
cd api-with-db-chart
helm dependency add bitnami/postgresql
```

#### Оновлення `Chart.yaml`:
```yaml
apiVersion: v2
name: api-with-db-chart
description: A Helm chart for API with PostgreSQL
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
  - name: postgresql
    version: 12.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

#### Створення `values.yaml`:
```yaml
# API налаштування
api:
  replicaCount: 2
  image:
    repository: myapi
    tag: "1.0.0"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

# PostgreSQL налаштування
postgresql:
  enabled: true
  auth:
    postgresPassword: "mypassword"
    database: "myapp"
    username: "myapp"
    password: "myapppassword"
  primary:
    persistence:
      enabled: true
      size: 8Gi
  metrics:
    enabled: true

# Ingress налаштування
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: api.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Крок 13: Пакетування та поширення чарту

```bash
# Пакетування чарту
helm package myapp-chart

# Створення index.yaml для репозиторію
helm repo index .

# Завантаження чарту в репозиторій
helm push myapp-chart-0.1.0.tgz my-repo

# Встановлення з власного репозиторію
helm repo add my-repo https://my-repo.example.com
helm install myapp my-repo/myapp-chart
```

## 📝 Завдання для практики

1. **Створи різні типи чартів:**
   - Простий web додаток
   - API з базою даних
   - Мікросервісна архітектура

2. **Налаштуй залежності:**
   - PostgreSQL, Redis, MongoDB
   - Prometheus, Grafana
   - Ingress контролери

3. **Створи власний репозиторій:**
   - GitHub Pages
   - GitLab Pages
   - Приватний репозиторій

4. **Оптимізуй чарти:**
   - Шаблони та функції
   - Валідація та тестування
   - Документація та приклади

## 🔍 Перевірка знань

- [ ] Розумію призначення Helm та його концепції
- [ ] Можу створити власний Helm чарт
- [ ] Налаштував залежності та шаблони
- [ ] Можу встановлювати та керувати чартами
- [ ] Розумію як пакетувати та поширювати чарти

## 📚 Додаткові ресурси

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Charts](https://helm.sh/docs/topics/charts/)
- [Helm Hub](https://hub.helm.sh/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [CI/CD](../10-ci-cd/README.md) 