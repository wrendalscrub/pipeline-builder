#!/bin/bash -l
# Converts sorted byname bedpe column to expanded (start of +, end of -) and sorted bed file

# input params
inBed=$1
tabix_file=$2
_SYS_TYPE=$3
TABIX=$4

# I/O
bedBase=`basename $inBed .sorted.byname.bam.bed`
outBed=`dirname $tabix_file`/`basename $tabix_file .gz`
# Grabs the chr, start of the first read and end of the second read
# Sorts by position
awk -v OFS="\t" '{print $1, $2, $6}' $inBed | sort -k 1,1 -k 2,2n -k 3,3n > $outBed


if [ $_SYS_TYPE = "SCC" ]; then
	module load TABIX
fi
${TABIX}bgzip -f $outBed
${TABIX}tabix -p bed -0 $tabix_file

