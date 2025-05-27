# 💽 Ініціалізація нового диска в Windows

Цей файл описує три способи ініціалізації нового жорсткого диска або SSD у Windows:

---

## 🔧 1. Через PowerShell

### Знайти неініціалізовані диски
```powershell
Get-Disk | Where-Object PartitionStyle -Eq 'RAW'
```
### Ініціалізувати диск (наприклад, диск №1)
```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
```
### Створити розділ, присвоїти літеру і відформатувати
```powershell
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter | `
Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false
```

> 🔎 *PartitionStyle може бути: `GPT` або `MBR`. GPT — рекомендований для сучасних систем.*

---

## 🧱 2. Через DiskPart (CLI)

```cmd
diskpart
```
### Усередині інтерфейсу DiskPart:
```diskpart
list disk
```
# Вибери диск, який потрібно ініціалізувати
```diskpart
select disk 1
```
# Очистить всі дані на диску
```diskpart
clean
```
### Вибери стиль розділу (GPT або MBR)
```diskpart
convert gpt
```
```diskpart
create partition primary
```
```diskpart
format fs=ntfs quick
```
### Присвоїти літеру диску
```diskpart
assign letter=E
```
```diskpart
exit
```

> ⚠️ Команда `clean` повністю видаляє всі дані на диску. Будь уважним.

---

## 🖱 3. Через графічний інтерфейс (Disk Management)

1. Натисни **Win + X** → **Disk Management** (або введи `diskmgmt.msc` у вікні `Win + R`).
2. Знайди диск з позначкою *"Not Initialized"*.
3. Натисни **праву кнопку миші** → **Initialize Disk**.
4. Вибери GPT або MBR.
5. Потім створи **New Simple Volume**, присвой літеру диску і відформатуй.

---

## 🏷 Позначки

- **GPT (GUID Partition Table)** — рекомендовано для нових ПК та дисків > 2ТБ.
- **MBR (Master Boot Record)** — старіший формат для сумісності з Legacy BIOS.

---
