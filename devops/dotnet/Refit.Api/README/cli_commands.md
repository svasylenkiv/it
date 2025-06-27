# 🐳 Docker + AWS ECR інструкція

## Змінні
Встановіть змінні для зручності:

```bash
# ACCOUNT_ID=123456789012
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REGION=us-east-1
REPO_NAME=refit-api
IMAGE=refit-api
ECR_REPOSITORY=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME
```

## 🔨 Побудова Docker-образу
```bash
docker build -t $IMAGE . -f Refit.Api/Dockerfile
```

## ▶️ Запуск локально
```bash
docker run -p 5000:8080 -e ASPNETCORE_ENVIRONMENT=Development $IMAGE:latest
```
Перевірка в браузері: [http://localhost:5000/swagger/index.html](http://localhost:5000/swagger/index.html)

## 🔐 Авторизація в ECR
```bash
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY
```

## 🏷️ Тегування образу
```bash
docker tag $IMAGE:latest $ECR_REPOSITORY:latest
```

## 🚀 Відправка образу в ECR
```bash
docker push $ECR_REPOSITORY:latest
```