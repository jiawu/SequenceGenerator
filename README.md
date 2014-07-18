Hi there,

Requirements:
boost, gcc, edit the Makefile to include the paths to include the boost library

To create your seqGen:
make -f Makeme

To test if it works:
./seqGen test.txt path/to/TRANSFAC2FIMO.txt GATA1_01 10 100

