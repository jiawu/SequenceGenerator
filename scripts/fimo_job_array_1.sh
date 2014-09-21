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
`
