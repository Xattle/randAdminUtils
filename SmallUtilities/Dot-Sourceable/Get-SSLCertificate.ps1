function Get-SSLCertificate
{
    <#
    .SYNOPSIS
        Gets the SSL certificate info for a specific IP and hostname

    .DESCRIPTION
        Establishes an SSL stream to inspect the certificate used on a specific IP address for a given hostname. Useful for virtual hosts and load-balanced applications. Combine with Resolve-DNSName -Name "host" to discover potential server IPs. Please see examples for more.

    .PARAMETER IP
        The IP address of the target server

    .PARAMETER Hostname
        The hostname passed to the server

    .EXAMPLE
        PS C:\> Get-SSLCertificate -IP a.b.c.d -Host test.domain.com
        Shows the cert info for virtual server test.domain.com on ip a.b.c.d

        PS C:\> Get-SSLCertificate -IP a.b.c.d, e.f.g.h -Host test.domain.com
        Shows the certs for both ip addresses

        PS C:\> resolve-DnsName -Name "serverhostname" | Get-SSLCertificate -Hostname hostname.com |ogv
        Shows all certs for resolved IP addresses
    #>

[CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName = $true)][string[]]$IPAddress,
    [Parameter(Mandatory)][string]$Hostname
    )

    begin {
        $result = @()
    }
    process {
        foreach ($address in $IPAddress) {
            try {
                $port = 443
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $tcpClient.Connect($address, $port)
                $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, ({ $true }))
                $sslStream.AuthenticateAsClient($Hostname)
                $cert = $sslStream.RemoteCertificate
                $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $cert
                $result += [PSCustomObject]@{
                    IP         = $address
                    Hostname   = $Hostname
                    Subject    = $cert2.Subject
                    Issuer     = $cert2.Issuer
                    NotBefore  = $cert2.NotBefore
                    NotAfter   = $cert2.NotAfter
                    Thumbprint = $cert2.Thumbprint    
                }
                $sslStream.Close()
                $tcpClient.Close()
            }
            catch {
                Write-Warning "Failed to retrieve certificate from $address - $_"
            }
        }

    }
    end {
        return $result
    }

}

if ($(Split-Path $MyInvocation.InvocationName -Leaf) -eq $MyInvocation.MyCommand) {
    try {
        # If so, run the Get-ServiceUptime function
        Get-SSLCertificate @args
        
    }
    catch {
        Write-Output "This script can be dot-sourced using using . .\Get-SSLCertificate.ps1 then run Get-Help Get-SSLCertificate for more details."
    }
}
