#!/bin/bash


#battle plan:
# just run FIMO for now.
for filename in $(find /projects/p20519/jia_output/FIMO/*.txt -type f);
do
  echo $filename
  #cat <<EOS | msub -
#!/bin/bash
#MSUB -A
  #sed -n 1,2000p ${filename}
done
