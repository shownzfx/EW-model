#!/bin/bash
 
##SBATCH --nodes=1                  # set number of processes x per node
##SBATCH --ntasks-per-node=28 # set cores per node
#SBATCH -n 28                     # number of cores
#SBATCH -t 0-02:30                  # wall time (D-HH:MM)
##SBATCH -A jswatts             # Account hours will be pulled from (commented out with double # in front)
#SBATCH -o slurm.%j.out             # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err             # STDERR (%j = JobId)
#SBATCH --mail-type=ALL             # Send a notification when the job starts, stops, or fails
#SBATCH --mail-user=jswatts@asu.edu # send-to address

bash  /home/jswatts/netlogo-headless.sh \
--model /home/jswatts/queue_project/20171114_Discrete_Event_Simulation-Queues_and_Servers.nlogo \
--experiment experiment_2 \
--table /home/jswatts/queue_project/TEST_1_8-$SLURM_ARRAYID.csv \
--threads 28

date