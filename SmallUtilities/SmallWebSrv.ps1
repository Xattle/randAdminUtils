New-NetFirewallRule -DisplayName "TempPort8080" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:8080/")
$listener.Start()
Write-Output "Listening on port 80..."

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $response = $context.Response
    $response.StatusCode = 200
    $response.ContentType = "text/html"
    $html = "<html><body><h1>PowerShell Web Server</h1><p>Hello, world!</p></body></html>"
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
}

Remove-NetFirewallRule -DisplayName "TempPort8080"
