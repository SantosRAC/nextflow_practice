#!/bin/bash

#$ -q all.q
#$ -cwd
#$ -V
#$ -pe smp 1

module load miniconda3
conda activate nextflow

nextflow run nextflow/nextflow_pratice.nf -c nextflow.config -profile sge
