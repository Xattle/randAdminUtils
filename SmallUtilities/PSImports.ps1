# Adds useful Powershell functions
# Get-ServiceUptime
# Get-LoggedInUser - Powershell wrapper for query user

function Get-ServiceUptime
{
    <#
    .SYNOPSIS
        Gets the uptime for a specific service on the machine

    .DESCRIPTION
        Uses Get-CimInstance to identify the process connected to a service. Then pulls the creation date and calculates uptimes of the service based on that.

    .PARAMETER Name
        Service name

    .EXAMPLE
        PS C:\> ServiceUptime -Name wuauserv
        Shows the uptime for the wuauserv service
    #>

[CmdletBinding()]
  param(
    [string]$Name
    )

  # Prepare name filter for WQL
  $Name = $Name -replace "\\","\\" -replace "'","\'" -replace "\*","%"

  # Fetch service instance
  $Service = Get-CimInstance -ClassName Win32_Service -Filter "Name LIKE '$Name'"

  # Use ProcessId to fetch corresponding process
  $Process = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($Service.ProcessId)"

  # Calculate uptime and return
  return (Get-Date) - $Process.CreationDate
}

function Get-LoggedInUser
{
<#
    .SYNOPSIS
        Shows all the users currently logged in

    .DESCRIPTION
        Shows the users currently logged into the specified computernames

    .PARAMETER ComputerName
        One or more computernames

    .EXAMPLE
        PS C:\> Get-LoggedInUser
        Shows the users logged into the local system

    .EXAMPLE
        PS C:\> Get-LoggedInUser -ComputerName server1,server2,server3
        Shows the users logged into server1, server2, and server3

    .EXAMPLE
        PS C:\> Get-LoggedInUser  | where idletime -gt "1.0:0" | ft
        Get the users who have been idle for more than 1 day.  Format the output
        as a table.

        Note the "1.0:0" string - it must be either a system.timespan datatype or
        a string that can by converted to system.timespan.  Examples:
            days.hours:minutes
            hours:minutes
#>

    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )

    $out = @()
    $percentComplete = 0
    $computerIter = 1
    ForEach ($computer in $ComputerName)
    {
        $percentComplete = [math]::Round($computerIter / $ComputerName.Count * 100)
        Write-Progress -Activity "User Search in Progress" -Status "$percentComplete% Complete:" -PercentComplete $percentComplete
        $computerIter++
        try { if (-not (Test-Connection -ComputerName $computer -Quiet -Count 1 -ErrorAction Stop)) { Write-Warning "Can't connect to $computer"; continue } }
        catch { Write-Warning "Can't test connect to $computer"; continue }

        $quserOut = quser.exe /SERVER:$computer 2>&1
        if ($quserOut -match "No user exists")
        { Write-Warning "No users logged in to $computer";  continue }

        if ($quserOut -like "*Error 0*")
        { Write-Warning "Access is denied on $computer";  continue }


        $users = $quserOut -replace '\s{2,}', ',' |
        ConvertFrom-CSV -Header 'username', 'sessionname', 'id', 'state', 'idleTime', 'logonTime' |
        Add-Member -MemberType NoteProperty -Name ComputerName -Value $computer -PassThru

        $users = $users[1..$users.count]

        for ($i = 0; $i -lt $users.count; $i++)
        {
            if ($users[$i].sessionname -match '^\d+$')
            {
                $users[$i].logonTime = $users[$i].idleTime
                $users[$i].idleTime = $users[$i].STATE
                $users[$i].STATE = $users[$i].ID
                $users[$i].ID = $users[$i].SESSIONNAME
                $users[$i].SESSIONNAME = $null
            }

            # cast the correct datatypes
            $users[$i].ID = [int]$users[$i].ID

            $idleString = $users[$i].idleTime
            if ($idleString -eq '.') { $users[$i].idleTime = 0 }
            if ($idleString -eq 'none') { $users[$i].idleTime = 0 }
            if (!$idleString) { $users[$i].idleTime = 0 }

            # if it's just a number by itself, insert a '0:' in front of it. Otherwise [timespan] cast will interpret the value as days rather than minutes
            if ($idleString -match '^\d+$')
            { $users[$i].idleTime = "0:$($users[$i].idleTime)" }

            # if it has a '+', change the '+' to a colon and add ':0' to the end
            if ($idleString -match "\+")
            {
                $newIdleString = $idleString -replace "\+", ":"
                $newIdleString = $newIdleString + ':0'
                $users[$i].idleTime = $newIdleString
            }

            $users[$i].idleTime = [timespan]$users[$i].idleTime
            if (!$users[$i].logonTime) { $users[$i].logonTime = 0 }
            $users[$i].logonTime = [datetime]$users[$i].logonTime
        }
        $users = $users | Sort-Object -Property idleTime
        $out += $users
    }
    Write-Output $out
}
