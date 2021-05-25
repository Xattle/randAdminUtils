@echo off
setlocal ENableDelayedExpansion

set /a totalhosts = 1

For /f "delims=" %%h in (AllHosts.txt) DO (
	set /a totalhosts += 1
)

ECHO Total Hosts: %totalhosts%

ECHO Scan started %time% %date% > AllTasks.csv

set /a currenthostcount = 1

set /a currentpercent = 100 * currenthostcount / totalhosts

Title Host !currenthostcount! of %totalhosts% -- !currentpercent!%% Finished

For /f "delims=" %%h in (AllHosts.txt) DO (

ECHO %%h listing tasks.
tasklist /v /s %%h /fo csv > tempfile.csv
ECHO %%h appending temp file.

FOR /f "delims=" %%i in (tempfile.csv) DO (

ECHO %%i, %%h >> AllTasks.csv

)

ECHO %%h finished.

set /a currenthostcount += 1

set /a currentpercent = 100 * currenthostcount / totalhosts

Title Host !currenthostcount! of %totalhosts% -- !currentpercent!%% Finished


)

DEL tempfile.csv