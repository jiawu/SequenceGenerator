#!/bin/bash

#this is a script that adds jobs in variable batches
#first find all file names
#split filenames into batches
#chunk -> 1 job -> 40 jobs at a time
#for each batch, generate a script that has the fimo command for each file (a job)

#for each job, have a wait time every 40 jobs.

chunk_size=20
counter=0
#get all files
all_filenames=($(find /projects/p20519/jia_output/FIMO/P53_01_*.* -type f))
output_folder="P53_01"

#i need to call 1.. chunk. chunk +1 ... chunk + chunk... etc
#while loop A to check if all files are processed.
#inner loop B to generate command
#while loop A also submits the job
#while loop A also waits 10 minutes between each job submission after 40.

#nbatch should start at 1
nbatch=1
nfiles=${#all_filenames[@]}
max_batch=$(($(($nfiles+$chunk_size-1))/$chunk_size))

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

  compress_command="cat /projects/p20519/jia_output/FIMO/${output_folder}/${cmd_base_filename}_job${cmd_counter}.txt | gzip > /projects/p20519/jia_output/FIMO/${output_folder}/${cmd_base_filename}_job${cmd_counter}.txt.gz" 
}


echo "Processing ${nfiles} files in ${max_batch} batches "

counter=$(($nbatch*$chunk_size))
end_index=0
file_batch=()
while [ $nbatch -lt $(($max_batch+1)) ]; do
  command_list=""
  
  #every 40 jobs, sleep 4 minutes
  if [ $(( $nbatch%40 )) -eq 0 ]; then
    echo "pause"  
    sleep 4m
  fi
  if [ $(( $nbatch%80 )) -eq 0 ]; then
    echo "pause"  
    sleep 120m
  fi
  
  #get first batch of files
  end_index=$(($chunk_size+$counter))
  #if the end index is greater than the total number of files
  #the end index is re-evaluated to be nfiles - 1

  if [ "${end_index}" -gt "${nfiles}" ]
  then
    echo "last batch!"
    end_index=$(($nfiles-1))
  fi


  file_batch=("${all_filenames[@]:$counter:$chunk_size}")
  #generate commands for first batch
  echo "Processing batch $nbatch"
  for filename in ${file_batch[*]}; do
    
    base_filename=$(basename "$filename")
    extension="${base_filename##*.}"
    base_filename="${base_filename%.*}"
    generate_pipe $filename $base_filename $extension

    generate_command $filename $base_filename $extension
    
    generate_compress_command $filename $base_filename $extension
    
    #save each command to string
    command_list="$command_list"$'\n'"$pipe_command"$'\n'"$command"$'\n'"$compress_command"
    
    #"$command_list"$'\n'"$command"
    #compress_list="$compress_list"$' '"$compress_command"
    
  done
  echo "$command_list"
  #submit first batch
  cat <<EOS | msub -
#!/bin/bash
#MSUB -A p20519
#MSUB -l walltime=48:00:00
#MSUB -l nodes=1:ppn=1
#MSUB -j oe
#MSUB -M jiawu@u.northwestern.edu
#MSUB -N $nbatch
#MSUB -V
#MSUB -e FIMO_error_file.err
#MSUB -o FIMO_log_file.log
#MSUB -m bae
#MSUB -q normal

${command_list}

EOS
  
  
  let nbatch=nbatch+1
  let counter=$(($counter+$chunk_size))
done



