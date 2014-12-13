#!/bin/bash -l
# Computes genomic coverage of PE BAM files.
# Shraddha Pai, last updated 31 March 2014.
# Updated by Daniel Groot on 5 May 2014

inBAM=$1
outBED=$2
_SYS_TYPE=$3
BEDTOOLS=$4

# software dependencies
if [ $_SYS_TYPE = "SCINET" ]; then
	module load gcc;
	module load samtools
elif [ $_SYS_TYPE = "SCC" ]; then 
	module load SAMTOOLS 
	module load BEDTOOLS
fi

# I/O
bamBase=`basename $inBAM .bam`;
readSortBAM=`dirname $outBED`/$bamBase.byname
echo "generating index";
samtools index $inBAM;
echo "sorting";
samtools sort -n $inBAM $readSortBAM;
echo "bam->bed";

$BEDTOOLS bamtobed -bedpe -i $readSortBAM.bam > $outBED;
