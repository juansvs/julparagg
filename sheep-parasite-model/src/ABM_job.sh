#!/bin/bash

#SBATCH --job-name=abm
#SBATCH --output=abm-%J.out
#SBATCH --error=abm-%J.err
#SBATCH --time=24:00:00
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=2G
#SBATCH --nodes=1-4
#SBATCH --partition=k2-medpri
#SBATCH --mail-type=ALL

module load apps/julia/1.11.2

julia --machinefile=$SLURM_NODEFILE ~/julparagg/sheep-aggregation/src/main.jl
