$notPressed = $true
while ($notPressed)
{
    if([console]::KeyAvailable)
    {
        $notPressed = $false
    }
    $startTime = Get-Date "08:30am"
    $curTime = Get-Date
    
    $secPerTotal = 30600
    $secElapsed = ($curTime - $startTime).TotalSeconds
    $percentSpent = (($secElapsed / $secPerTotal) * 100)
    $percentSpent = "{0:n2}" -f $percentSpent
    $percentSpent = [float] $percentSpent
    Write-Progress -Activity "Day in Progress" -Status "$percentSpent% Complete:" -PercentComplete $percentSpent
    Start-Sleep -Milliseconds 250
}

Write-Host