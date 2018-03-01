#!/bin/bash

#SBATCH -t 20
#SBATCH --ntasks=1
#SBATCH   -J bb_stage_api
#SBATCH -o bb_stage_api.out
#SBATCH -e bb_stage_api.err
#DW jobdw type=scratch access_mode=striped capacity=5888GiB

echo -e "Test13: Use DataWarp API "

srun -n 1 stage_api $SLURM_SUBMIT_DIR/bigfile/file.txt ${DW_JOB_STRIPED}/file.txt

filesize_pfs=`du -hs bigfile/file.txt | awk '{print $1}' | sed 's/G//'`
cd $DW_JOB_STRIPED
filesize_bb=`du -hs file.txt | awk '{print $1}' | sed 's/G//'`
if [ $filesize_pfs -eq $filesize_bb ] 
then
 echo "13"
fi

exit 0
