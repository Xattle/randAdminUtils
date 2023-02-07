$phones = Get-Content -Path C:\phonelogs\hosts.txt
New-Item -ItemType Directory -Force -Path C:\phonelogs\phones\ | Out-Null
$phones | Foreach-Object  -throttlelimit 30 -parallel {
	$phone = $_
	$messages = @('messages.3','messages.2','messages.1','messages.0','messages')
	$allMessages = $phone
	$allMessages > C:\phonelogs\phones\$($phone).txt
	invoke-WebRequest "http://$($phone)/CGI/Java/Serviceability?adapter=device.statistics.consolelog" > nul
	Foreach ($message in $messages) {
	$result = invoke-WebRequest "http://$($phone)/FS/$($message)"
	$allMessages = $allMessages + "`n" + $result.content
	}
	$allMessages > C:\phonelogs\phones\$($phone).txt
}
