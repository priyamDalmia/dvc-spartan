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
JOB_BASE_DIR="$SPARTAN_JOB_HOME_DIR/$(basename $PWD)"
JOB_WORKING_DIR="$JOB_BASE_DIR/$EXPERIMENT_NAME"
# job runs on working branch; which is copied from submission branch 
JOB_SUBMISSION_BRANCH="jobs-spartan"
JOB_WORKING_BRANCH="dev"
# slurm job script submitted to HPC 
# TODO add conditions and select script by names
# TODO; ensure that job scripts exists
JOB_SCRIPT="cascade_spartan.sh"
# job logs 
JOB_LOGS="logs/submissions.log"

# checks if jobs branch exists locally
if ! git rev-parse --verify "$JOB_SUBMISSION_BRANCH" >/dev/null 2>&1; then 
    echo "Jobs branch $JOB_SUBMISSION_BRANCH does not exist"
    exit 1 
fi 

# TODO; check if both branchs have remotes setup
# working branch must have remote!
REMOTE_SUBMISSION=$(git ls-remote --heads origin "$JOB_SUBMISSION_BRANCH")
REMOTE_WORKING=$(git ls-remote --heads origin "$JOB_WORKING_BRANCH")
if [ -z "$REMOTE_SUBMISSION" ]; then 
    echo "Error: remote for branch \'${JOB_SUBMISSION_BRANCH} \' not found"
    exit 1
fi 

# start sync and merge 
# stash any local changes 
git add --update 
git stash push -u -m "stashing local changes before merging"

# checkout remote branch 
git checkout $JOB_SUBMISSION_BRANCH

# merge with latest commit form submission branch 
git merge --no-ff $JOB_WORKING_BRANCH --strategy-option theirs -m "prepare for submission"
git stash apply

# stage, commit and push to origin  
git add --update  
git commit -m "job: ${EXPERIMENT_NAME}"
git push origin $REMOTE_SUBMISSION --force

GIT_HASH==$(git log -1 --format="%H")
# Create a temporary file
TEMP_JOB_SCRIPT="${EXPERIMENT_NAME}_${JOB_SCRIPT}.sh"

# copy job scripts to SPARTAN
scp scripts/$JOB_SCRIPT spartan:$JOB_BASE_DIR/$TEMP_JOB_SCRIPT
# submit jobs 
ssh spartan \
    "source ~/.bashrc; \
    cd ${JOB_BASE_DIR} && \
    mkdir -p ${JOB_WORKING_DIR} && \
    cd ${JOB_WORKING_DIR} && \
    touch ${EXPERIMENT_NAME}.log"

# make a submission log
JOB_ID=$(tr -dc '0-9' < /dev/urandom | head -c 5)
echo "$(date %Y/%m/%d %H:%M:%SS),${EXPERIMENT_NAME},${JOB_ID}" >> $JOB_LOGS
echo "Job completed!"

    # && \
    # /apps/slurm/latest/bin/sbatch \
    # --export=EXPERIMENT_NAME=${EXPERIMENT_NAME},GIT_HASH=${GIT_HASH} \
    # ${TEMP_JOB_SCRIPT}"


# EXPERIMENT_NAME="test_experiment"
# GIT_HASH="abc"
# ssh spartan "source ~/.bashrc; cd ${SPARTAN_JOB_DIR} && /apps/slurm/latest/bin/sbatch --help >> logs.txt"
# # ssh spartan "cd ${SPARTAN_JOB_DIR} && ./spartan_cascade.sh $EXPERIMENT_NAME $GIT_HASH"