#!/bin/bash

#SBATCH --job-name=abm
#SBATCH --output=abm-%J.out
#SBATCH --error=abm-%J.err
#SBATCH --time=24:00:00
#SBATCH --ntasks=20
#SBATCH --mem-per-cpu=2G
#SBATCH --nodes=1-4
#SBATCH --partition=k2-medpri
#SBATCH --mail-type=ALL
#SBATCH --mail-user=j.vargas@qub.ac.uk

cd ~/julparagg
module load apps/julia/1.11.2

julia sheep-parasite-model/src/main.jl
