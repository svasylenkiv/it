творення Pod з Nginx через YAML — це вже буде справжнє declarative використання Kubernetes.

1️⃣ Створюємо YAML для Pod
📄 nginx-pod.yaml

yaml
Копіювати
Редагувати
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
2️⃣ Застосовуємо YAML у кластері
powershell
Копіювати
Редагувати
kubectl apply -f nginx-pod.yaml
3️⃣ Перевіряємо, що Pod створився
powershell
Копіювати
Редагувати
kubectl get pods
або з більш детальною інформацією:

powershell
Копіювати
Редагувати
kubectl describe pod nginx-pod
4️⃣ Створюємо Service для доступу до Pod
📄 nginx-service.yaml

yaml
Копіювати
Редагувати
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
5️⃣ Застосовуємо Service
powershell
Копіювати
Редагувати
kubectl apply -f nginx-service.yaml
6️⃣ Перевіряємо і відкриваємо сайт
powershell
Копіювати
Редагувати
kubectl get services
minikube service nginx-service
Відкриється в браузері стандартна сторінка Nginx.

7️⃣ Видалення
powershell
Копіювати
Редагувати
kubectl delete -f nginx-pod.yaml
kubectl delete -f nginx-service.yaml