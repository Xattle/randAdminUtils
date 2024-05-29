$accountToCheck = ''
$badWorkstations = ''
$validWorkstations = ''

foreach ($workstation in $(get-aduser -Identity $accountToCheck -Properties logonworkstations).logonworkstations -split ",") {
    Write-Output "Checking $workstation..."
    try {
        Get-ADComputer -Identity $workstation | out-null
        $validWorkstations = $validWorkstations + ",$workstation"
    }
    catch {
        Write-Output "$workstation errored out"
        $badWorkstations = $badWorkstations + ",$workstation"
        }
}

try {$validWorkstations = $validWorkstations.substring(1)}
catch {Write-Output "No valid workstations."}
try {$badWorkstations = $badWorkstations.substring(1)}
catch {Write-Output "No bad workstations."}

Write-Output "validWorkstations: $validWorkstations"
Write-Output "badWorkstations: $badWorkstations"

Write-Output "User account can be updated by running the following command without -WhatIf:"
Write-Output "set-aduser -WhatIf -Identity $accountToCheck -LogonWorkstations '$validWorkstations'"
