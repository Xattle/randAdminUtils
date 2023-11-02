# SAVE THIS SCRIPT SO IT IS IN TESTING MODE UNTIL FLAGS FOR TESTING ARE INTRODUCED
# Get user profiles with a null LastUseTime
$profilesToDelete = Get-CimInstance -ClassName Win32_UserProfile | Where-Object { (!$_.Special) }

# Loop through and delete the profiles and their folders
foreach ($profile in $profilesToDelete) {
    $profilePath = $profile.LocalPath
    Write-Host "Deleting user profile: $profilePath"
    
    # Remove the user profile - use WhatIf in testing mode
    Remove-CimInstance -InputObject $profile -Confirm:$false -WhatIf
    
    # Remove the user folder if it exists
    if (Test-Path -Path $profilePath -PathType Container) {
        Write-Host "Deleting user folder: $profilePath"
        #Remove-Item -Path $profilePath -Force -Recurse
    }
}