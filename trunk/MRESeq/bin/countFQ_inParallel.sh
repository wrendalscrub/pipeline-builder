#!/bin/bash -l

# Counts FQ lines for several fastq files in parallel (gnu parallel)
# Assume one job takes X time. Assumes fastq are gzipped.

#PBS -N FQ_counter
#PBS -l nodes=1:ppn=8,walltime=00:30:00

module load $GNU_PARALLEL_MODULE;

# reads from all FASTQ files are compiled here
statFull="$_OUT_DIR/counts_rawFQ.txt";

# ###########
# Calculate num reads
# ###########


jobFile=$_OUT_DIR/countFQ_jobs.txt
cat /dev/null > $jobFile;

echo "Fastq dir is: $_IN_DIR"

outFile=$_OUT_DIR/FQ_stats.txt
cat /dev/null > $outFile;

echo -e "Filename\tR1 fragments\tR2 fragments\t# PE reads" > $outFile;
for sampDir in $_IN_DIR/$patt*; do 	#Petronis_*; do # loop over sample dir
	echo -e "\t $sampDir";
		for f in $sampDir/*R1*.gz; do
		       r1=`basename $f .gz`;
		       r2=$(echo $r1 | awk 'sub(/R1/,"R2",$1)');
		       echo $r1
			r1_reads=`zcat ${sampDir}/${r1}.gz | wc -l | awk '{print $1/4}'`;
		       r2_reads=`zcat ${sampDir}/${r2}.gz | wc -l | awk '{print $1/4}'`;
			# TODO one more command here to write results to a loop-specific file.
		
			# TODO -- convert to gnu-parallel. 
			echo "$r1_reads;$r2_reads" >> $jobFile;
 			pe_reads=`echo "i"| awk -v R1=$r1_reads -v R2=$r2_reads '{print (R1+R2)/2}'`;
			echo -e "$r1\t$r1_reads\t$r2_reads\t$pe_reads" >> $outFile;
		done
done
# TODO: run gnuparallel
# TODO: finally harvest all loop-specific results into one file.
