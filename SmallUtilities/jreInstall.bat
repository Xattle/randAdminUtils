@echo off
xcopy "JAVA PATH" C:\Files\ /I /Y
start /wait /D "C:\Files\" .\jre-8u291-windows-x64.exe /s /L C:\Files\setup.log REBOOT=Suppress AUTO_UPDATE=Disable REMOVEOUTOFDATEJRES=1
REG ADD "HKLM\SOFTWARE\WOW6432Node\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
