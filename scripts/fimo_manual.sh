#!/bin/bash

#this will be a test script to make sure the outputs are correctly piped from
#to the python output

#sequence_file1="/projects/p20519/jia_output/FIMO/GATA1_01/GATA1_01_${i}_1000.0000"
sequence_file1="P53_01_1_7778.txt"
#sequence_file1="P53_01_1_7777.txt"
output_file1="p53_best_optimized_sequences_test_pipe.txt"

mkfifo ${output_file1}
fimo --max-stored-scores 500000000 --thresh 0.0001 --max-seq-length 250000000 --text /projects/p20519/jia_output/TRANSFAC2FIMO_3242014.txt ${sequence_file1}>>${output_file1} &
cat ${output_file1} | python FimoEvaluator.py

#sequence_file2="P53_01_1_7778.txt"
#sequence_file2="SMAD3_02_1_7777.txt"
#output_file2="p53_control_sequences_test.txt"

#mkfifo ${output_file2}
#fimo --max-stored-scores 500000000 --thresh 0.0001 --max-seq-length 250000000 --text /projects/p20519/jia_output/TRANSFAC2FIMO_3242014.txt ${sequence_file2}>>${output_file2} &
#cat ${output_file2} | python FimoEvaluator.py
