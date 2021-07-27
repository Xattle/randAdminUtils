#Pulls hrefs out of wordpress dumps. More work needed to make it useful but did its job.
#Merged from removed smallUtils repo

import csv, argparse, sys, os
from bs4 import BeautifulSoup

parser = argparse.ArgumentParser(description="Turn WP Database dumps into more useful things. Adds a column with all hyperlinks in a post. Delims are # and |")

parser.add_argument("-i", "--infile", help="Input a csv here.")
parser.add_argument("-o", "--outfile", help="Set the csv output here.")
args = parser.parse_args()

nl = "\n"
#Error handling
if ".csv" not in args.infile:
    print("Infile must be of type .csv")
    sys.exit

if ".csv" not in args.outfile:
    print("Outfile must be of type .csv")
    sys.exit

if os.path.isfile(args.infile) == False:
    print("Infile does not exist.")
    sys.exit

if os.path.isfile(args.outfile) == True:
    print("Outfile exists! Overwriting File")
    input("Press ENTER to confirm overwrite...")
    os.remove(args.outfile)

f = open(f"{args.outfile}", "a")

with open(args.infile, 'r') as read_obj:
    csv_reader = csv.reader(read_obj, delimiter="#", quotechar="|")
    for row in csv_reader:
        #Magic happens here
        output_data = row
        row_hrefs = ""
        soup = BeautifulSoup(row[4])
        for link in soup.findAll("a"):
            this_href = link.get("href")
            row_hrefs = (f"{row_hrefs}   {this_href}")
        output_data.append(row_hrefs)
        print(row_hrefs)
        f.write("#####".join(output_data))
        f.write(nl)
