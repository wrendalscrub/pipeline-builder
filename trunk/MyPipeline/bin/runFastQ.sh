#!/bin/bash -l
# runFastQ.sh
# run FastQC on all .fastq.gz files in the input directory. 

module load $JAVA_MODULE
for f in $_IN_DIR/*.fastq.gz
	do
	echo $FASTQC
	$FASTQC $f --o $_OUT_DIR
done
