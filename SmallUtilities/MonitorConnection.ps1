
function Get-NetSpeed {
    $a=Get-Date
    Invoke-WebRequest http://ipv4.download.thinkbroadband.com/10MB.zip|Out-Null
    $output = "$((10/((Get-Date)-$a).TotalSeconds)*8) Mbps"
    return $output
}

function New-NetworkMonitor {
    param (
        $url = "www.google.com"
    )
    
    Test-NetConnection $url

}

Get-NetSpeed
New-NetworkMonitor