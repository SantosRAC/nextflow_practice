#!/bin/bash

#PBS -N nextflow
#PBS -q serial
#PBS -e nextflow.sh.e
#PBS -o nextflow.sh.o

source /home/lovelace/proj/proj832/fvperes/miniconda3/etc/profile.d/conda.sh
conda activate nextflow

nextflow run /home/lovelace/proj/proj832/fvperes/nextflow_practice/nextflow/nextflow_pratice.nf -c /home/lovelace/proj/proj832/fvperes/nextflow_practice/nextflow.config -profile pbs
