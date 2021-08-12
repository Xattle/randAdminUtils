# This file contains the list of servers you want to copy files/folders to
$computers = Get-Content ".\IPList.txt"

# This is the file/folder(s) you want to copy to the servers in the $computer variable
$source = ".\printscan.ps1"

# The destination location you want the file/folder(s) to be copied to
$destination = "c$\temp\"

# PsExec Location
$psexecloc = "..\PsExec.exe"

foreach ($computer in $computers) {
	$copyitemargs = "powershell -noninteractive -command Copy-Item $source -Destination \\$computer\$destination -Verbose"
	Start-Process $psexecloc $copyitemargs

	#Slow down opening of processes to once every 2 seconds if there are more than 25 running
	if ((ps -Name 'PsExe*').count -gt 25) {
		Start-Sleep -s 2
	}
}

Wait-Process -Name PsExec

# Allows script to execute on remote PC
foreach ($computer in $computers) {
	$psargs = "\\$computer POWERSHELL set-executionpolicy remotesigned"
	Start-Process $psexecloc $psargs

	#Slow down opening of processes to once every 2 seconds if there are more than 25 running
	if ((ps -Name 'PsExe*').count -gt 25) {
		Start-Sleep -s 2
	}
}

Wait-Process -Name PsExec

#Generates printerlist.txt on remote PCs
foreach ($computer in $computers) {
	$psargs = "\\$computer /accepteula powershell -noninteractive -file C:\temp\printscan.ps1"
  Start-Process $psexecloc $psargs

	#Slow down opening of processes to once every 2 seconds if there are more than 25 running
  if ((ps -Name 'PsExe*').count -gt 25) {
		Start-Sleep -s 2
	}
}

Wait-Process -Name PsExec

powershell -noninteractive -command .\printListRetrieval.ps1

Read-Host -Prompt "Press Enter to continue"
