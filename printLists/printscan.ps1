Remove-Item -path C:\temp\printerlist.txt
"--------------------------------------`r`n" | Out-File -Append -FilePath C:\temp\printerlist.txt
Hostname | Out-File -Append -FilePath C:\temp\printerlist.txt
Get-NetIPAddress | findstr -i "10.*" | Out-File -Append -FilePath C:\temp\printerlist.txt
Get-Printer | Format-List Name | Out-File -Append -FilePath C:\temp\printerlist.txt
