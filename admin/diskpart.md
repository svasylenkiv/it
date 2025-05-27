# 🧹 Очистка диска за допомогою DiskPart

Цей приклад показує, як очистити флешку або інший диск у Windows за допомогою **DiskPart**.

## 🔧 Виконані кроки

```bash
diskpart
```

1. 📋 Перелік дисків
```bash
list disk
```

2. 🎯 Вибір диска (наприклад, USB флешки)
```bash
select disk 1
```
3. 🗑️ Очистка диска
```bash
clean
```
4. 📝 Створення нового розділу
```bash
create partition primary
```
5. 📂 Форматування розділу
```bash
format fs=ntfs quick
```
6. 🏷️ Присвоєння літери диска
```bash
assign letter=E
```
7. 🚀 Вихід з DiskPart
```bash
exit
```
## ⚠️ Увага
Будьте обережні при використанні команди `clean`, оскільки вона видаляє всі дані на вибраному диску. Переконайтеся, що ви вибрали правильний диск, щоб уникнути втрати важливих даних.
## 📌 Додаткова інформація
Для отримання додаткової інформації про DiskPart, ви можете скористатися командою:
```bash
help
```
## 📖 Документація
Для більш детальної інформації про DiskPart, ви можете звернутися до офіційної документації Microsoft:
[DiskPart documentation](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/diskpart)
## 🛠️ Приклад використання
```bash
diskpart
list disk
select disk 1
clean
create partition primary
format fs=ntfs quick
assign letter=E
exit
```
## 📖 Додаткові команди DiskPart
```bash
list volume
list partition
select volume 1
delete partition
extend
shrink desired=100
```
## 📜 Пояснення команд
- `list disk`: Показує список всіх дисків, підключених до системи.
- `select disk 1`: Вибирає диск з номером 1 для подальших операцій.
- `clean`: Видаляє всі розділи та дані на вибраному диску.
- `create partition primary`: Створює новий первинний розділ на вибраному диску.
- `format fs=ntfs quick`: Форматує новий розділ у файлову систему NTFS з використанням швидкого формату.
- `assign letter=E`: Присвоює літеру E новому розділу, щоб його можна було використовувати в системі.
- `exit`: Виходить з DiskPart.
## 📚 Додаткові ресурси

-[DiskPart](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/diskpart)
- [DiskPart scripting and examples](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/diskpart-scripts-and-examples)
## 📌 Примітки
- Перед виконанням команд DiskPart, переконайтеся, що ви маєте резервні копії важливих даних.
- Використовуйте DiskPart з обережністю, оскільки деякі команди можуть призвести до втрати даних.
- Якщо ви не впевнені у своїх діях, зверніться до фахівця або скористайтеся графічним інтерфейсом для управління дисками.
## 📝 Заключні думки
DiskPart є потужним інструментом для управління дисками в Windows. Використовуйте його з обережністю та завжди перевіряйте, що ви робите, щоб уникнути втрати даних. Якщо ви не впевнені у своїх діях, краще звернутися до фахівця або скористатися графічним інтерфейсом для управління дисками.
