#!/bin/bash 

#SBATCH -t 2
#SBATCH --ntasks=1
#SBATCH   -J bb_regression_stage_file_persistent
#SBATCH -o stagefile_bb_persistent.out
#SBATCH -e stagefile_bb_persistent.err
#DW persistentdw name=bb_regression
#DW stage_in type=file source=/project/k01/markomg/development/bb_regression/tmp/output9.txt  destination=$DW_PERSISTENT_STRIPED_bb_regression/output9.txt
#DW stage_out type=file source=$DW_PERSISTENT_STRIPED_bb_regression/tmp/output10.txt  destination=/project/k01/markomg/development/bb_regression/stageout/output10.txt

cd $DW_PERSISTENT_STRIPED_bb_regression
echo -e "Test9: Stage in file BB Persistent"
cat output9.txt

echo "10" > tmp/output10.txt

exit 0
