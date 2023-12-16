#!/usr/bin/env python

import json
import argparse
import os

parser = argparse.ArgumentParser(description='Get SRA FTP from JSON')
parser.add_argument('--json', type=str, dest='json_file',
                    help='JSON file', metavar="ffq_output.json",
                    required=True)
parser.add_argument('--sra', type=str, dest='sra_accession',
                    help='SRA Accession', metavar="SRR1156953",
                    required=False)
args = parser.parse_args()

ffq_file = args.json_file

sra_accession = ''

if args.sra_accession:
    sra_accession = args.sra_accession
else:
    sra_accession = ffq_file.split("/")[-1].replace(".json", "")

ffq_dict = json.load(open(ffq_file))

for sra in ffq_dict[sra_accession]['files']['ftp']:
    os.system("wget "+sra['url'])
    md5_ffq = sra['md5']
    file_name = sra['url'].split('/')[-1]
    md5_downloaded = os.popen(f'md5sum {file_name} | sed "s/ \+/\t/g" | cut -f1').read().rstrip()
    if md5_ffq == md5_downloaded:
        print("MD5 matches")
    else:
        print("MD5 does not match")
        exit(1)
