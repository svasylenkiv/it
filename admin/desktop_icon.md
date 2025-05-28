# Шлях до потрібного ключа
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

# Якщо ключа не існує — створюємо
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Значення: 0 = Показати, 1 = Приховати
$icons = @{
    'This PC'        = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
	'Control Panel'  = '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'
}

foreach ($icon in $icons.GetEnumerator()) {
    Set-ItemProperty -Path $regPath -Name $icon.Value -Value 0
    Write-Host "$($icon.Key) icon enabled."
}

# Перезапуск explorer для застосування
Stop-Process -Name explorer -Force
Start-Process explorer
