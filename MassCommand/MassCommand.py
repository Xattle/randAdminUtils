import sys, argparse, os, textwrap, subprocess, shutil, glob, logger

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
        This utility is designed to copy and/or run commands/files on all target systems in the specified hosts file.
        By default, it will:
            Parse host_list.txt for hosts & IPs
            Run the command specified using psexec \\\\host_from_host_list.txt command_given
            Crash your workstation if you aren't careful - It runs each in a new cmd window to allow for parallel operations to maximize speed.
                Fully automatic scripts - strongly suggested
        Operation requirements:
            Admin share enabled on target machines
            psexec utility either in the same folder as this command or fully installed
            Ran from network credentials that can access the target machines. Errors out according to normal psexec rules if they don't work.

        Notes:
            Running parallel windows will bog down or crash your system. It attempts to slow this down but not at the cost of usable deployment speed.
            Test with only one or two hosts in the file to make sure it does what you need. Quotes in the command section get to be painful.
            Yes, you could just use psexec @file but it doesn't run in parallel making it slow for +10 computers. Especially if some are offline.
            Compiles a logfile in same directory as output_log.txt once the command completes
    ''')

)
parser.add_argument("-t", "--targets", help="Name or location of the txt document with the target hosts listed. One per line, no extra punctuation. Defaults to host_list.txt in the current directory.")
parser.add_argument("-c", "--copy", help="Folder or file to be copied to the target system. Can be used without a command to just push files.")
parser.add_argument("-d", "--destination", help="Destination on the target computer to copy to. Defaults to \\c$\\temp")
parser.add_argument("-r", "--run", help="Runs a command on all target machines as this user by running psexec \\\\host COMMAND. Use quotes arround COMMAND.")
parser.add_argument("-a", "--append", help="Rebuilds output_log.txt as normal but anything in .\logs will remain and be appended to.",default=False, action='store_true')
args = parser.parse_args()

#Time for functions
def log_cleaning():
    if args.append is False:
        # Get a list of all the logfiles
        fileList = glob.glob('.\\logs\\*.log')
        # Iterate over the list & remove each file.
        for filePath in fileList:
            try:
                os.remove(filePath)
            except:
                logger.error("Error while deleting file : ", filePath)

def log_control():
        outfilename = ".\\output.log"
        #Take all of the logfiles and generate one centralized log
        with open(outfilename, 'wb') as outfile:
            for filename in glob.glob('.\\logs\\*.log'):
                if filename == outfilename:
                    # don't want to copy the output into the output
                    continue
                with open(filename, 'rb') as readfile:
                    shutil.copyfileobj(readfile, outfile)

def run_command():
    with open(args.targets) as fp:
        line = fp.readline()
        cnt = 1
        while line:
            line = line.strip('\n')
            line = line.strip('\t')

            #Generate header for each logfile
            f = open(f".\\logs\\{line}.log", "a")
            f.write("----------------------------\n")
            f.write(line)
            f.write("\n")

            #Put stuff in the interpreter
            logger.info(f"Running {args.run} on {line}")
            f.write(f"Running psexec \\\\{line} {args.run}")
            f.write("\n")
            f.close()

            #Setup, then run the commands, dumping contents to its own file

            subprocess.Popen(f"start .\\psexec.exe -nobanner -accepteula \\\\{line} {args.run}", shell=True)
            print("--------------------------------------------")
            line = fp.readline()
            cnt += 1

def push_copies():
    if args.destination is None:
        args.destination = "\\c$\\temp"
    with open(args.targets) as fp:
        line = fp.readline()
        cnt = 1
        while line:
            line = line.strip('\n')
            line = line.strip('\t')
            final_destination = f'\\\\{line}{args.destination}'

            #Generate header for each logfile
            f = open(f".\\logs\\{line}.log", "a")
            f.write("----------------------------\n")
            f.write(line)
            f.write("\n")
            f.close()
            #Put stuff in the interpreter
            logger.info(f"Sending {args.copy} to {final_destination}")

            #Setup, then run the commands, dumping contents to its own logfile
            final_command = f'xcopy "{args.copy}" "{final_destination}" /Y /E /H /C /I ^>^> .\\logs\\{line}.log'
            logger.info(final_command)
            subprocess.Popen(f"start cmd.exe /k {final_command}", shell=True)
            print("--------------------------------------------")
            line = fp.readline()
            cnt += 1

#Arg handling
if args.targets is None:
    args.targets = ".\\host_list.txt"

if os.path.isfile(args.targets) == False:
    print()
    logger.error("File does not exist: " + args.targets)
    sys.exit(1)

if args.copy is None and args.run is None:
    print()
    logger.error("Please specify copy, run, or both.")
    sys.exit(1)

#Zhu-Li, do the thing.
if args.copy is not None and args.run is not None:
    log_cleaning()
    push_copies()
    input("Once all copies have been pushed (All windows closed), press Enter to continue...")
    run_command()
    input("Once all commands have ran, press Enter to compile logs and close...")
    log_control()
    sys.exit(0)

if args.copy is not None:
    log_cleaning()
    push_copies()
    input("Once all copies have been pushed (All windows closed), press Enter to compile logs and close...")
    log_control()
    sys.exit(0)

if args.run is not None:
    log_cleaning()
    run_command()
    input("Once all commands have ran (All windows closed), press Enter to compile logs and close...")
    log_control()
    sys.exit(0)
