#!/bin/bash
#MSUB -A p20519
#MSUB -l walltime=168:00:00
#MSUB -l nodes=1:ppn=1
#MSUB -M jiawu@u.northwestern.edu
#MSUB -j oe
#MSUB -o /projects/p20519/jia_output/error.txt
#MSUB -m bae
#MSUB -q long
#MSUB -N GATA1_01_$nbatch
#MSUB -V

export R_LIBS="/home/jjw036/R/library"
export PATH="$PATH:/home/jjw036/.local/bin"
#:/home/jjw036/meme/bin:
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/jjw036/R/library"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/jjw036/.local/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/jjw036/.local/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/hpc/software"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/jjw036/.local/lib64/R/lib"
export WORKON_HOME="/home/jjw036/virtualenv"
export VIRTUALENVWRAPPER_PYTHON="/software/enthought/python/epd_free-7.3.2-rh6-x86_64/bin/python2.7"
export VIRTUALENVWRAPPER_VIRTUALENV="/home/jjw036/.local/bin/virtualenv"
. /home/jjw036/.local/bin/virtualenvwrapper.sh

workon seqgen
module load python/anaconda3

chunk_size=1
counter=0
search_base=GATA1_01
search=GATA1_01_2_10000
all_filenames=($(find /projects/p20519/jia_output/FIMO/${search_base}/${search}.* -type f))
output_folder="GATA1_output"

nbatch=${MOAB_JOBARRAYINDEX}
nfiles=${#all_filenames[@]}
max_batch=$(($(($nfiles+$chunk_size-1))/$chunk_size))

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

  compress_command="cat /projects/p20519/jia_output/FIMO/${output_folder}/${cmd_base_filename}_job${cmd_counter}.txt | python /home/jjw036/SequenceGenerator/scripts/FimoEvaluator.py"
}
echo "Processing ${nfiles} files in ${max_batch} batches"

counter=$(($nbatch*$chunk_size))

end_index=0
file_batch=()
command_list=""
  
end_index=$(($chunk_size+$counter))

if [ "${counter}" -gt "${nfiles}" ]
then
  counter=0
fi
if [ "${chunk_size}" -gt "${nfiles}" ]
then
  chunk_size=${nfiles}
fi

if [ "${end_index}" -gt "${nfiles}" ]
then
  echo "last batch"
  end_index=$(($nfiles-1))
fi

file_batch=("${all_filenames[@]:$counter:$chunk_size}")
echo "Processing batch $nbatch"

for filename in ${file_batch[*]};
do
  base_filename=$(basename "$filename")
  extension="${base_filename##*.}"
  base_filename="${base_filename%.*}"

  mkfifo /projects/p20519/jia_output/FIMO/${output_folder}/${base_filename}_job${extension}.txt
  
  fimo --max-stored-scores 500000000 --thresh 0.0001  --max-seq-length 250000000 --text /projects/p20519/jia_output/TRANSFAC2FIMO_3242014.txt $filename >> /projects/p20519/jia_output/FIMO/${output_folder}/${base_filename}_job${extension}.txt &

  cat /projects/p20519/jia_output/FIMO/${output_folder}/${base_filename}_job${extension}.txt | python /home/jjw036/SequenceGenerator/scripts/FimoEvaluator.py

done
