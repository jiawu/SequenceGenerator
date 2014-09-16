#!/bin/bash

#this is a script that adds jobs in variable batches via job arrays.

#first find all file names
#split filenames into batches

#split filenames into batches
# 1 chunk -> 1 job -> 40 sequences at a time
# for each batch, generate a a script that has a fimo command for each file (a
# job)

chunk_size=20
counter=0
all_filenames=($(find /projects/p20519/jia_output/FIMO/P53_01/P53_01_*.* -type f))
output_folder="P53_output"

nbatch=1
nfiles=${#all_filenames[@]}
max_batch=$(($(($nfiles+$chunk_size-1))/$chunk_size))i

#this script will generate one job array (500 jobs)
#how is this different from fimo_script.sh?
#each chunk = batch

generate_pipe () {
  #echo "file name is $1"
  #echo "base file name is $2"
  #echo "counter is $3"
  local cmd_filename=$1
  local cmd_base_filename=$2
  local cmd_counter=$3

  pipe_command="mkfifo /projects/p20519/jia_output/FIMO/${output_folder}/${cmd_base_filename}_job${cmd_counter}.txt" # in bash, all variables declared inside the function is shared with the# calling environment
}

generate_command () {
  #echo "file name is $1"
  #echo "base file name is $2"
  #echo "counter is $3"
  local cmd_filename=$1
  local cmd_base_filename=$2
  local cmd_counter=$3

  command="fimo --max-stored-scores 500000000 --thresh 0.0001  --max-seq-length 250000000 --text /projects/p20519/jia_output/TRANSFAC2FIMO_3242014.txt $cmd_filename >> /projects/p20519/jia_output/FIMO/${output_folder}/${cmd_base_filename}_job${cmd_counter}.txt &" # in bash, all variables declared inside the function is shared with the calling environment
}

generate_compress_command () {
  #echo "file name is $1"
  #echo "base file name is $2"
  #echo "counter is $3"
  local cmd_filename=$1
  local cmd_base_filename=$2
  local cmd_counter=$3

  compress_command="cat /projects/p20519/jia_output/FIMO/${output_folder}/${cmd_base_filename}_job${cmd_counter}.txt | python /home/jjw036/SequenceGenerator/scripts/FimoEvaluator_P53.py"
}

