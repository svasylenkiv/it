🔄 Ініціалізація та конфігурація

```bash
git init                      # Створити новий репозиторій
```

```bash
git config --global user.name "Твоє Ім’я"
```

```bash
git config --global user.email "email@example.com"
```

```bash
git config --list             # Перевірити налаштування
```

🔍 Статус та перегляд змін

```bash
git status                    # Поточний статус файлів
```

```bash
git diff                      # Показати зміни у файлах
```

```bash
git diff --staged             # Показати зміни, які додані до коміту
```

➕ Додавання файлів

```bash
git add file.txt              # Додати конкретний файл
```

```bash
git add .                     # Додати всі нові/зміненні файли
```

```bash
git add -u                    # Додати лише змінені та видалені (без нових)
```

✅ Коміти

```bash
git commit -m "Коментар"     # Зробити коміт з повідомленням
```

```bash
git commit --amend           # Виправити останній коміт
```

📂 Гілки

```bash
git branch                    # Показати всі гілки
```

```bash
git branch new-branch         # Створити нову гілку
```

```bash
git checkout new-branch       # Перейти на гілку
```

```bash
git checkout -b new-branch    # Створити і перейти одразу
```

⬆️ Відправлення та отримання

```bash
git remote add origin https://...   # Додати віддалений репозиторій
```

```bash
git push -u origin master           # Відправити перший раз з прив'язкою
```

```bash
git push                            # Надіслати зміни
```

```bash
git pull                            # Отримати останні зміни
```

🧹 Очистка

```bash
git clean -fd                      # Видалити untracked файли/папки
```

```bash
git reset HEAD file.txt           # Відмінити git add
```

```bash
git restore file.txt              # Повернути файл до попереднього стану
```

📘 Журнал

```bash
git log                            # Показати історію комітів
```

```bash
git log --oneline --graph         # Стисла історія з гілками
```

🔄 Скасування змін

```bash
git reset --soft HEAD~1           # Скасувати останній коміт (залишити зміни)
```

```bash
git reset --hard HEAD~1           # Скасувати коміт і зміни
```

```bash
git add -u
```

```bash
git add --update
```

## додати усе (включаючи нові файли).
```bash
git add .
```

## Теж додасть усе, включаючи нові, змінені, видалені.
```bash
git add -A
```

## додасть тільки вже відстежувані файли (modified або deleted).
```bash
git add -u
```