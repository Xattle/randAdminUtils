$notPressed = $true
while ($notPressed)
{
    if([console]::KeyAvailable)
    {
        $notPressed = $false
    }
    $startTime = Get-Date "08:00am"
    $curTime = Get-Date
    
    $secPerTotal = 28800
    $secElapsed = ($curTime - $startTime).TotalSeconds
    $percentSpent = (($secElapsed / $secPerTotal) * 100)
    Write-Host ("`r{0:n2}%" -f $percentSpent) -NoNewline
    Start-Sleep -Seconds 1
}

Write-Host