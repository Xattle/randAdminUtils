workflow PingEverything {
#region Variables
$ErrorActionPreference = "Stop"
$RTEPrint   = ""
#$CRouter  = ""
#$Router1  = ""
#$Router2  = ""
#$Router3  = ""
#$Router4  = ""
#$Router5  = ""
#$Router6  = ""
#$Internet = ""
$PingList = @("$RTEPrint")

$LoggerLoc = ".\PingLogs.log"
#endregion Variables
function Logger{
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$FilePath,
        [switch]$NewLine
    )
    $timestamp = (Get-Date).ToString("yyyy/MM/dd-HH:mm:ss")
    $LogLine = "$timestamp| $Text"
    if($FilePath)
    {
        if(Test-Path $FilePath){Add-Content $FilePath -Value $LogLine}
        else
        {
        New-Item -Path $FilePath -ItemType File
        Add-Content $FilePath -Value $LogLine
        }
    }
    if($NewLine.IsPresent)
    {Add-Content $FilePath -Value ""}
}

    Logger -FilePath $LoggerLoc -Text "Starting pings"
    Foreach -Parallel ($Pingme in $PingList){
        do{try{Test-Connection -ComputerName $Pingme}catch{Logger -FilePath $LoggerLoc -Text "Failed to ping $Pingme"}}while ($true)
    }
}

PingEverything
