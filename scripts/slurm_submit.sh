#!/bin/bash

# exit on first fail
set -exuo pipefail
# experiment variables 
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M_%SS)
EXPERIMENT_NAME="${DATE}_${TIME}"
HOME_DIR="/data/gpfs/projects/punim1355/dalmiapriyam"
PROJECT_DIR="$HOME_DIR/$(basename $PWD)"
JOB_DIR="$PROJECT_DIR/$EXPERIMENT_NAME"
JOB_BRANCH="dev"
JOB_SCRIPT="spartan_test.sh"
JOB_LOGS="submissions.log"
JOB_GIT_HASH=$(git log -1 --format="%H")
TEMP_JOB_SCRIPT=${EXPERIMENT_NAME}_${JOB_SCRIPT}
JOB_PATCH=${EXPERIMENT_NAME}.patch
SBATCH="/apps/slurm/latest/bin/sbatch"
SCONTROL="/apps/slurm/latest/bin/scontrol"

# TODO add check to see if we are on the same branch as job branch!  

# make a stash patch
git add --update 
git stash push -u -m "stash for experiment $EXPERIMENT_NAME"
git stash show -p > temp/${JOB_PATCH}
git stash pop 

# copy job scripts to SPARTAN
ssh spartan "mkdir -p $JOB_DIR"
scp scripts/$JOB_SCRIPT spartan:$PROJECT_DIR/$TEMP_JOB_SCRIPT
scp temp/$JOB_PATCH spartan:$PROJECT_DIR/

# submit jobs
commandstr="cd $PROJECT_DIR && echo \$PATH && JOB_STR=\$(sbatch $TEMP_JOB_SCRIPT $EXPERIMENT_NAME $JOB_BRANCH $JOB_GIT_HASH) && JOB_ID=\${JOB_STR//[!0-9]/} && scontrol update JobID=\$JOB_ID JobName=$EXPERIMENT_NAME && echo "$EXPERIMENT_NAME,\$JOB_ID" >> $JOB_LOGS" 
ssh spartan -t "bash -l -c '${commandstr}'"
# ssh spartan \
#     "source ~/.bashrc; \
#     cd ${PROJECT_DIR} && \
#     JOB_STR=\$($SBATCH $TEMP_JOB_SCRIPT $EXPERIMENT_NAME $JOB_BRANCH $JOB_GIT_HASH) && \\
#     JOB_ID=\${JOB_STR//[!0-9]/} && \\
#     $SCONTROL update JobID=\$JOB_ID JobName=$EXPERIMENT_NAME && \\
#     echo "$EXPERIMENT_NAME,\$JOB_ID" >> $JOB_LOGS"
    # echo \"\$(date +%Y/%m/%d) \$(date +%H:%M:%S),${EXPERIMENT_NAME},\${JOB_ID} >> $JOB_LOGS\""

# copy submission log over
scp spartan:$PROJECT_DIR/$JOB_LOGS ./logs/ 
cat ./logs/$JOB_LOGS