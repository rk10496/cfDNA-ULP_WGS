#!/bin/bash
#
#SBATCH --job-name=ichorCNAsnakemake
#SBATCH -N 1
#SBATCH --cpus-per-task=8 # Request that ncpus be allocated per process.
#SBATCH -t 1-00:00 # Runtime in D-HH:MM
#SBATCH --output=/bgfs/soesterreich/pan_data/soesterreich/Tendo/InstalledTools/ichorCNA/scripts/snakemake/ichorCNAsnake.out



module purge
module load gcc/8.2.0 r/3.6.0
module load snakemake/5.4.0
cd /bgfs/soesterreich/pan_data/soesterreich/Tendo/InstalledTools/ichorCNA/scripts/snakemake
snakemake -s ichorCNA.noNormal.snakefile --cores 16
