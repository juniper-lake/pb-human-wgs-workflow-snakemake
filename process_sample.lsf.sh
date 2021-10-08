#!/bin/bash
#BSUB -A 100humans
#BSUB -cwd
#BSUB -L /bin/bash
#BSUB -q default
#BSUB -n 4
#BSUB -o ./cluster_logs/sge-$LSB_JOBNAME-$LSB_JOBID-$HOSTNAME.out
#BSUB -e ./cluster_logs/sge-$LSB_JOBNAME-$LSB_JOBID-$HOSTNAME.err

# set umask to avoid locking each other out of directories
umask 002

SAMPLE=$1
LOCKFILE=samples/${SAMPLE}/process_sample.lock

# add lockfile to directory to prevent multiple simultaneous jobs
lockfile -r 0 ${LOCKFILE} || exit 1
trap "rm -f ${LOCKFILE}; exit" SIGINT SIGTERM ERR EXIT

# execute snakemake
snakemake --reason \
    --rerun-incomplete \
    --keep-going \
    --printshellcmds \
    --config sample=${SAMPLE} \
    --nolock \
    --local-cores 4 \
    --jobs 500 \
    --max-jobs-per-second 1 \
    --use-conda --conda-frontend conda \
    --use-singularity \
    --latency-wait 120 \
    --cluster-config workflow/process_sample.cluster.lsf.yaml \
    --cluster "bsub -cwd \
                    -q {cluster.partition} \
                    -n {cluster.cpus} \
                    -o {cluster.out} \
                    -e {cluster.err} \
                    {cluster.extra} " \
    --snakefile workflow/process_sample.smk
