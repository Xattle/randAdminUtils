# Finds profiles that haven't logged in in the last 14 days and removes teams from appdata and registry.
# When using Teams Machine-Wide Installer, this will enable a short reinstall of the latest version on next login.
# Can take -DaysSinceLastLogin as a parameter.

param (
    [int]$DaysSinceLastLogin = 14
)

# Get the current date
$CurrentDate = Get-Date

# Get a list of user profile folders
$UserProfileFolders = Get-ChildItem -Path C:\Users -Directory

foreach ($UserProfileFolder in $UserProfileFolders) {
    $UserProfilePath = $UserProfileFolder.FullName
    $LastModifiedTime = $(Get-Item "$($UserProfileFolder.FullName)\Appdata\Roaming\access.log").LastWriteTime

    # Check if the user hasn't logged in within the specified days
    if (-not $LastModifiedTime -or ($CurrentDate - $LastModifiedTime).Days -gt $DaysSinceLastLogin) {
        try {
            # Remove Teams directories
            Remove-Item -Path "$UserProfilePath\AppData\Local\Microsoft\Teams" -Recurse -Force -ErrorAction Continue
            Remove-Item -Path "$UserProfilePath\AppData\Local\Microsoft\TeamsMeetingAddin" -Recurse -Force -ErrorAction Continue
            Remove-Item -Path "$UserProfilePath\AppData\Local\Microsoft\TeamsPresenceAddin" -Recurse -Force -ErrorAction Continue

            # Remove Teams registry entries
            $UserSID = $UserProfileFolder.Name
            Remove-Item -Path "Registry::HKEY_USERS\$UserSID\Software\Microsoft\Office\Teams" -Recurse -Force -ErrorAction Continue
                
            # Log successful cleanup
            Write-Output "Successfully cleaned up Teams for $($UserProfileFolder.Name)"
        } catch {
            # Log any errors
            Write-Output "Error cleaning up Teams for $($UserProfileFolder.Name): $_"
        }
    } else {
        Write-Output "Cleanup not needed for $($UserProfileFolder.Name)"
    }
}
