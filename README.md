# Cray DataWarp regression suite
A suite of scripts that execute many regression tests on Cray DataWarp 

These script were developed to test Cray DataWarp, before we release the system to the users.

The main script is called [dw_regression.sh](dw_regression.sh)

You can edit the following in the above script:

* If you use a command different than sbatch (the script is not ready to support other schedulers)

scheduler_options="sbatch"

* Define special queue/partition, separate commands by "\n" as in the example below 

sbatch_options="#SBATCH --partition=debug\n#SBATCH -A k01"

* The path that will be used for all the experiments on your PFS

root_path=$PWD

* Name of the folder with the results

results_folder="results"

* Output name and path of the result file

```
output_date=`date '+%d_%m_%Y_%H_%M_%S'`
output=$results_folder"/dw_regression_"$output_date".txt"
```

* As we want to find issues with any broken DW node, we execute also IOR by reserving one instance on each online node, select if you want to run such experiment ( 0 for no, 1 for yes)

run_big_ior=1

# Execute the regression suite

```
./dw_regression.sh
```
