#!/bin/bash -l

# This script for a given list of samples, will create scripts to run fastqc on each file on the cluster. 
# IF ANY ERROR ARISES WITH THIS SCRIPT, check that $FASTQC exists and is readable, as well as that extensions of the files do in fact end in "01.fastq.gz"


fastqcoutputdir="$_OUT_DIR/FastQC_OUTPUT"
mkdir -p $fastqcoutputdir

JOBDIR=$_OUT_DIR/JOBS_FASTQC
mkdir -p $JOBDIR
cd $JOBDIR

for rawDir in $_IN_DIR/${patt}* #Petronis_*
	do
	for f in $rawDir/*.fastq.gz
		do
		r1=`basename $f .fastq.gz`
		cmd="$FASTQC $f --o $fastqcoutputdir"

		SAMPLE=$r1
		echo $SAMPLE
		# Start writing script for file, f.
		jobFile=${JOBDIR}/${SAMPLE}.fastqc.sh
		echo "#!/bin/bash -l" > $jobFile
		echo "#PBS -l nodes=1:ppn=8,walltime=$fastqc_walltime" >> $jobFile
		echo "#PBS -N $SAMPLE.fastqc" >> $jobFile
		
		echo "module load $JAVA_MODULE" >> $jobFile

		echo "$cmd" >> $jobFile
		chmod u+x $jobFile
	done
done

