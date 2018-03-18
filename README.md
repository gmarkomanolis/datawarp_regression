# Cray DataWarp regression suite
A suite of scripts that execute many regression tests on Cray DataWarp 

These script were developed to test Cray DataWarp, before we release the system to the users.

The main script is called [dw_regression.sh](dw_regression.sh)

## Script preparation

You can edit the following in the above script:

* If you use a command different than sbatch (the script is not ready to support other schedulers)

```
scheduler_options="sbatch"
```

* Define special queue/partition, separate commands by "\n" as in the example below 

```
sbatch_options="#SBATCH --partition=debug\n#SBATCH -A k01"
```

* The path that will be used for all the experiments on your PFS

```
root_path=$PWD
```

* Name of the folder with the results

```
results_folder="results"
```

* Output name and path of the result file

```
output_date=`date '+%d_%m_%Y_%H_%M_%S'`
output=$results_folder"/dw_regression_"$output_date".txt"
```

* As we want to find issues with any broken DW node, we execute also IOR by reserving one instance on each online node, select if you want to run such experiment ( 0 for no, 1 for yes)

```
run_big_ior=1
```

## Templates

Many templates script are used to create the main ones, you can edit the template scripts if required by your system

# Execute the regression suite

```
./dw_regression.sh
```

# Output

For example the output file will be in the results directory with the following format

```
dw_regression_01_03_2018_11_07_17.txt
```

With partial content:

```
wlm_pool bytes   1.5PiB 1.5PiB 368GiB 

Active nodes: 268 drain nodes: 1

Current usage: 

Name=cray DefaultPool=wlm_pool Granularity=368GiB TotalSpace=1541TiB FreeSpace=1572096GiB UsedSpace=368GiB
  Flags=EnablePersistent
  StageInTimeout=1800 StageOutTimeout=1800 ValidateTimeout=5 OtherTimeout=300
  AllowUsers=hadrib,markomg
  GetSysState=/opt/cray/dw_wlm/default/bin/dw_wlm_cli
  
Test1: Use BB
1
Test2: Stage in folder BB
2
Test3: Stage out folder BB
3
Test4: Stage in file BB
4
Test5: Stage out file BB
5
Test6: Create Persistent Allocation
6
Test7: Stage in folder BB Persistent
7
Test8: Stage out folder BB Persisten
8
Test9: Stage in file BB Persistent
9
Test10: Stage out file BB Persisten
10
Test11: Delete Persistent Allocation
11
Test12: Stage in folder of 98 GB 
12
Test13: Stage out folder of 98 GB 
13
Test14: Use DataWarp API 
Stage in API duration 30.047291 seconds
14
Test15: IOR execution
15
Test16:IOR execution with full DataWarp allocation 
16
```

For each TestX you should see the number X below, then the test is sucessfull. There will be one extra output file per IOR test.
For issues and additions, contact me at georgios.markomanolis@kaust.edu.sa
