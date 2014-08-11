#!/bin/bash

#this will be a test script to make sure the outputs are correctly piped from
#to the python output

sequence_file="/projects/p20519/jia_output/FIMO/SMAD3_02_2_10000000.0488"
output_file="/projects/p20519/jia_output/FIMO/P53_01/SMAD3_test.txt"

mkfifo ${output_file}
fimo --max-stored-scores 500000000 --thresh 0.0001 --max-seq-length 250000000 --text /projects/p20519/jia_output/TRANSFAC2FIMO_3242014.txt ${sequence_file} >> ${output_file} &

cat ${output_file} | python FimoEvaluator.py

