#!/bin/bash

# USAGE: Parsing .json metadata information from sequencing reads into .csv files headed with file name, sample name and each attribute

# Creating the file variable from outside the script (from nextflow pipeline or command line flag)
filejs=${1}

# Creating variable with BioSample value
bspl=`jq '.[].sample' "$filejs"`; echo BioSample: "${bspl//\"/}"

# Creating variable with Accession number
filnm=`jq '.[].accession' "$filejs"`; echo Acession: "${filnm//\"/}"

# Gathering .json metadata information from Entrez Utilities into variable
smr=`esearch -db biosample -query $bspl | esummary -mode json`

# Parsing attributes information from metadata into variables
## Sample Name
splnm=`echo "$smr" | jq '.. | select(.title?).title'`
splnm=${splnm^^}
## Sample Project
splprj=`echo "$smr" | jq '.. | select(.accession?).accession'`
echo "$splprj"
## Gather library info
splprjf=`esearch -db sra -query "$splprj" | esummary -db sra`
run_info=$(echo "$splprjf" | awk -v run="$filnm" '/<Run acc="/ {found=($0 ~ run)} found && /<\/ExpXml>/{exit} found')
if echo "$run_info" | awk '/<LIBRARY_LAYOUT>/,/<\/LIBRARY_LAYOUT>/' | grep -q "PAIRED"; then
    layout="PAIRED"
elif echo "$run_info" | awk '/<LIBRARY_LAYOUT>/,/<\/LIBRARY_LAYOUT>/' | grep -q "SINGLE"; then
    layout="SINGLE"
else
    layout="NA"
fi
echo "Library: $layout"

## Sample Data including all attributes from file
attb=`jq '.. | select(.sampledata?).sampledata' <<< "$smr"`
attb=${attb##*<Attributes>}
attb=${attb%</Attributes>*}
## Listing each attribute
attnms=$(echo $attb | grep -oP '(?<=<Attribute ).*?(?=</Attribute>)' | tr '\n' '^')
## Number of attributes
elemn=$(echo $attb | grep -oP '(?<=attribute_name=\\").*?(?=\\")' | wc -l)
echo "$elemn" Attributes
## Starting loop for parsing each attribute into readable information
while [ $elemn -gt 0 ]
  do
  attln=$(echo $attnms | cut -d "^" -f$elemn)
  attln=${attln##*attribute_name=\\\"}
  attnm=$(echo $attln | cut -d "\\" -f1)
  attnm=${attnm^^}
  attnm="${attnm//[^[:alnum:]]/_}"
  attnm="${attnm//__/_}"
## Creating the variable with all information headers and merging with each new attribute from loop
  if [ -z $attnmt ]
    then
      attnmt=FILE_NAME,SAMPLE_NAME,LAYOUT,$attnm
    else
      attnmt+=,$attnm
    fi
  attvar=${attln##*>}
  attvar=${attvar^^}
  attvar="${attvar//[^[:alnum:]]/_}"
  attvar="${attvar//__/_}"
## Creating the variable with all information values and merging with each new attribute from loop
  if [ -z $attvart ]
    then
      attvart=${filnm//\"/},${bspl//\"/},$layout,$attvar
    else
      attvart+=,$attvar
    fi
  echo Attribute: $attnm:$attvar
  elemn=$((--elemn))
  done

# Creating the .csv file with variable headers and values
echo $attnmt > ${filnm//\"/}_SAMPLEINFO.csv
echo $attvart >> ${filnm//\"/}_SAMPLEINFO.csv

# Reseting variables for next loop run
unset attvart
unset attnmt
