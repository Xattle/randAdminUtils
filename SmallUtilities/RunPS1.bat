@echo off
del C:\windows\temp\USBPowerSettings.ps1
copy "LOCATION" C:\windows\temp\ /Z /Y
%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "C:\Windows\temp\USBPowerSettings.ps1"
exit