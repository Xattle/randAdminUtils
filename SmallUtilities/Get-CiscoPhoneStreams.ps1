
function Get-CiscoPhoneStreams
{
<#
    .SYNOPSIS
        Shows the call state of Cisco Phones in a hosts file

    .DESCRIPTION
        Shows the call state of any Cisco Phones listed in a hosts file. Defaults to look in local directory and C:\phonelogs\ for either a hosts.txt or CUCMList.csv.
		CUCMList.csv should have the following headers: Device_Type,Device_Name,Description,Status,Last Registered,Last Active,IPv4.
		Hosts.txt only looks for individual IP addresses per line.
		If -HostList is not specified, the file checking order is local CUCMList.csv, local hosts.txt, C:\phonelogs\CUCMList.csv, C: hosts.txt.

    .PARAMETER HostList
        Location and filename of hosts.txt or CUCMList.csv

	.PARAMETER ForceType
		Set the file type to txt or csv regardless of what the filetyp of HostList is.

    .EXAMPLE
        PS C:\> Get-CiscoPhoneStreams -HostList .\hosts.txt
        Shows status for phones in hosts.txt

    .EXAMPLE
        PS C:\> Get-CiscoPhoneStreams -HostList .\CUCMList.csv
        Shows status and extended information for phones in CUCMList.csv

	.EXAMPLE
		PS C:\> Get-CiscoPhoneStreams -HostList .\DifferentFile.bak -ForceType txt
		Uses a non-expected file and runs it as a txt file regardless of extension or contents

#>

    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [String[]]$HostList = "none",
		[String[]]$ForceType = "none"
    )

	If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
		Write-Verbose "Installing PowerHTML module for the current user..."
		Install-Module PowerHTML -ErrorAction Stop
	}
	Import-Module -ErrorAction Stop PowerHTML
	
	if ($HostList -eq "none") {
		if(Test-Path .\CUCMList.csv) {
			$mode = "csv"
			$phones = Import-Csv -Path .\CUCMList.csv
		} elseif (Test-Path .\hosts.txt) {
			$mode = "txt"
			$phones = Get-Content -Path .\hosts.txt
		} elseif (Test-Path C:\phonelogs\CUCMList.csv) {
			$mode = "csv"
			$phones = Import-Csv -Path C:\phonelogs\CUCMList.csv
		} elseif (Test-Path C:\phonelogs\hosts.txt) {
			$mode = "txt"
			$phones = Get-Content -Path C:\phonelogs\hosts.txt
		} else {
			Write-Error "Host file does not exist in local directory or C:\phonelogs! See Get-Help for more details."
		}
	} else {
		if(Test-Path $HostList) {
			if($HostList -like "*.csv" -or $ForceType -like "csv") {
				$mode = "csv"
				$phones = Import-Csv -Path $HostList
			} elseif ($HostList -like "*.txt" -or $ForceType -like "txt") {
				$mode = "txt"
				$phones = Get-Content -Path $HostList
			} else {
				Write-Error "HostList is not csv or txt file. If you still want to use this file specify -ForceType csv or txt"
			}
		} else {
			Write-Error "HostList file does not exist!"
		}
	}


	$output = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

	$phones | Foreach-Object  -throttlelimit 100 -parallel {
		try {
			if ($_ -is [string]) {
				$mode = "txt"
			} else {
				$mode = "csv"
			}
			if ($mode -eq "csv") {
				$phone = $_.IPv4
			} else {
				$phone = $_
			}
			$result = invoke-WebRequest "http://$($phone)/CGI/Java/Serviceability?adapter=device.statistics.streaming.0" -TimeoutSec 1
			$result = ConvertFrom-Html $result.Content
			$phoneName = $result.selectNodes('//tr[1]/td[2]/p[2]/b/font').InnerText
			$streamStatus = $result.selectNodes('//tr/td/b')[10].InnerText
			# $streamStatus = $result.selectNodes('//tr/td/b')[10].InnerText
		
			if ($mode -eq "csv") {
				$dataString = "$phone,$($_.Device_Type),$($_.Description),$($_.Device_Name),$streamStatus"
			} else {
				$dataString = "$phone,$phoneName,$streamStatus"
			}

			$localOutput = $using:output
			$localOutput.Add($($dataString))
		}
		catch {
			<#Do this if a terminating exception happens#>
		}
	}
	if ($mode -eq "csv") {
		$results = "IP,Type,Description,Name,Stream Status"
	} else {
		$results = "IP,Name,Stream Status"
	}

	$output | ForEach-Object {
		$results = $results + "`n" + $_
	}

	return ConvertFrom-Csv $results
}

Write-Output "To run this script, dot-source the file using . .\Get-CiscoPhoneStreams.ps1 then run Get-Help Get-CiscoPhoneStreams"