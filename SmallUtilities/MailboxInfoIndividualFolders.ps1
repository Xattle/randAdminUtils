<#
  This script generates a csv list of all user's individual mail folders and their sizes.
  Only works when running directly on the exchange server (with snap in enabled) and may throw warnings about folders.
#>

$outFile = "mailIndividualFolders$((Get-Date -Format dd.MM.yyyy-HH.mm).ToString()).csv"

Write-Host Generating $outFile

$All = Get-Mailbox -ResultSize Unlimited
$All | foreach {Get-MailboxFolderStatistics -Identity $_.Name | Select @{expression = {$_.Identity -replace '\\[^\\]*',''};label="Username"},Name,ItemsInFolderAndSubfolders,@{expression = {$_.FolderAndSubfolderSize.ToMB()}; label="FolderAndSubfolderSizeMB"}}| where-object {$_.ItemsInFolderAndSubfolders -ne "0"} | Export-CSV $outFile -NoTypeInformation

Write-Host $outFile has been created!
