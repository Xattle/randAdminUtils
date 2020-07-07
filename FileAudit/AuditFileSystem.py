#import stuff :P
import csv, sys, argparse, os, textwrap, subprocess
from prettytable import PrettyTable

#Setup argparse stuff
parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=textwrap.dedent('''\
        This utility is designed to take input from either a .csv file or a scan as outlined and format it.
            By default, it prints as a table to the command line
            but can format an output file if defined by -o
                File formats are:
                    .csv
                    .html
                To define them, use the appropriate ending when specifying -o
    ''')

)
parser.add_argument("-i", "--infile", help="Inputfile name. Looks only in local directory if path is not specified.")
parser.add_argument("-s", "--scanpath", help="Defines an absolute path to scan if not using an infile.")
parser.add_argument("-c", "--csvoutput", help="Only use with scanpath. Sets the output name apart from the default Permissions.csv")
parser.add_argument("-o", "--outfile", help="Outfile name. Can specify .csv or .html as the file type. Defaults to .csv")
parser.add_argument("-g", "--generate", help="Generates the ps1 file to build the .csv in case it needs to be ran elsewhere. Use with -s and -c as needed.")
args = parser.parse_args()

#logic variables start here
output_csv = False
output_html = False
output_cli = False

#Arg handling
if args.infile is None and args.scanpath is None:
    print("Please enter an infile or a scanpath argument.")
    ###Interactive mode?
    #is_interactive = True
    sys.exit()

if args.outfile is not None:
    if ".csv" in args.outfile:
        output_csv = True
    elif ".html" in args.outfile:
        output_html = True
    else:
        output_cli = True
else:
    output_cli = True

if args.csvoutput is not None:
    csv_output = args.csvoutput
else:
    csv_output = ".\Permissions.csv"

#Function Stuff
def scan_path_ps1():

    if os.path.isfile(csv_output) == True:
        os.remove(csv_output)

    if os.path.isfile(".\GenerateFileAudit.ps1") == True:
        os.remove(".\GenerateFileAudit.ps1")

    write_ps1_file()

    subprocess.call('powershell.exe -command Set-ExecutionPolicy RemoteSigned', shell=True)
    subprocess.call('powershell.exe .\GenerateFileAudit.ps1', shell=True)
    os.remove(".\GenerateFileAudit.ps1")

def write_ps1_file():
    f = open("GenerateFileAudit.ps1", "a")
    ps1_contents=textwrap.dedent(f'''\
        $OutFile = "{csv_output}"
        $Header = "Folder Path,IdentityReference,AccessControlType,FileSystemRights,IsInherited,InheritanceFlags,PropagationFlags,"
        Del $OutFile
        Add-Content -Value $Header -Path $OutFile

        $RootPath = "{args.scanpath}"
        ''')

    ps1_contents = ps1_contents + textwrap.dedent('''\
        $Folders = dir $RootPath -recurse | where {$_.psiscontainer -eq $true}

        foreach ($Folder in $Folders){
           $ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access }
              Foreach ($ACL in $ACLs){
                    $OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference + "," + $ACL.AccessControlType + "," + $ACL.FileSystemRights + ","+ $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
                                Add-Content -Value $OutInfo -Path $OutFile
                    echo $OutInfo
                                   }
                                   }

            ''')
    f.write(ps1_contents)
    f.close()

def cli_table_display():
    table = PrettyTable()
    table.field_names = ["User Group", "File System Rights", "Folder Path", "Is Inherited"]
    with open(args.infile, mode='r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        line_count = 0
        display_count = 0
        for row in csv_reader:
            if row["IsInherited"] == "False":
                table.add_row([row["IdentityReference"],row["FileSystemRights"],row["Folder Path"],row["IsInherited"]])
                display_count += 1
            line_count += 1
        table.sortby = "User Group"
        print(table)
        print()
        print(f'Inheritance Flag filter is active. Displaying {display_count} out of {line_count} entries.')

##############################
#Call functions and run stuff#
if args.generate is True:
    write_ps1_file()
    print("GenerateFileAudit.ps1 has been created.")
elif args.infile is not None and args.scanpath is None:
    #Check for infile being the right type and existing
    if ".csv" not in args.infile:
        print()
        print("Infile is not of type .csv")
        sys.exit()

    if os.path.isfile(args.infile) == False:
        print()
        print("File does not exist: " + args.infile)
        sys.exit()

    #Say Stuff
    print ()
    print ("Infile: " + args.infile)
    if args.outfile is not None:
        print ("Outfile: " + args.outfile)
    else:
        print ("Outfile not specified. Displaying table in cli.")
    print()
    cli_table_display()
    print(f"Scan and charting complete. CSV file has been saved as {csv_output}")
elif args.scanpath is not None:
    scan_path_ps1()
    args.infile = csv_output
    cli_table_display()
else:
    print("How did you find me?")
