$computerName = "vdmc-train1"

while ($true) {
    # Test the connection to the specified computer
    $connectionTest = Test-NetConnection -ComputerName $computerName -InformationLevel Quiet

    # Check if the computer is online
    if ($connectionTest) {
        # Computer is online, display a pop-up message
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("The computer '$computerName' is online.", 0, "Computer Status", 64)
        break  # Exit the loop once the computer is online
    }
    else {
        # Computer is offline, wait for a while before testing again
        Start-Sleep -Seconds 10
    }
}
