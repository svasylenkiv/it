# Щоб перевірити, чи відкритий порт RDP (порт 3389), ти можеш використати один з наступних методів:

###🔹 1. Через PowerShell з іншого комп'ютера
```powershell
Test-NetConnection -ComputerName <IP_адреса_або_ім’я_хоста> -Port 3389
```

Приклад:
```powershell
Test-NetConnection -ComputerName 192.168.1.10 -Port 3389
```

✅ Якщо порт відкритий — ти побачиш TcpTestSucceeded : True
❌ Якщо закритий — TcpTestSucceeded : False

🔹 2. Через Telnet (за потреби увімкнути цю функцію)
```cmd
telnet <IP_адреса_або_ім’я_хоста> 3389
```

Приклад:
```cmd
telnet 192.168.1.10 3389
```

➡️ Якщо екран стане чорним — з'єднання встановлено. Якщо буде помилка — порт закритий або заблокований.

## Щоб увімкнути Telnet:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient
```

### 🔹 3. З локального комп’ютера (чи увімкнений RDP)
```powershell
Get-NetFirewallRule -DisplayName '*RDP*' | Where-Object {$_.Enabled -eq 'True'}
```

або

```powershell
Get-NetTCPConnection -LocalPort 3389
```

### 🔹 4. Через онлайн-сервіси (якщо це публічна IP-адреса)
https://www.yougetsignal.com/tools/open-ports/

Введи публічну IP-адресу й порт 3389.

## 🔐 Нагадування з безпеки:
Якщо RDP відкритий на публічний інтернет — використовуй MFA, VPN або обмежуй доступ за IP, щоб уникнути атак.

Якщо хочеш — можу допомогти налаштувати безпечний доступ.







