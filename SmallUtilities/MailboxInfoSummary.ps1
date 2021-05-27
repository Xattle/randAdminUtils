<#
  This script generates a csv list of all users and their total mailbox sizes.
#>

$outFile = "mailSummary$((Get-Date -Format dd.MM.yyyy-HH.mm).ToString()).csv"

Write-Host Generating $outFile

$All = Get-Mailbox -ResultSize Unlimited
$All | foreach {Get-MailboxStatistics -Identity $_.Name | Select DisplayName,ItemCount,@{expression = {$_.TotalItemSize.Value.ToMB()}; label="TotalItemSizeMB"} | Sort TotalItemSize -desc} | Export-CSV $outFile -NoTypeInformation

Write-Host $outFile has been created!
