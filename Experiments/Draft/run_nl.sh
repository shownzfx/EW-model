#!/bin/bash
 
##SBATCH --nodes=1                  # set number of processes x per node
#SBATCH --ntasks-per-node=28       # set cores per node
#SBATCH -n 28                       # number of cores
#SBATCH -t 0-02:30                  # wall time (D-HH:MM)
##SBATCH -A fzhang59                 # Account hours will be pulled from (commented out with double # in front)
#SBATCH -o slurm.%j.out             # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err             # STDERR (%j = JobId)
#SBATCH --mail-type=ALL             # Send a notification when the job starts, stops, or fails
#SBATCH --mail-user=fzhang59@asu.edu # send-to address

bash  /home/fzhang59/netlogo-headless.sh \
--model /home/fzhang59/dev/EW-model/EW\ model\ using\ numeric\ chooser.nlogo \
--experiment experiment_2 \
--table /home/fzhang59/TEST_1_8-$SLURM_ARRAYID.csv \
--threads 28

date
