#!/bin/bash 

#SBATCH -t 2
#SBATCH --ntasks=1
#SBATCH   -J bb_regression_stage_file
#SBATCH -o stagefile_bb.out
#SBATCH -e stagefile_bb.err
#DW jobdw type=scratch access_mode=striped capacity=1GiB
#DW stage_in type=file source=/project/k01/markomg/development/bb_regression/tmp/output4.txt  destination=$DW_JOB_STRIPED/output4.txt
#DW stage_out type=file source=$DW_JOB_STRIPED/tmp/output5.txt  destination=/project/k01/markomg/development/bb_regression/stageout/output5.txt

cd $DW_JOB_STRIPED
echo -e "Test4: Stage in file BB"
cat output4.txt

mkdir tmp
echo "5" > tmp/output5.txt


exit 0
