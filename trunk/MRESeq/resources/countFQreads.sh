#!/bin/bash -l

# countFQread.sh
# counts number of PE reads in a set of fastq files. 
# A read has two paired fragments. Therefore if a sample has 100
# fragments, the script will report 50 reads.
# output will be written in a tab-delimited file.
#
# preconditions: 
# 1. fastq files are expected to be gzip-ed and have the extension
# output file will be written to the directory from which this script
# is run.

#PBS -N countFQ
#PBS -l nodes=1:ppn=8,walltime=01:00:00


outFile=$2;
totSum=0;
r1_reads=`zcat $1 | wc -l | awk '{print $1/4}'`;
pe_reads=`echo "" | awk -v R1=$r1_reads '{print R1}'`;
echo -e "$1\t$r1_reads\t$pe_reads" >> $outFile;
echo "Counting complete for $1"
