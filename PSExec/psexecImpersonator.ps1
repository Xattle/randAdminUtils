$ComputerName = Read-Host -Prompt 'PLEASE ENTER PC NAME'
$UserName = Read-Host -Prompt 'PLEASE ENTER USER ID'

$results = .\PsExec.exe \\$ComputerName query session
$id = $results | Select-String "$UserName\s+(\w+)" |
Foreach {$_.Matches[0].Groups[1].Value}

.\PsExec.exe -s \\$ComputerName cmd