# Functions here
# Powershell function to use query user and return an object

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

    ForEach ($computer in $ComputerName)
    {
        try { if (-not (Test-Connection -ComputerName $computer -Quiet -Count 1 -ErrorAction Stop)) { Write-Warning "Can't connect to $computer"; continue } }
        catch { Write-Warning "Can't test connect to $computer"; continue }

        $quserOut = quser.exe /SERVER:$computer 2>&1
        if ($quserOut -match "No user exists")
        { Write-Warning "No users logged in to $computer";  continue }

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
            $users[$i].logonTime = [datetime]$users[$i].logonTime
        }
        $users = $users | Sort-Object -Property idleTime
        $out += $users
    }
    Write-Output $out
}

# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$LocalPrinterForm                    = New-Object system.Windows.Forms.Form

# Define the size, title and background color
$LocalPrinterForm.ClientSize         = '500,300'
$LocalPrinterForm.text               = "Hello World GUI"
$LocalPrinterForm.BackColor          = "#ffffff"

# Display the form
# [void]$LocalPrinterForm.ShowDialog()


# Get list of computers from ad
$computers = Get-ADComputer -Filter 'Name -like "*"'
$output = Get-LoggedInUser -ComputerName $computers.name

# Show list as drop down

# Choose from list

# Query users on choice

# Display user information
$output | Out-GridView

# Loop back to initial