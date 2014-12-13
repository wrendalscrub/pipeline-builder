#!/bin/bash

echo "This is step 2 of a generic pipeline."
echo "To execute correctly it depends on an externally defined variable path"
echo "The following should be the path of fastq on SCC:"
echo $FASTQ_SCC
echo "This step also creates testarg.out in the output directory"
echo "this is a test argument created by step 2 to be used by step 3" > $PIPELINE_DIR/output/testarg.out
