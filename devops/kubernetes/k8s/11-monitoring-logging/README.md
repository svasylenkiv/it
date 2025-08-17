# 🔹 11. Моніторинг і логування

**⏱️ Час: 2-3 дні**

## 📚 Теорія

### Моніторинг в Kubernetes
**Моніторинг** - це збір та аналіз метрик про стан кластера та додатків:
- **Resource metrics** - CPU, пам'ять, диск
- **Application metrics** - бізнес-логіка, performance
- **Infrastructure metrics** - nodes, pods, services

### Логування в Kubernetes
**Логування** - це збір та аналіз логів з різних компонентів:
- **Container logs** - логи додатків
- **System logs** - логи Kubernetes компонентів
- **Audit logs** - логи доступу та змін

## 🛠️ Практика

### Крок 1: Встановлення Prometheus та Grafana

```bash
# Додавання репозиторію
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Встановлення Prometheus Stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### Крок 2: Базові команди моніторингу

```bash
# Перегляд ресурсів
kubectl top pods
kubectl top nodes

# Перегляд логів
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs --previous <pod-name>

# Перегляд events
kubectl get events --sort-by='.lastTimestamp'
```

### Крок 3: Налаштування EFK Stack

```bash
# Встановлення Elasticsearch
helm install elasticsearch elastic/elasticsearch \
  --namespace logging \
  --create-namespace

# Встановлення Fluentd
helm install fluentd fluent/fluentd \
  --namespace logging

# Встановлення Kibana
helm install kibana elastic/kibana \
  --namespace logging
```

### Крок 4: Створення Custom Metrics

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-metrics
  namespace: monitoring
data:
  custom-metrics.yaml: |
    rules:
    - record: app:requests_per_second
      expr: rate(http_requests_total[5m])
```

### Крок 5: Налаштування алертів

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: app-alerts
  namespace: monitoring
spec:
  groups:
  - name: app.rules
    rules:
    - alert: HighErrorRate
      expr: rate(http_errors_total[5m]) > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate detected"
```

## 📝 Завдання для практики

1. **Налаштуй базовий моніторинг:**
   - Prometheus + Grafana
   - Базові метрики кластера
   - Dashboard для відстеження

2. **Створи систему логування:**
   - EFK Stack
   - Централізоване зберігання логів
   - Пошук та аналіз

3. **Налаштуй алерти:**
   - Prometheus Rules
   - Notification channels
   - Escalation policies

## 🔍 Перевірка знань

- [ ] Розумію принципи моніторингу в Kubernetes
- [ ] Налаштував Prometheus та Grafana
- [ ] Створив систему логування
- [ ] Налаштував алерти та нотифікації

## 📚 Додаткові ресурси

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [EFK Stack](https://www.elastic.co/what-is/elk-stack)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Розгортання в хмарі](../12-cloud-deployment/README.md) 