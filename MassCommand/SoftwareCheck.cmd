@echo off
for /f %%a in (.\iplist.txt) do (
echo %%a
.\psinfo.exe -s \\%%a |findstr -i ""
echo ------------------------------------------------
)
pause
