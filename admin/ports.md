PowerShell-команди для відкриття портів:
✅ Відкрити 5985 (HTTP):
```powershell
New-NetFirewallRule -Name "Allow WinRM HTTP" -DisplayName "Allow WinRM over HTTP" -Enabled True -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5985
```
✅ Відкрити 5986 (HTTPS):
```powershell
llRule -Name "Allow WinRM HTTPS" -DisplayName "Allow WinRM over HTTPS" -Enabled True -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5986
```
