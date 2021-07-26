MassCommand Tool
By Nathan Griswold

A python utility for copying out files and executing commands on large groups of computers, quickly.

PsExec can do most of the things in this script naturally. What this adds is the ability to run everything in parallel.
  Depending on the length of the host_list.txt file, your machine may have difficulties operating.

I'm sure it could be cleaner or smaller. It works how I want it to though.

For further information please run MassCommand.py -h

Requirements
Must have psexec.exe in the same directory as this script run programs but not to copy.

####################TODO###########################
Add output log for run command that captures command output - surprisingly painful

Extremely dirty. Leaves multiple files on target machine unnecessarily.
