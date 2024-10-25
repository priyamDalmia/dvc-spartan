#!/bin/bash
#SBATCH --output="slurmoutput/%j.out"
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=p.dalmia@unimelb.edu.au

# resources
#SBATCH --nodes=1
#SBTACH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --partition=cascade
#SBATCH --time=01:00:00

EXPERIMENT_NAME=$1
JOB_BRANCH=$2
GIT_HASH=$3

echo "$(date +%Y/%m/%d) $(date +%H:%M:%S)"
echo "Running Experiment $EXPERIMENT_NAME on branch $JOB_BRANCH and revision $GIT_HASH at $PWD"

source "${HOME}/.bashrc"
set -euxo pipefail

export JOB_REPO_NAME="dvc-spartan"
export JOB_REPO_URL="git@github.com:priyamDalmia/dvc-spartan.git"
export JOB_REPO_BRANCH=${JOB_BRANCH}
export JOB_REPO_REV=${GIT_HASH}

# Ensure cleanup after job finishes, regardless of exit status
function cleanup_job_dir(){
    echo "Cleaning up the job directory."
    # make a submission log
    # rm "${EXPERIMENT_NAME}".patch ${EXPERIMENT_NAME}_*
    # rm -rf ${EXPERIMENT_NAME}
}

trap cleanup_job_dir EXIT

# Create an insulated Git workspace for the current job
echo "Cloning git repo to $EXPERIMENT_NAME"
git clone --branch "${JOB_REPO_BRANCH}" "${JOB_REPO_URL}" "${EXPERIMENT_NAME}"
cp ${EXPERIMENT_NAME}.patch $EXPERIMENT_NAME
cd "${EXPERIMENT_NAME}"
git apply ${EXPERIMENT_NAME}.patch

echo "Cloned Project! Inside experiment working directory:$PWD"
git checkout "${GIT_HASH}"
git apply ${EXPERIMENT_NAME}.patch

# echo "Will try to checkout hash: $GIT_HASH"
# # Ensure the job runs on the same revision as was submitted (even if the branch has moved on in the meantime)