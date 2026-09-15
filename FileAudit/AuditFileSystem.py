#import stuff :P
import csv, sys, argparse, os, textwrap, subprocess
from prettytable import PrettyTable
import logging

#Default variable starts for later
scan_things = False
output_csv = False
output_html = False
output_cli = False

#Make logger and do stuff
logger=logging.getLogger(__name__)
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler = logging.StreamHandler(sys.stderr)
handler.setFormatter(formatter)
logger.addHandler(handler)
handler = logging.StreamHandler(sys.stderr)
handler.setFormatter(formatter)
logger.addHandler(handler)
del handler

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
parser.add_argument("-c", "--csvoutput", help="Only use with scanpath. Sets the output name apart from the default Permissions.csv for the raw scan data")
parser.add_argument("-o", "--outfile", help="Outfile name. Can specify .csv or .html as the file type. Defaults to .csv")
parser.add_argument("-g", "--generate", help="Generates the ps1 file to build the .csv in case it needs to be ran elsewhere. Use with -s and -c as needed.")
args = parser.parse_args()

#Function Stuff
def scan_path_ps1():
    if args.csvoutput is None:
        args.csvoutput = ".\Permissions.csv"
    args.infile = args.csvoutput
    if os.path.isfile(args.csvoutput) == True:
        os.remove(args.csvoutput)

    if os.path.isfile(".\GenerateFileAudit.ps1") == True:
        os.remove(".\GenerateFileAudit.ps1")

    write_ps1_file()

    subprocess.call('powershell.exe -command Set-ExecutionPolicy RemoteSigned', shell=True)
    subprocess.call('powershell.exe .\GenerateFileAudit.ps1', shell=True)
    os.remove(".\GenerateFileAudit.ps1")
    logger.info(f"Scan is now finished and raw csv outputted to {args.csvoutput}")

def write_ps1_file():
    f = open("GenerateFileAudit.ps1", "a")
    ps1_contents=textwrap.dedent(f'''\
        $OutFile = "{args.csvoutput}"
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

def html_formatter():
    html_name = args.outfile.replace(".html", "")
    html_output_top=textwrap.dedent(f'''\
        <!DOCTYPE html>
        <html>
        <head>
        <title>{html_name}</title>
        <style>
        ''')
    html_output_predata=textwrap.dedent('''\
        table {
          border-spacing: 0;
          width: 100%;
          border: 1px solid #ddd;
        }

        th {
          cursor: pointer;
        }

        th, td {
          text-align: left;
          padding: 16px;
        }

        tr:nth-child(even) {
          background-color: #f2f2f2
        }
        </style>
        </head>
        <body>

        <p><strong>Sortable by header.</strong></p>
         <table id="myTable">
          <tr>
            <th onclick="sortTable(0)">User Group</th>
            <th onclick="sortTable(1)">File System Rights</th>
            <th onclick="sortTable(2)">Folder Path</th>
            <th onclick="sortTable(3)">Is Inherited</th>
          </tr>
    ''')
    html_output_postdata=textwrap.dedent('''\

        <script>
        function sortTable(n) {
          var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
          table = document.getElementById("myTable");
          switching = true;
          dir = "asc";
          while (switching) {
            switching = false;
            rows = table.rows;
            for (i = 1; i < (rows.length - 1); i++) {
              shouldSwitch = false;
              x = rows[i].getElementsByTagName("TD")[n];
              y = rows[i + 1].getElementsByTagName("TD")[n];
              if (dir == "asc") {
                if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                  shouldSwitch= true;
                  break;
                }
              } else if (dir == "desc") {
                if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                  shouldSwitch = true;
                  break;
                }
              }
            }
            if (shouldSwitch) {
              rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
              switching = true;
              switchcount ++;
            } else {
              if (switchcount == 0 && dir == "asc") {
                dir = "desc";
                switching = true;
              }
            }
          }
        }
        </script>

        </body>
        </html>

    ''')
    if os.path.isfile(args.outfile) == True:
        os.remove(args.outfile)

    f = open(f"{args.outfile}", "a")
    f.write(html_output_top)
    f.write("\n")
    f.write(html_output_predata)
    f.write("\n")
    f.write(f"")

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
        f.write(table.get_html_string())


    f.write("\n")
    f.write(html_output_postdata)
    f.close

    f1 = open(args.outfile, 'r')
    f2 = open(args.outfile, 'w')
    for line in f1:
        f2.write(line.replace('table', 'table id="myTable"'))
    f1.close()
    f2.close()

    logger.info(f"HTML Output has been sent to: {args.outfile}")

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
        # Not switching to logger.info because this seems that it's meant to prettyprint, not log anything
        print(table)
        print()
        print(f'Inheritance Flag filter is active by default. Displaying {display_count} out of {line_count} entries.')

##############################
#Check for args and set bools#
if args.infile is None and args.scanpath is None:
    logger.error("Please enter an infile or a scanpath argument.")
    sys.exit(1)

if args.infile is not None and args.scanpath is not None:
    logger.error("Choose infile or scanpath, not both")
    sys.exit(1)

if args.scanpath is not None:
    scan_things = True

if args.outfile is not None:
    if ".csv" in args.outfile:
        output_csv = True
    elif ".html" in args.outfile:
        output_html = True
    else:
        logger.warn("Outfile is not specified or not .csv/.html. Outputting to CLI.")
        output_cli = True

##############################
#Call functions and run stuff#
if scan_things is True:
    scan_path_ps1()

if output_csv == True:
    logger.warn("CSV Output not set up!! Displaying CLI Output.")
    cli_table_display()
elif output_html == True:
    html_formatter()
elif output_cli == True:
    cli_table_display()

if args.generate is True:
    write_ps1_file()
    logger.info("GenerateFileAudit.ps1 has been created.")
