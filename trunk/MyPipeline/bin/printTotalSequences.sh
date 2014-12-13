#!/bin/bash -l
# printTotalSequences.sh 
# Look in the directory of each analyzed fastq and
#  print the total number of sequences found in fastqc_data.txt. 

for dir in $_OUT_DIR/*
	do
	if [ -r $dir/fastqc_data.txt ]; then
		seq=`grep "Total Sequences" $dir/fastqc_data.txt | awk ' { print $3 } '`
		fqfile=`basename $dir`
		echo "$fqfile: $seq"
	fi
done



