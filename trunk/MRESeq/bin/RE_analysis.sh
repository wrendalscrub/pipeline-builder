#!/bin/bash -l

# This script sources the config.sh file that should be in the same folder as this script
# For the given list of samples, it will create scripts to run RE analysis for each file

BAM_TO_BEDPE=$_PIPELINE_DIR/resources/bam_to_bedpe.sh
BEDPE_TO_TABIX=$_PIPELINE_DIR/resources/bedpe_to_tabix.sh
COVERAGE_R_SCRIPT=$_PIPELINE_DIR/resources/MREseq_offset_BAM2RE_coverage_tabix.R

JOBDIR=$_OUT_DIR/JOBS_RE_analysis
REdir=$_OUT_DIR/RE_analysis
BAMdir=$_OUT_DIR/filtered_bams
mkdir -p $REdir
mkdir -p $JOBDIR
cd $JOBDIR

for folder in $_IN_DIR/$patt*; do
	SAMPLE=`basename $folder`
	jobFile=${JOBDIR}/${SAMPLE}.RE_analysis.sh
	echo $jobFile
	echo "#!/bin/bash -l" > $jobFile
	echo "#PBS -l nodes=1:ppn=8,walltime=$REanalysis_walltime" >> $jobFile
	echo "#PBS -N $SAMPLE.REanalysis" >> $jobFile

	echo "module load $R_MODULE" >> $jobFile

	BAM=$BAMdir/${SAMPLE}_001.fastq.gz.bt2.concordant.f_MAPQ.f_isize.sorted.bam
	BED=$REdir/${SAMPLE}_001.fastq.gz.bt2.concordant.f_MAPQ.f_isize.sorted.byname.bam.bed
	TABIX_FILE=$REdir/${SAMPLE}_001.fastq.gz.bt2.concordant.f_MAPQ.f_isize.sorted.expanded.bam.bed.gz
	percentagesFile=$REdir/$SAMPLE.RE_percentages
	RE_log=$REdir/${SAMPLE}.RE_analysis.log

	echo >> $jobFile	
	echo "$BAM_TO_BEDPE $BAM $BED $_SYS_TYPE $BEDTOOLS && \\" >> $jobFile
	echo "$BEDPE_TO_TABIX $BED $TABIX_FILE $_SYS_TYPE $TABIX && \\" >> $jobFile
	echo "R -q -e \"source('$COVERAGE_R_SCRIPT'); bedpe2REcvg(file='${TABIX_FILE}', REfile='$_PIPELINE_DIR/resources/$reFile', percentagesFile='$percentagesFile', addOffset=$offset, testMode=F)\" | tee -a $RE_log" >> $jobFile

	chmod u+x $jobFile
done
