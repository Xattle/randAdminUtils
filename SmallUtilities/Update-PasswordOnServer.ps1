# This script is designed to take in a csv file and reset the password for a designated account. The CSV should be formatted with a header as follows:
# domain, server, note

function Update-PasswordOnServer {
    $testRun = Read-Host "Is this a [t]est only run (will not change passwords) or [l]ive run (WILL RESET PASSWORDS)? [t]est or [l]ive"
    $pathToCSV = Read-Host "Enter the relative path to the CSV file"
    $csvFile = Import-CSV -Path $pathToCSV
    $shouldConnect = 'n'
    foreach ($entry in $csvFile) {
        $shouldConnect = Read-Host "Connect to $($entry.server).$($entry.domain) ($($entry.note))? [y]es or [n]o"
        if ($shouldConnect -eq 'y') {
            $loginCred = Get-Credential -Message "Please enter login credentials for server $($entry.server) on domain $($entry.domain) ($($entry.note))."
            $fullLoginCred = new-object -typename System.Management.Automation.PSCredential -argumentlist "$($loginCred.username)@$($entry.domain)",$loginCred.password
            $s = New-PSSession -ComputerName "$($entry.server).$($entry.domain)" -Credential $fullLoginCred
            
            if ($testRun -eq "l") {
                Invoke-Command -Session $s -Scriptblock {
                    $newCred = Get-Credential -Message "Please enter username and new password for domain $($entry.domain)"
                    Set-ADAccountPassword -Identity $newCred.username -NewPassword $newCred.password -Reset
                }
                Remove-PSSession $s
                Write-Host "Password changed for user on $($entry.domain) ($($entry.note))!"
            } else {
                Invoke-Command -Session $s -Scriptblock {
                $newCred = Get-Credential -Message "Please enter username and new password for domain $($entry.domain)"
                Set-ADAccountPassword -WhatIf -Identity $newCred.username -NewPassword $newCred.password -Reset
                }
                Remove-PSSession $s
                Write-Host "Test scenario ran on $($entry.domain) ($($entry.note))!"    
            }

        } else {
            Write-Output "Skipping $($entry.server).$($entry.domain) ($($entry.note))."
        }
        $shouldConnect = 'n'
    }
    Write-Output "All CSV entries have been iterated through in file $($pathToCSV)"

}

Update-PasswordOnServer