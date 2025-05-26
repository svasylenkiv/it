# Щоб активувати правило "Віддалений робочий стіл — режим користувача (TCP-ввід)" у Windows Defender Firewall, виконай один із наступних способів:

### 🔹 Спосіб 1: Через PowerShell
```powershell
This command enables a specific firewall rule in Windows Defender Firewall by its display name.
Enable-NetFirewallRule -DisplayName "Віддалений робочий стіл — режим користувача (TCP-ввід)"
```

Якщо система англомовна, використай:
```powershell
Enable-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)"
```

### 🔹 Спосіб 2: Через командний рядок (cmd)

```cmd
netsh advfirewall firewall set rule name="Remote Desktop - User Mode (TCP-In)" new enable=yes
```

### 🔹 Спосіб 3: Через графічний інтерфейс (GUI)

1. Відкрий "Windows Defender Firewall with Advanced Security"
    Натисни Win + R, введи wf.msc, натисни Enter.

2. У лівому меню обери:
    "Inbound Rules" / "Вхідні правила".

3. У списку знайди правило:
    "Remote Desktop - User Mode (TCP-In)" або українською "Віддалений робочий стіл — режим користувача (TCP-ввід)".

4. Перевір, чи воно має статус "Disabled" / "Вимкнено".

5. Клікни правою кнопкою по правилу → обери "Enable Rule" / "Увімкнути правило".