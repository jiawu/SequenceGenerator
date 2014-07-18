#!/bin/bash
for filename in $(find /projects/p20519/jia_output/FIMO/P53_01_*.txt -type f); do
  #decompose filename
  base_filename=$(basename "$filename")
  extension="${base_filename##*.}"
  base_filename="${base_filename%.*}"
  #echo $base_filename
  
  arr=($(echo $base_filename | tr "_" "\n"))
  MOTIF_NAME="${arr[0]}"
  MOTIF_ID="${arr[1]}"
  RUN_ID="${arr[2]}"
  RUN_LENGTH="${arr[3]}"

  #okay now replace the MOTIF_NAME_MOTIF_ID_ with
  #MOTIF_NAME_MOTIF_ID_RUN_ID_RUN_LENGTH
  find="${MOTIF_NAME}_${MOTIF_ID}_s"
  replace="${MOTIF_NAME}_${MOTIF_ID}_${RUN_ID}_${RUN_LENGTH}_s"
  echo $find
  echo $replace
  sed -i -e "s/$find/$replace/g" $filename
  
  split -d -a 4 -l 20000 $filename /projects/p20519/jia_output/FIMO/${base_filename}.
  rm $filename
done
