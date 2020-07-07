Write-Host "THIS ONLY WORKS IF SCREEN IS NOT LOCKED"
Write-Host " "

$ComputerName = Read-Host -Prompt 'PLEASE ENTER PC NAME'
$UserName = Read-Host -Prompt 'PLEASE ENTER USER ID'

# Copies script to remote PC
copy-item ".\screenGrab.ps1" "\\$ComputerName\C$\Temp"
copy-item ".\silentScreenGrab.ps1" "\\$ComputerName\C$\Temp"

#Captures correct session ID

$results = .\PsExec.exe \\$ComputerName query session
$id = $results | Select-String "$UserName\s+(\w+)" |
Foreach {$_.Matches[0].Groups[1].Value}

# Allows script to execute on remote PC

#.\PsExec.exe \\$ComputerName POWERSHELL set-executionpolicy remotesigned

#Takes screenshot of remote PC

.\PsExec.exe -s -i $id \\$ComputerName POWERSHELL -WindowStyle Hidden -file "C:\Temp\silentScreenGrab.ps1"
