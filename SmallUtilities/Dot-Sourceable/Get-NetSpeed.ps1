function Get-NetSpeed {
    #SIZE OF SPECIFIED FILE IN MB (10 or 100)
    $size = 100
    
    #FILE TO DOWNLOAD
    $downloadUrl = "http://ipv4.download.thinkbroadband.com/$($size)MB.zip"
    $uploadUrl = "http://ipv4.download.thinkbroadband.com/$($size)MB.zip"
    
    #WHERE TO STORE DOWNLOADED FILE
    $localfile = "$($env:TEMP)/$($size)MB.zip"
    
    Write-Output "$($size)MB test started at $(get-date -Format "HH:mm:ss MM/dd/yyyy")"
    
    #RUN DOWNLOAD
    $webclient = New-Object System.Net.WebClient
    $webclient.Headers.Add("User-Agent: Other")
    $downloadstart_time = Get-Date
    $webclient.DownloadFile($downloadurl, $localfile)
    
    #CALCULATE DOWNLOAD SPEED
    $downloadtimetaken = $((Get-Date).Subtract($downloadstart_time).Seconds)
    $downloadspeed = ($size / $downloadtimetaken)*8
    Write-Output "Time taken: $downloadtimetaken second(s)   |   Download Speed: $downloadspeed mbps"
    
    #RUN UPLOAD
    $uploadstart_time = Get-Date
    $webclient.UploadFile($UploadURL, $localfile) > $null;
    
    #CALCULATE UPLOAD SPEED
    $uploadtimetaken = $((Get-Date).Subtract($uploadstart_time).Seconds)
    $uploadspeed = ($size / $uploadtimetaken) * 8
    Write-Output "Upload currently broken. Need to find site to allow for upload testing"
    Write-Output "Time taken: $uploadtimetaken second(s)   |   Upload Speed: $uploadspeed mbps" 

    #DELETE TEST DOWNLOAD FILE
    Remove-Item –path $localfile

}

if ($(Split-Path $MyInvocation.InvocationName -Leaf) -eq $MyInvocation.MyCommand) {
    try {
        # If so, run the Get-NetSpeed function
        Get-NetSpeed @args
        
    }
    catch {
        Write-Output "This script can be dot-sourced using using . .\Get-NetSpeed.ps1 then run Get-Help Get-NetSpeed for more details."
        Write-Output "Work In Process - Download works but upload is broken. Script runs clean."
    }
}

# # Small download version
# function Get-NetworkSpeed {
#     $a=Get-Date
#     Invoke-WebRequest http://ipv4.download.thinkbroadband.com/10MB.zip|Out-Null
#     $output = "$((10/((Get-Date)-$a).TotalSeconds)*8) Mbps Download"
#     return $output
# }
