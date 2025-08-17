# ❓ Часто задавані питання (FAQ)

## 🚀 Загальні питання

### Q: Чи можу я вивчити Kubernetes без досвіду з Docker?
**A:** Так, але Docker знання дуже корисні. Kubernetes працює з контейнерами, тому розуміння Docker концепцій допоможе швидше освоїти матеріал.

### Q: Скільки часу потрібно для вивчення курсу?
**A:** Курс розрахований на 25-35 днів при щоденних занять 2-3 години. Загальний час залежить від вашого досвіду та інтенсивності навчання.

### Q: Чи потрібен потужний комп'ютер?
**A:** Ні, Minikube працює на більшості комп'ютерів. Мінімум: 4GB RAM, 2 CPU cores, 20GB вільного місця.

### Q: Чи можна вивчати без інтернету?
**A:** Частково. Вам потрібен інтернет для завантаження образів та встановлення інструментів, але основна практика може бути локальною.

---

## 🛠️ Технічні питання

### Q: Minikube не запускається, що робити?
**A:** Перевірте:
- Включений Hyper-V (Windows) або VirtualBox
- Достатньо RAM (мінімум 4GB)
- Встановлений Docker Desktop
- Оновлені драйвери

### Q: Як отримати доступ до додатку ззовні кластера?
**A:** Використовуйте:
- `kubectl port-forward` для тестування
- Service типу NodePort або LoadBalancer
- Ingress контролер для HTTP/HTTPS

### Q: Чому Pod не запускається?
**A:** Перевірте:
- `kubectl describe pod <pod-name>`
- `kubectl logs <pod-name>`
- Resource limits та requests
- Image name та tag
- ConfigMaps та Secrets

### Q: Як зберегти дані між перезапусками Pod?
**A:** Використовуйте:
- PersistentVolume та PersistentVolumeClaim
- ConfigMaps для конфігурації
- Secrets для чутливих даних

---

## 🔐 Безпека та доступ

### Q: Як налаштувати доступ для різних користувачів?
**A:** Використовуйте RBAC:
- Створіть Namespaces
- Створіть Roles та ClusterRoles
- Створіть RoleBindings
- Використовуйте Service Accounts

### Q: Чи безпечно використовувати Minikube для production?
**A:** Ні! Minikube призначений тільки для розробки та тестування. Для production використовуйте:
- AWS EKS
- Azure AKS
- GCP GKE
- Self-hosted кластери

### Q: Як захистити чутливі дані?
**A:** Використовуйте:
- Kubernetes Secrets
- External secret managers (AWS Secrets Manager, Azure Key Vault)
- Pod Security Policies
- Network Policies

---

## 📊 Моніторинг та логування

### Q: Як переглянути логи додатку?
**A:** Використовуйте:
```bash
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # follow logs
kubectl logs --previous <pod-name>  # logs from previous container
```

### Q: Як налаштувати алерти?
**A:** Використовуйте:
- Prometheus + AlertManager
- PrometheusRules для створення алертів
- Grafana для візуалізації
- Notification channels (Slack, Email, PagerDuty)

### Q: Як збирати метрики додатку?
**A:** Використовуйте:
- Prometheus client libraries
- Custom metrics API
- ServiceMonitor для автоматичного discovery
- Grafana dashboards

---

## 🚀 Розгортання та CI/CD

### Q: Як автоматизувати розгортання?
**A:** Використовуйте:
- GitHub Actions або GitLab CI
- Helm для templating
- ArgoCD для GitOps
- Flux для автоматичної синхронізації

### Q: Як оновити додаток без downtime?
**A:** Використовуйте:
- Rolling updates в Deployment
- Blue-Green deployment
- Canary deployment
- Istio для traffic splitting

### Q: Як відкотити зміни?
**A:** Використовуйте:
```bash
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=2
helm rollback <release> <revision>
```

---

## ☁️ Хмарні платформи

### Q: Яку хмарну платформу обрати?
**A:** Залежить від ваших потреб:
- **AWS EKS:** Велика екосистема, багато сервісів
- **Azure AKS:** Хороша інтеграція з Microsoft продуктами
- **GCP GKE:** Простота використання, хороша продуктивність

### Q: Скільки коштує хмарний кластер?
**A:** Вартість залежить від:
- Кількості та типу nodes
- Регіону
- Використання ресурсів
- Додаткових сервісів

### Q: Як перенести з Minikube в хмару?
**A:** Процес:
1. Створіть кластер в хмарі
2. Налаштуйте kubectl
3. Застосуйте ваші manifests
4. Оновіть image references
5. Налаштуйте networking

---

## 📚 Навчання та сертифікація

### Q: Чи потрібна сертифікація?
**A:** Не обов'язково, але корисно для:
- Підтвердження знань
- Кар'єрного росту
- Роботи з клієнтами
- Особистого розвитку

### Q: Як готуватися до сертифікації?
**A:** Рекомендації:
- Пройдіть повний курс
- Практикуйтесь щодня
- Використовуйте офіційні матеріали
- Розв'язуйте практичні завдання
- Використовуйте симулятори

### Q: Які сертифікати існують?
**A:** Основні:
- **CKAD:** Certified Kubernetes Application Developer
- **CKA:** Certified Kubernetes Administrator
- **CKS:** Certified Kubernetes Security Specialist

---

## 🐛 Troubleshooting

### Q: Pod в стані Pending
**A:** Можливі причини:
- Недостатньо ресурсів на nodes
- Проблеми з PersistentVolume
- NodeSelector не знаходить відповідний node
- ResourceQuota перевищена

### Q: Pod в стані CrashLoopBackOff
**A:** Перевірте:
- Логи контейнера
- Resource limits
- Health checks
- Environment variables
- Volume mounts

### Q: Service не може знайти Pod
**A:** Перевірте:
- Labels та selectors
- Namespace
- Pod status
- Service configuration

---

## 🔧 Корисні команди

### Базові команди
```bash
# Перегляд ресурсів
kubectl get all
kubectl get pods,services,deployments

# Детальна інформація
kubectl describe pod <name>
kubectl describe service <name>

# Логи
kubectl logs <pod-name>
kubectl logs -f <pod-name>

# Exec в контейнер
kubectl exec -it <pod-name> -- /bin/bash

# Port forwarding
kubectl port-forward <resource> <local-port>:<remote-port>
```

### Debug команди
```bash
# Перегляд events
kubectl get events --sort-by='.lastTimestamp'

# Перегляд logs з попереднього контейнера
kubectl logs <pod-name> --previous

# Перегляд YAML ресурсу
kubectl get <resource> <name> -o yaml

# Dry run
kubectl apply -f <file> --dry-run=client
```

---

## 📞 Підтримка

### Якщо у вас є питання:
1. **Перевірте документацію** - більшість відповідей там
2. **Пошук в Google** - багато проблем вже вирішені
3. **Stack Overflow** - технічні питання
4. **GitHub Issues** - проблеми з інструментами
5. **Kubernetes Slack** - спільнота

### Корисні ресурси:
- [Kubernetes.io](https://kubernetes.io/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/kubernetes)
- [GitHub Kubernetes](https://github.com/kubernetes/kubernetes)
- [Reddit r/kubernetes](https://www.reddit.com/r/kubernetes/)

---

**💡 Порада: Не бійтеся робити помилки - це частина навчання!**

*Кожна помилка - це можливість чомусь навчитися.* 