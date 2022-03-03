#!/bin/bash

# set umask to avoid locking each other out of directories
umask 002

COHORT=$1
mkdir -p cohorts/${COHORT}/
# LOCKFILE=cohorts/${COHORT}/process_cohort.lock

# add lockfile to directory to prevent multiple simultaneous jobs
# lockfile -r 0 ${LOCKFILE} || exit 1
# trap "rm -f ${LOCKFILE}; exit" SIGINT SIGTERM ERR EXIT

mkdir -p logs

source workflow/variables.env
export SINGULARITY_TMPDIR="$TEMP"
export SINGULARITY_BIND="$TEMP"

# execute snakemake
snakemake --reason \
    --keep-going \
    --printshellcmds \
    --config cohort=${COHORT} \
    --nolock \
    --cores 78 \
    --use-conda --conda-frontend mamba \
    --use-singularity \
    --default-resources "tmpdir='${TEMP}'" \
    --snakefile workflow/process_cohort.smk \
    2>&1 | tee "logs/process_cohort.${COHORT}.$(date -d 'today' +'%Y%m%d%H%M').log"
