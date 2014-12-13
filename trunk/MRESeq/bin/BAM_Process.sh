#!/bin/bash -login

# #################################################################
# NGS post-alignment processing
# #################################################################
# Steps:
# 0. 	-> count # reads
# 1. Filter for reads that are mapped + mate is mapped + mapQ = 42
# 	-> count # reads
# 2. Filter by insert size.
# 2b. Convert SAM -> BAM
# 	-> count # reads
# 3. Sort by genomic coordinate.
#
# Author: Shraddha Pai and Ulises Schmill
# Last updated: 29 April 2014
# #################################################################

jobdir=$_OUT_DIR/JOBS_bamprocess
mapqDir=$_OUT_DIR/filtered_bams
alignDir=$_OUT_DIR/BTaligned
mkdir -p $mapqDir
mkdir -p $jobdir
cd $jobdir;

FILTER_ISIZE=$_PIPELINE_DIR/resources/BAM_filterByIsize # c++ executable
isize_min=0; isize_max=1000;

for sampleDir in $_IN_DIR/${patt}*; do
	bamBase=`basename $sampleDir`_001.fastq.gz.bt2.concordant
	filtMAPQ_bam=${mapqDir}/${bamBase}.f_MAPQ.bam;	
	osam=${mapqDir}/${bamBase}.f_MAPQ.f_isize.sam;
	obam=${mapqDir}/${bamBase}.f_MAPQ.f_isize.bam;
	sorted_bam=${mapqDir}/${bamBase}.f_MAPQ.f_isize.sorted;
	stats=$mapqDir/$bamBase.stats.txt

	# 0. get align stats
	cmd0="samtools flagstat $bamFile > $stats" # stats right after align

	# 1. FILTER 1: Mated + MAPQ
	# flag 3 = mapped + mate mapped. -q 42 filters for MAPQ=42
	cmd1="samtools view -bhf 3 -q 42 $bamFile > $filtMAPQ_bam"
	cmd1b="samtools flagstat $filtMAPQ_bam > ${filtMAPQ_bam}.stats.txt";
	
	# 2. FILTER 2: Filter by insert size
	cmd2="samtools view -h ${filtMAPQ_bam} | $FILTER_ISIZE $isize_min $isize_max $osam"
	# 2b. convert SAM to BAM
	cmd2b="samtools view -hbS $osam > $obam"
	cmd2c="samtools flagstat $obam > ${obam}.stats.txt"

	# 3. Order by genomic coordinate
	cmd3="samtools sort $obam $sorted_bam"

	# ###############
	# Write job submission script
	# ###############
	SAMPLE=$bamBase;
        jobFile=${jobdir}/${SAMPLE}.bam_process.sh;
	SAMPLE=${SAMPLE}.BAMjob
        echo "#!/bin/bash -login" > $jobFile;
        echo "#PBS -l nodes=1:ppn=8,walltime=${bam_process_walltime}" >> $jobFile;
        echo "#PBS -N $SAMPLE" >> $jobFile;

	echo "module load $SAMTOOLS_MODULE" >> $jobFile
        
        echo "$cmd0;" >> $jobFile; 		# flagstat
	echo "$cmd1; " >> $jobFile; 	# MAPQ filter + flagstat
	echo "$cmd1b; " >> $jobFile 
	echo "$cmd2 " >> $jobFile;
	echo "$cmd2b" >> $jobFile;
	echo "$cmd2c; ">> $jobFile; # ISIZE filter + sam2bam + flagstat
	echo "$cmd3;" >> $jobFile		# sort by genomic coord
        chmod u+x $jobFile;      
done


