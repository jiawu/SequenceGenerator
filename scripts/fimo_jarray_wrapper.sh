#!/bin/bash

run_number_start=1
run_number_end=10

search_base_array=("P53_01" "SMAD3_02" "GATA1_01")
output_array=("P53" "SMAD3" "GATA1")
nTF=${#search_base_array[@]}

run_size_array=(10000 100000 1000000)
batch_array=(1 1 5)
nrun_size=${#run_size_array[@]}
nbatch_size=${#batch_array[@]}
for (( p=0; p<${nrun_size}; p++));
do
  run_size=${run_size_array[p]}
  batches=${batch_array[p]}
  for (( i=0; i<${nTF}; i++)); 
  do
    search_base=${search_base_array[i]}
    output=${output_array[i]}
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
      sleep 3m
    done
  done
done
