#!/bin/bash 

#SBATCH -t 2
#SBATCH --ntasks=1
#SBATCH   -J bb_regression_stage_folder_persistent
#SBATCH -o stagefolder_bb_persistent.out
#SBATCH -e stagefolder_bb_persistent.err
#DW persistentdw name=bb_regression
#DW stage_in type=directory source=/project/k01/markomg/development/bb_regression/tmp  destination=$DW_PERSISTENT_STRIPED_bb_regression
#DW stage_out type=directory source=$DW_PERSISTENT_STRIPED_bb_regression/tmp/  destination=/project/k01/markomg/development/bb_regression/stageout

cd $DW_PERSISTENT_STRIPED_bb_regression
echo -e "Test7: Stage in folder BB Persistent"
cat output7.txt

mkdir tmp
echo "8" > tmp/output8.txt


exit 0
