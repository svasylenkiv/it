Якщо отримуєш помилку
![alt text](image.png)

зміни remote URL на SSH
Зараз у тебе стоїть HTTPS URL:

```bash
https://github.com/svasylenkiv/it.git
```

Треба змінити його на SSH URL:
```bash
git remote set-url origin git@github.com:svasylenkiv/it.git
```

🔁 Перевір:
```bash
git remote -v
```