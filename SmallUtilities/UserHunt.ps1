# Returns users on a list of computers. First arg is file location, line delimited hostnames.
# Second arg is blank or yes. Adding yes only returns hosts without users.

param ($filename,$available)
write-host "Checking hosts in $filename for active users..."

foreach($line in Get-Content $filename) {
    $result = ''
    if ($available -eq 'yes') {
        $result = $(query user /server:$line 2>&1)
        if ($result -like '*No User exists for*') {
            write-host $line has no users.
        }
    } else {
        write-host $line
        query user /server:$line
        write-host ----------------------
    }
}