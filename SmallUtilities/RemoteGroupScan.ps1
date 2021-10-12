foreach($line in Get-Content .\mainhosts.csv) {
  $line
  .\PsExec.exe -nobanner \\$line net localgroup "Remote Desktop Users"
  "---------------------------------------------------------------------"
}
