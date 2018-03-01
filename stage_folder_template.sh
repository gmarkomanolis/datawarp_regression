#!/bin/bash 

#SBATCH -t 2
#SBATCH --ntasks=1
#SBATCH   -J bb_regression_stage_folder
#SBATCH -o stagefolder_bb.out
#SBATCH -e stagefolder_bb.err
#DW jobdw type=scratch access_mode=striped capacity=1GiB
#DW stage_in type=directory source=/project/k01/markomg/development/bb_regression/tmp  destination=$DW_JOB_STRIPED
#DW stage_out type=directory source=$DW_JOB_STRIPED/tmp/  destination=/project/k01/markomg/development/bb_regression/stageout

cd $DW_JOB_STRIPED
echo -e "Test2: Stage in folder BB"
cat output2.txt

mkdir tmp
echo "3" > tmp/output3.txt


exit 0
