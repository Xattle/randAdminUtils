New-Item -Path "c:\" -Name "temp" -ItemType "directory"
New-Item -Path "c:\temp\" -Name "screengrab" -ItemType "directory"
function ScreenGrab {
	$mytime = (Get-Date -Format "MM-dd-yyyy.HH-mm") | Out-String
	$mytime = $mytime -replace "`t|`n|`r",""
	$File = "C:\temp\screengrab\Screenshot$($mytime).bmp"
	Add-Type -AssemblyName System.Windows.Forms
	Add-type -AssemblyName System.Drawing
	# Gather Screen resolution information
	$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	$Width = $Screen.Width
	$Height = $Screen.Height
	$Left = $Screen.Left
	$Top = $Screen.Top
	# Create bitmap using the top-left and bottom-right bounds
	$bitmap = New-Object System.Drawing.Bitmap $Width, $Height
	# Create Graphics object
	$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
	# Capture screen
	$graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
	# Save to file
	$bitmap.Save($File)
}

ScreenGrab
