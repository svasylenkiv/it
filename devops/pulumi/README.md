# 🚀 Pulumi на Windows 11 - Повний гід

Цей репозиторій містить повний гід по встановленню та використанню Pulumi на Windows 11, включаючи автоматичні скрипти, готові приклади та детальну документацію.

## 📋 Що включено

- 📖 **Детальний гід** - повна інструкція по встановленню та використанню
- 🔧 **Автоматичний скрипт** - PowerShell скрипт для швидкого встановлення
- 🎯 **Готовий приклад** - повноцінний проект з веб-сервером на AWS
- ⚡ **Швидкий старт** - мінімальні інструкції для початківців

## 🚀 Швидкий старт

### 1. Автоматичне встановлення (рекомендовано)

```powershell
# Завантажте файли
git clone <your-repo-url>
cd pulumi-windows-guide

# Запустіть PowerShell як адміністратор
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup-pulumi-windows.ps1
```

### 2. Ручне встановлення

```powershell
# Встановлення основних компонентів
winget install Pulumi.Pulumi
winget install OpenJS.NodeJS
winget install Amazon.AWSCLI
winget install Git.Git
```

### 3. Перший проект

```powershell
# Створення проекту
mkdir my-first-pulumi
cd my-first-pulumi
pulumi new aws-typescript

# Розгортання
npm install
pulumi up
```

## 📁 Структура проекту

```
pulumi-windows-guide/
├── 📖 pulumi-guide-windows.md     # Детальний гід
├── ⚡ quick-start-guide.md        # Швидкий старт
├── 🔧 setup-pulumi-windows.ps1   # Автоматичний скрипт
├── 🎯 example-project/           # Готовий приклад
│   ├── index.ts                  # Код інфраструктури
│   ├── Pulumi.yaml              # Конфігурація проекту
│   ├── package.json             # Залежності
│   └── README.md                # Інструкції по проекту
└── 📋 README.md                 # Цей файл
```

## 🎯 Готовий приклад

Проект `example-project` демонструє створення повної інфраструктури AWS:

- **VPC** з публічною підмережею
- **Internet Gateway** для доступу до інтернету
- **Security Group** з правилами для HTTP, HTTPS та SSH
- **EC2 Instance** з веб-сервером Apache
- **Elastic IP** для статичної IP адреси
- **S3 Bucket** для зберігання логів

### Запуск прикладу

```powershell
cd example-project
npm install
pulumi up
```

Після розгортання ви отримаєте URL веб-сервера з красивою сторінкою.

## 🔧 Автоматичний скрипт

Скрипт `setup-pulumi-windows.ps1` автоматично:

- ✅ Встановлює всі необхідні компоненти
- ✅ Налаштовує середовище розробки
- ✅ Створює швидкі команди PowerShell
- ✅ Налаштовує VS Code
- ✅ Створює директорію для проектів

### Швидкі команди (після встановлення)

```powershell
# Створити новий проект
New-PulumiProject "my-project"

# Створити демо проект
Start-PulumiDemo

# Показати статус
Show-PulumiStatus
```

## 📚 Документація

### Основні файли

- **[Детальний гід](pulumi-guide-windows.md)** - повна інструкція з прикладами
- **[Швидкий старт](quick-start-guide.md)** - мінімальні інструкції
- **[Приклад проекту](example-project/README.md)** - документація по готовому прикладу

### Основні команди Pulumi

| Команда | Опис |
|---------|------|
| `pulumi new` | Створити новий проект |
| `pulumi preview` | Перегляд змін |
| `pulumi up` | Розгортання |
| `pulumi destroy` | Видалення ресурсів |
| `pulumi stack` | Перегляд стеку |
| `pulumi config` | Керування конфігурацією |

## 🌟 Особливості

### ✅ Переваги цього гіду

- **Автоматизація** - один скрипт для встановлення всього
- **Готовий приклад** - робочий проект з реальною інфраструктурою
- **Детальна документація** - покрокові інструкції
- **Windows-оптимізований** - спеціально для Windows 11
- **Безпека** - найкращі практики безпеки

### 🎯 Що ви навчитеся

- Встановлювати та налаштовувати Pulumi на Windows
- Створювати інфраструктуру AWS за допомогою TypeScript
- Керувати конфігурацією та стеками
- Розгортати реальні проекти
- Використовувати найкращі практики

## 🔒 Безпека

### Рекомендації

1. **AWS Credentials** - використовуйте IAM користувачів з мінімальними правами
2. **Security Groups** - обмежуйте доступ до необхідних портів
3. **Тегування** - додавайте теги до всіх ресурсів
4. **Моніторинг** - налаштуйте логування та сповіщення

### Production готовність

Для production середовища рекомендується:

- Використання приватних підмереж
- Application Load Balancer
- Auto Scaling Groups
- CloudWatch логування
- SSL сертифікати

## 🤝 Підтримка

### Корисні ресурси

- 📚 [Офіційна документація Pulumi](https://www.pulumi.com/docs/)
- 🎯 [Pulumi Registry](https://www.pulumi.com/registry/)
- 💬 [Pulumi Community Slack](https://slack.pulumi.com/)
- 🐛 [GitHub Issues](https://github.com/pulumi/pulumi/issues)
- ❓ [Stack Overflow](https://stackoverflow.com/questions/tagged/pulumi)

### Вирішення проблем

Якщо у вас виникли проблеми:

1. Перевірте [детальний гід](pulumi-guide-windows.md)
2. Переконайтеся, що всі компоненти встановлені
3. Перевірте AWS credentials
4. Зверніться до спільноти Pulumi

## 📄 Ліцензія

MIT License - ви можете вільно використовувати, модифікувати та розповсюджувати цей матеріал.

## 🙏 Подяки

- Команда Pulumi за чудовий інструмент
- AWS за хмарну платформу
- Спільнота за підтримку та відгуки

---

**Готово до створення інфраструктури як код! 🚀** 