$allWavFiles = Get-ChildItem -Path C:\Windows\Media\
$wavFiles = @(
    "C:\Windows\Media\Windows Background.wav",
    "C:\Windows\Media\Windows Battery Critical.wav",
    "C:\Windows\Media\Windows Critical Stop.wav",
    "C:\Windows\Media\Windows Ding.wav",
    "C:\Windows\Media\Windows Error.wav",
    "C:\Windows\Media\Windows Foreground.wav",
    "C:\Windows\Media\Windows Hardware Insert.wav",
    "C:\Windows\Media\Windows Hardware Remove.wav",
    "C:\Windows\Media\Windows Information Bar.wav",
    "C:\Windows\Media\Windows Notify Calendar.wav",
    "C:\Windows\Media\Windows Notify Email.wav",
    "C:\Windows\Media\Windows Notify System Generic.wav",
    "C:\Windows\Media\Windows Notify.wav",
    "C:\Windows\Media\Windows User Account Control.wav"
)

while ($true) {
    $curNumber = Get-Random -Minimum 0 -Maximum $($wavFiles.count-1)
    (New-Object Media.SoundPlayer $wavFiles[$curNumber]).PlaySync();
    $waitTime = Get-Random -Minimum 30 -Maximum 300
    Start-Sleep -Seconds $waitTime;
}