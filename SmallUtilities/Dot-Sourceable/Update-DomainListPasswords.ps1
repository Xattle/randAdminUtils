function Update-DomainListPasswords {
<#
    .SYNOPSIS
        Changes passwords in a list of domains based from a CSV file semi-automatically

    .DESCRIPTION
        Must use a CSV file with the following headers:
        domain, server, note
        
        Cycles through the list of servers on various domains based on the CSV file.
        When ran, it checks the CSV and confirms if you want to connect to the first server in the list.
        Then it asks for a username and password (@domain is automatically appended from the CSV).
        The credentials are used to login to the server specified. Server must have powershell remoting enabled.
        Once logged in, prompts for the username to reset and the new password. DOES NOT CONFIRM PASSWORD TWICE
        Immedeately tries to set password for the user using Set-ADAccountPassword. Server needs to have ActiveDirectory powershell module for this to work.
        Logs out of domain and moves to the next server in the list.

        Will only do test runs unless -Live is included. Test runs work the same but using Set-ADAccountPassword -WhatIf.

    .PARAMETER ServerList
        Relative location and filename of the server list CSV.
        Must be formatted with the following headers:
        domain, server, note

	.PARAMETER Live
		Include to actually change passwords. If NOT included, script will run using -WhatIf and no passwords will be changed.

    .PARAMETER AlwaysConnect
        Ignores the confirmation for each server and jumps to requesting credentials.
        Makes it harder to break execution in case of error.

    .EXAMPLE
        PS C:\> Update-DomainListPasswords -ServerList .\ListOfServers.csv
        Runs a test run without changing passwords. Good for confirming hostnames, domains, and powershell remoting is working as expected.

    .EXAMPLE
        PS C:\> Update-DomainListPasswords -ServerList .\ListOfServers.csv -Live -AlwaysConnect
        Goes through the CSV list and changes passwords as documented. Does not prompt before connecting to each server. Not automatic. Quicker than logging into 20 different domains.

#>

    [CmdletBinding()]

    param( 
        [Parameter(Mandatory=$true)][string]$ServerList,
        [switch]$Live,
        [switch]$AlwaysConnect
    )

    $pathToCSV = $ServerList
    $csvFile = Import-CSV -Path $pathToCSV
    $shouldConnect = 'n'
    foreach ($entry in $csvFile) {

        if($AlwaysConnect) {
            $shouldConnect = 'y'
        } else {
            $shouldConnect = Read-Host "Connect to $($entry.server).$($entry.domain) ($($entry.note))? [y]es or [n]o"
        }

        if ($shouldConnect -eq 'y') {
            $loginCred = Get-Credential -Message "Please enter login credentials for server $($entry.server) on domain $($entry.domain) ($($entry.note))."
            $fullLoginCred = new-object -typename System.Management.Automation.PSCredential -argumentlist "$($loginCred.username)@$($entry.domain)",$loginCred.password
            $s = New-PSSession -ComputerName "$($entry.server).$($entry.domain)" -Credential $fullLoginCred
            
            if ($Live) {
                Invoke-Command -Session $s -Scriptblock {
                    $newCred = Get-Credential -Message "Please enter username to lookup and NEW password"
                    Set-ADAccountPassword -Identity $newCred.username -NewPassword $newCred.password -Reset
                }
                Remove-PSSession $s
                Write-Host "Password changed for user on $($entry.domain) ($($entry.note))!"
            } else {
                Invoke-Command -Session $s -Scriptblock {
                $newCred = Get-Credential -Message "Please enter username to lookup and NEW password"
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