@Echo Off

REM only arg is the full path of the printer on the print server using backslashes ex: PrinterMap.bat \\PRINTSERVER\PRINTERNAME
rundll32 printui.dll,PrintUIEntry /in /n%1
