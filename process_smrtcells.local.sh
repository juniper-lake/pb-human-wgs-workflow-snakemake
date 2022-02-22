#!/bin/bash

# set umask to avoid locking each other out of directories
umask 002

mkdir -p logs

# execute snakemake
snakemake --reason \
    --rerun-incomplete \
    --printshellcmds \
    --keep-going \
    --cores 78 \
    --use-conda --conda-frontend mamba \
    --latency-wait 120 \
    --snakefile workflow/process_smrtcells.smk 2>&1 | tee logs/process_smrtcells.$(date -d "today" +"%Y%m%d%H%M").log
