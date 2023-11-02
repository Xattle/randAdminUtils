function Update-SecurityGroups {
    <#
    .SYNOPSIS
        Refreshes Kerberos tickets updating computer security group listings

    .DESCRIPTION
        Uses the klist commands as well as gpupdate to refresh the kerberos tickets for the computer. Has to be ran as admin and only works on remote devices if Powershell Remoting is enabled.

    .PARAMETER ComputerName
        Computer to refresh tickets on.

    .EXAMPLE
        PS C:\> Update-SecurityGroups -ComputerName TARGETHOSTNAME
    #>

[CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,    
            ValueFromPipelineByPropertyName = $true
            )]
        [Alias('ComputerName')]
        [string]$Name = $env:COMPUTERNAME
    )

    process {
            $computer = $Name
            if ($computer -eq $env:COMPUTERNAME) {
                Write-Output "Running locally on $computer"
                # klist.exe sessions | findstr /i $env:COMPUTERNAME
                # klist.exe -li 0x3e7 purge
                # gpupdate /force
            } else {
                Write-Output "Connecting to $computer"
                Enter-PSSession -ComputerName $computer
                # klist.exe sessions | findstr /i $env:COMPUTERNAME
                # klist.exe -li 0x3e7 purge
                # gpupdate /force
                Exit-PSSession
            }
    }
    
}

if ($(Split-Path $MyInvocation.InvocationName -Leaf) -eq $MyInvocation.MyCommand) {
    try {
        # If so, run the Update-SecurityGroups function
        Update-SecurityGroups @args
        
    }
    catch {
        Write-Output "This script can be dot-sourced using using . .\Update-SecurityGroups.ps1 then run Get-Help Update-SecurityGroups for more details."
    }
}
