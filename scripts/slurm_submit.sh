#!/bin/bash

# exit on first fail
set -exuo pipefail
# build experiment level variables 
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M_%SS)
EXPERIMENT_NAME="${DATE}_${TIME}"
# job directory = spartan/../project/dalmiapriyam + project name 
# get the current directory where script is called, ie project name
JOB_HOME_DIR="/data/gpfs/projects/punim1355/dalmiapriyam/"
JOB_BASE_DIR="$JOB_HOME_DIR/$(basename $PWD)"
JOB_WORKING_DIR="$JOB_BASE_DIR/$EXPERIMENT_NAME"
# job runs on working branch; which is copied from submission branch 
JOB_SUBMISSION_BRANCH="dev"
# slurm job script submitted to HPC 
# TODO add conditions and select script by names
# TODO; ensure that job scripts exists
JOB_SCRIPT="spartan_cascade.sh"
# job logs 
JOB_LOGS="logs/submissions.log"
GIT_HASH==$(git log -1 --format="%H")

# make a stash patch
git add --update 
git stash push -u -m "stash for experiment $EXPERIMENT_NAME"
git stash show -p > temp/${EXPERIMENT_NAME}.patch
git stash pop 

# copy job scripts to SPARTAN
ssh spartan "mkdir -p $JOB_WORKING_DIR"
scp scripts/$JOB_SCRIPT spartan:$JOB_BASE_DIR/$JOB_SCRIPT
scp temp/${EXPERIMENT_NAME}.patch spartan:$JOB_BASE_DIR/

# submit jobs 
ssh spartan \
    "source ~/.bashrc; \
    cd ${JOB_BASE_DIR} && \
    touch ${EXPERIMENT_NAME}.log && \
    echo \"new experiment \${EXPERIMENT_NAME}\" >> ${EXPERIMENT_NAME}.log"

# make a submission log
JOB_ID=$RANDOM
echo "$(date +%Y/%m/%d) $(date +%H:%M:%S),${EXPERIMENT_NAME},${JOB_ID}" >> $JOB_LOGS
echo "Job completed!"