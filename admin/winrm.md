# Щоб увімкнути WinRM у PowerShell, виконай наступні кроки — вони підходять як для робочих станцій, так і для серверів:

## Перевірити мережевий профіль
```powershell
Get-NetConnectionProfile
```

## Якщо мережевий профіль встановлено як Public, WinRM не зможе внести зміни в брандмауер.
## Змінити мережевий профіль на Private
```powershell
Set-NetConnectionProfile -NetworkCategory Private
```
# Або, якщо потрібно вказати конкретний інтерфейс
```powershell
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private
```

### ✅ 1. Запусти PowerShell як адміністратор
### ✅ 2. Увімкни службу WinRM
```powershell
winrm quickconfig
```
## Якщо все гаразд, то winrm сам налаштує Windows Firewall. Включивши дане правило:
```plaintext 
Віддалене керування Windows – (HTTP-ввід)
```
### ✅ 3. (Опційно) Дозволь Basic-автентифікацію (небезпечно)
```powershell
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
```
## Увага: якщо ти використовуєш Basic, потрібно також увімкнути незашифрований трафік:
```powershell
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
```
## 🔒 Це небезпечно для продуктивних систем — використовуй HTTPS для безпечного з'єднання.
### ✅ 4. Перевір, чи WinRM працює
```powershell
Test-WsMan
```













```powershell
Enable-PSRemoting -Force
```
Ця команда:
запускає службу WinRM;
створює слухач на HTTP (порт 5985);
додає виключення в брандмауер;
дозволяє вхідні підключення.

### ✅ 3. Перевір, чи WinRM працює
```powershell
Test-WsMan
```
Успішне виконання без помилок означає, що WinRM працює.

⚠️ Якщо комп'ютер не в домені — додай хост до TrustedHosts:
```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"
```
🔐 Або вкажи конкретний IP/хост:
```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.0.101"
```
### ✅ 5. (Опційно) Відкрий порт у брандмауері
```powershell
New-NetFirewallRule -Name "_Allow_WinRM_HTTP" -DisplayName "WinRM over HTTP" -Protocol TCP -LocalPort 5985 -Action Allow
```

## 🔁 Повторна активація (якщо раніше було вимкнено)
```powershell
winrm quickconfig
```
### ###########################################










🛠 Можливі причини та рішення:
🔒 1. WinRM не налаштований або не працює на машині
Перевірте, чи служба WinRM запущена на Windows-сервері:

```powershell
Get-Service WinRM
```
Якщо не запущена:
```powershell
Start-Service WinRM
```
Перевірте, чи створений HTTPS listener (порт 5986):
```powershell
winrm enumerate winrm/config/Listener
```

Якщо його немає, створіть:
```powershell
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="hostname";CertificateThumbprint="THUMBPRINT"}

🔐 2. Немає SSL-сертифікату для WinRM HTTPS
WinRM через HTTPS вимагає SSL-сертифікат. Перевірте, чи встановлений коректний сертифікат у Cert:\LocalMachine\My.

Можна створити самопідписаний:

```powershell
New-SelfSignedCertificate -DnsName "hostname" -CertStoreLocation Cert:\LocalMachine\My
```
Після цього додайте thumbprint у Listener (див. п.1).

🌐 3. Порт 5986 заблокований між машинами
З комп’ютера, з якого запускаєш Ansible:

```bash
nc -zv 192.168.0.30 5986
```
або:
```bash
telnet 192.168.0.30 5986
```

Якщо порт закритий — відкрий у Windows Firewall:
```powershell
New-NetFirewallRule -Name "AllowWinRM" -DisplayName "Allow WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -Protocol TCP -LocalPort 5986
```
⚙️ 4. WinRM не налаштований на дозволи віддаленого доступу
Запусти:
```powershell
Set-NetConnectionProfile -NetworkCategory Private
```
Потім налаштуй WinRM:

```cmd
winrm quickconfig -q
winrm set winrm/config/service @{AllowUnencrypted="false"}
winrm set winrm/config/service/auth @{Basic="true"}
```
📋 5. Ansible неправильно налаштовано
У inventory або host_vars для LHC-101 повинно бути:

yaml
Копіювати
Редагувати
ansible_connection: winrm
ansible_winrm_transport: basic
ansible_port: 5986
ansible_winrm_server_cert_validation: ignore
ansible_user: your_username
ansible_password: your_password