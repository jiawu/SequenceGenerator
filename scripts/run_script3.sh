#!/bin/sh

MOTIFS="SMAD3_02"
COUNTER="1"

for run_counter in {1..10}
do
  COUNTER="$run_counter"
  for motif_name in $MOTIFS
  do
    cat <<EOS | msub -

    #!/bin/bash
    #MSUB -A p20519
    #MSUB -M jiawu@u.northwestern.edu
    #MSUB -e seqGen_error_file.err
    #MSUB -o seqGen_log_file.log
    #MSUB -l walltime=24:00:00
    #MSUB -l nodes=1:ppn=1
    #MSUB -j oe
    #MSUB -m bae
    #MSUB -V
    #MSUB -N ${motif_name}_${COUNTER}

    module load boost
    module load gcc
    module load utilities
    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 1000 65


    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 10000 65

    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 100000 65

    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 1000000 65

    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 10000000 65

EOS
  done
  jobs_running=true
  while ((jobs_running)); do
    if [ -n $(qselect -u jjw036 -s QR)]; then
      echo "there are no jobs"
      scp /projects/p20519/jia_output/SequenceGenerator/sequences.7z jia_wu@hera.chem-eng.northwestern.edu:/home/jia_wu/Public/SequenceGenerator/.
      jobs_running=false
    else
      echo "there are jobs"
      now=$(date + "%T")
      echo "Run counter : $run_counter Current time : $now"
      sleep 10m
    fi
  done
done
