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

if ($(Split-Path $MyInvocation.InvocationName -Leaf) -eq $MyInvocation.MyCommand) {
    try {
        # If so, run the Get-ServiceUptime function
        Get-ServiceUptime @args
        
    }
    catch {
        Write-Output "This script can be dot-sourced using using . .\Get-ServiceUptime.ps1 then run Get-Help Get-ServiceUptime for more details."
    }
}
