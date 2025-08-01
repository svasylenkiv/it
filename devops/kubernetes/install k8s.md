Крок 1. Встановити інструменти
Docker Desktop

Під час встановлення постав галочку "Enable Kubernetes".

Це підніме локальний кластер Kubernetes (простий для навчання).

kubectl — офіційний CLI для керування кластером.

Після встановлення перевір:

powershell
Копіювати
Редагувати
kubectl version --client
(Опціонально) Lens — зручний GUI для Kubernetes (щоб наочно бачити кластери, поди, сервіси).

Чому не Minikube?
Docker Desktop вже дає готовий Kubernetes без зайвої конфігурації. Minikube стане в пригоді, якщо ти захочеш гнучкіше керувати кластером (потім спробуємо).


Крок 2. Перевірити, що Kubernetes працює
У PowerShell:

powershell
Копіювати
Редагувати
kubectl cluster-info
kubectl get nodes
Очікувано: 1 нода зі статусом Ready.

Крок 3. Розгортаємо перший Pod
Створимо найпростіший pod з Nginx:

powershell
Копіювати
Редагувати
kubectl run nginx-pod --image=nginx --port=80
kubectl get pods
Якщо все добре — под у статусі Running.

Крок 4. Доступ до pod
Pod за замовчуванням ізольований. Додамо сервіс:

powershell
Копіювати
Редагувати
kubectl expose pod nginx-pod --type=NodePort --port=80
kubectl get svc
Там побачиш порт (наприклад, 30080). Відкрий у браузері:
http://localhost:30080 → має відкритись стартова сторінка Nginx.

Крок 1. Встановлюємо Minikube
Встанови Hypervisor (щоб віртуалка для кластеру працювала швидко):

Якщо у тебе Windows 11 Pro — увімкни Hyper-V (через "Turn Windows features on or off").

Якщо Home — зручніше встановити VirtualBox.

Скачай Minikube:
https://minikube.sigs.k8s.io/docs/start/
Встанови .exe (через PowerShell із правами адміністратора):

powershell
Копіювати
Редагувати
choco install minikube -y
(Якщо немає Chocolatey: інструкція).

Встанови kubectl (якщо ще не ставив):

powershell
Копіювати
Редагувати
choco install kubernetes-cli -y
Крок 2. Запускаємо кластер
Запускаємо:

powershell
Копіювати
Редагувати
minikube start --driver=hyperv
(або --driver=virtualbox якщо VirtualBox).
Це створить віртуалку й підніме 1-нодовий кластер.

Перевіряємо:

powershell
Копіювати
Редагувати
kubectl get nodes
Має бути minikube Ready.

Крок 3. Розгортаємо перший pod
powershell
Копіювати
Редагувати
kubectl run nginx-pod --image=nginx --port=80
kubectl get pods
Статус має бути Running.

Крок 4. Робимо доступ з браузера
powershell
Копіювати
Редагувати
kubectl expose pod nginx-pod --type=NodePort --port=80
minikube service nginx-pod
Ця команда відкриє браузер з реальною IP-адресою та портом, де працює Nginx.

Крок 5. Зберігаємо як YAML
Згенеруємо YAML для пода (щоб далі писати маніфести вручну):

powershell
Копіювати
Редагувати
kubectl get pod nginx-pod -o yaml > nginx-pod.yaml
Тепер є базовий маніфест, який ми зможемо змінювати.