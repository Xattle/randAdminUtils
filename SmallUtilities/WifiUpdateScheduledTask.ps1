Invoke-Command -ScriptBlock {
    $scheduledTaskName = "SSID Update - VDMC-Wireless Password"
    $wifiKey = "Register3!Manmade"
    $wifiProfileName = "VDMC-Wireless"
    $filePathName = "C:\Wi-Fi-VDMC-Wireless-6-5-2023.xml"
    $xmlFile = @"
    <?xml version="1.0"?>
    <WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
            <name>VDMC-Wireless</name>
            <SSIDConfig>
                    <SSID>
                            <hex>56444D432D576972656C657373</hex>
                            <name>$wifiProfileName</name>
                    </SSID>
            </SSIDConfig>
            <connectionType>ESS</connectionType>
            <connectionMode>auto</connectionMode>
            <MSM>
                    <security>
                            <authEncryption>
                                    <authentication>WPA2PSK</authentication>
                                    <encryption>AES</encryption>
                                    <useOneX>false</useOneX>
                            </authEncryption>
                            <sharedKey>
                                    <keyType>passPhrase</keyType>
                                    <protected>false</protected>
                                    <keyMaterial>$wifiKey</keyMaterial>
                            </sharedKey>
                    </security>
            </MSM>
            <MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3">
                    <enableRandomization>false</enableRandomization>
                    <randomizationSeed>3536636478</randomizationSeed>
            </MacRandomization>
    </WLANProfile>
"@

    Write-Output $xmlFile > $filePathName
    netsh wlan add profile filename=$filePathName user=all
    $foundNewKey = netsh wlan show profile name=$wifiProfileName key=clear | Select-String $wifiKey
    if ($foundNewKey) {
        remove-item -force $filePathName
    }
    else {
        Start-ScheduledTask $scheduledTaskName
    }
}

#Single Line (Remove #)
#Invoke-Command -ScriptBlock {$scheduledTaskName = "SSID Update - VDMC-Wireless Password";$wifiKey = "Register3!Manmade";$wifiProfileName = "VDMC-Wireless";$filePathName = "C:\Wi-Fi-VDMC-Wireless-6-5-2023.xml";$xmlFile = "<?xml version=`"1.0`"?><WLANProfile xmlns=`"http://www.microsoft.com/networking/WLAN/profile/v1`"><name>VDMC-Wireless</name><SSIDConfig><SSID><hex>56444D432D576972656C657373</hex><name>VDMC-Wireless</name></SSID></SSIDConfig><connectionType>ESS</connectionType><connectionMode>auto</connectionMode><MSM><security><authEncryption><authentication>WPA2PSK</authentication><encryption>AES</encryption><useOneX>false</useOneX></authEncryption><sharedKey><keyType>passPhrase</keyType><protected>false</protected><keyMaterial>Register3!Manmade</keyMaterial></sharedKey></security></MSM><MacRandomization xmlns=`"http://www.microsoft.com/networking/WLAN/profile/v3`"><enableRandomization>false</enableRandomization><randomizationSeed>3536636478</randomizationSeed></MacRandomization></WLANProfile>";Write-Output $xmlFile > $filePathName;netsh wlan add profile filename=$filePathName user=all;$foundNewKey = netsh wlan show profile name=$wifiProfileName key=clear | Select-String $wifiKey;if ($foundNewKey) {remove-item -force $filePathName}else {Start-ScheduledTask $scheduledTaskName};}