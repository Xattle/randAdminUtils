This is a collection of Windows System administration tools.
They're made up of:
  Python
  Bash
  Powershell

And utilitze existing utilites like:
  Psexec
  Psinfo

Due to local system differences, most of the requirements are local to the folder.
Python scripts will be frozen as needed. pyinstall -f is the current method.

The Private folder in .gitignore is only full of logs, scripts, and ranges that haven't been sanitized yet.

SmallUtilities are fragments that work well with some of the other, larger projects. Some
  of them are less utilities and more "Don't forget this useful snippet"

MassCommand is the most developed right now, followed by FileAudit.

Connection test is a concept that needs finished
PrintLists is unclean but usable. Leaves unnecessary files on the target system.
  Probably replaceable with a SmallUtility after MassCommand is finalized.

Speedtest uses Selenium to navigate to openspeedtest.com and pull results.
  The advantage of this is it purely uses HTML5 so any traffic comes across as standard browsing.
  Locally, it runs with GUI enabled
  Using psexec to run on a remote machine, it will cause no pop ups or notifications for any logged in users that it ran.
    In psexec, use the exe made using pyinstall -f to avoid dependency. Still needs edge and selenium driver in same folder.
