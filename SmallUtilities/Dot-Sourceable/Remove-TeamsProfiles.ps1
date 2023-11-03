# Finds profiles that haven't logged in in the last 14 days and removes teams from appdata and registry.
# When using Teams Machine-Wide Installer, this will enable a short reinstall of the latest version on next login.
# Can take -DaysSinceLastLogin as a parameter. Use -1
function Remove-TeamsProfiles {
    <#
    .SYNOPSIS
    Cleans up Microsoft Teams installations for user profiles based on last login time. Uses Active Directory for SID so will need adjustments for local-only profiiles.
    
    NOTE: Because of limitations using ntuser.dat or other methods of tracking when a profile was last used, this script relies on checking %appdata%\access.log for the last write time. This doesn't exist normally but can be easily added to an environment through a logon script GPO or task that runs "echo Logon %date% %time% > %APPDATA%\access.log" If access.log doesn't exist, all teams profiles will be deleted.

    .DESCRIPTION
    This script finds user profiles that haven't logged in within the specified number of days and removes Microsoft Teams from their AppData folders and registry entries. You can set the number of days for the last login using the -DaysSinceLastLogin parameter. If you want to clean all profiles regardless of their last login time, you can use -1 for -DaysSinceLastLogin.

    .PARAMETER DaysSinceLastLogin
    Specifies the number of days since the last login. Profiles that haven't logged in within this period will have Microsoft Teams removed. Use -1 to clean all profiles regardless of their last login time. Default value is 14.

    .EXAMPLE
    .\Cleanup-Teams.ps1 -DaysSinceLastLogin 30
    Cleans up Teams installations for profiles that haven't logged in within the last 30 days.

    .EXAMPLE
    .\Cleanup-Teams.ps1 -DaysSinceLastLogin -1
    Cleans up Teams installations for all profiles, regardless of their last login time.
    #>

    [CmdletBinding()]
    param (
        [int]$DaysSinceLastLogin = 14
    )

    # Get the current date
    $CurrentDate = Get-Date

    # Get a list of user profile folders
    $UserProfileFolders = Get-ChildItem -Path C:\Users -Directory

    foreach ($UserProfileFolder in $UserProfileFolders) {
        $UserProfilePath = $UserProfileFolder.FullName
        $LastModifiedTime = $(Get-Item "$($UserProfileFolder.FullName)\Appdata\Roaming\access.log" -ErrorAction SilentlyContinue).LastWriteTime

        # Check if the user hasn't logged in within the specified days
        if (-not $LastModifiedTime -or ($CurrentDate - $LastModifiedTime).Days -gt $DaysSinceLastLogin) {
            try {
                # Remove Teams directories
                Remove-Item -Path "$UserProfilePath\AppData\Local\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$UserProfilePath\AppData\Local\Microsoft\TeamsMeetingAddin" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$UserProfilePath\AppData\Local\Microsoft\TeamsPresenceAddin" -Recurse -Force -ErrorAction SilentlyContinue

                # Remove Teams registry entries
                $UserSID = $(Get-ADUser -Identity $UserProfileFolder.Name).SID
                Remove-Item -Path "Registry::HKEY_USERS\$UserSID\Software\Microsoft\Office\Teams" -Recurse -Force -ErrorAction SilentlyContinue
                    
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
}

if ($(Split-Path $MyInvocation.InvocationName -Leaf) -eq $MyInvocation.MyCommand) {
    try {
        # If so, run the Remove-TeamsProfiles function
        Remove-TeamsProfiles @args
        
    }
    catch {
        Write-Output "This script can be dot-sourced using using . .\Remove-TeamsProfiles.ps1 then run Get-Help Remove-TeamsProfiles for more details."
    }
}
