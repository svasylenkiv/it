# ===========================
# 🔧 Конфігураційні змінні
# ===========================
$SiteName = "TaskApp"
$SitePort = 80
$SitePath = "D:\TaskApp"

$SitePath = "C:\inetpub\wwwroot\MinimalApp"

# ===========================
# 🌐 Створення нового сайту
# ===========================
New-Website -Name $SiteName -Port $SitePort -PhysicalPath $SitePath

# ===========================
# ▶️ Запуск сайту
# ===========================
Start-Website -Name $SiteName

# ===========================
# ⏹ Зупинка сайту
# ===========================
Stop-Website -Name $SiteName

# ===========================
# ❌ Видалення сайту
# ===========================
Remove-Website -Name $SiteName
