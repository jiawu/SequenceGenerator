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
# need to utilize ${MOAB_JOBARRAYINDEX}

#need to generate job array script for one batch!
#transform numbers into index

#workflow
# 1. generate index file for all the files
# 2. generate general MOAB.pbs file that utilizes indexes, and has 20 commands
  # a. name of the file should include chunk_size

#submit via msub jobname.[1-end index:chunksize] myscript.pbs


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
echo "Processing ${nfiles} files in ${max_batch} batches"

counter=$(($nbatch*$chunk_size))
end_index=0
file_batch=()
while [ $nbatch -lt $(($max_batch+1)) ]; do
  command_list=""
  
  if [ $(( $nbatch%40 )) -eq 0 ]; then
    echo "pause"
    sleep 2m
  fi
  if [$(( $nbatch%200 )) -eq 0 ]; then
    echo "pause"
    sleep 60m
  fi

  end_index=$(($chunk_size+$counter))

  if [ "${end_index}" -gt "${nfiles}" ]
  then
    echo "last batch"
    end_index=$(($nfiles-1))
  fi

  file_batch=("${all_filenames[@]:$counter:$chunk_size}"
  echo "Processing batch $nbatch"
  for filename in ${file_batch[*]}; do

    base_filename=$(basename "$filename")
    extension="${base_filename##*.}"
    base_filename="${base_filename%.*}"

    generate_pipe $filename $base_filename $extension

    generate_command $filename $base_filename $extension

    generate compress_command $filename $base_filename $extension

    command_list="$command_list"$'\n'"$pipe_command"$'\n'"$command"$'\n'"$compress_command"

  done
  echo "$command_list"

  cat <<EOS | msub -
#!/bin/bash
#MSUB -A p20519
#MSUB -l walltime=24:00:00
#MSUB -l nodes=1:ppn=1
#MSUB -j oe
#MSUB -M jiawu@u.northwestern.edu
#MSUB -N P53_$nbatch
#MSUB -V
#MSUB -e FIMO_error_file.err
#MSUB -o FIMO_log_file_p53.log
#MSUB -m bae
#MSUB -q normal

workon seqgen
module load python/anaconda3
${command_list}
EOS

