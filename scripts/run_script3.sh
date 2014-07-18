#!/bin/sh

MOTIFS="GATA1_01
GATA1_02
GATA1_03
GATA1_04
GATA1_05
GATA1_06
GATA1_Q6
P53_01
P53_02
P53_03
P53_04
P53_05
TRP53_01
TRP53_02
TRP53_03
SMAD_Q6
SMAD_Q6_01
SMAD1_01
SMAD2_Q6
SMAD3_03
SMAD3_Q6
SMAD3_Q6_01
SMAD4_04
SMAD5_Q5"
COUNTER="1"

for run_counter in {11..20}
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
    /home/jjw036/SequenceGenerator/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 1000 65

    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/sequences.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000.txt

    /home/jjw036/SequenceGenerator/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 10000 65
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/sequences.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000.txt

    /home/jjw036/SequenceGenerator/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 100000 65
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/sequences.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_100000.txt

    /home/jjw036/SequenceGenerator/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 1000000 65
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/sequences.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_1000000.txt

    /home/jjw036/SequenceGenerator/seqGen /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt /home/jjw036/SequenceGenerator/TRANSFAC2FIMO.txt $motif_name 10000000 65
    7za a -t7z /projects/p20519/jia_output/SequenceGenerator/sequences.7z /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt
    rm /projects/p20519/jia_output/SequenceGenerator/${motif_name}_${COUNTER}_10000000.txt

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
