#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
input=$DIR/MREseq_sample
output=/EPIGENETICS/SCRATCH/$USER/MREseq_test_output
mkdir $output


cd $DIR/../
./run -i $input -o $output
