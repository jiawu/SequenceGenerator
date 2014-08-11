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
    
    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 10000000 50
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt
    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 1000000 50
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt

    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 100000 50
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt

    /home/jjw036/SequenceGenerator/bin/seqGen
    /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 10000 50
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt
    
    /home/jjw036/SequenceGenerator/bin/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 1000 50
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt



EOS
  done
  jobs_running=true
done
