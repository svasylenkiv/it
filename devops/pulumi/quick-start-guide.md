# 🚀 Швидкий старт з Pulumi на Windows 11

## Крок 1: Встановлення

### Автоматичне встановлення (рекомендовано)
```powershell
# Запустіть PowerShell як адміністратор
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup-pulumi-windows.ps1
```

### Ручне встановлення
```powershell
# Встановлення Pulumi
winget install Pulumi.Pulumi

# Встановлення Node.js
winget install OpenJS.NodeJS

# Встановлення AWS CLI
winget install Amazon.AWSCLI

# Встановлення Git
winget install Git.Git
```

## Крок 2: Налаштування AWS

```powershell
aws configure
```

Введіть:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region: `us-west-2`
- Default output format: `json`

## Крок 3: Перший проект

```powershell
# Створення проекту
mkdir my-first-pulumi
cd my-first-pulumi
pulumi new aws-typescript

# Встановлення залежностей
npm install

# Перегляд змін
pulumi preview

# Розгортання
pulumi up
```

## Крок 4: Використання готового прикладу

```powershell
# Клонування прикладу
git clone <your-repo>
cd example-project

# Встановлення залежностей
npm install

# Розгортання
pulumi up
```

## Основні команди

| Команда | Опис |
|---------|------|
| `pulumi new` | Створити новий проект |
| `pulumi preview` | Перегляд змін |
| `pulumi up` | Розгортання |
| `pulumi destroy` | Видалення ресурсів |
| `pulumi stack` | Перегляд стеку |
| `pulumi config` | Керування конфігурацією |

## Швидкі команди (після встановлення)

```powershell
# Створити новий проект
New-PulumiProject "my-project"

# Створити демо проект
Start-PulumiDemo

# Показати статус
Show-PulumiStatus
```

## Корисні посилання

- 📖 [Повний гід](pulumi-guide-windows.md)
- 🎯 [Приклад проекту](example-project/)
- 🔧 [Автоматичне встановлення](setup-pulumi-windows.ps1)
- 📚 [Офіційна документація](https://www.pulumi.com/docs/)

## Підтримка

- 💬 [Pulumi Community Slack](https://slack.pulumi.com/)
- 🐛 [GitHub Issues](https://github.com/pulumi/pulumi/issues)
- ❓ [Stack Overflow](https://stackoverflow.com/questions/tagged/pulumi) 