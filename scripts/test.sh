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
git stash push -u -m "stashing local changes for experiment $EXPERIMENT_NAME"

# trap return to working branch if anything fails 
# Ensure cleanup after job finishes, regardless of exit status
function cleanup_job_dir(){
    echo "Returning to working directory."
    # checkout working dir 
    git checkout ${JOB_WORKING_BRANCH}
    echo "Reapplying changes to working branch"
    git stash pop

    # make a submission log
    JOB_ID=$(tr -dc '0-9' < /dev/urandom | head -c 5)
    echo "$(date %Y/%m/%d %H:%M:%SS),${EXPERIMENT_NAME},${JOB_ID}" >> $JOB_LOGS
    echo "Job submitted!"
}

trap cleanup_job_dir EXIT

# checkout remote branch 
git checkout $JOB_SUBMISSION_BRANCH

# merge with latest commit form submission branch 
git merge --no-ff $JOB_WORKING_BRANCH -X theirs -m "prepare for submission"
git stash apply

# stage, commit and push to origin  
git add -A 
git commit -m "job: ${EXPERIMENT_NAME}"
git push origin $JOB_SUBMISSION_BRANCH --force

GIT_HASH==$(git log -1 --format="%H")
# Create a temporary file
TEMP_JOB_SCRIPT="${EXPERIMENT_NAME}_${JOB_SCRIPT}.sh"
echo "Making submission to cluster"

