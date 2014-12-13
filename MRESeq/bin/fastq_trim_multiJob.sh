#!/bin/bash -login

#########################################
# Process FASTQ files using Trimmomatic
# Ulises Schmill
# Last updated 2014-04-29
#########################################

# This script needs no input, it will be run via submissionScript.sh and will create per file, a script to perform counting and trimming.
# If there are any problems with this script once it has run and crashed on the script, Check first of all the paths in the config file, especially that of the $COUNTER since it may change place or permissions. 
# Adjustment to the Trimmomatic trimming parameters is discouraged but if necessary be vigilent, Trimmomatic is very specific

COUNTER=$(readlink -m $COUNTER)

jobdir=$_OUT_DIR/JOBS_fastqtrim
trimDir=$_OUT_DIR/FASTQtrimmed
mkdir -p $jobdir # -p flag only creates the Dir if it does not exist.
mkdir -p $trimDir
cd $jobdir; # so log files will be generated here.

#################################################
# Start script
#################################################

for rawDir in $_IN_DIR/${patt}*; do #Petronis_H*; do
	for f in ${rawDir}/*_R1_*001.fastq.gz; do
		r1=`basename $f .fastq.gz`; 
		echo $r1
		r2=$(echo $r1 | awk 'sub(/R1/,"R2",$1)');
		FQ1=${rawDir}/${r1}.fastq.gz; 
		FQ2=${rawDir}/${r2}.fastq.gz;
		PAIRED1=${trimDir}/${r1}.trimmed.P.fastq.gz; 
		PAIRED2=${trimDir}/${r2}.trimmed.P.fastq.gz
		UNPAIRED1=${trimDir}/${r1}.trimmed.UP.fastq.gz; 
		UNPAIRED2=${trimDir}/${r2}.trimmed.UP.fastq.gz
		LOG=${trimDir}/${r1}.trimmomatic.log
		
		# see trimmomatic user manual for details.
		cmd1="java -jar $TRIMMOMATIC PE -threads 8 -trimlog $LOG $FQ1 $FQ2 $PAIRED1 $UNPAIRED1 $PAIRED2 $UNPAIRED2 ILLUMINACLIP:${ADAPTERS}/$ADAPTER:2:15:12 TRAILING:20 MINLEN:$TRIM_MINLENGTH";
		readCount_trimmed=${trimDir}/trimmed_FastQ_readCount.txt;
		cat /dev/null > $readCount_trimmed;
		cmd2="sh -l $COUNTER $PAIRED1 $readCount_trimmed";
		cmd3="sh -l $COUNTER $PAIRED2 $readCount_trimmed";
		cmd4="sh -l $COUNTER $UNPAIRED1 $readCount_trimmed";
		cmd5="sh -l $COUNTER $UNPAIRED2 $readCount_trimmed";
	
		##### Write commands to Shell script
		SAMPLE=$r1;
	        jobFile=${jobdir}/${SAMPLE}.trim.sh;
		SAMPLE=${SAMPLE}.trimjob
	        echo "#!/bin/bash -login" > $jobFile;
	        echo "#PBS -l nodes=1:ppn=8,walltime=$fastq_trim_walltime" >> $jobFile;
	        echo "#PBS -N $SAMPLE" >> $jobFile;

		echo "module load $JAVA_MODULE" >> $jobFile;

	        echo "$cmd1;" >> $jobFile; # trim
		echo "" >> $jobFile;
		echo "module load $GNU_PARALLEL_MODULE" >> $jobFile
		echo "$cmd2;">> $jobFile;
		echo "$cmd3; $cmd4; $cmd5;" >> $jobFile
	        chmod u+x $jobFile;      
	done
done

