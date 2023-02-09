$computers = get-content -Path .\hosts.txt

$computers | Foreach-Object  -throttlelimit 30 -parallel {
    $computer = $_
    $ip = (Resolve-DnsName $computer -Type A | Where-Object IPAddress -like "10.*").ipaddress
    Set-NetFirewallRule -RemoteAddress $ip -DisplayGroup 'Remote Event Log Management' -Enabled True -PassThru | Select-Object -Property DisplayName, Enabled

}