#!/bin/bash 

#SBATCH -t 20
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=8
#SBATCH   -J bb_ior
#SBATCH -o bb_ior.out
#SBATCH -e bb_ior.err
#DW jobdw type=scratch access_mode=striped capacity=1472GiB

srun -n 32 --hint=nomultithread ./ior_bin -t 2m -b 19262m -F -o ${DW_JOB_STRIPED}/IOR_file -g -vv -C

exit 0
