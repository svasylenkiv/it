## GitHub CLI (gh) — шпаргалка

### 🔹 Аутентифікація
`gh auth login`

(далі обираєш GitHub.com, HTTPS, браузер для входу)

---

### 🔹 Репозиторії

Клонувати:
```bash
gh repo clone user/repo
```

Створити новий:
```bash
gh repo create my-repo --public --source=. --push
```

---

### 🔹 Pull Requests

Створити PR:
```bash
gh pr create --title "Новий PR" --body "Опис змін"
```

Список PR:
```bash
gh pr list
```

Переглянути PR:
```bash
gh pr view 123
```

Змерджити PR:
```bash
gh pr merge 123 --squash --delete-branch
```

---

### 🔹 Issues

Створити issue:
```bash
gh issue create --title "Баг" --body "Опис проблеми"
```

Список:
```bash
gh issue list
```

Переглянути issue:
```bash
gh issue view 123
```

---

### 🔹 Secrets & Variables

Додати секрет:
```bash
gh secret set AWS_SECRET_ACCESS_KEY --body "value"
```

Додати змінну:
```bash
gh variable set ENVIRONMENT --body "dev"
```

Список:
```bash
gh secret list
gh variable list
```

---

### 🔹 Actions

Запустити workflow вручну:
```bash
gh workflow run deploy.yml
```

Список workflow:
```bash
gh workflow list
```

Переглянути останні джоби:
```bash
gh run list
gh run view 123456789
```

---

🚀 Таким чином git = робота з локальним репо, а gh = керування GitHub API (репо, PR-и, секрети, воркфлови).