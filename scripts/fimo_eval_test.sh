#!/bin/bash

#this will be a test script to make sure the outputs are correctly piped from
#to the python output

for i in `seq 1 10`;
do

  sequence_file="/projects/p20519/jia_output/FIMO/GATA1_01/GATA1_01_${i}_1000.0000"
  output_file="/projects/p20519/jia_output/FIMO/test_${i}.txt"

  mkfifo ${output_file}
  fimo --max-stored-scores 500000000 --thresh 0.0001 --max-seq-length 250000000 --text /projects/p20519/jia_output/TRANSFAC2FIMO_3242014.txt ${sequence_file} >> ${output_file} &

  cat ${output_file} | python FimoEvaluator.py

done
