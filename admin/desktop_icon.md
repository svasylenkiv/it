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

# Windows Server 2019 

```powershell
$code = @"
[DllImport("user32.dll")]
public static extern bool SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@

Add-Type -MemberDefinition $code -Name WinAPI -Namespace User32

# Увімкнути значки: This PC, User Files, Network, Recycle Bin, Control Panel (значення 0x1F)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 0  # This PC
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value 0  # User Files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{208D2C60-3AEA-1069-A2D7-08002B30309D}' -Value 0  # Network
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value 0  # Recycle Bin
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}' -Value 0  # Control Panel

# Перезапустити оболонку (explorer), щоб застосувалося
Stop-Process -Name explorer -Force
Start-Process explorer.exe
```