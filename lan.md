# 🛠 Вирішення помилки WinRM: "WinRM firewall exception will not work since one of the network connection types on this machine is set to Public"

## 🔍 Проблема

Під час спроби ввімкнути WinRM виникає помилка:
"WinRM firewall exception will not work since one of the network connection types on this machine is set to Public.
Change the network connection type to either Domain or Private and try again."


**Код помилки**: `0x80338169`

Це означає, що мережевий профіль вашого комп’ютера встановлений як `Public`, і WinRM не може внести зміни в брандмауер.

---

## ✅ Рішення

### ВАРІАНТ 1: Змінити мережевий профіль на Private через PowerShell

1. Відкрий PowerShell **від імені адміністратора**
2. Перевір поточні мережеві підключення:

```powershell
Get-NetConnectionProfile
```
3. Знайди мережу з типом `Public` і запам’ятай її `InterfaceIndex` або `Name`.
4. Зміни тип мережі на `Private`:

```powershell
Set-NetConnectionProfile -InterfaceIndex <InterfaceIndex> -NetworkCategory Private
```
АБО

```powershell
Set-NetConnectionProfile -Name "<Name>" -NetworkCategory Private
```
5. Перевір, чи змінився тип мережі:

```powershell
Get-NetConnectionProfile
```
### ВАРІАНТ 2: Змінити мережевий профіль на Private через GUI
1. Відкрий **Параметри** (Win + I).
2. Перейди до **Мережа та Інтернет**.
3. Вибери **Ethernet** або **Wi-Fi** (залежно від твого підключення).
4. Клацни на назву мережі, до якої ти підключений.
5. Знайди параметр **Профіль мережі** і вибери **Приватна**.
### ВАРІАНТ 3: Змінити мережевий профіль на Private через реєстр
1. Відкрий **Редактор реєстру** (regedit).
2. Перейдіть до ключа:
```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
```
3. Знайди профіль мережі, який має тип `Public`.
4. Змініть значення `Category` з `0` (Public) на `1` (Private).
5. Перезавантаж комп'ютер.
### ВАРІАНТ 4: Використати команду для зміни мережевого профілю
1. Відкрий **Командний рядок** від імені адміністратора.
2. Виконай команду:

```cmd
netsh interface set interface name="<Name>" newname="<NewName>" admin=enabled
```
3. Заміни `<Name>` на назву твого мережевого інтерфейсу, а `<NewName>` на бажане ім'я.
### ВАРІАНТ 5: Використати групову політику
1. Відкрий **Редактор групових політик** (gpedit.msc).
2. Перейди до **Конфігурація комп'ютера** > **Адміністративні шаблони** > **Мережа** > **Параметри мережі**.
3. Знайди політику **Змінити тип мережі на Приватна**.
4. Встанови її в **Увімкнено**.
5. Застосуй зміни та перезавантаж комп'ютер.
### ВАРІАНТ 6: Використати сценарій PowerShell
1. Створи файл `ChangeNetworkProfile.ps1` з наступним вмістом:

```powershell
$network = Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' }
if ($network) {
    Set-NetConnectionProfile -InterfaceIndex $network.InterfaceIndex -NetworkCategory Private
    Write-Host "Network profile changed to Private."
} else {
    Write-Host "No Public network profile found."
}
```