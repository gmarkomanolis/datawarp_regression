#!/bin/bash 

#SBATCH -t 20
#SBATCH --ntasks=1
#SBATCH   -J bb_regression_stage_folder_big
#SBATCH -o stagefolder_bb_big.out
#SBATCH -e stagefolder_bb_big.err
#DW jobdw type=scratch access_mode=striped capacity=5888GiB
#DW stage_in type=directory source=/project/k01/markomg/development/bb_regression/bigfile  destination=$DW_JOB_STRIPED
#DW stage_out type=directory source=$DW_JOB_STRIPED/  destination=/project/k01/markomg/development/bb_regression/stageout

cd $DW_JOB_STRIPED
echo -e "Test12: Stage in folder of 98 GB "

filesize_pfs=`du -hs $SLURM_SUBMIT_DIR/bigfile/file.txt | awk '{print $1}' | sed 's/G//'`
filesize_bb=`du -hs file.txt | awk '{print $1}' | sed 's/G//'`
if [ $filesize_pfs -eq $filesize_bb ] 
then
 echo "12"
fi


exit 0
