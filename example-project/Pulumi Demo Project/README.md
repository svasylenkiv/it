# Pulumi Demo Project

Цей проект демонструє створення повної інфраструктури AWS за допомогою Pulumi на Windows 11.

## Що розгортається

- **VPC** з публічною підмережею
- **Internet Gateway** для доступу до інтернету
- **Security Group** з правилами для HTTP, HTTPS та SSH
- **EC2 Instance** з веб-сервером Apache
- **Elastic IP** для статичної IP адреси
- **S3 Bucket** для зберігання логів

## Передумови

1. **Pulumi CLI** встановлений
2. **Node.js** (версія 16 або вище)
3. **AWS CLI** налаштований з credentials
4. **Git** для клонування проекту

## Швидкий старт

### 1. Клонування проекту

```powershell
git clone <your-repo-url>
cd example-project
```

### 2. Встановлення залежностей

```powershell
npm install
```

### 3. Налаштування AWS credentials

```powershell
aws configure
```

Введіть ваші AWS credentials:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: us-west-2
- Default output format: json

### 4. Перегляд змін

```powershell
pulumi preview
```

### 5. Розгортання інфраструктури

```powershell
pulumi up
```

Підтвердіть розгортання, ввівши `yes`.

### 6. Перегляд результатів

```powershell
pulumi stack output
```

## Використання

### Доступ до веб-сервера

Після успішного розгортання ви отримаєте URL веб-сервера:

```powershell
pulumi stack output webServerUrl
```

Відкрийте цей URL у браузері для перегляду веб-сторінки.

### SSH підключення (опціонально)

Якщо у вас є SSH ключ, ви можете підключитися до сервера:

```powershell
# Спочатку налаштуйте ім'я ключа
pulumi config set keyName your-key-name

# Потім отримайте команду для SSH
pulumi stack output sshCommand
```

### Перегляд логів

```powershell
pulumi logs
```

## Керування інфраструктурою

### Оновлення конфігурації

```powershell
# Зміна середовища
pulumi config set environment production

# Зміна регіону
pulumi config set aws:region us-east-1

# Зміна типу інстансу
pulumi config set instanceType t3.small
```

### Перегляд стану

```powershell
# Перегляд всіх ресурсів
pulumi stack

# Перегляд конфігурації
pulumi config

# Перегляд ресурсів з деталями
pulumi stack --show-urns
```

### Видалення інфраструктури

```powershell
pulumi destroy
```

**Увага!** Це видалить всі створені ресурси.

## Структура проекту

```
example-project/
├── index.ts              # Основний код інфраструктури
├── Pulumi.yaml           # Конфігурація проекту
├── Pulumi.dev.yaml       # Конфігурація для dev середовища
├── package.json          # Залежності Node.js
├── tsconfig.json         # Конфігурація TypeScript
└── README.md             # Цей файл
```

## Налаштування

### Конфігураційні параметри

- `environment` - середовище (dev, staging, production)
- `projectName` - назва проекту
- `keyName` - ім'я SSH ключа (опціонально)
- `aws:region` - AWS регіон

### Зміна конфігурації

```powershell
# Встановлення значення
pulumi config set environment production

# Перегляд значення
pulumi config get environment

# Видалення значення
pulumi config rm environment
```

## Моніторинг та логування

### S3 Bucket для логів

Логи Apache автоматично копіюються в S3 bucket щодня о 2:00 AM.

### Перегляд логів в S3

```powershell
# Отримання імені bucket
pulumi stack output logsBucketName

# Перегляд логів через AWS CLI
aws s3 ls s3://<bucket-name>/logs/
```

## Безпека

### Security Group

Веб-сервер налаштований з security group, який дозволяє:
- HTTP (порт 80)
- HTTPS (порт 443)
- SSH (порт 22)

### Рекомендації для production

1. Обмежте SSH доступ до конкретних IP адрес
2. Використовуйте HTTPS з SSL сертифікатом
3. Налаштуйте CloudWatch логування
4. Додайте Auto Scaling Group
5. Використовуйте Application Load Balancer

## Вирішення проблем

### Помилка "Access Denied"

Перевірте AWS credentials:
```powershell
aws sts get-caller-identity
```

### Помилка "AMI not found"

Оновіть AMI ID в коді на актуальний для вашого регіону:
```powershell
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "Images[0].ImageId"
```

### Помилка "VPC limit exceeded"

Видаліть непотрібні VPC або зверніться до AWS Support для збільшення лімітів.

## Корисні команди

```powershell
# Перегляд всіх стеків
pulumi stack ls

# Створення нового стеку
pulumi stack init production

# Переключення між стеками
pulumi stack select dev

# Експорт стеку
pulumi stack export --file stack.json

# Імпорт стеку
pulumi stack import --file stack.json
```

## Підтримка

- [Pulumi Documentation](https://www.pulumi.com/docs/)
- [AWS Provider Documentation](https://www.pulumi.com/registry/packages/aws/)
- [Pulumi Community Slack](https://slack.pulumi.com/)

## Ліцензія

MIT License 