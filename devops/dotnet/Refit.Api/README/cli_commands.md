# 🐳 Docker + AWS ECR інструкція

---

## 0. Налаштування AWS CLI

Виконай команду:

```bash
aws configure
```

📌 Введи:
- AWS Access Key ID
- AWS Secret Access Key
- Region (наприклад, us-east-1)
- output format (рекомендується json)

---

## 1. Змінні

Встановіть змінні для зручності (заміни значення за потреби):

```bash
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text) # ID твого AWS акаунта
REGION=us-east-1         # Регіон AWS
PROJECT=refit-api
REPO_NAME="$PROJECT-ecr" # Назва репозиторію ECR
IMAGE=refit-api          # Локальна назва Docker-образу
ECR_REPOSITORY=$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME # Повна адреса репозиторію
```

---

## 2. (Опційно) Створення репозиторію ECR

Якщо репозиторій ще не створено:

```bash
aws ecr create-repository --repository-name $REPO_NAME --region $REGION
```

---

## 3. Побудова Docker-образу

```bash
docker build -t $IMAGE . -f Refit.Api/Dockerfile
```

---

## 4. Запуск локально

```bash
docker run -p 8080:8080 -e ASPNETCORE_ENVIRONMENT=Development $IMAGE:latest
```

Перевірка в браузері: [http://localhost:5000/swagger/index.html](http://localhost:5000/swagger/index.html)

---

## 5. Авторизація в ECR

```bash
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY
```

---

## 6. Тегування образу

```bash
docker tag $IMAGE:latest $ECR_REPOSITORY:latest
```

---

## 7. Відправка образу в ECR

```bash
docker push $ECR_REPOSITORY:latest
```

---

## 8. (Опційно) Видалення локальних образів

```bash
docker rmi $IMAGE:latest $ECR_REPOSITORY:latest
```

---

## 📚 Корисні посилання
- [AWS ECR Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [Docker Documentation](https://docs.docker.com/)