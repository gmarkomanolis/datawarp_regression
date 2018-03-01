#!/bin/bash 

#SBATCH -t 2
#SBATCH --ntasks=1
#SBATCH   -J bb_regression_use
#SBATCH -o use_bb.out
#SBATCH -e use_bb.err
#DW jobdw type=scratch access_mode=striped capacity=1GiB

cd $DW_JOB_STRIPED
echo "1" > output.txt
cd
echo -e "Test1: Use BB" 
cat $DW_JOB_STRIPED/output.txt

exit 0
