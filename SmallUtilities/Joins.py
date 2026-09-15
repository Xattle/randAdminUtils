import pandas as pd
import argparse
import textwrap
import os.path
import logging

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
    prog='Joins',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=textwrap.dedent('''\
        -----------------------------------------------------------------------
        This utility is for joining different data files into one. It uses the
        Pandas join commands for the back-end work. The main advantage of this
        utility is to be able to handle these joins from the command line.
        -----------------------------------------------------------------------
    '''
    )
)

parser.add_argument("-a", "--filea", help="Name of file A to be joined.")
parser.add_argument("-at", "--fileatype", help="The filetype of file A. Defaults assume CSV. Can take CSV or Excel", default='CSV')
parser.add_argument("-ac", "--fileacolumn", help="The column in file A that will be used to match with file B.")
parser.add_argument("-b", "--fileb", help="Name of file B to be joined.")
parser.add_argument("-bt", "--filebtype", help="The filetype of file B. Defaults assume CSV. Can take CSV or Excel", default='CSV')
parser.add_argument("-bc", "--filebcolumn", help="The column in file B that will be used to match with file A.")
parser.add_argument("-j", "--jointype", help="Which kind of join to be performed. Options are: inner, left, right, leftouter, rightouter, fullouter. Deaults to an inner join.", default='inner')

args = parser.parse_args()

if args.filea == '':
    logger.critical('File A must be specified')
    sys.exit(1)
if args.fileb == '':
    logger.critical('File B must be specified')
    sys.exit(1)

if not os.path.isfile(args.filea):
    logger.critical('Cannot find file {}!'.format(args.filea))
    sys.exit(1)
if not os.path.isfile(args.fileb):
    logger.critical('Cannot find file {}!'.format(args.fileb))
    sys.exit(1)

if args.fileacolumn == '':
    logger.critical('File A column header to join must be specified.')
    sys.exit(1)
if args.filebcolumn == '':
    logger.critical('File B column header to join must be specified.')
    sys.exit(1)

def trim_all_columns(df):
    """
    Trim whitespace from ends of each value across all series in dataframe
    """
    trim_strings = lambda x: x.strip() if isinstance(x, str) else x
    return df.applymap(trim_strings)


def runjoin(filea, fileatype, fileacolumn, fileb, filebtype, filebcolumn, jointype):
    if fileatype.lower() == 'csv':
        table_a = pd.read_csv(filea, error_bad_lines=True, dtype=str)
    elif fileatype.lower() == 'excel':
        table_a = pd.read_excel(filea, dtype=str)
    else:
        logger.critical("Fileatype must be set to listed parameter.")
        sys.exit(1)


    if filebtype.lower() == 'csv':
        table_b = pd.read_csv(fileb, error_bad_lines=True, dtype=str)
    elif filebtype.lower() == 'excel':
        table_b = pd.read_excel(fileb, dtype=str)
    else:
        logger.critical("Filebtype must be set to listed parameter.")
        sys.exit(1)

    trim_all_columns(table_a)
    trim_all_columns(table_b)

    #Inner join
    if jointype.lower() == 'inner':
        outdata = pd.merge(table_a,table_b,left_on=fileacolumn,right_on=filebcolumn)

    #Left join
    if jointype.lower() == 'left':
        outdata = pd.merge(table_a,table_b,left_on=fileacolumn,right_on=filebcolumn,how='left')

    #Right join
    if jointype.lower() == 'right':
        outdata = pd.merge(table_a,table_b,left_on=fileacolumn,right_on=filebcolumn,how='right')

    #Outer left join
    if jointype.lower() == 'leftouter':
        outdata=pd.merge(table_a,table_b,left_on=fileacolumn,right_on=filebcolumn,how="outer",indicator=True)
        outdata=outdata[outdata['_merge']=='left_only']

    #Outer right join
    if jointype.lower() == 'rightouter':
        outdata=pd.merge(table_a,table_b,left_on=fileacolumn,right_on=filebcolumn,how="outer",indicator=True)
        outdata=outdata[outdata['_merge']=='right_only']

    #Full outer join
    if jointype.lower() == 'fullouter':
        outdata=pd.merge(table_a,table_b,left_on=fileacolumn,right_on=filebcolumn,how="outer",indicator=True)

    print(outdata)
    return outdata

joindata = runjoin(args.filea, args.fileatype, args.fileacolumn, args.fileb, args.filebtype, args.filebcolumn, args.jointype)
joindata.to_csv('Results-{}.csv'.format(args.jointype), index=False)
