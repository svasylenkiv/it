### ✅ 1. Створити кілька папок одночасно
```powershell
New-Item -Path "dir1","dir2","dir3" -ItemType Directory
```

Або з mkdir:

```powershell
mkdir dir1,dir2,dir3
```

### ✅ 2. Створити вкладені папки
```powershell
New-Item -Path "devops/aws/terraform" -ItemType Directory -Force
New-Item -Path "admin/ad-management" -ItemType Directory -Force
```
-Force створює також проміжні каталоги, якщо вони ще не існують.

### ✅ 3. Зі списком у масиві
```powershell
$folders = @("devops", "admin", "shared", "docs")
foreach ($folder in $folders) {
    New-Item -Path $folder -ItemType Directory -Force
}
```

### ✅ 4. Створити підпапки в кожній основній папці
```powershell
$structure = @{
    "devops"        = @("aws", "azure", "docker", "kubernetes")
    "windows-admin" = @("ad-management", "powershell-scripts", "automation")
    "shared"        = @("snippets", "utils")
}

foreach ($parent in $structure.Keys) {
    foreach ($child in $structure[$parent]) {
        New-Item -Path "$parent\$child" -ItemType Directory -Force
    }
}
```
