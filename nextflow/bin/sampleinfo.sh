#!/bin/bash

# USAGE: Parsing .json metadata information from sequencing reads into .csv files headed with file name, sample name and each attribute

# Creating the file variable from outside the script (from nextflow pipeline or command line flag)
filejs=${1}
jqpth=`which jq`

# Creating variable with BioSample value
bspl=`$jqpth '.[].sample' "$filejs"`; echo BioSample: "${bspl//\"/}"

# Creating variable with Accession number
filnm=`$jqpth '.[].accession' "$filejs"`; echo Acession: "${filnm//\"/}"

# Gathering .json metadata information from Entrez Utilities into variable
smr=`esearch -db biosample -query $bspl | esummary -mode json`

# Parsing attributes information from metadata into variables
## Sample Name
splnm=`echo "$smr" | $jqpth '.. | select(.title?).title'`
splnm=${splnm^^}
## Sample Data including all attributes from file
attb=`$jqpth '.. | select(.sampledata?).sampledata' <<< "$smr"`
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
      attnmt=FILE_NAME,SAMPLE_NAME,$attnm
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
      attvart=${filnm//\"/},${bspl//\"/},$attvar
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
