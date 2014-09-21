#!/bin/bash

run_number_start=1
run_number_end=10

run_size=10000

batches=1

search_base=SMAD3_02
output=SMAD3
#run_number_current=1

for ((run_number_current=${run_number_start}; run_number_current<=${run_number_end}; run_number_current++))
do
  search=${search_base}_${run_number_current}_${run_size}
  #search example: GATA1_01_5_10000000
  msub_script=$(<fimo_jarray_template.sh)
  #echo "${msub_script}"
  msub_altered="${msub_script//SEARCHBASECONSTANT/${search_base}}"
  #echo "${msub_altered}"
  msub_altered="${msub_altered//SEARCHCONSTANT/${search}}"
  #echo "${msub_altered}"
  msub_altered="${msub_altered//OUTPUTCONSTANT/${output}}"
  echo "${msub_altered}" > fimo_jarray_$search.sh
  msub -t ${search_base}_bigrun${run_number_current}.[1-$batches] fimo_jarray_$search.sh 
  sleep 2m
done
