# This file contains the list of servers you want to copy files/folders to
$computers = Get-Content ".\IPList.txt"

# The destination location you want the file/folder(s) to be copied to
$source = "c$\temp\printerlist.txt"

# PsExec Location
$psexecloc = "..\PsExec.exe"

foreach ($computer in $computers) {
	$FileName = $computer + ".txt"
	$copyitemargs = "powershell -noninteractive -command Copy-Item \\$computer\$source -Destination .\printerlists\$FileName -Verbose"
	Start-Process $psexecloc $copyitemargs
	
	#Slow down opening of processes to once every 2 seconds if there are more than 25 running
	if ((ps -Name 'PsExe*').count -gt 25) {
		Start-Sleep -s 2
	}
}

Wait-Process -Name PsExec

dir .\printerlists\* -include *.txt -rec | gc | out-file .\masterPrinterList.txt 