#!/bin/bash -login

#########################################
# Align FASTQ files using bowtie2
# Ulises Schmill
# Last updated 2014-05-27 by Daniel Groot
#
# This script writes individual .sh files for individual alignment jobs.
# If this script crashes, make sure that the paths exist on the config file. 
#########################################

jobdir=$_OUT_DIR/JOBS_align; # indiv .sh will be written here
mkdir -p $jobdir
alignDir=$_OUT_DIR/BTaligned #output for this step
mkdir -p $alignDir
trimDir=$_OUT_DIR/FASTQtrimmed #output from previous step, input for this one

cd $jobdir;

#################################################
# Start script
#################################################

for rawDir in $_IN_DIR/${patt}*; do #Petronis_*; do
	for fastq in ${rawDir}/${patt}*_R1_*001.fastq.gz; do
		SAMPLE=`basename $fastq`
		SAMPLE=$(echo $SAMPLE | awk 'sub(/_R1/,"",$1)');
		
		P1=${trimDir}/$(basename $fastq .fastq.gz).trimmed.P.fastq.gz;
		P2=$(echo $P1 | awk 'sub(/R1/,"R2",$1)');	
		
		UP1=$(echo $P1 | awk 'sub(/trimmed\.P\./,"trimmed.UP.",$1)'); 
		UP2=$(echo $P2 | awk 'sub(/trimmed\.P\./,"trimmed.UP.",$1)'); 
	
		#output files 
		OSAM=${alignDir}/${SAMPLE}.bt2.concordant.sam; 
		OBAM=$(echo $OSAM | awk 'sub(/sam$/,"bam",$1)');
		
		# fastq -> SAM
		cmd1="$BOWTIE2 --very-sensitive --no-mixed --no-discordant --maxins 1000 -x $GENOME -p 8 -1 $P1 -2 $P2 -U $UP1,$UP2 -S $OSAM &> $OSAM.log";
		# SAM -> BAM
		cmd2="samtools view -bS $OSAM > $OBAM";
		cmd3="rm $OSAM";
	
		# command for job file.
		jobFile=${jobdir}/${SAMPLE}.align.sh
		SAMPLE=${SAMPLE}.alignjob
		echo "#!/bin/bash -login" > $jobFile;
		echo "#PBS -l nodes=1:ppn=8,walltime=$bt2_walltime" >> $jobFile;
		echo "#PBS -N $SAMPLE" >> $jobFile;

		echo "module load $SAMTOOLS_MODULE" >> $jobFile;

		echo "export BOWTIE2_INDEXES=\"${BT2_INDEX}/${GENOME}\"" >> $jobFile;
		echo "$cmd1;" >> $jobFile; # align
		echo "$cmd2;" >> $jobFile; # sam 2 bam
		echo "$cmd3;" >> $jobFile # delete sam
		
		chmod u+x $jobFile;
		echo "created `basename $jobFile`"

	done 
done

