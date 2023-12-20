#!/bin/bash

filejs=${1}
bspl=`/home/bkoffee/anaconda3/bin/jq '.[].sample' "$filejs"`; echo BioSample: "${bspl//\"/}"
filnm=`/home/bkoffee/anaconda3/bin/jq '.[].accession' "$filejs"`; echo Acession: "${filnm//\"/}"
smr=`esearch -db biosample -query $bspl | esummary -mode json`
splnm=`echo "$smr" | /home/bkoffee/anaconda3/bin/jq '.. | select(.title?).title'`
splnm=${splnm^^}
attb=`/home/bkoffee/anaconda3/bin/jq '.. | select(.sampledata?).sampledata' <<< "$smr"`
attb=${attb##*<Attributes>}
attb=${attb%</Attributes>*}
attnms=$(echo $attb | grep -oP '(?<=<Attribute ).*?(?=</Attribute>)' | tr '\n' '^')
elemn=$(echo $attb | grep -oP '(?<=attribute_name=\\").*?(?=\\")' | wc -l)
echo "$elemn" Attributes
while [ $elemn -gt 0 ]
  do
  attln=$(echo $attnms | cut -d "^" -f$elemn)
  attln=${attln##*attribute_name=\\\"}
  attnm=$(echo $attln | cut -d "\\" -f1)
  attnm=${attnm^^}
  attnm="${attnm//[^[:alnum:]]/_}"
  attnm="${attnm//__/_}"
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
  if [ -z $attvart ]
    then
      attvart=${filnm//\"/},${bspl//\"/},$attvar
    else
      attvart+=,$attvar
    fi
  echo Attribute: $attnm:$attvar
  elemn=$((--elemn))
  done
echo $attnmt > ${filnm//\"/}_SAMPLEINFO.csv
echo $attvart >> ${filnm//\"/}_SAMPLEINFO.csv
unset attvart
unset attnmt
