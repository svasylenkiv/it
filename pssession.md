# Щоб підключитися до Windows 11 Pro, який не в домені, через PowerShell, можна скористатися одним із таких варіантів:

### 🔹 Варіант 1: Підключення через PowerShell Remoting (WinRM)
✅ Кроки на віддаленій машині (Windows 11 Pro)
Увімкнути WinRM:

```powershell
Enable-PSRemoting -Force
```

Додати дозвіл для вхідних підключень по локальній мережі:

```powershell
Set-Item wsman:\localhost\client\trustedhosts -Value "*"  # або вкажи IP
```

Перевір, чи сервіс WinRM запущено:

```powershell
Get-Service WinRM
Start-Service WinRM
```

(Рекомендовано) Створити користувача, наприклад RemoteUser, і додати його до групи Administrators:

```powershell
net user RemoteUser "StrongPassword123" /add
net localgroup Administrators RemoteUser /add
```

### 🔹 Варіант 2: Підключення з іншої машини (локальна мережа)
На клієнтській машині (наприклад, твій робочий ПК):

```powershell
Enter-PSSession -ComputerName 192.168.1.50 -Credential (Get-Credential)
```

📝 Введи облікові дані користувача на віддаленій машині (наприклад RemoteUser)

## 🔐 Якщо машини не в домені:
Необхідно вимкнути перевірку SSL або використовувати HTTP (не HTTPS) для WinRM.

Для цього можна тимчасово дозволити небезпечні хости:

```powershell
Set-Item wsman:\localhost\Client\TrustedHosts -Value "IP або *"
```

🔍 Перевірити підключення:

```powershell
Test-WsMan 192.168.1.50
```
❗ Важливо
Windows Home не підтримує WinRM (тобто PowerShell Remoting не працюватиме).

Перевір, чи відкритий порт 5985 (HTTP) у брандмауері:

```powershell
netsh advfirewall firewall add rule name="WinRM" dir=in action=allow protocol=TCP localport=5985
```

Хочеш, я згенерую скрипт для автоматичної підготовки віддаленого хоста до підключення через PowerShell Remoting?