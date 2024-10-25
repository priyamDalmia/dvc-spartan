#!/bin/bash

# environment variables
# SBATCH --export=EXPERIMENT_NAME,GIT_HASH

# logs and settings 
# SBATCH --job-name=${EXPERIMENT_NAME}
# SBATCH --output="slurmoutput/%j.out"
# SBATCH --mail-type=END,FAIL
# SBATCH --mail-user=p.dalmia@unimelb.edu.au

# resources 
# SBATCH --nodes=1
# SBTACH --ntasks=1
# SBATCH --ntasks-per-node=1
# SBATCH --cpus-per-task=1
# SBATCH --mem-per-cpu=4G
# SBATCH --partition=cascade
# SBATCH --time=03-00:00:00


# SBATCH --gres=gpu:1
# SBATCH --qos=gpgpudeeplearn
# SBATCH --partition=deeplearn

# set -eu
IFS=$'\n\t'

# TODO if experiment name not in env vars; error here
export EXPERIMENT_NAME=$1
# TODO if git hash not in env vars; error here
export GIT_HASH=$2

export JOB_REPO_NAME="dvc-spartan"
export JOB_REPO_URL="git@github.com:priyamDalmia/dvc-spartan.git"
export JOB_REPO_BRANCH="jobs-spartan"
export JOB_REPO_REV=${GIT_HASH}

touch logs.txt
echo "Running script for experiment: ${EXPERIMENT_NAME}" >> logs.txt
echo "Git hash for submission: ${GIT_HASH}"
echo "Submission directory: $SLURM_SUBMIT_DIR"

#   echo "Cleaning up the job directory."
# export WORK_DIR="${RDVC_DIR:-${HOME}/.rdvc}"
# Prepare a directory for the current job
# export JOB_WORKSPACE_DIR="${SLURM_JOB_ID}"
# mkdir -p "${JOB_WORKSPACE_DIR}"

# # Ensure cleanup after job finishes, regardless of exit status
# function cleanup_job_dir(){
#   rm -rf "${JOB_WORKSPACE_DIR}"
# }

# trap cleanup_job_dir EXIT
