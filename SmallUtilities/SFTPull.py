import pysftp
import argparse
import textwrap
import shutil
import ntpath
import os
import logger

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

#Handle command line args
parser = argparse.ArgumentParser(
    prog='SFTPull',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=textwrap.dedent('''\
        -----------------------------------------------------------------------
        A simple command line method of pulling files over SFTP.
        Will overwrite if full file name is specified in savelocation.
        -----------------------------------------------------------------------
    '''
    )
)

parser.add_argument("server", help="Name of SFTP server to access.")
parser.add_argument("username", help="SFTP Username to log in with.")
parser.add_argument("password", help="Password to log in with.")
parser.add_argument("serverlocation", help="The path to the file or folder on the SFTP server to copy from.")
parser.add_argument("savelocation", help="The path to where the copied file will be saved. Can also rename if specifiying a file.")
parser.add_argument("-p", "--port", help="Port, if different than standard port 22.", default=22)

args = parser.parse_args()

def path_leaf(path):
    head, tail = ntpath.split(path)
    return tail or ntpath.basename(head)

logger.info("Connecting to {} as {}".format(args.server, args.username))
con_info = {'host':args.server,'username':args.username,'password':args.password,'port':args.port}
with pysftp.Connection(**con_info) as sftp:
    logger.info("Copying {} locally.".format(args.serverlocation))
    sftp.get(args.serverlocation)

logger.info("Relocating local {} to {}".format(path_leaf(args.serverlocation),os.path.realpath(args.savelocation)))
shutil.move(path_leaf(args.serverlocation), os.path.realpath(args.savelocation))
logger.info("Operations finished.")
