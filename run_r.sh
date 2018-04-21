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

bash module load rstudio/1.1.423 ; Rscript "nlexperiment OAT.R"
date
