# PowerShell скрипт для встановлення та налаштування Pulumi на Windows 11
# Запустіть цей скрипт від імені адміністратора

Write-Host "🚀 Встановлення Pulumi на Windows 11" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Перевірка чи запущений скрипт від адміністратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Цей скрипт повинен бути запущений від імені адміністратора!" -ForegroundColor Red
    Write-Host "Спробуйте запустити PowerShell як адміністратор і виконайте скрипт знову." -ForegroundColor Yellow
    exit 1
}

# Функція для перевірки чи встановлена програма
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Функція для встановлення через winget
function Install-WingetPackage($packageName, $displayName) {
    if (Test-Command $packageName) {
        Write-Host "✅ $displayName вже встановлено" -ForegroundColor Green
        return $true
    }
    
    Write-Host "📦 Встановлення $displayName..." -ForegroundColor Yellow
    try {
        winget install $packageName --accept-source-agreements --accept-package-agreements
        if (Test-Command $packageName) {
            Write-Host "✅ $displayName успішно встановлено" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "❌ Помилка встановлення $displayName" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Помилка встановлення $displayName: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Перевірка чи встановлений winget
if (-not (Test-Command winget)) {
    Write-Host "❌ winget не встановлено. Встановіть App Installer з Microsoft Store." -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Перевірка та встановлення необхідних компонентів..." -ForegroundColor Blue

# Встановлення Git
$gitInstalled = Install-WingetPackage "Git.Git" "Git"

# Встановлення Node.js
$nodeInstalled = Install-WingetPackage "OpenJS.NodeJS" "Node.js"

# Встановлення Python
$pythonInstalled = Install-WingetPackage "Python.Python.3.11" "Python 3.11"

# Встановлення AWS CLI
$awsInstalled = Install-WingetPackage "Amazon.AWSCLI" "AWS CLI"

# Встановлення Azure CLI
$azureInstalled = Install-WingetPackage "Microsoft.AzureCLI" "Azure CLI"

# Встановлення Pulumi
$pulumiInstalled = Install-WingetPackage "Pulumi.Pulumi" "Pulumi"

# Оновлення PATH
Write-Host "🔄 Оновлення змінної PATH..." -ForegroundColor Yellow
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

# Перевірка встановлених версій
Write-Host "`n📋 Перевірка встановлених версій:" -ForegroundColor Blue

if ($gitInstalled) {
    $gitVersion = git --version 2>$null
    Write-Host "Git: $gitVersion" -ForegroundColor Green
}

if ($nodeInstalled) {
    $nodeVersion = node --version 2>$null
    $npmVersion = npm --version 2>$null
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "npm: $npmVersion" -ForegroundColor Green
}

if ($pythonInstalled) {
    $pythonVersion = python --version 2>$null
    $pipVersion = pip --version 2>$null
    Write-Host "Python: $pythonVersion" -ForegroundColor Green
    Write-Host "pip: $pipVersion" -ForegroundColor Green
}

if ($awsInstalled) {
    $awsVersion = aws --version 2>$null
    Write-Host "AWS CLI: $awsVersion" -ForegroundColor Green
}

if ($azureInstalled) {
    $azureVersion = az version --output table 2>$null
    Write-Host "Azure CLI: встановлено" -ForegroundColor Green
}

if ($pulumiInstalled) {
    $pulumiVersion = pulumi version 2>$null
    Write-Host "Pulumi: $pulumiVersion" -ForegroundColor Green
}

# Створення директорії для проектів
$projectsDir = "$env:USERPROFILE\pulumi-projects"
if (-not (Test-Path $projectsDir)) {
    New-Item -ItemType Directory -Path $projectsDir | Out-Null
    Write-Host "📁 Створено директорію для проектів: $projectsDir" -ForegroundColor Green
}

# Створення конфігураційного файлу для VS Code
$vscodeSettingsDir = "$env:APPDATA\Code\User"
if (-not (Test-Path $vscodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vscodeSettingsDir -Force | Out-Null
}

$vscodeSettings = @{
    "terminal.integrated.defaultProfile.windows"           = "PowerShell"
    "terminal.integrated.profiles.windows"                 = @{
        "PowerShell" = @{
            "source" = "PowerShell"
            "args"   = @("-NoExit", "-Command", "cd $projectsDir")
        }
    }
    "files.associations"                                   = @{
        "*.ts"   = "typescript"
        "*.yaml" = "yaml"
        "*.yml"  = "yaml"
    }
    "typescript.preferences.includePackageJsonAutoImports" = "on"
}

$vscodeSettingsPath = "$vscodeSettingsDir\settings.json"
$vscodeSettings | ConvertTo-Json -Depth 10 | Set-Content $vscodeSettingsPath
Write-Host "⚙️ Налаштовано VS Code для роботи з Pulumi" -ForegroundColor Green

# Створення швидких команд
Write-Host "`n📝 Створення швидких команд..." -ForegroundColor Blue

$quickCommands = @"
# Швидкі команди для роботи з Pulumi
function New-PulumiProject {
    param([string]`$ProjectName, [string]`$Template = "aws-typescript")
    `$projectPath = "$projectsDir\`$ProjectName"
    if (Test-Path `$projectPath) {
        Write-Host "❌ Проект `$ProjectName вже існує!" -ForegroundColor Red
        return
    }
    mkdir `$projectPath
    cd `$projectPath
    pulumi new `$Template
    Write-Host "✅ Проект `$ProjectName створено в `$projectPath" -ForegroundColor Green
}

function Start-PulumiDemo {
    cd "$projectsDir"
    if (Test-Path "pulumi-demo") {
        Write-Host "❌ Проект pulumi-demo вже існує!" -ForegroundColor Red
        return
    }
    mkdir pulumi-demo
    cd pulumi-demo
    pulumi new aws-typescript
    Write-Host "✅ Демо проект створено. Перейдіть в директорію та виконайте 'npm install'" -ForegroundColor Green
}

function Show-PulumiStatus {
    Write-Host "=== Статус Pulumi ===" -ForegroundColor Cyan
    Write-Host "Pulumi версія: $(pulumi version)" -ForegroundColor Green
    Write-Host "Поточний стек: $(pulumi stack --show-name 2>`$null)" -ForegroundColor Green
    Write-Host "Всі стеки: $(pulumi stack ls 2>`$null)" -ForegroundColor Green
}

# Експорт функцій
Export-ModuleMember -Function New-PulumiProject, Start-PulumiDemo, Show-PulumiStatus
"@

$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$profileDir = Split-Path $profilePath -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$quickCommands | Out-File -FilePath $profilePath -Append -Encoding UTF8
Write-Host "✅ Додано швидкі команди до PowerShell profile" -ForegroundColor Green

# Створення README файлу
$readmeContent = @"
# Pulumi на Windows 11 - Швидкий старт

## Встановлені компоненти:
- ✅ Git
- ✅ Node.js
- ✅ Python 3.11
- ✅ AWS CLI
- ✅ Azure CLI
- ✅ Pulumi

## Швидкі команди:
- `New-PulumiProject "my-project"` - створити новий проект
- `Start-PulumiDemo` - створити демо проект
- `Show-PulumiStatus` - показати статус Pulumi

## Наступні кроки:

### 1. Налаштування AWS (якщо використовуєте AWS):
```powershell
aws configure
```

### 2. Створення першого проекту:
```powershell
New-PulumiProject "my-first-project"
cd my-first-project
npm install
pulumi preview
```

### 3. Розгортання:
```powershell
pulumi up
```

## Корисні посилання:
- [Pulumi Documentation](https://www.pulumi.com/docs/)
- [AWS Provider](https://www.pulumi.com/registry/packages/aws/)
- [Azure Provider](https://www.pulumi.com/registry/packages/azure/)

## Директорія проектів:
$projectsDir

Створено: $(Get-Date)
"@

$readmePath = "$projectsDir\README.md"
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8

Write-Host "`n🎉 Встановлення завершено успішно!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "📁 Проекти будуть створюватися в: $projectsDir" -ForegroundColor Cyan
Write-Host "📖 README файл: $readmePath" -ForegroundColor Cyan
Write-Host "`n🚀 Готово до роботи з Pulumi!" -ForegroundColor Green

Write-Host "`n💡 Поради:" -ForegroundColor Yellow
Write-Host "- Перезапустіть PowerShell для завантаження нових команд" -ForegroundColor White
Write-Host "- Використовуйте 'New-PulumiProject' для створення нових проектів" -ForegroundColor White
Write-Host "- Налаштуйте AWS credentials перед першим використанням" -ForegroundColor White

Write-Host "`nНатисніть будь-яку клавішу для завершення..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
