# 🛠 Встановлення програм без Chocolatey через PowerShell

Цей документ містить PowerShell-команди для безшумного встановлення популярних програм вручну.

---

## 🚀 Google Chrome Canary

```powershell
$canaryInstaller = "$env:TEMP\chrome_canary_installer.exe"
Invoke-WebRequest -Uri "https://dl.google.com/tag/s/appguid%3D%7B4DC8B4CA-1BDA-483e-B5FA-D3C12E15B62D%7D&iid=&lang=en&browser=4&usagestats=0&appname=Chrome%20Canary&needsadmin=prefers/dl/chrome/install/canary/ChromeSetup.exe" -OutFile $canaryInstaller

Start-Process -FilePath $canaryInstaller -Args "/silent /install" -Wait
Remove-Item $canaryInstaller
```
## 🚀 Microsoft Edge Canary

```powershell
$edgeCanaryInstaller = "$env:TEMP\edge_canary_installer.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2135547" -OutFile $edgeCanaryInstaller
Start-Process -FilePath $edgeCanaryInstaller -Args "/silent /install" -Wait
Remove-Item $edgeCanaryInstaller
```
## 🚀 Microsoft Edge Dev

```powershell
$edgeDevInstaller = "$env:TEMP\edge_dev_installer.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2135548" -OutFile $edgeDevInstaller
Start-Process -FilePath $edgeDevInstaller -Args "/silent /install" -Wait
Remove-Item $edgeDevInstaller
```
## 🚀 Microsoft Edge Beta

```powershell
$edgeBetaInstaller = "$env:TEMP\edge_beta_installer.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2135549" -OutFile $edgeBetaInstaller
Start-Process -FilePath $edgeBetaInstaller -Args "/silent /install" -Wait
Remove-Item $edgeBetaInstaller
```
## 🚀 Microsoft Edge Stable

```powershell
$edgeStableInstaller = "$env:TEMP\edge_stable_installer.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2135546" -OutFile $edgeStableInstaller
Start-Process -FilePath $edgeStableInstaller -Args "/silent /install" -Wait
Remove-Item $edgeStableInstaller
```
## 🚀 Microsoft Edge Legacy

```powershell
$edgeLegacyInstaller = "$env:TEMP\edge_legacy_installer.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2135545" -OutFile $edgeLegacyInstaller
Start-Process -FilePath $edgeLegacyInstaller -Args "/silent /install" -Wait
Remove-Item $edgeLegacyInstaller
```

## 🚀 Microsoft Edge

```powershell
$edgeInstaller = "$env:TEMP\edge_installer.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2135544" -OutFile $edgeInstaller
Start-Process -FilePath $edgeInstaller -Args "/silent /install" -Wait
Remove-Item $edgeInstaller
```
## 🚀 Microsoft Visual Studio Code

```powershell
$vsCodeInstaller = "$env:TEMP\vscode_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/win32-x64-user-stable" -OutFile $vsCodeInstaller
Start-Process -FilePath $vsCodeInstaller -Args "/silent /install" -Wait
Remove-Item $vsCodeInstaller
```
## 🚀 Microsoft Visual Studio Community

```powershell
$vsCommunityInstaller = "$env:TEMP\vs_community_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_community.exe" -OutFile $vsCommunityInstaller
Start-Process -FilePath $vsCommunityInstaller -Args "--quiet --wait --norestart" -Wait
Remove-Item $vsCommunityInstaller
```
## 🚀 Microsoft Visual Studio Professional

```powershell
$vsProfessionalInstaller = "$env:TEMP\vs_professional_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_professional.exe" -OutFile $vsProfessionalInstaller
Start-Process -FilePath $vsProfessionalInstaller -Args "--quiet --wait --norestart" -Wait
Remove-Item $vsProfessionalInstaller
```
## 🚀 Microsoft Visual Studio Enterprise

```powershell
$vsEnterpriseInstaller = "$env:TEMP\vs_enterprise_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_enterprise.exe" -OutFile $vsEnterpriseInstaller
Start-Process -FilePath $vsEnterpriseInstaller -Args "--quiet --wait --norestart" -Wait
Remove-Item $vsEnterpriseInstaller
```
## 🚀 Microsoft Visual Studio Build Tools

```powershell
$vsBuildToolsInstaller = "$env:TEMP\vs_build_tools_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile $vsBuildToolsInstaller
Start-Process -FilePath $vsBuildToolsInstaller -Args "--quiet --wait --norestart" -Wait
Remove-Item $vsBuildToolsInstaller
```
## 🚀 Microsoft Visual Studio Installer

```powershell
$vsInstaller = "$env:TEMP\vs_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_installer.exe" -OutFile $vsInstaller
Start-Process -FilePath $vsInstaller -Args "--quiet --wait --norestart" -Wait
Remove-Item $vsInstaller
```
## 🚀 Microsoft Visual Studio 2022

```powershell
$vs2022Installer = "$env:TEMP\vs2022_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_community.exe" -OutFile $vs2022Installer
Start-Process -FilePath $vs2022Installer -Args "--quiet --wait --norestart" -Wait
Remove-Item $vs2022Installer
```
## 🚀 Microsoft Visual Studio 2019

```powershell
$vs2019Installer = "$env:TEMP\vs2019_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/16/release/vs_community.exe" -OutFile $vs2019Installer
Start-Process -FilePath $vs2019Installer -Args "--quiet --wait --norestart" -Wait
Remove-Item $vs2019Installer
```
## 🚀 Microsoft Visual Studio 2017

```powershell
$vs2017Installer = "$env:TEMP\vs2017_installer.exe"
Invoke-WebRequest -Uri "https://aka.ms/vs/15/release/vs_community.exe" -OutFile $vs2017Installer
Start-Process -FilePath $vs2017Installer -Args "--quiet --wait --norestart" -Wait
Remove-Item $vs2017Installer
```
## 🚀 Microsoft Visual Studio 2015

```powershell
$vs2015Installer = "$env:TEMP\vs2015_installer.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/0/2/102A6F7B-3D8C-4B9E-8F5A-3D1B0F2E4C6B/vs_community.exe" -OutFile $vs2015Installer
Start-Process -FilePath $vs2015Installer -Args "--quiet --wait --norestart" -Wait
Remove-Item $vs2015Installer
```
## 🚀 Microsoft Visual Studio 2013

```powershell
$vs2013Installer = "$env:TEMP\vs2013_installer.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/0/2/102A6F7B-3D8C-4B9E-8F5A-3D1B0F2E4C6B/vs_community.exe" -OutFile $vs2013Installer
Start-Process -FilePath $vs2013Installer -Args "--quiet --wait --norestart" -Wait
Remove-Item $vs2013Installer
```
## 🚀 Microsoft Visual Studio 2012

```powershell
$vs2012Installer = "$env:TEMP\vs2012_installer.exe"
