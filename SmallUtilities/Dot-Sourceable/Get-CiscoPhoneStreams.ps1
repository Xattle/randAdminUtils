
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

	$phones | Foreach-Object  -throttlelimit 300 -parallel {
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
			$result = invoke-WebRequest "http://$($phone)/CGI/Java/Serviceability?adapter=device.statistics.streaming.0" -TimeoutSec 3
			$resultDevInfo = invoke-WebRequest "http://$($phone)/CGI/Java/Serviceability?adapter=device.statistics.device" -TimeoutSec 3
			$result = ConvertFrom-Html $result.Content
			$resultDevInfo = ConvertFrom-Html $resultDevInfo.Content
			$phoneName = $result.selectNodes('//tr[1]/td[2]/p[2]/b/font').InnerText
			$streamStatus = $result.selectNodes('//tr/td/b')[10].InnerText

			$additionalDataPoints = "Extension,Firmware,Cumulative Conceal Ratio,Max ConcealRatio,Conceal Seconds,Severely Conceal Seconds,Receiver discarded"
			$additionalDataPoints = $resultDevInfo.selectNodes('//tr/td/b')[14].InnerText + ","
			$additionalDataPoints += $resultDevInfo.selectNodes('//tr/td/b')[20].InnerText + ","
			$additionalDataPoints += $result.selectNodes('//tr/td/b')[38].InnerText + ","
			$additionalDataPoints += $result.selectNodes('//tr/td/b')[42].InnerText + ","
			$additionalDataPoints += $result.selectNodes('//tr/td/b')[44].InnerText + ","
			$additionalDataPoints += $result.selectNodes('//tr/td/b')[46].InnerText + ","
			$additionalDataPoints += $result.selectNodes('//tr/td/b')[60].InnerText

					
			if ($mode -eq "csv") {
				$dataString = "$phone,$($_.Device_Type),$($_.Description),$($_.Device_Name),$streamStatus,$additionalDataPoints"
			} else {
				$dataString = "$phone,$phoneName,$streamStatus,$additionalDataPoints"
			}

			$localOutput = $using:output
			$localOutput.Add($($dataString))
		}
		catch {
			<#Do this if a terminating exception happens#>
		}
	}
	$additionalDataPoints = "Extension,Firmware,Cumulative Conceal Ratio,Max ConcealRatio,Conceal Seconds,Severely Conceal Seconds,Receiver discarded"
	if ($mode -eq "csv") {
		$results = "IP,Type,Description,Name,Stream Status,$additionalDataPoints"
	} else {
		$results = "IP,Name,Stream Status,$additionalDataPoints"
	}

	$output | ForEach-Object {
		$results = $results + "`n" + $_
	}

	return ConvertFrom-Csv $results
}

if ($(Split-Path $MyInvocation.InvocationName -Leaf) -eq $MyInvocation.MyCommand) {
    try {
        # If so, run the Get-CiscoPhoneStreams function
        Get-CiscoPhoneStreams @args
        
    }
    catch {
        Write-Output "This script can be dot-sourced using using . .\Get-CiscoPhoneStreams.ps1 then run Get-Help Get-CiscoPhoneStreams for more details."
    }
}

# # Notes: The following are the array ID of the Stream stat, the stream stat name, and the +1 in the array for that stat which should correspond to its value
# 1,Device logs,Streaming statistics
# 3, Remote address,10.10.2.223&#x2F;19778
# 5, Local address,10.10.2.244&#x2F;29602
# 7, Start time,9:59:33am
# 9, Stream status,Not ready
# 11, Host name,SEP8C941FFF4321
# 13, Sender packets,951
# 15, Sender octets,152160
# 17, Sender codec,G.711u
# 19, Sender reports sent,3
# 21, Sender report time sent,9:59:48am
# 23, Rcvr lost packets,0
# 25, Avg jitter,1
# 27, Receiver codec,G.711u
# 29, Receiver reports sent,0
# 31, Receiver report time sent,00:00:00
# 33, Rcvr packets,954
# 35, Rcvr octets,163916
# 37, Cumulative conceal ratio,0.0016
# 39, Interval conceal ratio,0.0000
# 41, Max conceal ratio,0.0099
# 43, Conceal seconds,1
# 45, Severely conceal seconds,0
# 47, Latency,2
# 49, Max jitter,4
# 51, Sender size,20 ms
# 53, Sender reports received,4
# 55, Sender report time received,9:59:51am
# 57, Receiver size,20 ms
# 59, Receiver discarded,1
# 61, Receiver reports received,0
# 63, Receiver report time received,00:00:00
# 65, Rcvr encrypted,0
# 67, Sender encrypted,0
# 69, Sender frames,0
# 71, Sender partial frames,0
# 73, Sender iframes,0
# 75, Sender IDR frames,0
# 77, Sender frame Rate,0
# 79, Sender bandwidth,0
# 81, Sender resolution,0 * 0
# 83, Rcvr frames,0
# 85, Rcvr partial frames,0
# 87, Rcvr iframes,0
# 89, Rcvr IDR frames,0
# 91, Rcvr iframes req,0
# 93, Rcvr frame rate,0
# 95, Rcvr frames lost,0
# 97, Rcvr frame errors,0
# 99, Rcvr bandwidth,0
# 101, Rcvr resolution,0 * 0
# 103, Domain,snmpUDPDomain
# 105, Sender joins,0
# 107, Rcvr joins,0
# 109, Byes,0
# 111, Sender start time,9:59:33am
# 113, Rcvr start time,9:59:33am
# 115, Row status,Not ready
# 117, Sender tool,G.711u
# 119, Sender reports,2
# 121, Sender report time,00:00:00
# 123, Rcvr jitter,4
# 125, Receiver tool,G.711u
# 127, Rcvr reports,2
# 129, Rcvr report time,00:00:00
# 131, Is video,False
# 133, Call ID,813
# 135, Group ID,813