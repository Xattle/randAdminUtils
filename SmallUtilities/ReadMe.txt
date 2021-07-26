###################################
AllTasklists
Creates csv output of all tasks running on all hosts listed in
local AllHosts.txt file

Saves as AllTasks.csv

###################################
GetMessageStatsToFile
Scavenged script. Well documented.
Read through script and determine usability.

Grabs message stats by account for a timeframe from a local exchange server.

###################################
InstallOrUninstallService
Simple thing to register or remove an exe as a service.
Used for C# service builds. Has not been tested using any other kind of exe.

###################################
Joins
Does SQL style joins of Excel or CSV files using Pandas.
Run Joins.py -h for more details.

###################################
jreInstall
Edit JAVA PATH before using.
Copies jre-8u291-windows-x64.exe from a location into C:\Files\ then
installs silently and disables auto updates. Works well with psexec.

###################################
MailboxInfoIndividualFolders
Makes csv file with all users, folders, and respective sizes used for
local exchange instance.

###################################
MailboxInfoSummary
Same as Individual Folders above but only outputs users and total size.

###################################
PrinterMap
Takes a single arg, the full path of a printer on a print server. Then maps it.

###################################
PrinterMapAndDefault
Same as PrinterMap but then makes it the default.
