### Щоб включити IIS (Internet Information Services) через PowerShell у Windows, виконай наступні команди від імені адміністратора:

## 🧰 1. Встановити IIS:
```powershell
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
```
Ця команда встановлює веб-сервер (IIS) разом із інструментами керування (IIS Manager тощо).

## ✅ 2. Перевірити, чи встановлено IIS:
```powershell
Get-WindowsFeature -Name Web-Server
```
У стовпці Installed має бути True.

## 🔄 3. Перезапустити IIS (опційно):
```powershell
iisreset
```
Це перезапустить веб-сервер (усі сайти).

### 📍Корисні модулі PowerShell для IIS:
Щоб мати доступ до додаткових IIS командлетів:
```powershell
Import-Module WebAdministration
```
### 📂 Додаткові команди для роботи з IIS:
```powershell
# Список всіх сайтів
Get-Website
# Створення нового сайту
New-Website -Name "MinimalApp" -Port 5000 -PhysicalPath "C:\inetpub\wwwroot\MinimalApp"
# Запуск сайту
Start-Website -Name "MinimalApp"
# Зупинка сайту
Stop-Website -Name "MinimalApp"
# Видалення сайту
Remove-Website -Name "MinimalApp"
```
### 📖 Документація:
Для більш детальної інформації про IIS та його налаштування, відвідай офіційну документацію Microsoft:
[Документація IIS](https://docs.microsoft.com/en-us/iis/)
### 🛠️ Налаштування IIS через PowerShell:
```powershell
# Додавання модуля для керування IIS
Import-Module WebAdministration
# Перевірка статусу IIS
Get-Service W3SVC
# Запуск служби IIS
Start-Service W3SVC
# Зупинка служби IIS
Stop-Service W3SVC
# Перезапуск служби IIS
Restart-Service W3SVC
# Отримання інформації про всі сайти
Get-Website
# Отримання інформації про конкретний сайт
Get-Website -Name "Default Web Site"
# Створення нового сайту
New-Website -Name "MyNewSite" -Port 8080 -PhysicalPath "C:\inetpub\wwwroot\MyNewSite"
# Видалення сайту
Remove-Website -Name "MyNewSite"
# Зміна порту сайту
Set-ItemProperty "IIS:\Sites\Default Web Site" -Name "bindings" -Value @{protocol="http";bindingInformation="*:8080:"}
# Додавання нового віртуального каталогу
New-WebVirtualDirectory -Site "Default Web Site" -Name "MyVirtualDir" -PhysicalPath "C:\inetpub\wwwroot\MyVirtualDir"
# Видалення віртуального каталогу
Remove-WebVirtualDirectory -Site "Default Web Site" -Name "MyVirtualDir"
# Отримання журналів IIS
Get-ChildItem "C:\inetpub\logs\LogFiles"
# Перегляд журналів IIS
Get-Content "C:\inetpub\logs\LogFiles\W3SVC1\u_ex*.log" | Select-Object -Last 10
```
### 📝 Примітки:
- Переконайся, що ти запускаєш PowerShell від імені адміністратора для виконання цих команд.
- Для налаштування брандмауера Windows, щоб дозволити трафік на порту 80 або 443, можеш використовувати такі команди:
```powershell
New-NetFirewallRule -DisplayName "IIS HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName "IIS HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow
```
### 📌 Додаткові ресурси:
- [Офіційна документація Microsoft по IIS](https://docs.microsoft.com/en-us/iis/)
- [Керівництво по PowerShell для IIS](https://docs.microsoft.com/en-us/powershell/module/webadministration/)
### 🛡️ Безпека:
Перед відкриттям доступу до IIS ззовні, переконайся, що ти налаштував безпеку, включаючи SSL для HTTPS, обмеження доступу та моніторинг журналів.
### 🖥️ Налаштування SSL для IIS:
```powershell
# Імпортування SSL сертифікату
Import-PfxCertificate -FilePath "C:\path\to\your\certificate.pfx" -CertStoreLocation "cert:\LocalMachine\My"
# Додавання SSL прив'язки до сайту
New-WebBinding -Name "Default Web Site" -Protocol "https" -Port 443 -CertificateThumbprint "YOUR_CERTIFICATE_THUMBPRINT" -CertificateStoreName "My"
# Перевірка прив'язок сайту
Get-WebBinding -Name "Default Web Site"
# Видалення SSL прив'язки
Remove-WebBinding -Name "Default Web Site" -Protocol "https" -Port 443
```
### 🗂️ Структура каталогів IIS:
```plaintext
C:\inetpub\wwwroot\        # Основний каталог для веб-сайтів
C:\inetpub\logs\LogFiles\  # Каталог для журналів IIS
C:\inetpub\temp\IIS Temporary Compressed Files\  # Тимчасові файли стиснення
C:\inetpub\history\        # Історія змін конфігурації IIS
```