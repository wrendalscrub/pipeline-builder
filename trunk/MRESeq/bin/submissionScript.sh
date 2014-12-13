#!/bin/bash -l

# Written by Ulises Schmill
# Updated by Daniel Groot on 27 May 2014 to add functionality for post-alignment RE coverage calculation

#this script will qsub many things with many dependencies. 

# The order in which is as follows:
	# 1. write scripts for each file a each step (eg. qsub fastq_trim_multiJob.sh)
	# 2. qsub each file written for that step with the dependency that that script has been made
	# 3. qsub bt2_aligner_multiJob.sh depends on 2 having been completed
	# 4. qsub each file written for alignment depends on #3 writing all scripts
	# etc for BAM 


PIPELINE_START=$_PIPELINE_DIR/resources/pipelineStart.sh

# Dummy job that kickstarts all other jobs
cd $_OUT_DIR
JOBID3=$(qsub $PIPELINE_START)


QCdir=JOBS_FASTQC
for s in $_OUT_DIR/${QCdir}/*.sh; do
	# Waits for dummy to start before running each fastqc job in parallel
	qsub -W depend=afterok:$JOBID3 $s
done
echo "FastQC jobs have been submitted"

jobdir=JOBS_fastqtrim
for f in $_OUT_DIR/${jobdir}/*.sh; do
	cd $_OUT_DIR/${jobdir}
	basef=$(basename $f _R1_001.trim.sh)
	echo $basef
	# Names of the subsequent step files ($f is the trimming file)
	alignName=${basef}_001.fastq.gz.align.sh;
	BAMName=${basef}_001.fastq.gz.bt2.concordant.bam_process.sh;
	REanalysisName=${basef}.RE_analysis.sh;

	# Submits the Trimming job to start only once the dummy job has completed
	STEP1ID=$(qsub -W depend=afterok:$JOBID3 $f)
	
	# Submit the Alignment job to start only after the trimming job has completed successfully. (afterok)
	cd $_OUT_DIR/JOBS_align
	STEP2ID=$(qsub -W depend=afterok:$STEP1ID $alignName)
	
	#Submit the BAM processing job to start only after the alignment job has completed successfully
	cd $_OUT_DIR/JOBS_bamprocess
	STEP3ID=$(qsub -W depend=afterok:$STEP2ID $BAMName)

	# Submit the RE score/coverage jobs to start only after the BAM processing jobs have finished
	cd $_OUT_DIR/JOBS_RE_analysis
	qsub -W depend=afterok:$STEP3ID $REanalysisName
done
echo "Trimming, alignment, BAM_Processing and RE analysis jobs have been submitted"


