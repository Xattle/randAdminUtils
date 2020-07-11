@echo off

SET /P uninstall=Would you like to uninstall the service? [Y/N]
SET /P path=Please enter the full path to \Debug\SERVICE.exe:

if %uninstall%==N goto install
if %uninstall%==n goto install
if %uninstall%==Y goto uninstall
if %uninstall%==y goto uninstall
goto closeg

:install
rem Install the service
C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe "%path%"
echo .
pause
goto close


:uninstall
rem Uninstall the service
C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe -u "%path%"
Echo .
pause

:close
echo Now closing...
pause
