filepathlist=$(ls /projects/p20519/jia_output/FIMO/P53_01/P53_01_{1..575}_filelist.txt)
for item in $filepathlist; do
  echo $item
  while read file; do rm "$file"; done < $item
  echo $file
done
