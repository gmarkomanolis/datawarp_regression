#!/bin/sh 

# Cray DataWarp Regression testing
# v0.3

# Users can edit the lines below.
# The script supports SLURM scheduler
# Change the declaration of sbatch_options according to your system
# Declare the root_path if it is different than the current path

# Command to submit job on your system
scheduler_options="sbatch"
# Customized SBATCH options for your system, 
# use multiple options with \n between them as below
sbatch_options="#SBATCH --partition=debug\n#SBATCH -A k01"

#The path that will ve used for all the experiments on your PFS
root_path=$PWD
results_folder="results"

if [ ! -d  $results_folder ];
then 
	mkdir $results_folder; 
fi

output_date=`date '+%d_%m_%Y_%H_%M_%S'`
output=$results_folder"/dw_regression_"$output_date".txt"

#Do you want to perform full DataWarp IOR? 0 for no, 1 for yes
#We use all DW space but with small number of compute nodes
run_big_ior=1

# Do not edit below if you are not familiar with the code

rm -r tmp
rm -r stageout

function wait_for_job {
job=`squeue -n $1 | wc -l`
while [ $job -gt 1 ]; 
do 
	sleep 5; 
	job=`squeue -n $1 |  wc -l`; 
	if [ $job -eq 2 ]; then
		handle_dw_error $1
	fi
done
}

function wait_for_file {
while [ ! -f stageout/$1 ]; 
do 
	sleep 5;  
done
}

function handle_dw_error {

jobidis=`squeue -n $1 | tail -n 1 | awk '{print $1}'`
job_error=`scontrol show job $jobidis | grep Reason=burst_buffer | wc -l`
if [ $job_error -eq 1 ]; then
	echo -e "\n!!! There is a problem with the DataWarp configuration, aborting regression !!!\n"
	scontrol show job $jobidis
	exit 1
fi
}

function prepare_test {
echo $1 > tmp/output$1.txt
}

function prepare_job_script {

head -n 1 $1 > $2
echo -e $sbatch_options >> $2
grep "#SBATCH" $1 >> $2
grep "dw" $1 >> $2
grep "#DW stage_in" $1 | sed "s|source=.* |source=$3/$4 |" >> $2
grep "#DW stage_out" $1 | sed "s|destination=.*|destination=$3/$5 |" >> $2

line=`grep -n \#DW $1 | tail -n 1 | awk -F ":" '{print $1}'`
let line=$line+1
tail -n+$line $1 >> $2

}

function prepare_job_script_pers {

head -n 1 $1 > $2
echo -e $sbatch_options >> $2
grep "#SBATCH" $1 >> $2
grep "BB" $1 >> $2

line=`grep -n \#BB $1 | tail -n 1 | awk -F ":" '{print $1}'`
let line=$line+1
tail -n+$line $1 >> $2

}

function save {
cat $1 >> $output
}

function prepare_file {
check=1
if [ -f bigfile/file.txt ];
then
        filesize_bb=`du -k bigfile/file.txt | awk '{print $1}'`;
#        f_pfs=`echo $filesize_bb | awk '{print $1}' | sed 's/G//'`;
        if [ "$filesize_bb" -eq 102400576 ];
        then
                echo -e "\nInput file is already created";
		check=0
        fi

fi
if [ $check -eq 1 ];
then
	echo -e "\nPreparing a file of 98 GiB, please wait";
	mkdir bigfile
	lfs setstripe -c -1 bigfile
	cd bigfile
	dd if=/dev/zero of=file.txt count=1024000 bs=102400
	cd ..
fi
}

function compare_file_size {
check=0
sleep 30
while [ $check -eq 0 ]; 
do
	file_size_stageout=`du -hs stageout/file.txt | awk '{print $1}' | sed 's/G//'`; 
	if [ $file_size_stageout -eq 98 ]; 
	then 
		check=1; 
	fi; 
	sleep 30; 
done
filesize_pfs=`du -hs bigfile/file.txt | awk '{print $1}' | sed 's/G//'`
filesize_stageout=`du -hs stageout/file.txt | awk '{print $1}' | sed 's/G//'`
if [ $filesize_pfs -eq $filesize_stageout ]
then
echo -e "Test13: Stage out folder of 98 GB " >> $output
echo "13" >> $output
fi
}

function compile_stage {
	module load datawarp
	cc -o stage_api stage_api.c 
}

module load dws

dwstat most | sed -n 2p > $output

nodes=`dwstat nodes | wc -l`
let nodes=$nodes-1
echo "Starting Cray DataWarp regression tests "
drain_nodes=`dwstat nodes | awk '{if($3!="online") print $0}' | wc -l`
let available_nodes=$nodes-$drain_nodes
echo -e "\nActive nodes: "$nodes" drain nodes: "$drain_nodes >> $output
echo -e "\nCurrent usage: \n" >> $output

scontrol show burst >> $output 

granularity=`cat $output | head -n 1 | awk '{print $5}' | sed 's/GiB//'`
let ior_bb_nodes=4*$granularity
let stage_folder=16*$granularity
let full_space=$available_nodes*$granularity
sed -i "s/capacity=.*GiB/capacity=${ior_bb_nodes}GiB/" run_ior_template.sh
sed -i "s/capacity=.*GiB/capacity=${full_space}GiB/" big_ior_template.sh
sed -i "s/capacity=.*GiB/capacity=${stage_folder}GiB/" stage_folder_big_template.sh
sed -i "s/capacity=.*GiB/capacity=${stage_folder}GiB/" stage_api_template.sh 

# Scratch mode
echo -e "\nUsing Burst Buffer"
prepare_job_script use_bb_template.sh use_bb.sh $root_path 
$scheduler_options use_bb.sh
wait_for_job bb_regression_use
save use_bb.out

mkdir tmp
mkdir stageout
lfs setstripe -c -1 stageout

prepare_test 2
echo -e "\nStage in/out folder"
prepare_job_script stage_folder_template.sh stage_folder.sh $root_path tmp stageout
$scheduler_options stage_folder.sh
wait_for_job bb_regression_stage_folder
wait_for_file output3.txt
save stagefolder_bb.out 

echo -e "Test3: Stage out folder BB" >> $output
cat stageout/output3.txt >> $output

prepare_test 4
echo -e "\nStage in/out file"
prepare_job_script stage_file_template.sh stage_file.sh $root_path "tmp/output4.txt" "stageout/output5.txt"
$scheduler_options stage_file.sh
wait_for_job bb_regression_stage_file
save stagefile_bb.out 
wait_for_file output5.txt
echo -e "Test5: Stage out file BB" >> $output
save stageout/output5.txt 

# Persistent mode
echo -e "\nCreate persistent allocation"
prepare_job_script_pers create_persistent_template.sh create_persistent.sh $root_path
$scheduler_options create_persistent.sh
wait_for_job create_persistent_space

persistent=`dwstat most | grep bb_regression | grep public | wc -l`

if [ $persistent -eq 1 ]
then 
	echo -e "Test6: Create Persistent Allocation\n6" >> $output
fi

prepare_test 7
echo -e "\nStage in/out folder in persistent allocation"
prepare_job_script stage_folder_persistent_template.sh stage_folder_persistent.sh $root_path tmp stageout
$scheduler_options stage_folder_persistent.sh 
wait_for_job bb_regression_stage_folder_persistent
save stagefolder_bb_persistent.out 
wait_for_file output8.txt
echo -e "Test8: Stage out folder BB Persistent" >> $output
save stageout/output8.txt 

prepare_test 9
echo -e "\nStage in/out file in persistent allocation"
prepare_job_script stage_file_persistent_template.sh stage_file_persistent.sh $root_path "tmp/output9.txt" "stageout/output10.txt"
$scheduler_options stage_file_persistent.sh
wait_for_job bb_regression_stage_file_persistent
save stagefile_bb_persistent.out 

wait_for_file output10.txt
echo -e "Test10: Stage out file BB Persistent" >> $output
save stageout/output10.txt 

echo -e "\nDelete persistent allocation"
prepare_job_script_pers delete_persistent_template.sh delete_persistent.sh $root_path
$scheduler_options delete_persistent.sh
wait_for_job delete_persistent_space

persistent=`dwstat most | grep bb_regression | grep public | wc -l`

if [ $persistent -eq 0 ]
then
        echo -e "Test11: Delete Persistent Allocation\n11" >> $output
fi

# Stage in 98GB of data

prepare_file
echo -e "\nStage in folder with large file"
prepare_job_script stage_folder_big_template.sh stage_folder_big.sh $root_path bigfile stageout
$scheduler_options stage_folder_big.sh
wait_for_job bb_regression_stage_folder_big
save stagefolder_bb_big.out

echo -e "\nWaiting for stage-out to finish"
compare_file_size

# Test DataWarp API

echo -e "\ntesting DataWarp API"
compile_stage
prepare_job_script stage_api_template.sh stage_api.sh $root_path
$scheduler_options stage_api.sh
wait_for_job bb_stage_api
bbnodes=`dwstat instances | tail -n 1 | awk '{print $5}'`
echo "BB nodes: "$bbnodes >> $output
save bb_stage_api.out

# IOR performance
echo -e "\nTest15: Execute IOR"
echo "Test15: IOR execution ">> $output
prepare_job_script run_ior_template.sh run_ior.sh $root_path
$scheduler_options run_ior.sh
wait_for_job bb_ior
cp bb_ior.out $results_folder/bb_ior_${output_date}.txt
ior_run=`cat bb_ior.out | grep "Max " | wc -l`
if [ $ior_run -eq 2 ];
then
        echo "15" >> $output
	grep "Max " bb_ior.out >> $output
	echo "IOR execution is successful"
else
        echo "There is a problem with at least one DataWarp node, contact your support"
fi

if [ $run_big_ior -eq 1 ]; then
	echo -e "\nTest16: Execute IOR with full DataWarp space allocation"
	echo -e "Test16: IOR execution with full DataWarp allocation">> $output
	prepare_job_script big_ior_template.sh big_ior.sh $root_path
	$scheduler_options big_ior.sh
	wait_for_job bb_big_ior
	cp bb_big_ior.out $results_folder/bb_big_ior_${output_date}.txt
	big_ior_run=`cat bb_big_ior.out | grep "Max " | wc -l`
	if [ $ior_run -eq 2 ];
	then
                echo "16" >> $output
	        echo "IOR execution with full DataWarp space is successful"
	        grep "Max " bb_big_ior.out >> $output
	else
		echo "There is a problem with at least one DataWarp node, contact your support"
	fi
fi
echo "Regression tests finished, the results are inside the file "$output

exit 0
