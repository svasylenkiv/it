# 🔹 5. Зберігання (Storage)

**⏱️ Час: 2-3 дні**

## 📚 Теорія

### PersistentVolume (PV) та PersistentVolumeClaim (PVC)
**PersistentVolume** - це ресурс кластера, який представляє фізичне зберігання:
- **Фізичне зберігання** - диски, NFS, AWS EBS, тощо
- **Статичне створення** - адміністратор створює PV
- **Динамічне створення** - автоматично через StorageClass

**PersistentVolumeClaim** - це запит на зберігання від користувача:
- **Запит ресурсів** - розмір, тип доступу
- **Зв'язування з PV** - автоматичне або ручне
- **Життєвий цикл** - незалежний від Pod

### StorageClass
**StorageClass** - визначає тип зберігання та параметри:
- **Тип зберігання** - SSD, HDD, network storage
- **Провайдер** - AWS, Azure, GCP, NFS
- **Параметри** - розмір блоку, тип шифрування

### StatefulSet
**StatefulSet** - для додатків з станом:
- **Стабільна ідентичність** - кожен Pod має унікальне ім'я
- **Стабільне зберігання** - кожен Pod має свій PVC
- **Порядок розгортання** - послідовне створення/видалення

## 🛠️ Практика

### Крок 1: Створення StorageClass

Створи файл `storage-class.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: k8s.io/minikube-hostpath
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
parameters:
  type: pd-ssd
  fsType: ext4
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: slow-hdd
provisioner: k8s.io/minikube-hostpath
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: false
parameters:
  type: pd-standard
  fsType: ext4
```

### Крок 2: Створення PersistentVolumeClaim

Створи файл `pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-pvc
  labels:
    app: myapp
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: fast-ssd
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-data-pvc
  labels:
    app: myapp
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: slow-hdd
```

### Крок 3: Створення Pod з PersistentVolume

Створи файл `pod-with-storage.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-storage
  labels:
    app: myapp
spec:
  containers:
  - name: app
    image: nginx:alpine
    ports:
    - containerPort: 80
    
    # Монтування volume
    volumeMounts:
    - name: app-storage
      mountPath: /app/data
    - name: backup-storage
      mountPath: /app/backup
    
    # Команда для створення тестових файлів
    command: ["/bin/sh"]
    args:
    - -c
    - |
      echo "Hello from $(date)" > /app/data/test.txt
      echo "Backup created at $(date)" > /app/backup/backup.txt
      nginx -g "daemon off;"
  
  volumes:
  - name: app-storage
    persistentVolumeClaim:
      claimName: app-data-pvc
  - name: backup-storage
    persistentVolumeClaim:
      claimName: backup-data-pvc
```

### Крок 4: Застосування ресурсів

```bash
# Застосування StorageClass
kubectl apply -f storage-class.yaml

# Застосування PVC
kubectl apply -f pvc.yaml

# Застосування Pod
kubectl apply -f pod-with-storage.yaml

# Перевірка статусу
kubectl get storageclass
kubectl get pvc
kubectl get pods
```

### Крок 5: Перевірка зберігання

```bash
# Перегляд PVC
kubectl describe pvc app-data-pvc

# Перегляд Pod
kubectl describe pod app-with-storage

# Перевірка файлів в Pod
kubectl exec -it app-with-storage -- ls -la /app/data/
kubectl exec -it app-with-storage -- cat /app/data/test.txt
kubectl exec -it app-with-storage -- ls -la /app/backup/
```

### Крок 6: Тестування стійкості даних

```bash
# Видалення Pod
kubectl delete pod app-with-storage

# Створення нового Pod з тим же PVC
kubectl apply -f pod-with-storage.yaml

# Перевірка що дані збереглися
kubectl exec -it app-with-storage -- cat /app/data/test.txt
```

### Крок 7: Створення StatefulSet з PostgreSQL

Створи файл `postgres-statefulset.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  labels:
    app: postgres
spec:
  ports:
  - port: 5432
    targetPort: 5432
  clusterIP: None
  selector:
    app: postgres
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  serviceName: postgres-service
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "myapp"
        - name: POSTGRES_USER
          value: "postgres"
        - name: POSTGRES_PASSWORD
          value: "password123"
        
        # Монтування зберігання
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
          subPath: postgres
        
        # Health checks
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - postgres
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - postgres
          initialDelaySeconds: 5
          periodSeconds: 5
        
        # Resource limits
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
  
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 10Gi
```

### Крок 8: Застосування StatefulSet

```bash
# Застосування StatefulSet
kubectl apply -f postgres-statefulset.yaml

# Перевірка статусу
kubectl get statefulsets
kubectl get pods
kubectl get pvc

# Очікування готовності
kubectl wait --for=condition=ready pod/postgres-0
```

### Крок 9: Тестування PostgreSQL

```bash
# Підключення до бази даних
kubectl exec -it postgres-0 -- psql -U postgres -d myapp

# SQL команди для тестування
CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100), email VARCHAR(100));
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
SELECT * FROM users;
\q

# Перевірка що дані зберігаються
kubectl exec -it postgres-0 -- psql -U postgres -d myapp -c "SELECT * FROM users;"
```

### Крок 10: Розширення StatefulSet

```bash
# Збільшення кількості реплік
kubectl scale statefulset postgres --replicas=3

# Перевірка створення нових Pod-ів
kubectl get pods -l app=postgres

# Перевірка створення нових PVC
kubectl get pvc -l app=postgres
```

### Крок 11: Розширення зберігання

```bash
# Перегляд поточного розміру
kubectl get pvc

# Оновлення PVC для збільшення розміру
kubectl patch pvc postgres-storage-postgres-0 -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# Перевірка оновлення
kubectl get pvc
```

### Крок 12: Створення Backup Job

Створи файл `backup-job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: postgres-backup
  labels:
    app: postgres
spec:
  template:
    spec:
      containers:
      - name: backup
        image: postgres:13
        command:
        - /bin/bash
        - -c
        - |
          pg_dump -h postgres-service -U postgres -d myapp > /backup/backup_$(date +%Y%m%d_%H%M%S).sql
        env:
        - name: PGPASSWORD
          value: "password123"
        volumeMounts:
        - name: backup-storage
          mountPath: /backup
      volumes:
      - name: backup-storage
        persistentVolumeClaim:
          claimName: backup-data-pvc
      restartPolicy: Never
  backoffLimit: 3
```

## 📝 Завдання для практики

1. **Створи різні типи зберігання:**
   - Local storage для швидкого доступу
   - Network storage для спільного доступу
   - Cloud storage для резервних копій

2. **Налаштуй StatefulSet для різних додатків:**
   - MongoDB з реплікацією
   - Redis з кластеризацією
   - Elasticsearch з індексами

3. **Створи систему резервного копіювання:**
   - Автоматичні backup через CronJob
   - Ротація backup файлів
   - Відновлення з backup

4. **Досліди різні провайдери зберігання:**
   - AWS EBS, Azure Disk, GCP PD
   - NFS, Ceph, GlusterFS
   - Порівняй продуктивність та вартість

## 🔍 Перевірка знань

- [ ] Розумію різницю між PV, PVC та StorageClass
- [ ] Можу створити різні типи зберігання
- [ ] Налаштував StatefulSet з PostgreSQL
- [ ] Можу розширити зберігання та StatefulSet
- [ ] Створив систему резервного копіювання

## 📚 Додаткові ресурси

- [Kubernetes Storage](https://kubernetes.io/docs/concepts/storage/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

## ➡️ Наступний крок

Після завершення цього розділу переходимо до [Health checks](../06-health-checks/README.md) 