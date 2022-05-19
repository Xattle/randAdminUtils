# Disable the advanced power saving mode on all USB Hubs 
# Has to be ran as admin
# Device Manager, Universal Serial Bus controllers, Select USB Root Hub, Properties, Power Management, deselect "Allow the computer to turn off this device to save power"

$hubs = Get-WmiObject Win32_USBHub
$powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
foreach ($p in $powerMgmt)
{
  $IN = $p.InstanceName.ToUpper()
  foreach ($h in $hubs)
  {
    $PNPDI = $h.PNPDeviceID
                if ($IN -like "*$PNPDI*")
                {
                    $p.enable = $False
                    $p.psbase.put()
                }
  }
}
exit